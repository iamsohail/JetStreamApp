import axios from 'axios';

export class AmadeusService {
  private baseUrl = 'https://test.api.amadeus.com';
  private accessToken: string | null = null;
  private tokenExpiry: number = 0;

  private async getAccessToken(): Promise<string> {
    if (this.accessToken && Date.now() < this.tokenExpiry) {
      return this.accessToken;
    }

    const apiKey = process.env.AMADEUS_API_KEY;
    const apiSecret = process.env.AMADEUS_API_SECRET;

    if (!apiKey || !apiSecret) {
      throw new Error('Amadeus API credentials not configured');
    }

    const response = await axios.post(
      `${this.baseUrl}/v1/security/oauth2/token`,
      new URLSearchParams({
        grant_type: 'client_credentials',
        client_id: apiKey,
        client_secret: apiSecret,
      }),
      { headers: { 'Content-Type': 'application/x-www-form-urlencoded' } }
    );

    this.accessToken = response.data.access_token;
    this.tokenExpiry = Date.now() + (response.data.expires_in - 60) * 1000;
    return this.accessToken!;
  }

  async lookupPNR(pnr: string) {
    const token = await this.getAccessToken();

    // Note: Amadeus Self-Service doesn't have direct PNR lookup.
    // In production, use Amadeus Enterprise API or a GDS.
    // For now, return a placeholder that the frontend can handle.
    throw new Error('PNR lookup requires Amadeus Enterprise API access');
  }

  async searchFlights(origin: string, destination: string, date: string) {
    const token = await this.getAccessToken();

    const response = await axios.get(
      `${this.baseUrl}/v2/shopping/flight-offers`,
      {
        params: {
          originLocationCode: origin,
          destinationLocationCode: destination,
          departureDate: date,
          adults: 1,
          max: 5,
        },
        headers: { Authorization: `Bearer ${token}` },
      }
    );

    return response.data.data;
  }

  async searchAirports(keyword: string) {
    const token = await this.getAccessToken();

    const response = await axios.get(
      `${this.baseUrl}/v1/reference-data/locations`,
      {
        params: {
          subType: 'AIRPORT',
          keyword,
          'page[limit]': 10,
        },
        headers: { Authorization: `Bearer ${token}` },
      }
    );

    return response.data.data;
  }
}
