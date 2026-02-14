import { Request, Response, NextFunction } from 'express';
import { AuthService } from '../services/authService';
import { validationResult } from 'express-validator';

const authService = new AuthService();

export class AuthController {
  async register(req: Request, res: Response, next: NextFunction) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(422).json({ success: false, error: { code: 'VALIDATION_ERROR', message: 'Invalid input', details: errors.array() } });
      }

      const { email, password, name } = req.body;
      const result = await authService.register(email, password, name);
      res.status(201).json({ success: true, data: result });
    } catch (error) {
      next(error);
    }
  }

  async login(req: Request, res: Response, next: NextFunction) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(422).json({ success: false, error: { code: 'VALIDATION_ERROR', message: 'Invalid input', details: errors.array() } });
      }

      const { email, password } = req.body;
      const result = await authService.login(email, password);
      res.json({ success: true, data: result });
    } catch (error) {
      next(error);
    }
  }

  async socialAuth(req: Request, res: Response, next: NextFunction) {
    try {
      const { provider, token } = req.body;
      const result = await authService.socialAuth(provider, token);
      res.json({ success: true, data: result });
    } catch (error) {
      next(error);
    }
  }

  async refreshToken(req: Request, res: Response, next: NextFunction) {
    try {
      const { refresh_token } = req.body;
      const result = await authService.refreshToken(refresh_token);
      res.json({ success: true, data: result });
    } catch (error) {
      next(error);
    }
  }
}

export const authController = new AuthController();
