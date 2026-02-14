import { Router } from 'express';
import { body } from 'express-validator';
import { flightController } from '../controllers/flightController';
import { authenticate } from '../middleware/auth';

const router = Router();

// Reference (no auth required, must be before /:id)
router.get('/airports/search', flightController.searchAirports.bind(flightController));
router.get('/airlines/search', flightController.searchAirlines.bind(flightController));

// Flight number search
router.post('/search-by-number', authenticate, flightController.searchByFlightNumber.bind(flightController));

// CRUD
router.get('/', authenticate, flightController.listFlights.bind(flightController));
router.post('/', authenticate, [
  body('flight_number').notEmpty(),
  body('airline_code').notEmpty(),
  body('airline_name').notEmpty(),
  body('departure_airport').notEmpty(),
  body('arrival_airport').notEmpty(),
  body('scheduled_departure').notEmpty(),
  body('scheduled_arrival').notEmpty(),
], flightController.createFlight.bind(flightController));

router.get('/:id', authenticate, flightController.getFlightDetail.bind(flightController));
router.put('/:id', authenticate, flightController.updateFlight.bind(flightController));
router.delete('/:id', authenticate, flightController.deleteFlight.bind(flightController));

// Status
router.get('/:id/status', authenticate, flightController.getFlightStatus.bind(flightController));

export { router as flightRoutes };
