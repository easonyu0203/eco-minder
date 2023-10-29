# Use a smaller base image like the official Node.js slim image
FROM node:18-slim

# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json to the working directory
COPY eco_minder_flutter_app/mqtt-to-firestore/package*.json ./

# Install project dependencies
RUN npm install --production

# Copy the rest of the application code
COPY eco_minder_flutter_app/mqtt-to-firestore/ .

# Command to run your TypeScript application
CMD [ "npm", "run", "start" ]