import { Response } from 'express';
import prisma from '../config/db';
import { AuthenticatedRequest } from '../middleware/auth.middleware';

export const createIncident = async (req: AuthenticatedRequest, res: Response) => {
  try {
    const { incidentType, reporterName, location, description, urgencyLevel } = req.body;

    if (!incidentType || !location || !description || !urgencyLevel) {
      return res.status(400).json({
        error: 'incidentType, location, description, and urgencyLevel are required.',
      });
    }

    const reporterId = req.user?.userId || null;
    const finalReporterName = reporterName || req.user?.email || 'Anonymous';

    const incident = await prisma.incidentReport.create({
      data: {
        incidentType,
        reporterName: finalReporterName,
        reporterId,
        location,
        description,
        urgencyLevel,
        status: 'pending',
      },
    });

    // Automatically update area count if location matches an area
    const matchingArea = await prisma.area.findFirst({
      where: {
        name: {
          contains: location,
          mode: 'insensitive',
        },
      },
    });

    if (matchingArea) {
      await prisma.area.update({
        where: { id: matchingArea.id },
        data: { incidentsCount: { increment: 1 } },
      });
    }

    return res.status(201).json({
      message: 'Incident reported successfully.',
      incident,
    });
  } catch (error: any) {
    console.error('CreateIncident Error:', error);
    return res.status(500).json({ error: 'Failed to report incident.' });
  }
};

export const getIncidents = async (req: AuthenticatedRequest, res: Response) => {
  try {
    const { showArchived } = req.query;

    const incidents = await prisma.incidentReport.findMany({
      where: {
        isArchived: showArchived === 'true' ? true : false,
      },
      orderBy: {
        createdAt: 'desc',
      },
    });

    return res.status(200).json({ incidents });
  } catch (error: any) {
    console.error('GetIncidents Error:', error);
    return res.status(500).json({ error: 'Failed to fetch incidents.' });
  }
};

export const getMyIncidents = async (req: AuthenticatedRequest, res: Response) => {
  try {
    if (!req.user) {
      return res.status(401).json({ error: 'Authentication required.' });
    }

    const user = await prisma.user.findUnique({
      where: { id: req.user.userId },
    });

    const incidents = await prisma.incidentReport.findMany({
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
  } catch (error: any) {
    console.error('GetMyIncidents Error:', error);
    return res.status(500).json({ error: 'Failed to fetch user incidents.' });
  }
};

export const updateIncidentStatus = async (req: AuthenticatedRequest, res: Response) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    const validStatuses = ['pending', 'inProgress', 'solved', 'spam'];
    if (!status || !validStatuses.includes(status)) {
      return res.status(400).json({
        error: `Invalid status. Must be one of: ${validStatuses.join(', ')}`,
      });
    }

    const existing = await prisma.incidentReport.findUnique({
      where: { id },
    });

    if (!existing) {
      return res.status(404).json({ error: 'Incident report not found.' });
    }

    const updatedIncident = await prisma.incidentReport.update({
      where: { id },
      data: { status },
    });

    return res.status(200).json({
      message: 'Incident status updated successfully.',
      incident: updatedIncident,
    });
  } catch (error: any) {
    console.error('UpdateIncidentStatus Error:', error);
    return res.status(500).json({ error: 'Failed to update incident status.' });
  }
};
