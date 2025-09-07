# Build stage
FROM maven:3.8-openjdk-8 AS build

# Set the working directory
WORKDIR /app

# Copy the POM file and source code
COPY pom.xml .
COPY src ./src

# Build the application - explicitly telling Maven not to use module flags
RUN mvn clean package -DskipTests -Dmaven.compiler.source=1.8 -Dmaven.compiler.target=1.8

# Runtime stage
FROM tomcat:9.0-jdk8-openjdk

# Remove default Tomcat applications
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the WAR file from the build stage
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

# Copy the mp3 files directory from the build stage
COPY --from=build /app/src/main/webapp/mp3 /usr/local/tomcat/webapps/ROOT/mp3/

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
    echo 'exec catalina.sh run' >> /start.sh && \
    chmod +x /start.sh

# Health check (with increased start period)
HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=3 \
  CMD curl -f http://localhost:${PORT}/index.jsp || exit 1

# Start Tomcat using our script
CMD ["/start.sh"]
