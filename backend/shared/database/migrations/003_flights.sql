-- Flights table (user flight records)
CREATE TABLE IF NOT EXISTS flights (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    pnr VARCHAR(20),
    flight_number VARCHAR(10) NOT NULL,
    airline_code VARCHAR(2) NOT NULL,
    airline_name VARCHAR(255) NOT NULL,
    departure_airport VARCHAR(3) NOT NULL,
    departure_city VARCHAR(255),
    arrival_airport VARCHAR(3) NOT NULL,
    arrival_city VARCHAR(255),
    scheduled_departure TIMESTAMPTZ NOT NULL,
    scheduled_arrival TIMESTAMPTZ NOT NULL,
    actual_departure TIMESTAMPTZ,
    actual_arrival TIMESTAMPTZ,
    status VARCHAR(20) DEFAULT 'scheduled',
    aircraft_type VARCHAR(50),
    seat_number VARCHAR(10),
    cabin_class VARCHAR(20) DEFAULT 'economy',
    booking_reference VARCHAR(50),
    distance_km DECIMAL(10, 2),
    duration_minutes INT,
    departure_terminal VARCHAR(10),
    arrival_terminal VARCHAR(10),
    departure_gate VARCHAR(10),
    arrival_gate VARCHAR(10),
    notes TEXT,
    is_manual_entry BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_flights_user_id ON flights(user_id);
CREATE INDEX idx_flights_pnr ON flights(pnr);
CREATE INDEX idx_flights_departure ON flights(scheduled_departure);

CREATE TRIGGER update_flights_updated_at
    BEFORE UPDATE ON flights
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();
