-- Airports reference table
CREATE TABLE IF NOT EXISTS airports (
    iata_code VARCHAR(3) PRIMARY KEY,
    icao_code VARCHAR(4),
    name VARCHAR(255) NOT NULL,
    city VARCHAR(255) NOT NULL,
    country VARCHAR(255) NOT NULL,
    latitude DECIMAL(10, 6),
    longitude DECIMAL(10, 6),
    timezone VARCHAR(50)
);

-- Airlines reference table
CREATE TABLE IF NOT EXISTS airlines (
    iata_code VARCHAR(2) PRIMARY KEY,
    icao_code VARCHAR(3),
    name VARCHAR(255) NOT NULL,
    country VARCHAR(255),
    logo_url TEXT,
    is_active BOOLEAN DEFAULT true
);

-- Seed popular Indian airports
INSERT INTO airports (iata_code, icao_code, name, city, country, latitude, longitude, timezone) VALUES
    ('DEL', 'VIDP', 'Indira Gandhi International Airport', 'New Delhi', 'India', 28.5562, 77.1000, 'Asia/Kolkata'),
    ('BOM', 'VABB', 'Chhatrapati Shivaji Maharaj International Airport', 'Mumbai', 'India', 19.0896, 72.8656, 'Asia/Kolkata'),
    ('BLR', 'VOBL', 'Kempegowda International Airport', 'Bangalore', 'India', 13.1986, 77.7066, 'Asia/Kolkata'),
    ('MAA', 'VOMM', 'Chennai International Airport', 'Chennai', 'India', 12.9941, 80.1709, 'Asia/Kolkata'),
    ('HYD', 'VOHS', 'Rajiv Gandhi International Airport', 'Hyderabad', 'India', 17.2403, 78.4294, 'Asia/Kolkata'),
    ('CCU', 'VECC', 'Netaji Subhas Chandra Bose International Airport', 'Kolkata', 'India', 22.6547, 88.4467, 'Asia/Kolkata'),
    ('GOI', 'VOGO', 'Goa International Airport', 'Goa', 'India', 15.3808, 73.8314, 'Asia/Kolkata'),
    ('COK', 'VOCI', 'Cochin International Airport', 'Kochi', 'India', 10.1520, 76.4019, 'Asia/Kolkata'),
    ('PNQ', 'VAPO', 'Pune Airport', 'Pune', 'India', 18.5822, 73.9197, 'Asia/Kolkata'),
    ('AMD', 'VAAH', 'Sardar Vallabhbhai Patel International Airport', 'Ahmedabad', 'India', 23.0772, 72.6347, 'Asia/Kolkata'),
    ('DXB', 'OMDB', 'Dubai International Airport', 'Dubai', 'UAE', 25.2532, 55.3657, 'Asia/Dubai'),
    ('SIN', 'WSSS', 'Singapore Changi Airport', 'Singapore', 'Singapore', 1.3644, 103.9915, 'Asia/Singapore'),
    ('LHR', 'EGLL', 'Heathrow Airport', 'London', 'United Kingdom', 51.4700, -0.4543, 'Europe/London'),
    ('JFK', 'KJFK', 'John F. Kennedy International Airport', 'New York', 'United States', 40.6413, -73.7781, 'America/New_York'),
    ('SFO', 'KSFO', 'San Francisco International Airport', 'San Francisco', 'United States', 37.6213, -122.3790, 'America/Los_Angeles')
ON CONFLICT (iata_code) DO NOTHING;

-- Seed popular airlines
INSERT INTO airlines (iata_code, icao_code, name, country, is_active) VALUES
    ('AI', 'AIC', 'Air India', 'India', true),
    ('6E', 'IGO', 'IndiGo', 'India', true),
    ('UK', 'VTI', 'Vistara', 'India', true),
    ('SG', 'SEJ', 'SpiceJet', 'India', true),
    ('G8', 'GOW', 'Go First', 'India', true),
    ('QP', 'AKJ', 'Akasa Air', 'India', true),
    ('EK', 'UAE', 'Emirates', 'UAE', true),
    ('SQ', 'SIA', 'Singapore Airlines', 'Singapore', true),
    ('BA', 'BAW', 'British Airways', 'United Kingdom', true),
    ('LH', 'DLH', 'Lufthansa', 'Germany', true)
ON CONFLICT (iata_code) DO NOTHING;
