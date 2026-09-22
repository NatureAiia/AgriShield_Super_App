-- AgriShield — prototype database schema (PostgreSQL + PostGIS)
--
-- Saved as pasted during planning, as a starting-point schema sketch, not a
-- reviewed/migrated production schema. See /docs/roadmap for which tables
-- belong to which build version:
--   farmers, farm_plots, crop_scans        -> V1 (foundation) / V2
--   insurance_policies, bnpl_loans          -> V3 only, and only once a real
--                                             underwriter / lender partner
--                                             is confirmed (see V3 roadmap doc)
--
-- NOTE: farmers.agrishield_credit_score is named here as a "credit score"
-- but per the roadmap it starts as a transparent, explainable RELIABILITY
-- score built from V1/V2 telemetry (storage conditions, disease-checker
-- usage, satellite field health, weather/planting adherence) — it is not
-- a certified financial credit score unless/until a credit bureau or
-- lender partner validates it. Rename or split this column before it is
-- exposed as an actual lending input.

-- 1. Farmers Table
CREATE TABLE farmers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20) UNIQUE NOT NULL,
    national_id VARCHAR(30) UNIQUE,
    agrishield_credit_score INT DEFAULT 650,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. Farm Plots (GeoSpatial Polygon via PostGIS)
CREATE TABLE farm_plots (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    farmer_id UUID REFERENCES farmers(id) ON DELETE CASCADE,
    plot_name VARCHAR(50),
    area_hectares NUMERIC(5,2) NOT NULL,
    primary_crop VARCHAR(50) NOT NULL,
    boundary_polygon GEOMETRY(Polygon, 4326),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. AI Crop Diagnostics
CREATE TABLE crop_scans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    plot_id UUID REFERENCES farm_plots(id),
    image_url TEXT NOT NULL,
    detected_disease VARCHAR(100),
    confidence_score NUMERIC(5,2),
    recommended_input_id UUID,
    scanned_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. Parametric Insurance Policies & Automated Payout Triggers
CREATE TABLE insurance_policies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    plot_id UUID REFERENCES farm_plots(id),
    policy_type VARCHAR(50) DEFAULT 'Drought_And_Moisture_Index',
    sum_insured NUMERIC(10,2) NOT NULL,
    rainfall_trigger_threshold_mm NUMERIC(6,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'ACTIVE', -- ACTIVE, TRIGGERED, PAID_OUT
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 5. Agrifinance & BNPL Input Credit
CREATE TABLE bnpl_loans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    farmer_id UUID REFERENCES farmers(id),
    loan_amount NUMERIC(10,2) NOT NULL,
    interest_rate NUMERIC(4,2) DEFAULT 5.00,
    due_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'DISBURSED', -- DISBURSED, REPAID, DEFAULTED
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
