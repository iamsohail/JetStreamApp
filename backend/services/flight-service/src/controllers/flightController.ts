import { Request, Response, NextFunction } from 'express';
import { FlightService } from '../services/flightService';
import { validationResult } from 'express-validator';

const flightService = new FlightService();

export class FlightController {
  async pnrLookup(req: Request, res: Response, next: NextFunction) {
    try {
      const { pnr } = req.body;
      const result = await flightService.lookupPNR(pnr);
      res.json({ success: true, data: result });
    } catch (error) {
      next(error);
    }
  }

  async listFlights(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = (req as any).user.userId;
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 20;
      const result = await flightService.getUserFlights(userId, page, limit);
      res.json({ success: true, data: result.flights, meta: { page, limit, total: result.total } });
    } catch (error) {
      next(error);
    }
  }

  async getFlightDetail(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = (req as any).user.userId;
      const result = await flightService.getFlightById(req.params.id, userId);
      if (!result) {
        return res.status(404).json({ success: false, error: { code: 'NOT_FOUND', message: 'Flight not found' } });
      }
      res.json({ success: true, data: result });
    } catch (error) {
      next(error);
    }
  }

  async createFlight(req: Request, res: Response, next: NextFunction) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(422).json({ success: false, error: { code: 'VALIDATION_ERROR', message: 'Invalid input', details: errors.array() } });
      }

      const userId = (req as any).user.userId;
      const result = await flightService.createFlight(userId, req.body);
      res.status(201).json({ success: true, data: result });
    } catch (error) {
      next(error);
    }
  }

  async updateFlight(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = (req as any).user.userId;
      const result = await flightService.updateFlight(req.params.id, userId, req.body);
      res.json({ success: true, data: result });
    } catch (error) {
      next(error);
    }
  }

  async deleteFlight(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = (req as any).user.userId;
      await flightService.deleteFlight(req.params.id, userId);
      res.json({ success: true, data: { message: 'Flight deleted' } });
    } catch (error) {
      next(error);
    }
  }

  async getFlightStatus(req: Request, res: Response, next: NextFunction) {
    try {
      const result = await flightService.getFlightStatus(req.params.id);
      res.json({ success: true, data: result });
    } catch (error) {
      next(error);
    }
  }

  async searchAirports(req: Request, res: Response, next: NextFunction) {
    try {
      const q = req.query.q as string;
      const result = await flightService.searchAirports(q);
      res.json({ success: true, data: result });
    } catch (error) {
      next(error);
    }
  }

  async searchAirlines(req: Request, res: Response, next: NextFunction) {
    try {
      const q = req.query.q as string;
      const result = await flightService.searchAirlines(q);
      res.json({ success: true, data: result });
    } catch (error) {
      next(error);
    }
  }
}

export const flightController = new FlightController();
