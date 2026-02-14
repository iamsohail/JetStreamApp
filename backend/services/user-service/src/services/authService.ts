import bcrypt from 'bcryptjs';
import { UserService } from './userService';
import { generateTokenPair, verifyToken } from '../utils/jwt';
import { verifyFirebaseToken } from '../utils/firebase';
import { AppError, UnauthorizedError, ConflictError } from '../middleware/errorHandler';

const userService = new UserService();

export class AuthService {
  async register(email: string, password: string, name: string) {
    const existing = await userService.findByEmail(email);
    if (existing) {
      throw new ConflictError('Email already registered');
    }

    const passwordHash = await bcrypt.hash(password, 12);
    const user = await userService.create({ email, passwordHash, name, authProvider: 'email' });
    const tokens = generateTokenPair(user.id, user.email);

    return { user: { id: user.id, email: user.email, name: user.name }, ...tokens };
  }

  async login(email: string, password: string) {
    const user = await userService.findByEmail(email);
    if (!user || !user.password_hash) {
      throw new UnauthorizedError('Invalid email or password');
    }

    const isValid = await bcrypt.compare(password, user.password_hash);
    if (!isValid) {
      throw new UnauthorizedError('Invalid email or password');
    }

    const tokens = generateTokenPair(user.id, user.email);
    return { user: { id: user.id, email: user.email, name: user.name }, ...tokens };
  }

  async socialAuth(provider: string, token: string) {
    const firebaseUser = await verifyFirebaseToken(token);

    // Check if user exists by firebase_uid
    let user = await userService.findByFirebaseUid(firebaseUser.uid);
    if (user) {
      const tokens = generateTokenPair(user.id, user.email);
      return { user: { id: user.id, email: user.email, name: user.name }, ...tokens };
    }

    // Check by email for account linking
    user = await userService.findByEmail(firebaseUser.email);
    if (user) {
      await userService.updateFirebaseUid(user.id, firebaseUser.uid);
      const tokens = generateTokenPair(user.id, user.email);
      return { user: { id: user.id, email: user.email, name: user.name }, ...tokens };
    }

    // Create new user
    user = await userService.create({
      email: firebaseUser.email,
      passwordHash: '',
      name: firebaseUser.name,
      authProvider: provider,
      firebaseUid: firebaseUser.uid,
      avatarUrl: firebaseUser.picture,
    });
    const tokens = generateTokenPair(user.id, user.email);
    return { user: { id: user.id, email: user.email, name: user.name }, ...tokens };
  }

  async refreshToken(refreshToken: string) {
    const payload = verifyToken(refreshToken);
    if (!payload || payload.type !== 'refresh') {
      throw new UnauthorizedError('Invalid refresh token');
    }

    const user = await userService.findById(payload.userId);
    if (!user) {
      throw new UnauthorizedError('User not found');
    }

    const tokens = generateTokenPair(user.id, user.email);
    return tokens;
  }
}
