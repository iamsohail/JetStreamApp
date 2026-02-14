import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import { flightRoutes } from './routes/flightRoutes';
import { analyticsRoutes } from './routes/analyticsRoutes';
import { errorHandler } from './middleware/errorHandler';

const app = express();
const PORT = process.env.PORT || 3002;

app.use(helmet());
app.use(cors({ origin: process.env.CORS_ORIGIN || '*' }));
app.use(express.json({ limit: '10mb' }));

const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW || '900') * 1000,
  max: parseInt(process.env.RATE_LIMIT_MAX || '100'),
  message: { success: false, error: { code: 'RATE_LIMITED', message: 'Too many requests' } },
});
app.use(limiter);

app.get('/health', (_, res) => {
  res.json({ status: 'healthy', service: 'flight-service', timestamp: new Date().toISOString() });
});

app.use('/api/v1/flights', flightRoutes);
app.use('/api/v1/analytics', analyticsRoutes);

app.use(errorHandler);

app.listen(PORT, () => {
  console.log(`Flight service running on port ${PORT}`);
});

export default app;
