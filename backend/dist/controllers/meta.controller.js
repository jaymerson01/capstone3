"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getAreas = exports.getCategories = void 0;
const db_1 = __importDefault(require("../config/db"));
const getCategories = async (req, res) => {
    try {
        let categories = await db_1.default.category.findMany({
            where: { isArchived: false },
        });
        if (categories.length === 0) {
            // Seed defaults if empty
            await db_1.default.category.createMany({
                data: [
                    { name: 'Theft', description: 'Stealing of personal property' },
                    { name: 'Accident', description: 'Road vehicular collisions' },
                    { name: 'Fire', description: 'Fires' },
                    { name: 'Violence', description: 'Fights, physical assault' },
                    { name: 'Suspicious Activity', description: 'Unidentified loitering' },
                ],
                skipDuplicates: true,
            });
            categories = await db_1.default.category.findMany({ where: { isArchived: false } });
        }
        return res.status(200).json({ categories });
    }
    catch (error) {
        console.error('GetCategories Error:', error);
        return res.status(500).json({ error: 'Failed to fetch categories.' });
    }
};
exports.getCategories = getCategories;
const getAreas = async (req, res) => {
    try {
        let areas = await db_1.default.area.findMany({
            where: { isArchived: false },
        });
        if (areas.length === 0) {
            // Seed defaults if empty
            await db_1.default.area.createMany({
                data: [
                    { name: 'Area 1', incidentsCount: 0 },
                    { name: 'Area 2', incidentsCount: 0 },
                    { name: 'Area 3', incidentsCount: 0 },
                    { name: 'Area 4', incidentsCount: 0 },
                    { name: 'Area 5', incidentsCount: 0 },
                ],
                skipDuplicates: true,
            });
            areas = await db_1.default.area.findMany({ where: { isArchived: false } });
        }
        return res.status(200).json({ areas });
    }
    catch (error) {
        console.error('GetAreas Error:', error);
        return res.status(500).json({ error: 'Failed to fetch areas.' });
    }
};
exports.getAreas = getAreas;
