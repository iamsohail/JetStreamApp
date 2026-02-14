import { Request, Response, NextFunction } from 'express';
import { AnalyticsService } from '../services/analyticsService';

const analyticsService = new AnalyticsService();

export class AnalyticsController {
  async getSummary(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = (req as any).user.userId;
      const result = await analyticsService.getSummary(userId);
      res.json({ success: true, data: result });
    } catch (error) {
      next(error);
    }
  }

  async getAirlineBreakdown(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = (req as any).user.userId;
      const result = await analyticsService.getAirlineBreakdown(userId);
      res.json({ success: true, data: result });
    } catch (error) {
      next(error);
    }
  }

  async getAirportStats(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = (req as any).user.userId;
      const result = await analyticsService.getAirportStats(userId);
      res.json({ success: true, data: result });
    } catch (error) {
      next(error);
    }
  }

  async getTrends(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = (req as any).user.userId;
      const result = await analyticsService.getTrends(userId);
      res.json({ success: true, data: result });
    } catch (error) {
      next(error);
    }
  }

  async getRecords(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = (req as any).user.userId;
      const result = await analyticsService.getRecords(userId);
      res.json({ success: true, data: result });
    } catch (error) {
      next(error);
    }
  }
}

export const analyticsController = new AnalyticsController();
