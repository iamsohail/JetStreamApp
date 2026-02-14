import { Router } from 'express';
import { body } from 'express-validator';
import { authController } from '../controllers/authController';

const router = Router();

router.post('/register', [
  body('email').isEmail().normalizeEmail(),
  body('password').isLength({ min: 8 }),
  body('name').trim().isLength({ min: 1 }),
], authController.register.bind(authController));

router.post('/login', [
  body('email').isEmail().normalizeEmail(),
  body('password').notEmpty(),
], authController.login.bind(authController));

router.post('/social', authController.socialAuth.bind(authController));
router.post('/refresh', authController.refreshToken.bind(authController));

export { router as authRoutes };
