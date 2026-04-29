-- =====================================================================
-- 05_procedures.sql
-- PL/SQL Stored Procedures
-- Demonstrates: parameters, exception handling, EXPLICIT CURSORS,
--               cursor FOR loops, %ROWTYPE, OUT params, REF CURSOR
-- =====================================================================

SET SERVEROUTPUT ON SIZE 1000000;

-- =====================================================================
-- PROCEDURE 1: register_farmer
-- Inserts a new farmer with validation. Returns generated farmer_id.
-- =====================================================================
CREATE OR REPLACE PROCEDURE register_farmer (
    p_name             IN  farmers.name%TYPE,
    p_contact          IN  farmers.contact_number%TYPE,
    p_village          IN  farmers.village%TYPE,
    p_district         IN  farmers.district%TYPE,
    p_state            IN  farmers.state%TYPE,
    p_land_acres       IN  farmers.total_land_acres%TYPE,
    p_soil_type        IN  farmers.soil_type%TYPE  DEFAULT NULL,
    p_has_irrigation   IN  farmers.has_irrigation%TYPE DEFAULT 'N',
    p_farmer_id        OUT farmers.farmer_id%TYPE
) IS
    v_count NUMBER;
BEGIN
    IF p_land_acres <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Land area must be positive.');
    END IF;

    SELECT COUNT(*) INTO v_count
    FROM farmers
    WHERE contact_number = p_contact;

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'A farmer with this contact number already exists.');
    END IF;

    p_farmer_id := seq_farmer.NEXTVAL;

    INSERT INTO farmers (
        farmer_id, name, contact_number, village, district, state,
        total_land_acres, soil_type, has_irrigation, registered_on
    ) VALUES (
        p_farmer_id, p_name, p_contact, p_village, p_district, p_state,
        p_land_acres, p_soil_type, p_has_irrigation, SYSDATE
    );

    DBMS_OUTPUT.PUT_LINE('Farmer registered with ID: ' || p_farmer_id);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END register_farmer;
/

-- =====================================================================
-- PROCEDURE 2: start_crop_cycle
-- Starts a new crop cycle, validating land availability via cursor.
-- =====================================================================
CREATE OR REPLACE PROCEDURE start_crop_cycle (
    p_farmer_id   IN  crop_cycles.farmer_id%TYPE,
    p_crop_id     IN  crop_cycles.crop_id%TYPE,
    p_sowing_date IN  crop_cycles.sowing_date%TYPE,
    p_area_acres  IN  crop_cycles.area_acres%TYPE,
    p_cycle_id    OUT crop_cycles.cycle_id%TYPE
) IS
    -- EXPLICIT CURSOR to compute current land in use
    CURSOR c_active_area IS
        SELECT NVL(SUM(area_acres), 0) AS used_acres
        FROM   crop_cycles
        WHERE  farmer_id = p_farmer_id
          AND  status    = 'ACTIVE';

    v_used_acres   NUMBER;
    v_total_land   farmers.total_land_acres%TYPE;
    v_growth_days  crops.avg_growth_days%TYPE;
    v_season_id    crops.season_id%TYPE;
BEGIN
    -- Verify farmer exists, fetch land
    SELECT total_land_acres INTO v_total_land
    FROM farmers WHERE farmer_id = p_farmer_id;

    -- Fetch crop's growth duration & default season
    SELECT avg_growth_days, season_id INTO v_growth_days, v_season_id
    FROM crops WHERE crop_id = p_crop_id;

    -- Use cursor to sum active area
    OPEN c_active_area;
    FETCH c_active_area INTO v_used_acres;
    CLOSE c_active_area;

    IF v_used_acres + p_area_acres > v_total_land THEN
        RAISE_APPLICATION_ERROR(-20010,
            'Requested area (' || p_area_acres || ') exceeds available land. ' ||
            'Used: ' || v_used_acres || ', Total: ' || v_total_land);
    END IF;

    p_cycle_id := seq_cycle.NEXTVAL;

    INSERT INTO crop_cycles (
        cycle_id, farmer_id, crop_id, season_id,
        sowing_date, expected_harvest_date, area_acres, status
    ) VALUES (
        p_cycle_id, p_farmer_id, p_crop_id, v_season_id,
        p_sowing_date, p_sowing_date + v_growth_days, p_area_acres, 'ACTIVE'
    );

    DBMS_OUTPUT.PUT_LINE('Crop cycle started. Cycle ID: ' || p_cycle_id ||
                         ', Expected harvest in ' || v_growth_days || ' days.');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20011, 'Farmer or crop not found.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END start_crop_cycle;
/

-- =====================================================================
-- PROCEDURE 3: record_water_usage
-- Logs a water usage event for a cycle (must still be ACTIVE).
-- =====================================================================
CREATE OR REPLACE PROCEDURE record_water_usage (
    p_cycle_id          IN water_usage.cycle_id%TYPE,
    p_usage_date        IN water_usage.usage_date%TYPE,
    p_water_source      IN water_usage.water_source%TYPE,
    p_quantity_liters   IN water_usage.quantity_liters%TYPE,
    p_irrigation_method IN water_usage.irrigation_method%TYPE
) IS
    v_status crop_cycles.status%TYPE;
BEGIN
    SELECT status INTO v_status
    FROM   crop_cycles
    WHERE  cycle_id = p_cycle_id;

    IF v_status <> 'ACTIVE' THEN
        RAISE_APPLICATION_ERROR(-20020,
            'Cannot log water usage on a ' || v_status || ' cycle.');
    END IF;

    INSERT INTO water_usage (
        water_id, cycle_id, usage_date, water_source,
        quantity_liters, irrigation_method
    ) VALUES (
        seq_water.NEXTVAL, p_cycle_id, p_usage_date, p_water_source,
        p_quantity_liters, p_irrigation_method
    );

    DBMS_OUTPUT.PUT_LINE('Water usage recorded for cycle ' || p_cycle_id);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20021, 'Cycle ID not found.');
END record_water_usage;
/

-- =====================================================================
-- PROCEDURE 4: record_harvest
-- Inserts yield record. Trigger on yield_records will auto-close cycle.
-- =====================================================================
CREATE OR REPLACE PROCEDURE record_harvest (
    p_cycle_id      IN yield_records.cycle_id%TYPE,
    p_harvest_date  IN yield_records.harvest_date%TYPE,
    p_yield_kg      IN yield_records.yield_quantity_kg%TYPE,
    p_quality       IN yield_records.quality_grade%TYPE,
    p_price_per_kg  IN yield_records.market_price_per_kg%TYPE
) IS
    v_status crop_cycles.status%TYPE;
BEGIN
    SELECT status INTO v_status FROM crop_cycles WHERE cycle_id = p_cycle_id;
    IF v_status <> 'ACTIVE' THEN
        RAISE_APPLICATION_ERROR(-20030,
            'Harvest can only be recorded for ACTIVE cycles. Current: ' || v_status);
    END IF;

    INSERT INTO yield_records (
        yield_id, cycle_id, harvest_date, yield_quantity_kg,
        quality_grade, market_price_per_kg
    ) VALUES (
        seq_yield.NEXTVAL, p_cycle_id, p_harvest_date, p_yield_kg,
        p_quality, p_price_per_kg
    );

    DBMS_OUTPUT.PUT_LINE('Harvest recorded. Cycle ' || p_cycle_id ||
                         ' will be marked HARVESTED by trigger.');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20031, 'Cycle ID not found.');
END record_harvest;
/

-- =====================================================================
-- PROCEDURE 5: generate_farmer_report
-- Comprehensive farmer report using EXPLICIT CURSOR with cursor FOR loop
-- =====================================================================
CREATE OR REPLACE PROCEDURE generate_farmer_report (
    p_farmer_id IN farmers.farmer_id%TYPE
) IS
    v_farmer farmers%ROWTYPE;

    -- Explicit parameterized cursor
    CURSOR c_cycles (cp_farmer_id NUMBER) IS
        SELECT cc.cycle_id, c.crop_name, c.variety, s.season_name,
               cc.sowing_date, cc.actual_harvest_date, cc.area_acres,
               cc.status,
               NVL(yr.yield_quantity_kg, 0)         AS yield_kg,
               NVL(yr.total_revenue, 0)             AS revenue,
               NVL((SELECT SUM(fu.total_cost) FROM fertilizer_usage fu
                    WHERE fu.cycle_id = cc.cycle_id), 0) AS fert_cost,
               NVL((SELECT SUM(wu.quantity_liters) FROM water_usage wu
                    WHERE wu.cycle_id = cc.cycle_id), 0) AS water_liters
        FROM crop_cycles cc
        JOIN crops    c ON cc.crop_id   = c.crop_id
        JOIN seasons  s ON cc.season_id = s.season_id
        LEFT JOIN yield_records yr ON cc.cycle_id = yr.cycle_id
        WHERE cc.farmer_id = cp_farmer_id
        ORDER BY cc.sowing_date;

    v_total_revenue NUMBER := 0;
    v_total_cost    NUMBER := 0;
    v_total_water   NUMBER := 0;
    v_cycle_count   NUMBER := 0;
BEGIN
    SELECT * INTO v_farmer FROM farmers WHERE farmer_id = p_farmer_id;

    DBMS_OUTPUT.PUT_LINE('====================================================');
    DBMS_OUTPUT.PUT_LINE('  FARMER REPORT - ID: ' || v_farmer.farmer_id);
    DBMS_OUTPUT.PUT_LINE('====================================================');
    DBMS_OUTPUT.PUT_LINE('Name        : ' || v_farmer.name);
    DBMS_OUTPUT.PUT_LINE('Location    : ' || v_farmer.village || ', ' ||
                         v_farmer.district || ', ' || v_farmer.state);
    DBMS_OUTPUT.PUT_LINE('Total Land  : ' || v_farmer.total_land_acres || ' acres');
    DBMS_OUTPUT.PUT_LINE('Soil Type   : ' || NVL(v_farmer.soil_type, 'N/A'));
    DBMS_OUTPUT.PUT_LINE('Irrigation  : ' || v_farmer.has_irrigation);
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('CROP CYCLES:');

    -- Cursor FOR loop (implicit OPEN/FETCH/CLOSE)
    FOR rec IN c_cycles(p_farmer_id) LOOP
        v_cycle_count := v_cycle_count + 1;
        v_total_revenue := v_total_revenue + rec.revenue;
        v_total_cost    := v_total_cost + rec.fert_cost;
        v_total_water   := v_total_water + rec.water_liters;

        DBMS_OUTPUT.PUT_LINE(' ');
        DBMS_OUTPUT.PUT_LINE('  Cycle #' || rec.cycle_id || '  [' || rec.status || ']');
        DBMS_OUTPUT.PUT_LINE('    Crop      : ' || rec.crop_name || ' (' || rec.variety || ')');
        DBMS_OUTPUT.PUT_LINE('    Season    : ' || rec.season_name);
        DBMS_OUTPUT.PUT_LINE('    Sown      : ' || TO_CHAR(rec.sowing_date, 'DD-Mon-YYYY'));
        DBMS_OUTPUT.PUT_LINE('    Harvested : ' || NVL(TO_CHAR(rec.actual_harvest_date,'DD-Mon-YYYY'),'-'));
        DBMS_OUTPUT.PUT_LINE('    Area      : ' || rec.area_acres || ' acres');
        DBMS_OUTPUT.PUT_LINE('    Yield     : ' || rec.yield_kg || ' kg');
        DBMS_OUTPUT.PUT_LINE('    Revenue   : Rs.' || rec.revenue);
        DBMS_OUTPUT.PUT_LINE('    FertCost  : Rs.' || rec.fert_cost);
        DBMS_OUTPUT.PUT_LINE('    Water Use : ' || rec.water_liters || ' L');
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('SUMMARY:');
    DBMS_OUTPUT.PUT_LINE('  Total Cycles    : ' || v_cycle_count);
    DBMS_OUTPUT.PUT_LINE('  Total Revenue   : Rs.' || v_total_revenue);
    DBMS_OUTPUT.PUT_LINE('  Total Fert Cost : Rs.' || v_total_cost);
    DBMS_OUTPUT.PUT_LINE('  Gross Profit    : Rs.' || (v_total_revenue - v_total_cost));
    DBMS_OUTPUT.PUT_LINE('  Total Water Use : ' || v_total_water || ' L');
    DBMS_OUTPUT.PUT_LINE('====================================================');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Farmer ID ' || p_farmer_id || ' not found.');
END generate_farmer_report;
/

-- =====================================================================
-- PROCEDURE 6: seasonal_efficiency_report
-- Uses explicit cursor + manual OPEN/FETCH/CLOSE to identify
-- best-performing crop per season by yield-per-acre.
-- =====================================================================
CREATE OR REPLACE PROCEDURE seasonal_efficiency_report IS
    CURSOR c_season_perf IS
        SELECT s.season_name,
               c.crop_name,
               COUNT(cc.cycle_id) AS cycles,
               ROUND(AVG(yr.yield_quantity_kg / cc.area_acres), 2) AS avg_yield_per_acre,
               ROUND(SUM(yr.total_revenue), 2) AS total_revenue
        FROM   crop_cycles cc
        JOIN   crops   c  ON cc.crop_id   = c.crop_id
        JOIN   seasons s  ON cc.season_id = s.season_id
        JOIN   yield_records yr ON cc.cycle_id = yr.cycle_id
        GROUP BY s.season_name, c.crop_name
        ORDER BY s.season_name, avg_yield_per_acre DESC;

    v_rec       c_season_perf%ROWTYPE;
    v_prev_season  VARCHAR2(20) := '*';
BEGIN
    DBMS_OUTPUT.PUT_LINE('================ SEASONAL EFFICIENCY REPORT ================');
    OPEN c_season_perf;
    LOOP
        FETCH c_season_perf INTO v_rec;
        EXIT WHEN c_season_perf%NOTFOUND;

        IF v_rec.season_name <> v_prev_season THEN
            DBMS_OUTPUT.PUT_LINE(' ');
            DBMS_OUTPUT.PUT_LINE('Season: ' || v_rec.season_name);
            DBMS_OUTPUT.PUT_LINE('  ' || RPAD('Crop',15) || RPAD('Cycles',10) ||
                                 RPAD('Avg Yld/Acre',16) || 'Total Revenue');
            v_prev_season := v_rec.season_name;
        END IF;

        DBMS_OUTPUT.PUT_LINE('  ' || RPAD(v_rec.crop_name, 15) ||
                                 RPAD(TO_CHAR(v_rec.cycles), 10) ||
                                 RPAD(TO_CHAR(v_rec.avg_yield_per_acre), 16) ||
                                 'Rs.' || v_rec.total_revenue);
    END LOOP;
    CLOSE c_season_perf;
    DBMS_OUTPUT.PUT_LINE('============================================================');
END seasonal_efficiency_report;
/

-- =====================================================================
-- PROCEDURE 7: get_cycles_for_farmer (REF CURSOR demo)
-- Returns a result set for application-layer consumption.
-- =====================================================================
CREATE OR REPLACE PROCEDURE get_cycles_for_farmer (
    p_farmer_id IN  farmers.farmer_id%TYPE,
    p_result    OUT SYS_REFCURSOR
) IS
BEGIN
    OPEN p_result FOR
        SELECT cc.cycle_id, c.crop_name, s.season_name,
               cc.sowing_date, cc.area_acres, cc.status,
               NVL(yr.yield_quantity_kg, 0) AS yield_kg,
               NVL(yr.total_revenue, 0)     AS revenue
        FROM   crop_cycles cc
        JOIN   crops c   ON cc.crop_id   = c.crop_id
        JOIN   seasons s ON cc.season_id = s.season_id
        LEFT JOIN yield_records yr ON cc.cycle_id = yr.cycle_id
        WHERE  cc.farmer_id = p_farmer_id
        ORDER BY cc.sowing_date DESC;
END get_cycles_for_farmer;
/

PROMPT Procedures compiled successfully.
