-- =====================================================================
-- 02_indexes.sql
-- Indexing strategy for query optimization
-- =====================================================================

-- Drop existing indexes (ignore errors)
BEGIN EXECUTE IMMEDIATE 'DROP INDEX idx_farmer_district';      EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP INDEX idx_crop_season';          EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP INDEX idx_cycle_farmer';         EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP INDEX idx_cycle_crop_season';    EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP INDEX idx_cycle_sowing_date';    EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP INDEX idx_water_cycle_date';     EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP INDEX idx_fu_cycle_date';        EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP INDEX idx_yield_harvest_date';   EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- Single-column indexes on frequently filtered columns
CREATE INDEX idx_farmer_district    ON farmers(district);
CREATE INDEX idx_crop_season        ON crops(season_id);
CREATE INDEX idx_cycle_farmer       ON crop_cycles(farmer_id);
CREATE INDEX idx_cycle_sowing_date  ON crop_cycles(sowing_date);
CREATE INDEX idx_yield_harvest_date ON yield_records(harvest_date);

-- Composite indexes for multi-column joins / filters
CREATE INDEX idx_cycle_crop_season  ON crop_cycles(crop_id, season_id);
CREATE INDEX idx_water_cycle_date   ON water_usage(cycle_id, usage_date);
CREATE INDEX idx_fu_cycle_date      ON fertilizer_usage(cycle_id, application_date);

PROMPT Indexes created successfully.
