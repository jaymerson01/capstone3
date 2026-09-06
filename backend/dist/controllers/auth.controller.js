"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getCurrentUser = exports.login = exports.signUp = void 0;
const bcryptjs_1 = __importDefault(require("bcryptjs"));
const db_1 = __importDefault(require("../config/db"));
const jwt_utils_1 = require("../utils/jwt.utils");
const signUp = async (req, res) => {
    try {
        const { name, email, password, role } = req.body;
        if (!name || !email || !password) {
            return res.status(400).json({ error: 'Name, email, and password are required.' });
        }
        const normalizedEmail = email.toLowerCase().trim();
        // Check existing user
        const existingUser = await db_1.default.user.findUnique({
            where: { email: normalizedEmail },
        });
        if (existingUser) {
            return res.status(409).json({ error: 'Email is already registered.' });
        }
        // Hash password securely
        const hashedPassword = await bcryptjs_1.default.hash(password, 10);
        const user = await db_1.default.user.create({
            data: {
                name,
                email: normalizedEmail,
                password: hashedPassword,
                role: 'user', // Public signup strictly forces 'user' / resident role
            },
        });
        const token = (0, jwt_utils_1.generateToken)({
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
    }
    catch (error) {
        console.error('SignUp Error:', error);
        return res.status(500).json({ error: 'Failed to sign up user.' });
    }
};
exports.signUp = signUp;
const login = async (req, res) => {
    try {
        const { email, password } = req.body;
        if (!email || !password) {
            return res.status(400).json({ error: 'Email and password are required.' });
        }
        const normalizedEmail = email.toLowerCase().trim();
        const user = await db_1.default.user.findUnique({
            where: { email: normalizedEmail },
        });
        if (!user || user.isArchived) {
            return res.status(401).json({ error: 'Invalid email or password.' });
        }
        if (!user.isActive) {
            return res.status(403).json({ error: 'Account is deactivated.' });
        }
        const isMatch = await bcryptjs_1.default.compare(password, user.password);
        if (!isMatch) {
            return res.status(401).json({ error: 'Invalid email or password.' });
        }
        const token = (0, jwt_utils_1.generateToken)({
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
    }
    catch (error) {
        console.error('Login Error:', error);
        return res.status(500).json({ error: 'Failed to log in.' });
    }
};
exports.login = login;
const getCurrentUser = async (req, res) => {
    try {
        if (!req.user) {
            return res.status(401).json({ error: 'Unauthenticated' });
        }
        const user = await db_1.default.user.findUnique({
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
    }
    catch (error) {
        console.error('GetCurrentUser Error:', error);
        return res.status(500).json({ error: 'Failed to retrieve current user.' });
    }
};
exports.getCurrentUser = getCurrentUser;
