-- Fix ride_requests table schema
-- This script handles the column name mismatch

-- First, check if the table exists and drop it if needed
DROP TABLE IF EXISTS ride_requests CASCADE;

-- Create the correct ride_requests table
CREATE TABLE ride_requests (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    ride_id UUID NOT NULL REFERENCES rides(id) ON DELETE CASCADE,
    seat_numbers TEXT[] NOT NULL, -- Array of seat numbers requested
    requested_by UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected')),
    message TEXT, -- Optional message from passenger
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_ride_requests_ride_id ON ride_requests(ride_id);
CREATE INDEX IF NOT EXISTS idx_ride_requests_requested_by ON ride_requests(requested_by);
CREATE INDEX IF NOT EXISTS idx_ride_requests_status ON ride_requests(status);

-- Enable Row Level Security (RLS)
ALTER TABLE ride_requests ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view ride requests" ON ride_requests;
DROP POLICY IF EXISTS "Users can create ride requests" ON ride_requests;
DROP POLICY IF EXISTS "Ride owners can update request status" ON ride_requests;
DROP POLICY IF EXISTS "Users can delete own pending requests" ON ride_requests;

-- RLS Policies for ride_requests

-- Policy: Users can view their own requests and requests for rides they own
CREATE POLICY "Users can view ride requests" ON ride_requests
    FOR SELECT
    USING (
        requested_by = auth.uid() OR
        EXISTS (
            SELECT 1 FROM rides
            WHERE rides.id = ride_requests.ride_id
            AND rides.car_guy_id = auth.uid()
        )
    );

-- Policy: Users can create ride requests for active rides (not their own)
CREATE POLICY "Users can create ride requests" ON ride_requests
    FOR INSERT
    WITH CHECK (
        requested_by = auth.uid() AND
        EXISTS (
            SELECT 1 FROM rides
            WHERE rides.id = ride_requests.ride_id
            AND rides.status = 'active'
            AND rides.car_guy_id != auth.uid()
        )
    );

-- Policy: Only ride owners can update request status
CREATE POLICY "Ride owners can update request status" ON ride_requests
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM rides
            WHERE rides.id = ride_requests.ride_id
            AND rides.car_guy_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM rides
            WHERE rides.id = ride_requests.ride_id
            AND rides.car_guy_id = auth.uid()
        )
    );

-- Policy: Users can delete their own pending requests
CREATE POLICY "Users can delete own pending requests" ON ride_requests
    FOR DELETE
    USING (
        requested_by = auth.uid() AND
        status = 'pending'
    );

-- Drop existing functions if they exist
DROP FUNCTION IF EXISTS update_ride_requests_updated_at() CASCADE;
DROP FUNCTION IF EXISTS check_seat_availability() CASCADE;

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_ride_requests_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-update updated_at field
CREATE TRIGGER update_ride_requests_updated_at_trigger
    BEFORE UPDATE ON ride_requests
    FOR EACH ROW
    EXECUTE FUNCTION update_ride_requests_updated_at();

-- Function to check if seats are available before accepting request
CREATE OR REPLACE FUNCTION check_seat_availability()
RETURNS TRIGGER AS $$
DECLARE
    seat_num TEXT;
    current_seats JSONB;
BEGIN
    -- Only check when status changes to 'accepted'
    IF NEW.status = 'accepted' AND OLD.status != 'accepted' THEN
        -- Get current seats from rides table
        SELECT seats INTO current_seats
        FROM rides
        WHERE id = NEW.ride_id;

        -- Check if any requested seat is already booked
        FOREACH seat_num IN ARRAY NEW.seat_numbers
        LOOP
            IF (current_seats->seat_num->>'isBooked')::boolean = true THEN
                RAISE EXCEPTION 'Seat % is already booked', seat_num;
            END IF;
        END LOOP;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to prevent accepting requests for already booked seats
CREATE TRIGGER check_seat_availability_trigger
    BEFORE UPDATE ON ride_requests
    FOR EACH ROW
    EXECUTE FUNCTION check_seat_availability();

-- Example usage and test data
-- INSERT INTO ride_requests (ride_id, seat_numbers, requested_by, message)
-- VALUES ('your-ride-id', ARRAY['1', '2'], 'your-user-id', 'Looking forward to the ride!');