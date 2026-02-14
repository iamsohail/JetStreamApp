# Build stage
FROM node:20-alpine AS builder
WORKDIR /app

# Install deps
COPY services/user-service/package*.json ./services/user-service/
WORKDIR /app/services/user-service
RUN npm ci

# Copy source and shared module (preserve relative paths)
WORKDIR /app
COPY services/user-service/tsconfig.json ./services/user-service/
COPY services/user-service/src/ ./services/user-service/src/
COPY shared/ ./shared/

# Build
WORKDIR /app/services/user-service
RUN npm run build

# Production stage
FROM node:20-alpine
WORKDIR /app/services/user-service
RUN addgroup -g 1001 -S nodejs && adduser -S nodeuser -u 1001
COPY --from=builder /app/services/user-service/dist ./dist
COPY --from=builder /app/services/user-service/node_modules ./node_modules
COPY --from=builder /app/services/user-service/package*.json ./
USER nodeuser
EXPOSE 3001
CMD ["node", "dist/services/user-service/src/index.js"]
