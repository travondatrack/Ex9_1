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

# Copy the WAR file from the build stage with specific name
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

# Create directory structure for webapp
RUN mkdir -p /usr/local/tomcat/webapps/ROOT && \
    mkdir -p /usr/local/tomcat/temp

# Extract WAR file directly (don't rely on Tomcat auto-deployment)
RUN cd /usr/local/tomcat/webapps/ROOT && \
    unzip -q /usr/local/tomcat/webapps/ROOT.war && \
    rm -f /usr/local/tomcat/webapps/ROOT.war && \
    echo "WAR file extracted manually"

# Ensure mp3 directory exists and copy the mp3 files
RUN mkdir -p /usr/local/tomcat/webapps/ROOT/mp3
COPY --from=build /app/src/main/webapp/mp3/ /usr/local/tomcat/webapps/ROOT/mp3/

# Create a simple test HTML file to verify Tomcat is working
RUN echo '<html><body><h1>Tomcat is running!</h1><p><a href="index.jsp">Go to application</a></p></body></html>' > /usr/local/tomcat/webapps/ROOT/test.html

# Set environment variables for Render
ENV CATALINA_OPTS="-Xmx300m -Xms128m -server"
ENV JAVA_OPTS="-Djava.security.egd=file:/dev/./urandom -Djava.awt.headless=true"

# Ensure proper permissions for Tomcat files
RUN chmod -R 755 /usr/local/tomcat/webapps

# Render uses dynamic PORT environment variable
ENV PORT=8080
EXPOSE $PORT

# Create startup script
RUN echo '#!/bin/bash' > /start.sh && \
    echo 'export PORT=${PORT:-8080}' >> /start.sh && \
    echo 'sed -i "s/port=\"8080\"/port=\"${PORT}\"/g" /usr/local/tomcat/conf/server.xml' >> /start.sh && \
    echo 'echo "Disabling shutdown port to prevent invalid shutdown commands..."' >> /start.sh && \
    echo 'sed -i "s/port=\"8005\"/port=\"-1\"/g" /usr/local/tomcat/conf/server.xml' >> /start.sh && \
    echo 'echo "Listing webapp directory contents:"' >> /start.sh && \
    echo 'ls -la /usr/local/tomcat/webapps/' >> /start.sh && \
    echo 'ls -la /usr/local/tomcat/webapps/ROOT/' >> /start.sh && \
    echo 'echo "Checking configuration file:"' >> /start.sh && \
    echo 'cat /usr/local/tomcat/conf/server.xml' >> /start.sh && \
    echo 'echo "Starting Tomcat..."' >> /start.sh && \
    echo 'exec catalina.sh run' >> /start.sh && \
    chmod +x /start.sh

# Health check using process check instead of HTTP requests
HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=3 \
  CMD ps -ef | grep -v grep | grep catalina.startup.Bootstrap || exit 1

# Start Tomcat using our script
CMD ["/start.sh"]
