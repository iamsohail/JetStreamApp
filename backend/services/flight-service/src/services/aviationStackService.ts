import axios from 'axios';

export class AviationStackService {
  private baseUrl = 'http://api.aviationstack.com/v1';

  async getFlightStatus(flightIata: string) {
    const apiKey = process.env.AVIATIONSTACK_API_KEY;
    if (!apiKey) {
      throw new Error('AviationStack API key not configured');
    }

    const response = await axios.get(`${this.baseUrl}/flights`, {
      params: {
        access_key: apiKey,
        flight_iata: flightIata,
      },
    });

    const flights = response.data.data;
    if (!flights || flights.length === 0) {
      throw new Error(`No status found for flight ${flightIata}`);
    }

    const flight = flights[0];
    return {
      status: flight.flight_status,
      actualDeparture: flight.departure?.actual,
      actualArrival: flight.arrival?.actual,
      departureGate: flight.departure?.gate,
      arrivalGate: flight.arrival?.gate,
      departureTerminal: flight.departure?.terminal,
      arrivalTerminal: flight.arrival?.terminal,
      delayMinutes: flight.departure?.delay || 0,
    };
  }

  async searchByFlightNumber(flightIata: string, date?: string) {
    const apiKey = process.env.AVIATIONSTACK_API_KEY;
    if (!apiKey) {
      throw new Error('AviationStack API key not configured');
    }

    const params: any = {
      access_key: apiKey,
      flight_iata: flightIata,
    };
    if (date) {
      params.flight_date = date;
    }

    const response = await axios.get(`${this.baseUrl}/flights`, { params });

    const flights = response.data.data;
    if (!flights || flights.length === 0) {
      throw new Error(`No flights found for ${flightIata}`);
    }

    return flights.map((f: any) => ({
      flight_number: f.flight?.iata || flightIata,
      airline_code: f.airline?.iata || '',
      airline_name: f.airline?.name || '',
      departure_airport: f.departure?.iata || '',
      departure_airport_name: f.departure?.airport || '',
      departure_city: f.departure?.timezone?.split('/')[1]?.replace('_', ' ') || '',
      arrival_airport: f.arrival?.iata || '',
      arrival_airport_name: f.arrival?.airport || '',
      arrival_city: f.arrival?.timezone?.split('/')[1]?.replace('_', ' ') || '',
      scheduled_departure: f.departure?.scheduled,
      scheduled_arrival: f.arrival?.scheduled,
      actual_departure: f.departure?.actual,
      actual_arrival: f.arrival?.actual,
      status: f.flight_status || 'scheduled',
      departure_terminal: f.departure?.terminal,
      arrival_terminal: f.arrival?.terminal,
      departure_gate: f.departure?.gate,
      arrival_gate: f.arrival?.gate,
    }));
  }
}
