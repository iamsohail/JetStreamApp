import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';

const JWT_SECRET = process.env.JWT_SECRET || 'your-super-secret-jwt-key-change-in-production';

interface TokenPayload {
  userId: string;
  email: string;
  type: 'access' | 'refresh';
}

export function authenticate(req: Request, res: Response, next: NextFunction) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ success: false, error: { code: 'UNAUTHORIZED', message: 'Access token required' } });
  }

  const token = authHeader.substring(7);

  try {
    const payload = jwt.verify(token, JWT_SECRET, { issuer: 'jetstream' }) as TokenPayload;

    if (payload.type !== 'access') {
      return res.status(401).json({ success: false, error: { code: 'UNAUTHORIZED', message: 'Invalid token type' } });
    }

    (req as any).user = payload;
    next();
  } catch {
    return res.status(401).json({ success: false, error: { code: 'UNAUTHORIZED', message: 'Invalid or expired token' } });
  }
}
