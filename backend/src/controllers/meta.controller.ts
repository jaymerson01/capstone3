import { Request, Response } from 'express';
import prisma from '../config/db';

export const getCategories = async (req: Request, res: Response) => {
  try {
    let categories = await prisma.category.findMany({
      where: { isArchived: false },
    });

    if (categories.length === 0) {
      // Seed defaults if empty
      await prisma.category.createMany({
        data: [
          { name: 'Theft', description: 'Stealing of personal property' },
          { name: 'Accident', description: 'Road vehicular collisions' },
          { name: 'Fire', description: 'Fires' },
          { name: 'Violence', description: 'Fights, physical assault' },
          { name: 'Suspicious Activity', description: 'Unidentified loitering' },
        ],
        skipDuplicates: true,
      });
      categories = await prisma.category.findMany({ where: { isArchived: false } });
    }

    return res.status(200).json({ categories });
  } catch (error: any) {
    console.error('GetCategories Error:', error);
    return res.status(500).json({ error: 'Failed to fetch categories.' });
  }
};

export const getAreas = async (req: Request, res: Response) => {
  try {
    let areas = await prisma.area.findMany({
      where: { isArchived: false },
    });

    if (areas.length === 0) {
      // Seed defaults if empty
      await prisma.area.createMany({
        data: [
          { name: 'Area 1', incidentsCount: 0 },
          { name: 'Area 2', incidentsCount: 0 },
          { name: 'Area 3', incidentsCount: 0 },
          { name: 'Area 4', incidentsCount: 0 },
          { name: 'Area 5', incidentsCount: 0 },
        ],
        skipDuplicates: true,
      });
      areas = await prisma.area.findMany({ where: { isArchived: false } });
    }

    return res.status(200).json({ areas });
  } catch (error: any) {
    console.error('GetAreas Error:', error);
    return res.status(500).json({ error: 'Failed to fetch areas.' });
  }
};
