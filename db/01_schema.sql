-- =====================================================================
-- 01_schema.sql
-- Farmer Crop & Resource Optimization Database
-- Schema: Tables, Sequences, Constraints (Oracle PL/SQL)
-- Normalized to 3NF / BCNF
-- =====================================================================

-- Drop in dependency-safe order (ignore errors on first run)
BEGIN EXECUTE IMMEDIATE 'DROP TABLE audit_log         CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE yield_records     CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE fertilizer_usage  CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE water_usage       CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE crop_cycles       CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE fertilizers       CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE crops             CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE farmers           CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE seasons           CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_farmer';      EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_crop';        EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_fertilizer';  EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_cycle';       EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_water';       EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_fert_use';    EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_yield';       EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_audit';       EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- =====================================================================
-- SEQUENCES (surrogate primary keys)
-- =====================================================================
CREATE SEQUENCE seq_farmer     START WITH 1001 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_crop       START WITH 101  INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_fertilizer START WITH 201  INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_cycle      START WITH 5001 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_water      START WITH 1    INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_fert_use   START WITH 1    INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_yield      START WITH 1    INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_audit      START WITH 1    INCREMENT BY 1 NOCACHE;

-- =====================================================================
-- TABLE: seasons
-- =====================================================================
CREATE TABLE seasons (
    season_id     NUMBER(3)      PRIMARY KEY,
    season_name   VARCHAR2(20)   NOT NULL UNIQUE,
    start_month   NUMBER(2)      NOT NULL,
    end_month     NUMBER(2)      NOT NULL,
    description   VARCHAR2(200),
    CONSTRAINT chk_season_start_month CHECK (start_month BETWEEN 1 AND 12),
    CONSTRAINT chk_season_end_month   CHECK (end_month   BETWEEN 1 AND 12)
);

-- =====================================================================
-- TABLE: farmers
-- =====================================================================
CREATE TABLE farmers (
    farmer_id        NUMBER(6)       PRIMARY KEY,
    name             VARCHAR2(80)    NOT NULL,
    contact_number   VARCHAR2(15)    NOT NULL UNIQUE,
    village          VARCHAR2(60)    NOT NULL,
    district         VARCHAR2(60)    NOT NULL,
    state            VARCHAR2(60)    NOT NULL,
    total_land_acres NUMBER(8,2)     NOT NULL,
    soil_type        VARCHAR2(30),
    has_irrigation   CHAR(1)         DEFAULT 'N',
    registered_on    DATE            DEFAULT SYSDATE,
    CONSTRAINT chk_land_positive CHECK (total_land_acres > 0),
    CONSTRAINT chk_irrigation    CHECK (has_irrigation IN ('Y','N'))
);

-- =====================================================================
-- TABLE: crops
-- =====================================================================
CREATE TABLE crops (
    crop_id              NUMBER(5)     PRIMARY KEY,
    crop_name            VARCHAR2(50)  NOT NULL,
    variety              VARCHAR2(50),
    season_id            NUMBER(3)     NOT NULL,
    avg_growth_days      NUMBER(4)     NOT NULL,
    water_requirement_mm NUMBER(7,2)   NOT NULL,
    CONSTRAINT fk_crop_season FOREIGN KEY (season_id) REFERENCES seasons(season_id),
    CONSTRAINT chk_growth_days CHECK (avg_growth_days > 0),
    CONSTRAINT chk_water_req   CHECK (water_requirement_mm > 0),
    CONSTRAINT uq_crop_variety UNIQUE (crop_name, variety)
);

-- =====================================================================
-- TABLE: fertilizers
-- =====================================================================
CREATE TABLE fertilizers (
    fertilizer_id            NUMBER(5)      PRIMARY KEY,
    fertilizer_name          VARCHAR2(60)   NOT NULL UNIQUE,
    n_ratio                  NUMBER(5,2)    NOT NULL,
    p_ratio                  NUMBER(5,2)    NOT NULL,
    k_ratio                  NUMBER(5,2)    NOT NULL,
    recommended_kg_per_acre  NUMBER(7,2)    NOT NULL,
    cost_per_kg              NUMBER(8,2)    NOT NULL,
    CONSTRAINT chk_n_ratio   CHECK (n_ratio   >= 0),
    CONSTRAINT chk_p_ratio   CHECK (p_ratio   >= 0),
    CONSTRAINT chk_k_ratio   CHECK (k_ratio   >= 0),
    CONSTRAINT chk_recommend CHECK (recommended_kg_per_acre > 0),
    CONSTRAINT chk_cost      CHECK (cost_per_kg > 0)
);

-- =====================================================================
-- TABLE: crop_cycles
-- =====================================================================
CREATE TABLE crop_cycles (
    cycle_id              NUMBER(8)     PRIMARY KEY,
    farmer_id             NUMBER(6)     NOT NULL,
    crop_id               NUMBER(5)     NOT NULL,
    season_id             NUMBER(3)     NOT NULL,
    sowing_date           DATE          NOT NULL,
    expected_harvest_date DATE          NOT NULL,
    actual_harvest_date   DATE,
    area_acres            NUMBER(8,2)   NOT NULL,
    status                VARCHAR2(15)  DEFAULT 'ACTIVE',
    notes                 VARCHAR2(500),
    CONSTRAINT fk_cycle_farmer FOREIGN KEY (farmer_id) REFERENCES farmers(farmer_id) ON DELETE CASCADE,
    CONSTRAINT fk_cycle_crop   FOREIGN KEY (crop_id)   REFERENCES crops(crop_id),
    CONSTRAINT fk_cycle_season FOREIGN KEY (season_id) REFERENCES seasons(season_id),
    CONSTRAINT chk_area_pos    CHECK (area_acres > 0),
    CONSTRAINT chk_cycle_dates CHECK (expected_harvest_date > sowing_date),
    CONSTRAINT chk_cycle_stat  CHECK (status IN ('ACTIVE','HARVESTED','FAILED','ABANDONED'))
);

-- =====================================================================
-- TABLE: water_usage
-- =====================================================================
CREATE TABLE water_usage (
    water_id          NUMBER(10)    PRIMARY KEY,
    cycle_id          NUMBER(8)     NOT NULL,
    usage_date        DATE          NOT NULL,
    water_source      VARCHAR2(30)  NOT NULL,
    quantity_liters   NUMBER(12,2)  NOT NULL,
    irrigation_method VARCHAR2(30)  NOT NULL,
    CONSTRAINT fk_water_cycle FOREIGN KEY (cycle_id) REFERENCES crop_cycles(cycle_id) ON DELETE CASCADE,
    CONSTRAINT chk_water_qty  CHECK (quantity_liters > 0),
    CONSTRAINT chk_water_src  CHECK (water_source IN ('CANAL','BOREWELL','RAIN','POND','TUBE_WELL','RIVER')),
    CONSTRAINT chk_irrig_meth CHECK (irrigation_method IN ('DRIP','SPRINKLER','FLOOD','FURROW','MANUAL'))
);

-- =====================================================================
-- TABLE: fertilizer_usage
-- =====================================================================
CREATE TABLE fertilizer_usage (
    usage_id           NUMBER(10)    PRIMARY KEY,
    cycle_id           NUMBER(8)     NOT NULL,
    fertilizer_id      NUMBER(5)     NOT NULL,
    application_date   DATE          NOT NULL,
    quantity_kg        NUMBER(10,2)  NOT NULL,
    application_method VARCHAR2(30)  NOT NULL,
    total_cost         NUMBER(12,2),
    CONSTRAINT fk_fu_cycle      FOREIGN KEY (cycle_id)      REFERENCES crop_cycles(cycle_id) ON DELETE CASCADE,
    CONSTRAINT fk_fu_fertilizer FOREIGN KEY (fertilizer_id) REFERENCES fertilizers(fertilizer_id),
    CONSTRAINT chk_fu_qty       CHECK (quantity_kg > 0),
    CONSTRAINT chk_app_method   CHECK (application_method IN ('BROADCAST','BAND','FOLIAR','FERTIGATION','MANUAL'))
);

-- =====================================================================
-- TABLE: yield_records
-- =====================================================================
CREATE TABLE yield_records (
    yield_id            NUMBER(10)    PRIMARY KEY,
    cycle_id            NUMBER(8)     NOT NULL UNIQUE,
    harvest_date        DATE          NOT NULL,
    yield_quantity_kg   NUMBER(12,2)  NOT NULL,
    quality_grade       VARCHAR2(2)   NOT NULL,
    market_price_per_kg NUMBER(8,2)   NOT NULL,
    total_revenue       NUMBER(14,2),
    CONSTRAINT fk_yield_cycle FOREIGN KEY (cycle_id) REFERENCES crop_cycles(cycle_id) ON DELETE CASCADE,
    CONSTRAINT chk_yield_qty  CHECK (yield_quantity_kg > 0),
    CONSTRAINT chk_yield_grd  CHECK (quality_grade IN ('A','B','C','D')),
    CONSTRAINT chk_yield_prc  CHECK (market_price_per_kg > 0)
);

-- =====================================================================
-- TABLE: audit_log (populated by triggers)
-- =====================================================================
CREATE TABLE audit_log (
    log_id        NUMBER(12)     PRIMARY KEY,
    action_type   VARCHAR2(10)   NOT NULL,
    table_name    VARCHAR2(40)   NOT NULL,
    record_id     VARCHAR2(40),
    action_date   TIMESTAMP      DEFAULT SYSTIMESTAMP,
    performed_by  VARCHAR2(40)   DEFAULT USER,
    details       VARCHAR2(500),
    CONSTRAINT chk_audit_action CHECK (action_type IN ('INSERT','UPDATE','DELETE'))
);

PROMPT Schema created successfully.
