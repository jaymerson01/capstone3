import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import authRoutes from './routes/auth.routes';
import incidentRoutes from './routes/incident.routes';
import metaRoutes from './routes/meta.routes';
import notificationRoutes from './routes/notification.routes';
import { errorHandler } from './middleware/error.middleware';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());

// Healthcheck Route
app.get('/api/health', (req, res) => {
  res.status(200).json({ status: 'OK', message: 'ResQ Backend API is operational' });
});

// API Routes
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/incidents', incidentRoutes);
app.use('/api/v1/meta', metaRoutes);
app.use('/api/v1/notifications', notificationRoutes);


// Global Error Handler
app.use(errorHandler);

// Start Server
app.listen(PORT, () => {
  console.log(`=================================`);
  console.log(`🚀 ResQ Backend running on port ${PORT}`);
  console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`=================================`);
});
