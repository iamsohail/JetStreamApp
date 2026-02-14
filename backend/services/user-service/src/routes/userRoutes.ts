import { Router } from 'express';
import { userController } from '../controllers/userController';
import { authenticate } from '../middleware/auth';

const router = Router();

router.get('/profile', authenticate, userController.getProfile.bind(userController));
router.put('/profile', authenticate, userController.updateProfile.bind(userController));

export { router as userRoutes };
