import jwt from 'jsonwebtoken';

const JWT_SECRET = process.env.JWT_SECRET || 'your-super-secret-jwt-key-change-in-production';
const ACCESS_TOKEN_EXPIRY = 900; // 15 minutes
const REFRESH_TOKEN_EXPIRY = 604800; // 7 days

interface TokenPayload {
  userId: string;
  email: string;
  type: 'access' | 'refresh';
}

export function generateAccessToken(userId: string, email: string): string {
  return jwt.sign({ userId, email, type: 'access' }, JWT_SECRET, {
    expiresIn: ACCESS_TOKEN_EXPIRY,
    issuer: 'jetstream',
  });
}

export function generateRefreshToken(userId: string, email: string): string {
  return jwt.sign({ userId, email, type: 'refresh' }, JWT_SECRET, {
    expiresIn: REFRESH_TOKEN_EXPIRY,
    issuer: 'jetstream',
  });
}

export function generateTokenPair(userId: string, email: string) {
  return {
    accessToken: generateAccessToken(userId, email),
    refreshToken: generateRefreshToken(userId, email),
    expiresIn: ACCESS_TOKEN_EXPIRY,
  };
}

export function verifyToken(token: string): TokenPayload | null {
  try {
    const decoded = jwt.verify(token, JWT_SECRET, { issuer: 'jetstream' }) as TokenPayload;
    return decoded;
  } catch {
    return null;
  }
}
