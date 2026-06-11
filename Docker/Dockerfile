# Step 1: Use an official lightweight Nginx base image
FROM nginx:alpine

# Step 2: Copy a local index.html file from the host straight into the container's web directory
COPY index.html /usr/share/nginx/html/index.html

# Step 3: Inform the Docker engine that this container listens on port 80
EXPOSE 80
