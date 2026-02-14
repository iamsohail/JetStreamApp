import { Request, Response, NextFunction } from 'express';
import { logger } from '../utils/logger';

export class AppError extends Error {
  statusCode: number;
  code: string;
  isOperational: boolean;

  constructor(statusCode: number, code: string, message: string) {
    super(message);
    this.statusCode = statusCode;
    this.code = code;
    this.isOperational = true;
    Object.setPrototypeOf(this, AppError.prototype);
  }
}

export class ValidationError extends AppError {
  constructor(message: string) { super(422, 'VALIDATION_ERROR', message); }
}

export class NotFoundError extends AppError {
  constructor(message: string = 'Resource not found') { super(404, 'NOT_FOUND', message); }
}

export class UnauthorizedError extends AppError {
  constructor(message: string = 'Unauthorized') { super(401, 'UNAUTHORIZED', message); }
}

export class ForbiddenError extends AppError {
  constructor(message: string = 'Forbidden') { super(403, 'FORBIDDEN', message); }
}

export class ConflictError extends AppError {
  constructor(message: string) { super(409, 'CONFLICT', message); }
}

export function errorHandler(err: Error, _req: Request, res: Response, _next: NextFunction) {
  if (err instanceof AppError) {
    logger.warn(`Operational error: ${err.code} - ${err.message}`);
    return res.status(err.statusCode).json({
      success: false,
      error: { code: err.code, message: err.message },
    });
  }

  logger.error(`Unexpected error: ${err.message}`);
  logger.error(err.stack || 'No stack trace');
  res.status(500).json({
    success: false,
    error: { code: 'INTERNAL_ERROR', message: err.message || 'An unexpected error occurred' },
  });
}
