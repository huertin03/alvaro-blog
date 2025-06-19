# Build stage
# FROM hugomods/hugo:exts-0.115.1 as builder
FROM hugomods/hugo:exts-0.144.0 as builder

# Set working directory
WORKDIR /src

# Copy source code
COPY . .

# Build the Hugo site
RUN hugo --minify --environment production

# Production stage
FROM nginx:alpine

# Copy built site from builder stage
COPY --from=builder /src/public /usr/share/nginx/html

# Copy custom nginx config (optional)
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]