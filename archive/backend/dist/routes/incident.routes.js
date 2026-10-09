"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const incident_controller_1 = require("../controllers/incident.controller");
const auth_middleware_1 = require("../middleware/auth.middleware");
const router = (0, express_1.Router)();
// Public / Authenticated incident reporting routes
router.post('/', auth_middleware_1.authenticate, incident_controller_1.createIncident);
router.get('/', incident_controller_1.getIncidents);
router.get('/my-reports', auth_middleware_1.authenticate, incident_controller_1.getMyIncidents);
// Admin incident routes
router.patch('/:id/status', auth_middleware_1.authenticate, auth_middleware_1.requireAdmin, incident_controller_1.updateIncidentStatus);
exports.default = router;
