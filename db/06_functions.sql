-- =====================================================================
-- 06_functions.sql
-- PL/SQL Functions
-- Each returns a scalar value derived from related tables.
-- =====================================================================

SET SERVEROUTPUT ON SIZE 1000000;

-- =====================================================================
-- FUNCTION: get_total_water_used
-- Returns total liters used in a cycle.
-- =====================================================================
CREATE OR REPLACE FUNCTION get_total_water_used (
    p_cycle_id IN water_usage.cycle_id%TYPE
) RETURN NUMBER IS
    v_total NUMBER;
BEGIN
    SELECT NVL(SUM(quantity_liters), 0)
    INTO v_total
    FROM water_usage
    WHERE cycle_id = p_cycle_id;

    RETURN v_total;
END get_total_water_used;
/

-- =====================================================================
-- FUNCTION: get_total_fertilizer_cost
-- Returns total fertilizer cost for a cycle.
-- =====================================================================
CREATE OR REPLACE FUNCTION get_total_fertilizer_cost (
    p_cycle_id IN fertilizer_usage.cycle_id%TYPE
) RETURN NUMBER IS
    v_total NUMBER;
BEGIN
    SELECT NVL(SUM(total_cost), 0)
    INTO v_total
    FROM fertilizer_usage
    WHERE cycle_id = p_cycle_id;

    RETURN v_total;
END get_total_fertilizer_cost;
/

-- =====================================================================
-- FUNCTION: calculate_profit
-- Profit = revenue − fertilizer_cost  (water cost ignored for simplicity)
-- =====================================================================
CREATE OR REPLACE FUNCTION calculate_profit (
    p_cycle_id IN crop_cycles.cycle_id%TYPE
) RETURN NUMBER IS
    v_revenue NUMBER := 0;
    v_cost    NUMBER := 0;
BEGIN
    SELECT NVL(total_revenue, 0)
    INTO v_revenue
    FROM yield_records
    WHERE cycle_id = p_cycle_id;

    v_cost := get_total_fertilizer_cost(p_cycle_id);

    RETURN v_revenue - v_cost;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN -get_total_fertilizer_cost(p_cycle_id);
END calculate_profit;
/

-- =====================================================================
-- FUNCTION: get_yield_per_acre
-- =====================================================================
CREATE OR REPLACE FUNCTION get_yield_per_acre (
    p_cycle_id IN crop_cycles.cycle_id%TYPE
) RETURN NUMBER IS
    v_yield NUMBER;
    v_area  NUMBER;
BEGIN
    SELECT yr.yield_quantity_kg, cc.area_acres
    INTO   v_yield, v_area
    FROM   yield_records yr
    JOIN   crop_cycles   cc ON yr.cycle_id = cc.cycle_id
    WHERE  cc.cycle_id = p_cycle_id;

    IF v_area = 0 THEN
        RETURN 0;
    END IF;
    RETURN ROUND(v_yield / v_area, 2);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
END get_yield_per_acre;
/

-- =====================================================================
-- FUNCTION: get_farmer_total_revenue
-- Cumulative revenue across all of a farmer's cycles.
-- =====================================================================
CREATE OR REPLACE FUNCTION get_farmer_total_revenue (
    p_farmer_id IN farmers.farmer_id%TYPE
) RETURN NUMBER IS
    v_total NUMBER;
BEGIN
    SELECT NVL(SUM(yr.total_revenue), 0)
    INTO   v_total
    FROM   crop_cycles cc
    JOIN   yield_records yr ON cc.cycle_id = yr.cycle_id
    WHERE  cc.farmer_id = p_farmer_id;

    RETURN v_total;
END get_farmer_total_revenue;
/

-- =====================================================================
-- FUNCTION: get_water_efficiency_label
-- CASE-based classification of water efficiency.
-- =====================================================================
CREATE OR REPLACE FUNCTION get_water_efficiency_label (
    p_cycle_id IN crop_cycles.cycle_id%TYPE
) RETURN VARCHAR2 IS
    v_water  NUMBER;
    v_yield  NUMBER;
    v_ratio  NUMBER;
BEGIN
    v_water := get_total_water_used(p_cycle_id);
    SELECT NVL(yield_quantity_kg, 0)
    INTO v_yield FROM yield_records WHERE cycle_id = p_cycle_id;

    IF v_yield = 0 THEN
        RETURN 'NO YIELD';
    END IF;

    v_ratio := v_water / v_yield;

    RETURN CASE
        WHEN v_ratio < 30   THEN 'EXCELLENT'
        WHEN v_ratio < 60   THEN 'GOOD'
        WHEN v_ratio < 100  THEN 'AVERAGE'
        ELSE                     'INEFFICIENT'
    END;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'NO DATA';
END get_water_efficiency_label;
/

PROMPT Functions compiled successfully.
