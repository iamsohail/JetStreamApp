import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import { authRoutes } from './routes/authRoutes';
import { userRoutes } from './routes/userRoutes';
import { errorHandler } from './middleware/errorHandler';
import { logger } from './utils/logger';

const app = express();
const PORT = process.env.PORT || 3001;

// Security middleware
app.use(helmet());
app.use(cors({ origin: process.env.CORS_ORIGIN || '*' }));
app.use(express.json({ limit: '10mb' }));

// Rate limiting
const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW || '900') * 1000,
  max: parseInt(process.env.RATE_LIMIT_MAX || '100'),
  message: { success: false, error: { code: 'RATE_LIMITED', message: 'Too many requests' } },
});
app.use(limiter);

// Health check
app.get('/health', (_, res) => {
  res.json({ status: 'healthy', service: 'user-service', timestamp: new Date().toISOString() });
});

// Routes
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/users', userRoutes);

// Error handler
app.use(errorHandler);

app.listen(PORT, () => {
  logger.info(`User service running on port ${PORT}`);
});

export default app;
