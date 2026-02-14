import { Router } from 'express';
import { analyticsController } from '../controllers/analyticsController';
import { authenticate } from '../middleware/auth';

const router = Router();

router.get('/summary', authenticate, analyticsController.getSummary.bind(analyticsController));
router.get('/airlines', authenticate, analyticsController.getAirlineBreakdown.bind(analyticsController));
router.get('/airports', authenticate, analyticsController.getAirportStats.bind(analyticsController));
router.get('/trends', authenticate, analyticsController.getTrends.bind(analyticsController));
router.get('/records', authenticate, analyticsController.getRecords.bind(analyticsController));

export { router as analyticsRoutes };
