import { Request, Response, NextFunction } from 'express';
import { UserService } from '../services/userService';

const userService = new UserService();

export class UserController {
  async getProfile(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = (req as any).user.userId;
      const profile = await userService.findById(userId);
      if (!profile) {
        return res.status(404).json({ success: false, error: { code: 'NOT_FOUND', message: 'User not found' } });
      }
      res.json({ success: true, data: profile });
    } catch (error) {
      next(error);
    }
  }

  async updateProfile(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = (req as any).user.userId;
      const { name, avatar_url } = req.body;
      const profile = await userService.updateProfile(userId, { name, avatarUrl: avatar_url });
      res.json({ success: true, data: profile });
    } catch (error) {
      next(error);
    }
  }
}

export const userController = new UserController();
