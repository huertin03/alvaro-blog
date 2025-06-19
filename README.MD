# Alvaro's Blog

A Hugo static site blog built with the LoveIt theme, containerized with Docker and deployed using Docker Swarm with Traefik reverse proxy.

## 🚀 Quick Start

### Prerequisites

- Hugo Extended (v0.144.0 or later)
- Git
- Docker
- Docker Swarm (for production deployment)

### Local Development

1. **Clone the repository with submodules:**
```bash
git clone --recurse-submodules https://github.com/your-username/alvaro-blog.git
cd alvaro-blog
```

2. **If you forgot to clone with submodules:**
```bash
git submodule update --init --recursive
```

3. **Run the development server:**
```bash
hugo server -D
```

4. **Access your site:**
Open http://localhost:1313 in your browser

## 📖 Hugo Installation & Setup

### Installing Hugo

**Linux (Ubuntu/Debian):**
```bash
sudo apt update
sudo apt install hugo
```

**macOS:**
```bash
brew install hugo
```

**Windows:**
```bash
choco install hugo-extended
```

### Project Setup

1. **Create new Hugo site:**
```bash
hugo new site alvaro-blog
cd alvaro-blog
```

2. **Add LoveIt theme:**
```bash
git init
git submodule add https://github.com/dillonzq/LoveIt.git themes/LoveIt
```

3. **Configure the theme in `hugo.toml`:**
```toml
baseURL = "https://blog.huertasserver.dpdns.org"
languageCode = "en-us"
title = "Alvaro's Blog"
theme = "LoveIt"

[params]
  # LoveIt theme parameters
  version = "0.2.X"
```

## ✍️ Content Creation

### Creating Posts

```bash
# Create a new post
hugo new posts/my-first-post.md
```

### Post Front Matter Example

```yaml
---
title: "My First Post"
date: 2025-06-20T10:00:00+00:00
tags: ["hugo", "blogging", "web-development"]
categories: ["Technology"]
draft: false
---

Your content here...
```

### Adding Tags and Categories

```yaml
# Multiple tags
tags: ["hugo", "themes", "static-sites"]

# Categories
categories: ["Web Development", "Technology"]
```

### Building for Production

```bash
# Build the site
hugo --minify --environment production

# Output will be in the 'public' directory
```

## 🐳 Docker Containerization

### Dockerfile

The project uses a multi-stage Docker build:

```dockerfile
# Build stage
FROM hugomods/hugo:0.144.0-exts AS builder
WORKDIR /src
COPY . .
RUN hugo --minify --environment production

# Production stage  
FROM nginx:alpine
RUN rm -rf /usr/share/nginx/html/*
COPY --from=builder /src/public/ /usr/share/nginx/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### Local Docker Testing

```bash
# Build the image
docker build -t alvaro-blog:latest .

# Run locally
docker run -d -p 8080:80 --name test-blog alvaro-blog:latest

# Test
curl http://localhost:8080

# Cleanup
docker rm -f test-blog
```

## 🚢 Production Deployment

### Docker Swarm Stack

The blog is deployed as part of a Docker Swarm stack with Traefik reverse proxy.

#### Stack Configuration (`blog-stack.yml`):

```yaml
version: '3.7'

services:
  blog:
    image: alvaro-blog:latest
    networks:
      - traefik
    deploy:
      mode: replicated
      replicas: 2
      update_config:
        delay: 10s
        order: start-first
        monitor: 15s
      restart_policy:
        condition: any
        delay: 5s
        max_attempts: 3
        window: 120s
      labels:
        - traefik.enable=true
        - traefik.docker.network=traefik
        - traefik.http.routers.blog.rule=Host(`blog.huertasserver.dpdns.org`)
        - traefik.http.routers.blog.entrypoints=websecure
        - traefik.http.routers.blog.tls=true
        - traefik.http.routers.blog.tls.certresolver=letsencrypt
        - traefik.http.services.blog.loadbalancer.server.port=80
        - traefik.constraint=proxy-public

networks:
  traefik:
    external: true
```

#### Deployment Commands:

```bash
# Deploy the stack
docker stack deploy -c blog-stack.yml blog

# Check service status
docker service ls
docker service logs blog_blog

# Update the service
docker service update --image alvaro-blog:latest blog_blog

# Remove the stack
docker stack rm blog
```

### Traefik Integration

The blog integrates with an existing Traefik setup that provides:

- **Automatic HTTPS** with Let's Encrypt certificates
- **Cloudflare DNS challenge** for wildcard certificates
- **Load balancing** across multiple replicas
- **Automatic service discovery**

The blog is accessible at: `https://blog.huertasserver.dpdns.org`

## 🔧 Development Workflow

### Making Changes

1. **Create/edit content:**
```bash
hugo new posts/new-post.md
# Edit the post in your favorite editor
```

2. **Test locally:**
```bash
hugo server -D
```

3. **Build and test with Docker:**
```bash
docker build -t alvaro-blog:latest .
docker run -d -p 8080:80 alvaro-blog:latest
```

4. **Deploy to production:**
```bash
docker service update --image alvaro-blog:latest blog_blog
```

### Updating the Theme

```bash
# Update LoveIt theme
git submodule update --remote themes/LoveIt
git add themes/LoveIt
git commit -m "Update LoveIt theme"
```

## 📁 Project Structure

```
alvaro-blog/
├── content/
│   └── posts/          # Blog posts
├── themes/
│   └── LoveIt/         # Theme submodule
├── static/             # Static files (images, etc.)
├── layouts/            # Custom layout overrides
├── hugo.toml           # Hugo configuration
├── Dockerfile          # Docker build configuration
├── blog-stack.yml      # Docker Swarm stack
└── README.md           # This file
```

## 🛠️ Troubleshooting

### Common Issues

**Theme not loading:**
```bash
# Ensure submodules are initialized
git submodule update --init --recursive
```

**Docker build fails:**
```bash
# Check if theme files exist
ls -la themes/LoveIt/
```

**Site not accessible in production:**
```bash
# Check service status
docker service ps blog_blog
docker service logs blog_blog
```

### Useful Commands

```bash
# Check Hugo version
hugo version

# Validate configuration
hugo config

# Check Docker Swarm status
docker node ls
docker service ls

# View Traefik dashboard
# Access: https://traefik.huertasserver.dpdns.org
```

## 📚 Resources

- [Hugo Documentation](https://gohugo.io/documentation/)
- [LoveIt Theme Documentation](https://hugoloveit.com/)
- [Docker Documentation](https://docs.docker.com/)
- [Traefik Documentation](https://doc.traefik.io/traefik/)
