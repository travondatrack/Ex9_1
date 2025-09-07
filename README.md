# JSTL Download Application

This is a Jakarta EE 8 web application that demonstrates the use of JSTL for displaying album information and downloading music files.

## Local Development

### Prerequisites

- Java 8 or higher
- Maven 3.6 or higher
- Docker and Docker Compose (optional, for containerized development)

### Building the Application

```bash
mvn clean package
```

### Running with Docker

```bash
docker-compose up --build
```

The application will be available at http://localhost:8080

## Deploying to Render

### Option 1: Using render.yaml (Blueprint)

1. Fork this repository to your GitHub account
2. Log in to Render (https://render.com)
3. Click "New" > "Blueprint"
4. Connect your GitHub repository
5. Render will automatically deploy the application based on render.yaml configuration

### Option 2: Manual Deployment

1. Log in to Render (https://render.com)
2. Click "New" > "Web Service"
3. Connect your GitHub repository
4. Choose "Docker" as the runtime
5. Set the name as "jstl-download-app"
6. Keep the default settings (they should detect the Dockerfile)
7. Click "Create Web Service"

## Environment Variables

- `PORT`: The port number for the application (default: 8080)

## Notes

- The application uses Java 8 and Tomcat 9
- MP3 files are included as placeholders, replace with actual music files if needed
- This configuration is specifically optimized for Java 8 compatibility on Render
