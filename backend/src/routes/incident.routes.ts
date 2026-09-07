import { Router } from 'express';
import {
  createIncident,
  getIncidents,
  getMyIncidents,
  updateIncidentStatus,
  archiveIncident,
} from '../controllers/incident.controller';
import { authenticate, requireAdmin } from '../middleware/auth.middleware';

const router = Router();

// Public / Authenticated incident reporting routes
router.post('/', authenticate, createIncident);
router.get('/', getIncidents);
router.get('/my-reports', authenticate, getMyIncidents);

// Admin incident routes
router.patch('/:id/status', authenticate, requireAdmin, updateIncidentStatus);
router.patch('/:id/archive', authenticate, requireAdmin, archiveIncident);

export default router;

