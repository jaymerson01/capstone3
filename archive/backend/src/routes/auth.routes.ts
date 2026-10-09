import { Router } from 'express';
import {
  signUp,
  login,
  getCurrentUser,
  getUsers,
  updateUserStatus,
  archiveUser,
  updateUserRole,
  updateProfile,
  updatePassword,
  updateSettings,
} from '../controllers/auth.controller';
import { authenticate, requireAdmin } from '../middleware/auth.middleware';

const router = Router();

// Public / User Auth routes
router.post('/signup', signUp);
router.post('/login', login);
router.get('/me', authenticate, getCurrentUser);
router.patch('/profile', authenticate, updateProfile);
router.patch('/password', authenticate, updatePassword);
router.patch('/settings', authenticate, updateSettings);

// Admin User Management routes
router.get('/users', authenticate, requireAdmin, getUsers);
router.patch('/users/:id/status', authenticate, requireAdmin, updateUserStatus);
router.patch('/users/:id/archive', authenticate, requireAdmin, archiveUser);
router.patch('/users/:id/role', authenticate, requireAdmin, updateUserRole);

export default router;

