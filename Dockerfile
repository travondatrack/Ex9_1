# Build stage
FROM maven:3.8-openjdk-8 AS build

# Set the working directory
WORKDIR /app

# Copy the POM file and source code
COPY pom.xml .
COPY src ./src

# Build the application - explicitly telling Maven not to use module flags
RUN mvn clean package -DskipTests -Dmaven.compiler.source=1.8 -Dmaven.compiler.target=1.8

# Verify the build was successful and WAR file exists
RUN ls -la /app/target/ && \
    echo "WAR file built successfully!"

# Runtime stage
FROM tomcat:9.0-jdk8-openjdk

# Install necessary tools
RUN apt-get update && apt-get install -y unzip curl && rm -rf /var/lib/apt/lists/*

# Remove default Tomcat applications
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the WAR file from the build stage
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

# Create mp3 directory in the webapps/ROOT folder
RUN mkdir -p /usr/local/tomcat/webapps/ROOT/mp3

# Wait for Tomcat to extract WAR file
RUN echo "Waiting for Tomcat to extract WAR file..." && \
    sleep 5

# Copy the mp3 files directory from the build stage
COPY --from=build /app/src/main/webapp/mp3 /usr/local/tomcat/webapps/ROOT/mp3/

# Create a simple test HTML file to verify Tomcat is working
RUN echo '<html><body><h1>Tomcat is running!</h1><p><a href="index.jsp">Go to application</a></p></body></html>' > /usr/local/tomcat/webapps/ROOT/test.html

# Set environment variables for Render
ENV CATALINA_OPTS="-Xmx300m -Xms128m -server"
ENV JAVA_OPTS="-Djava.security.egd=file:/dev/./urandom"

# Render uses dynamic PORT environment variable
ENV PORT=8080
EXPOSE $PORT

# Create startup script
RUN echo '#!/bin/bash' > /start.sh && \
    echo 'export PORT=${PORT:-8080}' >> /start.sh && \
    echo 'sed -i "s/port=\"8080\"/port=\"${PORT}\"/g" /usr/local/tomcat/conf/server.xml' >> /start.sh && \
    echo 'echo "Checking for WAR file..."' >> /start.sh && \
    echo 'ls -la /usr/local/tomcat/webapps/' >> /start.sh && \
    echo 'if [ -f /usr/local/tomcat/webapps/ROOT.war ]; then' >> /start.sh && \
    echo '  echo "Extracting WAR file manually..."' >> /start.sh && \
    echo '  mkdir -p /usr/local/tomcat/webapps/ROOT' >> /start.sh && \
    echo '  unzip -o /usr/local/tomcat/webapps/ROOT.war -d /usr/local/tomcat/webapps/ROOT/' >> /start.sh && \
    echo '  echo "WAR file extracted. Contents of webapps/ROOT:"' >> /start.sh && \
    echo '  ls -la /usr/local/tomcat/webapps/ROOT/' >> /start.sh && \
    echo 'else' >> /start.sh && \
    echo '  echo "WARNING: ROOT.war not found!"' >> /start.sh && \
    echo 'fi' >> /start.sh && \
    echo 'echo "Starting Tomcat..."' >> /start.sh && \
    echo 'exec catalina.sh run' >> /start.sh && \
    chmod +x /start.sh

# Health check (with increased start period)
HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=3 \
  CMD curl -f http://localhost:${PORT}/ || curl -f http://localhost:${PORT}/index.jsp || exit 1

# Start Tomcat using our script
CMD ["/start.sh"]
