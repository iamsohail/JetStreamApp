import { query } from '../../../../shared/database/connection';

export class AnalyticsService {
  async getSummary(userId: string) {
    const result = await query(
      `SELECT
        COUNT(*) as total_flights,
        COALESCE(SUM(distance_km), 0) as total_distance_km,
        COALESCE(SUM(duration_minutes), 0) as total_minutes,
        COUNT(DISTINCT departure_airport) + COUNT(DISTINCT arrival_airport) as unique_airports,
        COUNT(DISTINCT airline_code) as unique_airlines
       FROM flights WHERE user_id = $1`,
      [userId]
    );
    return result.rows[0];
  }

  async getAirlineBreakdown(userId: string) {
    const result = await query(
      `SELECT airline_name, airline_code, COUNT(*) as flight_count,
        COALESCE(SUM(distance_km), 0) as total_distance
       FROM flights WHERE user_id = $1
       GROUP BY airline_name, airline_code
       ORDER BY flight_count DESC`,
      [userId]
    );
    return result.rows;
  }

  async getAirportStats(userId: string) {
    const result = await query(
      `SELECT airport, city, COUNT(*) as visit_count FROM (
        SELECT departure_airport as airport, departure_city as city FROM flights WHERE user_id = $1
        UNION ALL
        SELECT arrival_airport as airport, arrival_city as city FROM flights WHERE user_id = $1
       ) airports
       GROUP BY airport, city
       ORDER BY visit_count DESC
       LIMIT 20`,
      [userId]
    );
    return result.rows;
  }

  async getTrends(userId: string) {
    const result = await query(
      `SELECT
        TO_CHAR(scheduled_departure, 'YYYY-MM') as month,
        COUNT(*) as flight_count
       FROM flights WHERE user_id = $1
       GROUP BY month
       ORDER BY month DESC
       LIMIT 12`,
      [userId]
    );
    return result.rows;
  }

  async getRecords(userId: string) {
    const [longest, shortest, mostFlown] = await Promise.all([
      query(
        `SELECT flight_number, airline_name, departure_airport, arrival_airport, distance_km
         FROM flights WHERE user_id = $1 AND distance_km IS NOT NULL
         ORDER BY distance_km DESC LIMIT 1`,
        [userId]
      ),
      query(
        `SELECT flight_number, airline_name, departure_airport, arrival_airport, distance_km
         FROM flights WHERE user_id = $1 AND distance_km IS NOT NULL AND distance_km > 0
         ORDER BY distance_km ASC LIMIT 1`,
        [userId]
      ),
      query(
        `SELECT departure_airport || ' → ' || arrival_airport as route, COUNT(*) as count
         FROM flights WHERE user_id = $1
         GROUP BY route ORDER BY count DESC LIMIT 1`,
        [userId]
      ),
    ]);

    return {
      longestFlight: longest.rows[0] || null,
      shortestFlight: shortest.rows[0] || null,
      mostFlownRoute: mostFlown.rows[0] || null,
    };
  }
}
