# Build stage
FROM maven:3.8-openjdk-8 AS build

# Set the working directory
WORKDIR /app

# Copy the POM file and source code
COPY pom.xml .
COPY src ./src

# Build the application
RUN mvn clean package -DskipTests

# Runtime stage - using the official Tomcat image
FROM tomcat:9.0-jdk8-openjdk

# Remove default Tomcat applications
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the WAR file from the build stage 
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

# Create mp3 directory in Tomcat
RUN mkdir -p /usr/local/tomcat/mp3

# Copy the mp3 files from the build stage
COPY --from=build /app/src/main/webapp/mp3/86_band /usr/local/tomcat/mp3/86_band
COPY --from=build /app/src/main/webapp/mp3/joe_rut /usr/local/tomcat/mp3/joe_rut
COPY --from=build /app/src/main/webapp/mp3/paddlefoot_cd1 /usr/local/tomcat/mp3/paddlefoot_cd1
COPY --from=build /app/src/main/webapp/mp3/paddlefoot_cd2 /usr/local/tomcat/mp3/paddlefoot_cd2

# Create ROOT.xml to handle context configuration
RUN mkdir -p /usr/local/tomcat/conf/Catalina/localhost/

# Create the ROOT.xml file for context configuration
RUN echo '<?xml version="1.0" encoding="UTF-8"?>' > /usr/local/tomcat/conf/Catalina/localhost/ROOT.xml && \
    echo '<Context>' >> /usr/local/tomcat/conf/Catalina/localhost/ROOT.xml && \
    echo '  <Resources>' >> /usr/local/tomcat/conf/Catalina/localhost/ROOT.xml && \
    echo '    <PreResources className="org.apache.catalina.webresources.DirResourceSet"' >> /usr/local/tomcat/conf/Catalina/localhost/ROOT.xml && \
    echo '                 base="/usr/local/tomcat/mp3"' >> /usr/local/tomcat/conf/Catalina/localhost/ROOT.xml && \
    echo '                 webAppMount="/mp3"/>' >> /usr/local/tomcat/conf/Catalina/localhost/ROOT.xml && \
    echo '  </Resources>' >> /usr/local/tomcat/conf/Catalina/localhost/ROOT.xml && \
    echo '</Context>' >> /usr/local/tomcat/conf/Catalina/localhost/ROOT.xml

# Environment variables
ENV CATALINA_OPTS="-Xmx300m -Xms128m"
ENV JAVA_OPTS="-Djava.security.egd=file:/dev/./urandom"
ENV PORT=8080

# Expose the port
EXPOSE $PORT

# Create startup script
RUN echo '#!/bin/bash' > /start.sh && \
    echo 'export PORT=${PORT:-8080}' >> /start.sh && \
    echo 'sed -i "s/port=\"8080\"/port=\"${PORT}\"/g" /usr/local/tomcat/conf/server.xml' >> /start.sh && \
    echo 'sed -i "s/port=\"8005\"/port=\"-1\"/g" /usr/local/tomcat/conf/server.xml' >> /start.sh && \
    echo 'exec catalina.sh run' >> /start.sh && \
    chmod +x /start.sh

# Simple health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD pidof java || exit 1

# Start Tomcat
CMD ["/start.sh"]
