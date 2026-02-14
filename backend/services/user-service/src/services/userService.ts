import { query } from '../../../../shared/database/connection';

interface CreateUserParams {
  email: string;
  passwordHash: string;
  name: string;
  authProvider: string;
  firebaseUid?: string;
  avatarUrl?: string;
}

interface UpdateProfileParams {
  name?: string;
  avatarUrl?: string;
}

export class UserService {
  async create(params: CreateUserParams) {
    const result = await query(
      `INSERT INTO users (email, password_hash, name, auth_provider, firebase_uid, avatar_url)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING id, email, name, avatar_url, auth_provider, created_at`,
      [params.email, params.passwordHash, params.name, params.authProvider, params.firebaseUid || null, params.avatarUrl || null]
    );
    return result.rows[0];
  }

  async findByEmail(email: string) {
    const result = await query(
      'SELECT id, email, password_hash, name, avatar_url, auth_provider, firebase_uid, created_at, updated_at FROM users WHERE email = $1',
      [email]
    );
    return result.rows[0] || null;
  }

  async findById(id: string) {
    const result = await query(
      'SELECT id, email, name, avatar_url, auth_provider, created_at, updated_at FROM users WHERE id = $1',
      [id]
    );
    return result.rows[0] || null;
  }

  async findByFirebaseUid(uid: string) {
    const result = await query(
      'SELECT id, email, name, avatar_url, auth_provider, firebase_uid, created_at, updated_at FROM users WHERE firebase_uid = $1',
      [uid]
    );
    return result.rows[0] || null;
  }

  async updateProfile(id: string, params: UpdateProfileParams) {
    const fields: string[] = [];
    const values: any[] = [];
    let paramIndex = 1;

    if (params.name !== undefined) {
      fields.push(`name = $${paramIndex++}`);
      values.push(params.name);
    }
    if (params.avatarUrl !== undefined) {
      fields.push(`avatar_url = $${paramIndex++}`);
      values.push(params.avatarUrl);
    }

    if (fields.length === 0) return this.findById(id);

    values.push(id);
    const result = await query(
      `UPDATE users SET ${fields.join(', ')} WHERE id = $${paramIndex} RETURNING id, email, name, avatar_url, auth_provider, created_at, updated_at`,
      values
    );
    return result.rows[0];
  }
}
