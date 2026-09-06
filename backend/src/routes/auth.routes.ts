import { Router } from 'express';
import { signUp, login, getCurrentUser } from '../controllers/auth.controller';
import { authenticate } from '../middleware/auth.middleware';

const router = Router();

router.post('/signup', signUp);
router.post('/login', login);
router.get('/me', authenticate, getCurrentUser);

export default router;
