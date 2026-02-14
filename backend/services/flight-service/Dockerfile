# Build stage
FROM node:20-alpine AS builder
WORKDIR /app

# Install deps
COPY services/flight-service/package*.json ./services/flight-service/
WORKDIR /app/services/flight-service
RUN npm ci

# Copy source and shared module (preserve relative paths)
WORKDIR /app
COPY services/flight-service/tsconfig.json ./services/flight-service/
COPY services/flight-service/src/ ./services/flight-service/src/
COPY shared/ ./shared/

# Symlink node_modules at root so shared/ can resolve deps
RUN ln -s /app/services/flight-service/node_modules /app/node_modules

# Build
WORKDIR /app/services/flight-service
RUN npm run build

# Production stage
FROM node:20-alpine
WORKDIR /app/services/flight-service
RUN addgroup -g 1001 -S nodejs && adduser -S nodeuser -u 1001
COPY --from=builder /app/services/flight-service/dist ./dist
COPY --from=builder /app/services/flight-service/node_modules ./node_modules
COPY --from=builder /app/services/flight-service/package*.json ./
USER nodeuser
EXPOSE 3002
CMD ["node", "dist/services/flight-service/src/index.js"]
