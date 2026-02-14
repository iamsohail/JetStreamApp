import { query } from '../../../../shared/database/connection';
import { AmadeusService } from './amadeusService';
import { AviationStackService } from './aviationStackService';

const amadeusService = new AmadeusService();
const aviationStackService = new AviationStackService();

export class FlightService {
  async lookupPNR(pnr: string) {
    // Try Amadeus first for PNR details
    try {
      return await amadeusService.lookupPNR(pnr);
    } catch {
      throw new Error(`Could not find flight for PNR: ${pnr}`);
    }
  }

  async getUserFlights(userId: string, page: number, limit: number) {
    const offset = (page - 1) * limit;
    const [flightsResult, countResult] = await Promise.all([
      query(
        'SELECT * FROM flights WHERE user_id = $1 ORDER BY scheduled_departure DESC LIMIT $2 OFFSET $3',
        [userId, limit, offset]
      ),
      query('SELECT COUNT(*) FROM flights WHERE user_id = $1', [userId]),
    ]);

    return {
      flights: flightsResult.rows,
      total: parseInt(countResult.rows[0].count),
    };
  }

  async getFlightById(id: string, userId: string) {
    const result = await query(
      'SELECT * FROM flights WHERE id = $1 AND user_id = $2',
      [id, userId]
    );
    return result.rows[0] || null;
  }

  async createFlight(userId: string, data: any) {
    const result = await query(
      `INSERT INTO flights (user_id, pnr, flight_number, airline_code, airline_name,
        departure_airport, departure_city, arrival_airport, arrival_city,
        scheduled_departure, scheduled_arrival, actual_departure, actual_arrival,
        status, aircraft_type, seat_number, cabin_class, booking_reference,
        distance_km, duration_minutes, departure_terminal, arrival_terminal,
        departure_gate, arrival_gate, notes, is_manual_entry)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23, $24, $25, $26)
       RETURNING *`,
      [
        userId, data.pnr, data.flight_number, data.airline_code, data.airline_name,
        data.departure_airport, data.departure_city, data.arrival_airport, data.arrival_city,
        data.scheduled_departure, data.scheduled_arrival, data.actual_departure || null, data.actual_arrival || null,
        data.status || 'scheduled', data.aircraft_type || null, data.seat_number || null,
        data.cabin_class || 'economy', data.booking_reference || null,
        data.distance_km || null, data.duration_minutes || null,
        data.departure_terminal || null, data.arrival_terminal || null,
        data.departure_gate || null, data.arrival_gate || null,
        data.notes || null, data.is_manual_entry || false,
      ]
    );
    return result.rows[0];
  }

  async updateFlight(id: string, userId: string, data: any) {
    const fields: string[] = [];
    const values: any[] = [];
    let paramIndex = 1;

    const allowedFields = [
      'seat_number', 'cabin_class', 'notes', 'status',
      'actual_departure', 'actual_arrival', 'departure_gate', 'arrival_gate',
      'departure_terminal', 'arrival_terminal', 'booking_reference',
    ];

    for (const field of allowedFields) {
      if (data[field] !== undefined) {
        fields.push(`${field} = $${paramIndex++}`);
        values.push(data[field]);
      }
    }

    if (fields.length === 0) {
      return this.getFlightById(id, userId);
    }

    values.push(id, userId);
    const result = await query(
      `UPDATE flights SET ${fields.join(', ')} WHERE id = $${paramIndex++} AND user_id = $${paramIndex} RETURNING *`,
      values
    );
    return result.rows[0];
  }

  async deleteFlight(id: string, userId: string) {
    await query('DELETE FROM flights WHERE id = $1 AND user_id = $2', [id, userId]);
  }

  async getFlightStatus(id: string) {
    const result = await query('SELECT flight_number, airline_code FROM flights WHERE id = $1', [id]);
    if (!result.rows[0]) throw new Error('Flight not found');

    const { flight_number, airline_code } = result.rows[0];
    try {
      return await aviationStackService.getFlightStatus(flight_number);
    } catch {
      return { status: 'unknown', message: 'Could not fetch live status' };
    }
  }

  async searchAirports(q: string) {
    const result = await query(
      `SELECT * FROM airports WHERE
       iata_code ILIKE $1 OR name ILIKE $2 OR city ILIKE $2
       ORDER BY city LIMIT 10`,
      [q, `%${q}%`]
    );
    return result.rows;
  }

  async searchAirlines(q: string) {
    const result = await query(
      `SELECT * FROM airlines WHERE
       iata_code ILIKE $1 OR name ILIKE $2
       ORDER BY name LIMIT 10`,
      [q, `%${q}%`]
    );
    return result.rows;
  }
}
