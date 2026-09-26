-- ==========================================
-- AgriShield MVP Supabase Setup Script
-- ==========================================

-- 1. CLEANUP
DROP TABLE IF EXISTS crop_scans CASCADE;
DROP TABLE IF EXISTS storage_readings CASCADE;
DROP TABLE IF EXISTS farmers CASCADE;

-- 2. TABLES SETUP

-- FARMERS: The core record
CREATE TABLE farmers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    location TEXT,
    crop TEXT,
    storage_hub TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- STORAGE READINGS: Sensor telemetry
CREATE TABLE storage_readings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    farmer_id UUID REFERENCES farmers(id) ON DELETE CASCADE,
    temperature_c FLOAT NOT NULL,
    humidity_percent FLOAT NOT NULL,
    co2_ppm FLOAT DEFAULT 420.0,
    taken_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- CROP SCANS: AI diagnosis results
CREATE TABLE crop_scans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    farmer_id UUID REFERENCES farmers(id) ON DELETE CASCADE,
    likely_issue TEXT NOT NULL,
    confidence FLOAT NOT NULL,
    source TEXT DEFAULT 'on_device', -- 'on_device' or 'server'
    scanned_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. SECURITY & PERMISSIONS (For MVP Demo)
ALTER TABLE farmers DISABLE ROW LEVEL SECURITY;
ALTER TABLE storage_readings DISABLE ROW LEVEL SECURITY;
ALTER TABLE crop_scans DISABLE ROW LEVEL SECURITY;

GRANT ALL ON TABLE farmers TO anon;
GRANT ALL ON TABLE farmers TO authenticated;
GRANT ALL ON TABLE farmers TO service_role;

GRANT ALL ON TABLE storage_readings TO anon;
GRANT ALL ON TABLE storage_readings TO authenticated;
GRANT ALL ON TABLE storage_readings TO service_role;

GRANT ALL ON TABLE crop_scans TO anon;
GRANT ALL ON TABLE crop_scans TO authenticated;
GRANT ALL ON TABLE crop_scans TO service_role;
