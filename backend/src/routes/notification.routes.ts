import { Router } from 'express';
import {
  getNotifications,
  markAsRead,
  markAllAsRead,
} from '../controllers/notification.controller';
import { authenticate, requireAdmin } from '../middleware/auth.middleware';

const router = Router();

router.get('/', authenticate, requireAdmin, getNotifications);
router.patch('/read-all', authenticate, requireAdmin, markAllAsRead);
router.patch('/:id/read', authenticate, requireAdmin, markAsRead);

export default router;
