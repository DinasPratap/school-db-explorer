-- =====================================================================
-- 08_queries.sql
-- Analytical SQL Query Library
-- Demonstrates: JOINs, subqueries, GROUP BY, HAVING, CTEs, window funcs,
--               CASE, DATE functions, BETWEEN, IN, EXISTS
-- =====================================================================

SET LINESIZE 200
SET PAGESIZE 50

PROMPT
PROMPT === Q1: All farmers with their state and total land =================
SELECT farmer_id, name, state, total_land_acres
FROM   farmers
ORDER  BY total_land_acres DESC;

PROMPT
PROMPT === Q2: Crops grouped by season (multi-table JOIN) ==================
SELECT s.season_name, c.crop_name, c.variety, c.avg_growth_days
FROM   crops c
JOIN   seasons s ON c.season_id = s.season_id
ORDER  BY s.season_id, c.crop_name;

PROMPT
PROMPT === Q3: Total water usage per crop_cycle (GROUP BY + JOIN) ==========
SELECT cc.cycle_id, f.name AS farmer, c.crop_name,
       SUM(wu.quantity_liters) AS total_liters
FROM   crop_cycles cc
JOIN   farmers f      ON cc.farmer_id = f.farmer_id
JOIN   crops   c      ON cc.crop_id   = c.crop_id
JOIN   water_usage wu ON cc.cycle_id  = wu.cycle_id
GROUP  BY cc.cycle_id, f.name, c.crop_name
ORDER  BY total_liters DESC;

PROMPT
PROMPT === Q4: Profit per cycle (revenue - fertilizer cost) ================
SELECT cc.cycle_id, f.name AS farmer, c.crop_name,
       NVL(yr.total_revenue, 0) AS revenue,
       NVL(SUM(fu.total_cost), 0) AS fert_cost,
       NVL(yr.total_revenue,0) - NVL(SUM(fu.total_cost),0) AS profit
FROM   crop_cycles cc
JOIN   farmers f      ON cc.farmer_id = f.farmer_id
JOIN   crops   c      ON cc.crop_id   = c.crop_id
LEFT   JOIN yield_records yr     ON cc.cycle_id = yr.cycle_id
LEFT   JOIN fertilizer_usage fu  ON cc.cycle_id = fu.cycle_id
GROUP  BY cc.cycle_id, f.name, c.crop_name, yr.total_revenue
ORDER  BY profit DESC;

PROMPT
PROMPT === Q5: Top-3 farmers by revenue per state (window function) ========
SELECT * FROM (
    SELECT f.farmer_id, f.name, f.state,
           SUM(yr.total_revenue) AS revenue,
           RANK() OVER (PARTITION BY f.state ORDER BY SUM(yr.total_revenue) DESC) AS state_rank
    FROM   farmers f
    JOIN   crop_cycles cc ON f.farmer_id = cc.farmer_id
    JOIN   yield_records yr ON cc.cycle_id = yr.cycle_id
    GROUP  BY f.farmer_id, f.name, f.state
)
WHERE state_rank <= 3
ORDER BY state, state_rank;

PROMPT
PROMPT === Q6: Average yield/acre by crop (HAVING filter) ==================
SELECT c.crop_name,
       COUNT(*) AS cycles,
       ROUND(AVG(yr.yield_quantity_kg / cc.area_acres), 2) AS avg_yield_per_acre
FROM   crop_cycles cc
JOIN   crops c        ON cc.crop_id  = c.crop_id
JOIN   yield_records yr ON cc.cycle_id = yr.cycle_id
GROUP  BY c.crop_name
HAVING COUNT(*) >= 1
ORDER  BY avg_yield_per_acre DESC;

PROMPT
PROMPT === Q7: Farmers who never had a FAILED cycle (subquery / NOT EXISTS) =
SELECT f.farmer_id, f.name
FROM   farmers f
WHERE  NOT EXISTS (
    SELECT 1 FROM crop_cycles cc
    WHERE cc.farmer_id = f.farmer_id AND cc.status = 'FAILED'
);

PROMPT
PROMPT === Q8: Seasonal revenue contribution (CTE + percentage) ============
WITH season_rev AS (
    SELECT s.season_name, SUM(yr.total_revenue) AS rev
    FROM   crop_cycles cc
    JOIN   seasons s ON cc.season_id = s.season_id
    JOIN   yield_records yr ON cc.cycle_id = yr.cycle_id
    GROUP  BY s.season_name
),
total AS (SELECT SUM(rev) AS grand FROM season_rev)
SELECT sr.season_name, sr.rev,
       ROUND(sr.rev * 100 / t.grand, 2) AS pct_of_total
FROM   season_rev sr CROSS JOIN total t
ORDER  BY sr.rev DESC;

PROMPT
PROMPT === Q9: Cycles harvested in a date range (BETWEEN + DATE) ===========
SELECT cc.cycle_id, f.name AS farmer, c.crop_name,
       cc.actual_harvest_date,
       yr.yield_quantity_kg
FROM   crop_cycles cc
JOIN   farmers f       ON cc.farmer_id = f.farmer_id
JOIN   crops   c       ON cc.crop_id   = c.crop_id
JOIN   yield_records yr ON cc.cycle_id = yr.cycle_id
WHERE  cc.actual_harvest_date BETWEEN DATE '2023-10-01' AND DATE '2024-04-30'
ORDER  BY cc.actual_harvest_date;

PROMPT
PROMPT === Q10: Quality-grade distribution with CASE label =================
SELECT
    yr.quality_grade,
    COUNT(*) AS cycles,
    CASE yr.quality_grade
        WHEN 'A' THEN 'Premium'
        WHEN 'B' THEN 'Standard'
        WHEN 'C' THEN 'Below-Average'
        WHEN 'D' THEN 'Poor'
    END AS grade_label,
    ROUND(AVG(yr.market_price_per_kg), 2) AS avg_price
FROM yield_records yr
GROUP BY yr.quality_grade
ORDER BY yr.quality_grade;

PROMPT
PROMPT === Q11: Water-efficient cycles (using function call) ===============
SELECT cycle_id,
       get_total_water_used(cycle_id)        AS water_liters,
       get_yield_per_acre(cycle_id)          AS yield_per_acre,
       get_water_efficiency_label(cycle_id)  AS efficiency
FROM   crop_cycles
WHERE  status = 'HARVESTED'
ORDER  BY 1;

PROMPT
PROMPT === Q12: Audit log inspection (last 20 entries) =====================
SELECT * FROM (
    SELECT log_id, action_type, table_name, record_id,
           TO_CHAR(action_date, 'DD-Mon-YYYY HH24:MI:SS') AS acted_on,
           details
    FROM audit_log
    ORDER BY log_id DESC
)
WHERE ROWNUM <= 20;

PROMPT === End of analytical query library ============================
