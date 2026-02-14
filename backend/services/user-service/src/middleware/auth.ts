import { Request, Response, NextFunction } from 'express';
import { verifyToken } from '../utils/jwt';
import { logger } from '../utils/logger';

export function authenticate(req: Request, res: Response, next: NextFunction) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ success: false, error: { code: 'UNAUTHORIZED', message: 'Access token required' } });
  }

  const token = authHeader.substring(7);
  const payload = verifyToken(token);

  if (!payload) {
    return res.status(401).json({ success: false, error: { code: 'UNAUTHORIZED', message: 'Invalid or expired token' } });
  }

  if (payload.type !== 'access') {
    return res.status(401).json({ success: false, error: { code: 'UNAUTHORIZED', message: 'Invalid token type' } });
  }

  (req as any).user = payload;
  next();
}
