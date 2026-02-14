import * as admin from 'firebase-admin';
import { logger } from './logger';

let initialized = false;

function initFirebase() {
  if (initialized) return;

  const projectId = process.env.FIREBASE_PROJECT_ID;
  if (!projectId) {
    logger.warn('FIREBASE_PROJECT_ID not set — social auth will fail');
    return;
  }

  admin.initializeApp({ projectId });
  initialized = true;
  logger.info('Firebase Admin initialized');
}

export interface FirebaseUserInfo {
  uid: string;
  email: string;
  name: string;
  picture?: string;
}

export async function verifyFirebaseToken(idToken: string): Promise<FirebaseUserInfo> {
  initFirebase();

  const decoded = await admin.auth().verifyIdToken(idToken);
  return {
    uid: decoded.uid,
    email: decoded.email || '',
    name: decoded.name || decoded.email?.split('@')[0] || 'User',
    picture: decoded.picture,
  };
}
