import { Response } from 'express';
import prisma from '../config/db';
import { AuthenticatedRequest } from '../middleware/auth.middleware';

export const getNotifications = async (req: AuthenticatedRequest, res: Response) => {
  try {
    const notifications = await prisma.notification.findMany({
      orderBy: {
        createdAt: 'desc',
      },
      take: 50,
    });

    return res.status(200).json({ notifications });
  } catch (error: any) {
    console.error('GetNotifications Error:', error);
    return res.status(500).json({ error: 'Failed to fetch notifications.' });
  }
};

export const markAsRead = async (req: AuthenticatedRequest, res: Response) => {
  try {
    const { id } = req.params;

    const notification = await prisma.notification.update({
      where: { id },
      data: { isRead: true },
    });

    return res.status(200).json({ notification });
  } catch (error: any) {
    console.error('MarkAsRead Error:', error);
    return res.status(500).json({ error: 'Failed to mark notification as read.' });
  }
};

export const markAllAsRead = async (req: AuthenticatedRequest, res: Response) => {
  try {
    await prisma.notification.updateMany({
      where: { isRead: false },
      data: { isRead: true },
    });

    return res.status(200).json({ message: 'All notifications marked as read.' });
  } catch (error: any) {
    console.error('MarkAllAsRead Error:', error);
    return res.status(500).json({ error: 'Failed to mark all notifications as read.' });
  }
};
