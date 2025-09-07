#!/bin/bash

# Use PORT environment variable or default to 8080
export PORT=${PORT:-8080}

# Configure Tomcat connector to use the PORT variable
sed -i "s/port=\"8080\"/port=\"${PORT}\"/g" /usr/local/tomcat/conf/server.xml

# Start Tomcat
exec catalina.sh run
