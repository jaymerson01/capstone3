"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateIncidentStatus = exports.getMyIncidents = exports.getIncidents = exports.createIncident = void 0;
const db_1 = __importDefault(require("../config/db"));
const createIncident = async (req, res) => {
    try {
        const { incidentType, reporterName, location, description, urgencyLevel, latitude, longitude } = req.body;
        console.log(`[DEBUG GEO BACKEND] Received createIncident request body: latitude=${latitude} (${typeof latitude}), longitude=${longitude} (${typeof longitude})`);
        if (!incidentType || !location || !description || !urgencyLevel) {
            return res.status(400).json({
                error: 'incidentType, location, description, and urgencyLevel are required.',
            });
        }
        const reporterId = req.user?.userId || null;
        const finalReporterName = reporterName || req.user?.email || 'Anonymous';
        const parsedLat = latitude !== undefined && latitude !== null && latitude !== '' && !isNaN(Number(latitude)) ? Number(latitude) : null;
        const parsedLng = longitude !== undefined && longitude !== null && longitude !== '' && !isNaN(Number(longitude)) ? Number(longitude) : null;
        console.log(`[DEBUG GEO BACKEND] Parsed coordinates for Prisma: latitude=${parsedLat}, longitude=${parsedLng}`);
        const incident = await db_1.default.incidentReport.create({
            data: {
                incidentType,
                reporterName: finalReporterName,
                reporterId,
                location,
                description,
                urgencyLevel,
                latitude: parsedLat,
                longitude: parsedLng,
                status: 'pending',
            },
        });
        console.log(`[DEBUG GEO BACKEND] Saved incident ID ${incident.id} with latitude=${incident.latitude}, longitude=${incident.longitude}`);
        // Automatically update area count if location matches an area
        const matchingArea = await db_1.default.area.findFirst({
            where: {
                name: {
                    contains: location,
                    mode: 'insensitive',
                },
            },
        });
        if (matchingArea) {
            await db_1.default.area.update({
                where: { id: matchingArea.id },
                data: { incidentsCount: { increment: 1 } },
            });
        }
        return res.status(201).json({
            message: 'Incident reported successfully.',
            incident,
        });
    }
    catch (error) {
        console.error('CreateIncident Error:', error);
        return res.status(500).json({ error: 'Failed to report incident.' });
    }
};
exports.createIncident = createIncident;
const getIncidents = async (req, res) => {
    try {
        const { showArchived } = req.query;
        const incidents = await db_1.default.incidentReport.findMany({
            where: {
                isArchived: showArchived === 'true' ? true : false,
            },
            orderBy: {
                createdAt: 'desc',
            },
        });
        return res.status(200).json({ incidents });
    }
    catch (error) {
        console.error('GetIncidents Error:', error);
        return res.status(500).json({ error: 'Failed to fetch incidents.' });
    }
};
exports.getIncidents = getIncidents;
const getMyIncidents = async (req, res) => {
    try {
        if (!req.user) {
            return res.status(401).json({ error: 'Authentication required.' });
        }
        const user = await db_1.default.user.findUnique({
            where: { id: req.user.userId },
        });
        const incidents = await db_1.default.incidentReport.findMany({
            where: {
                OR: [
                    { reporterId: req.user.userId },
                    { reporterName: user?.name },
                    { reporterName: user?.email },
                ],
            },
            orderBy: {
                createdAt: 'desc',
            },
        });
        return res.status(200).json({ incidents });
    }
    catch (error) {
        console.error('GetMyIncidents Error:', error);
        return res.status(500).json({ error: 'Failed to fetch user incidents.' });
    }
};
exports.getMyIncidents = getMyIncidents;
const updateIncidentStatus = async (req, res) => {
    try {
        const { id } = req.params;
        const { status } = req.body;
        const validStatuses = ['pending', 'inProgress', 'solved', 'spam'];
        if (!status || !validStatuses.includes(status)) {
            return res.status(400).json({
                error: `Invalid status. Must be one of: ${validStatuses.join(', ')}`,
            });
        }
        const existing = await db_1.default.incidentReport.findUnique({
            where: { id },
        });
        if (!existing) {
            return res.status(404).json({ error: 'Incident report not found.' });
        }
        const updatedIncident = await db_1.default.incidentReport.update({
            where: { id },
            data: { status },
        });
        return res.status(200).json({
            message: 'Incident status updated successfully.',
            incident: updatedIncident,
        });
    }
    catch (error) {
        console.error('UpdateIncidentStatus Error:', error);
        return res.status(500).json({ error: 'Failed to update incident status.' });
    }
};
exports.updateIncidentStatus = updateIncidentStatus;
