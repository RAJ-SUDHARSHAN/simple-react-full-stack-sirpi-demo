FROM node:20-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files for layer caching
COPY package*.json ./

# Install all dependencies (including devDependencies for build)
RUN npm ci

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Production stage
FROM node:20-alpine AS runner

# Arguments
ARG PORT=8080
ARG NODE_ENV=production

# Environment variables
ENV NODE_ENV=${NODE_ENV} \
    PORT=${PORT}

# Install wget for healthcheck
RUN apk add --no-cache wget

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install only production dependencies
RUN npm ci --omit=dev && \
    npm cache clean --force

# Copy built assets from builder stage
COPY --from=builder --chown=nodejs:nodejs /app/dist ./dist
COPY --from=builder --chown=nodejs:nodejs /app/src ./src

# Switch to non-root user
USER nodejs

# Expose port
EXPOSE ${PORT}

# Add labels
LABEL maintainer="DevOps Team" \
      version="1.0" \
      description="Node.js Express application" \
      platform="AWS Fargate"

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:${PORT}/ || exit 1

# Start command
CMD ["node", "src/server/index.js"]