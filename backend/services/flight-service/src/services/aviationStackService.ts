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
}
