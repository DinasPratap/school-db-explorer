-- =====================================================================
-- run_all.sql
-- Master script - executes the project end-to-end in correct order.
--
-- Usage in SQL*Plus / SQLcl:
--     SQL> @run_all.sql
--
-- Order matters:
--   1. Schema (tables, sequences)
--   2. Indexes
--   3. Functions
--   4. Triggers (must exist BEFORE data load so total_cost / revenue
--      and audit log are populated automatically during seed insert)
--   5. Sample data
--   6. Views   (depend on tables + data)
--   7. Procedures
--   8. Analytical query library
--   9. End-to-end demo
-- =====================================================================

SET ECHO OFF
SET FEEDBACK ON
SET SERVEROUTPUT ON SIZE 1000000
SET LINESIZE 200
SET PAGESIZE 50

PROMPT
PROMPT ##########  STEP 1/9 : SCHEMA  ##########
@@01_schema.sql

PROMPT
PROMPT ##########  STEP 2/9 : INDEXES  ##########
@@02_indexes.sql

PROMPT
PROMPT ##########  STEP 3/9 : FUNCTIONS  ##########
@@06_functions.sql

PROMPT
PROMPT ##########  STEP 4/9 : TRIGGERS  ##########
@@07_triggers.sql

PROMPT
PROMPT ##########  STEP 5/9 : SAMPLE DATA  ##########
@@03_sample_data.sql

PROMPT
PROMPT ##########  STEP 6/9 : VIEWS  ##########
@@04_views.sql

PROMPT
PROMPT ##########  STEP 7/9 : PROCEDURES  ##########
@@05_procedures.sql

PROMPT
PROMPT ##########  STEP 8/9 : ANALYTICAL QUERIES  ##########
@@08_queries.sql

PROMPT
PROMPT ##########  STEP 9/9 : END-TO-END DEMO  ##########
@@09_demo.sql

PROMPT
PROMPT ##########  ALL DONE  ##########
