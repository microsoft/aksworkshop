#
# Build stage
#
FROM jekyll/builder AS build
 
# Set workdir and copy source files
WORKDIR /src/app
COPY . .

# Install app dependencies and build static files
RUN mkdir _site && mkdir .jekyll-cache && \
    jekyll build --future

#
# Final stage
#
FROM nginx:1.15-alpine
 
# Set workdir and copy static files from build stage!
WORKDIR /usr/share/nginx/html
COPY --from=build /src/app/_site .

EXPOSE 80
