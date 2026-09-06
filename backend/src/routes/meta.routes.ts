import { Router } from 'express';
import { getCategories, getAreas } from '../controllers/meta.controller';

const router = Router();

router.get('/categories', getCategories);
router.get('/areas', getAreas);

export default router;
