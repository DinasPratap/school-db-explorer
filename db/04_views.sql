-- =====================================================================
-- 04_views.sql
-- Pre-defined analytical views
-- Demonstrates JOINS, aggregations, CASE, window functions
-- =====================================================================

-- ---------- v_farmer_summary ------------------------------------------
-- One row per farmer with total cycles, total area, total revenue
CREATE OR REPLACE VIEW v_farmer_summary AS
SELECT
    f.farmer_id,
    f.name,
    f.village,
    f.district,
    f.state,
    f.total_land_acres,
    COUNT(DISTINCT cc.cycle_id)                             AS total_cycles,
    NVL(SUM(cc.area_acres), 0)                              AS total_cultivated_acres,
    NVL(SUM(yr.yield_quantity_kg), 0)                       AS total_yield_kg,
    NVL(SUM(yr.total_revenue), 0)                           AS total_revenue,
    COUNT(DISTINCT CASE WHEN cc.status = 'ACTIVE' THEN cc.cycle_id END)    AS active_cycles,
    COUNT(DISTINCT CASE WHEN cc.status = 'HARVESTED' THEN cc.cycle_id END) AS harvested_cycles
FROM farmers f
LEFT JOIN crop_cycles  cc ON f.farmer_id = cc.farmer_id
LEFT JOIN yield_records yr ON cc.cycle_id  = yr.cycle_id
GROUP BY f.farmer_id, f.name, f.village, f.district, f.state, f.total_land_acres;

-- ---------- v_cycle_economics -----------------------------------------
-- Per-cycle profitability: revenue, fertilizer cost, yield-per-acre, profit
CREATE OR REPLACE VIEW v_cycle_economics AS
SELECT
    cc.cycle_id,
    cc.farmer_id,
    f.name                       AS farmer_name,
    c.crop_name,
    c.variety,
    s.season_name,
    cc.area_acres,
    cc.sowing_date,
    cc.actual_harvest_date,
    yr.yield_quantity_kg,
    ROUND(yr.yield_quantity_kg / cc.area_acres, 2) AS yield_per_acre,
    yr.quality_grade,
    yr.market_price_per_kg,
    NVL(yr.total_revenue, 0)                       AS revenue,
    NVL((SELECT SUM(fu.total_cost) FROM fertilizer_usage fu
         WHERE fu.cycle_id = cc.cycle_id), 0)      AS fertilizer_cost,
    NVL((SELECT SUM(wu.quantity_liters) FROM water_usage wu
         WHERE wu.cycle_id = cc.cycle_id), 0)      AS total_water_liters,
    NVL(yr.total_revenue, 0)
        - NVL((SELECT SUM(fu.total_cost) FROM fertilizer_usage fu
               WHERE fu.cycle_id = cc.cycle_id), 0) AS gross_profit
FROM crop_cycles cc
JOIN farmers f ON cc.farmer_id = f.farmer_id
JOIN crops   c ON cc.crop_id   = c.crop_id
JOIN seasons s ON cc.season_id = s.season_id
LEFT JOIN yield_records yr ON cc.cycle_id = yr.cycle_id;

-- ---------- v_seasonal_performance ------------------------------------
-- Aggregated performance per crop x season
CREATE OR REPLACE VIEW v_seasonal_performance AS
SELECT
    s.season_name,
    c.crop_name,
    COUNT(cc.cycle_id)                          AS cycles_count,
    ROUND(AVG(yr.yield_quantity_kg / cc.area_acres), 2) AS avg_yield_per_acre,
    ROUND(SUM(yr.total_revenue), 2)             AS total_revenue,
    ROUND(AVG(yr.market_price_per_kg), 2)       AS avg_price_per_kg
FROM crop_cycles cc
JOIN crops    c  ON cc.crop_id   = c.crop_id
JOIN seasons  s  ON cc.season_id = s.season_id
JOIN yield_records yr ON cc.cycle_id = yr.cycle_id
GROUP BY s.season_name, c.crop_name;

-- ---------- v_top_farmers ---------------------------------------------
-- Window-function ranked farmers by revenue
CREATE OR REPLACE VIEW v_top_farmers AS
SELECT
    farmer_id,
    name,
    state,
    total_revenue,
    RANK()       OVER (ORDER BY total_revenue DESC)               AS revenue_rank,
    RANK()       OVER (PARTITION BY state ORDER BY total_revenue DESC) AS rank_in_state
FROM v_farmer_summary
WHERE total_revenue > 0;

-- ---------- v_water_efficiency ----------------------------------------
-- Liters of water per kg of yield, per cycle
CREATE OR REPLACE VIEW v_water_efficiency AS
SELECT
    cc.cycle_id,
    f.name        AS farmer_name,
    c.crop_name,
    s.season_name,
    yr.yield_quantity_kg,
    NVL(SUM(wu.quantity_liters), 0)                               AS total_water_liters,
    CASE WHEN yr.yield_quantity_kg > 0
         THEN ROUND(NVL(SUM(wu.quantity_liters),0) / yr.yield_quantity_kg, 2)
         ELSE NULL END                                            AS liters_per_kg_yield
FROM crop_cycles cc
JOIN farmers f       ON cc.farmer_id = f.farmer_id
JOIN crops   c       ON cc.crop_id   = c.crop_id
JOIN seasons s       ON cc.season_id = s.season_id
LEFT JOIN yield_records yr ON cc.cycle_id = yr.cycle_id
LEFT JOIN water_usage   wu ON cc.cycle_id = wu.cycle_id
GROUP BY cc.cycle_id, f.name, c.crop_name, s.season_name, yr.yield_quantity_kg;

PROMPT Views created successfully.
