"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const dotenv_1 = __importDefault(require("dotenv"));
const auth_routes_1 = __importDefault(require("./routes/auth.routes"));
const incident_routes_1 = __importDefault(require("./routes/incident.routes"));
const meta_routes_1 = __importDefault(require("./routes/meta.routes"));
const error_middleware_1 = require("./middleware/error.middleware");
dotenv_1.default.config();
const app = (0, express_1.default)();
const PORT = process.env.PORT || 5000;
// Middleware
app.use((0, cors_1.default)());
app.use(express_1.default.json());
// Healthcheck Route
app.get('/api/health', (req, res) => {
    res.status(200).json({ status: 'OK', message: 'ResQ Backend API is operational' });
});
// API Routes
app.use('/api/v1/auth', auth_routes_1.default);
app.use('/api/v1/incidents', incident_routes_1.default);
app.use('/api/v1/meta', meta_routes_1.default);
// Global Error Handler
app.use(error_middleware_1.errorHandler);
// Start Server
app.listen(PORT, () => {
    console.log(`=================================`);
    console.log(`🚀 ResQ Backend running on port ${PORT}`);
    console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
    console.log(`=================================`);
});
