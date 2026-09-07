import { Response } from 'express';
import bcrypt from 'bcryptjs';
import prisma from '../config/db';
import { generateToken } from '../utils/jwt.utils';
import { AuthenticatedRequest } from '../middleware/auth.middleware';

export const signUp = async (req: AuthenticatedRequest, res: Response) => {
  try {
    const { name, email, password, role } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({ error: 'Name, email, and password are required.' });
    }

    const normalizedEmail = email.toLowerCase().trim();

    // Check existing user
    const existingUser = await prisma.user.findUnique({
      where: { email: normalizedEmail },
    });

    if (existingUser) {
      return res.status(409).json({ error: 'Email is already registered.' });
    }

    // Hash password securely
    const hashedPassword = await bcrypt.hash(password, 10);

    const user = await prisma.user.create({
      data: {
        name,
        email: normalizedEmail,
        password: hashedPassword,
        role: 'user', // Public signup strictly forces 'user' / resident role
      },
    });

    // Create system notification for new user signup
    try {
      await (prisma as any).notification.create({
        data: {
          title: 'New Resident Account Created',
          message: `User ${user.name} (${user.email}) registered as a resident.`,
          type: 'user',
        },
      });
    } catch (_) {}

    const token = generateToken({
      userId: user.id,
      email: user.email,
      role: user.role,
    });

    return res.status(201).json({
      message: 'User registered successfully.',
      token,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        isActive: user.isActive,
        isArchived: user.isArchived,
      },
    });
  } catch (error: any) {
    console.error('SignUp Error:', error);
    return res.status(500).json({ error: 'Failed to sign up user.' });
  }
};

export const login = async (req: AuthenticatedRequest, res: Response) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required.' });
    }

    const normalizedEmail = email.toLowerCase().trim();

    const user = await prisma.user.findUnique({
      where: { email: normalizedEmail },
    });

    if (!user || user.isArchived) {
      return res.status(401).json({ error: 'Invalid email or password.' });
    }

    if (!user.isActive) {
      return res.status(403).json({ error: 'Account is deactivated.' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ error: 'Invalid email or password.' });
    }

    const token = generateToken({
      userId: user.id,
      email: user.email,
      role: user.role,
    });

    return res.status(200).json({
      message: 'Login successful.',
      token,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        isActive: user.isActive,
        isArchived: user.isArchived,
      },
    });
  } catch (error: any) {
    console.error('Login Error:', error);
    return res.status(500).json({ error: 'Failed to log in.' });
  }
};

export const getCurrentUser = async (req: AuthenticatedRequest, res: Response) => {
  try {
    if (!req.user) {
      return res.status(401).json({ error: 'Unauthenticated' });
    }

    const user = await prisma.user.findUnique({
      where: { id: req.user.userId },
      select: {
        id: true,
        name: true,
        email: true,
        role: true,
        isActive: true,
        isArchived: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    if (!user) {
      return res.status(404).json({ error: 'User not found.' });
    }

    return res.status(200).json({ user });
  } catch (error: any) {
    console.error('GetCurrentUser Error:', error);
    return res.status(500).json({ error: 'Failed to retrieve current user.' });
  }
};

export const getUsers = async (req: AuthenticatedRequest, res: Response) => {
  try {
    const { showArchived } = req.query;

    const users = await prisma.user.findMany({
      where: {
        isArchived: showArchived === 'true' ? true : false,
      },
      select: {
        id: true,
        name: true,
        email: true,
        role: true,
        isActive: true,
        isArchived: true,
        createdAt: true,
        updatedAt: true,
      },
      orderBy: {
        createdAt: 'desc',
      },
    });

    return res.status(200).json({ users });
  } catch (error: any) {
    console.error('GetUsers Error:', error);
    return res.status(500).json({ error: 'Failed to fetch users.' });
  }
};

export const updateUserStatus = async (req: AuthenticatedRequest, res: Response) => {
  try {
    const { id } = req.params;
    const { isActive } = req.body;

    if (typeof isActive !== 'boolean') {
      return res.status(400).json({ error: 'isActive must be a boolean.' });
    }

    const user = await prisma.user.update({
      where: { id },
      data: { isActive },
      select: {
        id: true,
        name: true,
        email: true,
        role: true,
        isActive: true,
        isArchived: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    return res.status(200).json({ message: 'User status updated successfully.', user });
  } catch (error: any) {
    console.error('UpdateUserStatus Error:', error);
    return res.status(500).json({ error: 'Failed to update user status.' });
  }
};

export const archiveUser = async (req: AuthenticatedRequest, res: Response) => {
  try {
    const { id } = req.params;

    const user = await prisma.user.update({
      where: { id },
      data: { isArchived: true },
      select: {
        id: true,
        name: true,
        email: true,
        role: true,
        isActive: true,
        isArchived: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    return res.status(200).json({ message: 'User archived successfully.', user });
  } catch (error: any) {
    console.error('ArchiveUser Error:', error);
    return res.status(500).json({ error: 'Failed to archive user.' });
  }
};

export const updateUserRole = async (req: AuthenticatedRequest, res: Response) => {
  try {
    const { id } = req.params;
    const { role } = req.body;

    if (!role || !['user', 'admin'].includes(role)) {
      return res.status(400).json({ error: 'Role must be user or admin.' });
    }

    const user = await prisma.user.update({
      where: { id },
      data: { role },
      select: {
        id: true,
        name: true,
        email: true,
        role: true,
        isActive: true,
        isArchived: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    return res.status(200).json({ message: 'User role updated successfully.', user });
  } catch (error: any) {
    console.error('UpdateUserRole Error:', error);
    return res.status(500).json({ error: 'Failed to update user role.' });
  }
};

