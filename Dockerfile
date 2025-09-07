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

# Copy the mp3 files directory
COPY src/main/webapp/mp3 /usr/local/tomcat/webapps/ROOT/mp3/

# Set environment variables for Render
ENV CATALINA_OPTS="-Xmx300m -Xms128m -server"
ENV JAVA_OPTS="-Djava.security.egd=file:/dev/./urandom"

# Render uses dynamic PORT environment variable
ENV PORT=8080
EXPOSE $PORT

# Copy startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:${PORT}/ || exit 1

# Start Tomcat using our script
CMD ["/start.sh"]
