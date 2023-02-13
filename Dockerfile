
# Stage 0, "build-stage", based on Node.js, to build and compile the frontend
#  Create a node environment and build the angular application with production configuration
FROM node:16.17.0 as build-stage
WORKDIR /app
COPY package*.json /app/
RUN npm install
COPY ./ /app/
RUN npm run build --prod

# Stage 1, copy nginx conf
# Copy the dist folder from the previous stage to Nginx container and copy nginx-custom.conf inside the nginx
FROM nginx:alpine
COPY --from=build-stage /app/dist/spa /usr/share/nginx/html
#Copy default nginx configuration
COPY ./nginx-custom.conf /etc/nginx/conf.d/default.conf
