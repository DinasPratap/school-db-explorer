# Farmer Crop & Resource Optimization Database

## Project Overview
This is a DBMS project for managing farmer crop cycles, resource optimization, and agricultural analytics. The database tracks farmers, crops, seasons, water usage, fertilizer usage, and yield records to provide insights for agricultural decision-making.

## PL-SQL Requirements Met
This project demonstrates all required PL-SQL concepts:

### Procedures (7 procedures)
- `register_farmer` - Registers new farmers with validation
- `start_crop_cycle` - Starts crop cycles with land availability validation (uses explicit cursor)
- `record_water_usage` - Logs water usage for active cycles
- `record_harvest` - Records harvest data (triggers auto-close cycle)
- `generate_farmer_report` - Comprehensive farmer report using cursor FOR loop
- `seasonal_efficiency_report` - Seasonal performance analysis using manual cursor OPEN/FETCH/CLOSE
- `get_cycles_for_farmer` - Returns result set using REF CURSOR

### Functions (6 functions)
- `get_total_water_used` - Returns total water used in a cycle
- `get_total_fertilizer_cost` - Returns total fertilizer cost for a cycle
- `calculate_profit` - Calculates profit (revenue - fertilizer cost)
- `get_yield_per_acre` - Calculates yield per acre
- `get_farmer_total_revenue` - Returns cumulative farmer revenue
- `get_water_efficiency_label` - Classifies water efficiency (CASE-based)

### Cursors
- **Explicit cursors** with manual OPEN/FETCH/CLOSE
- **Parameterized cursors** for reusable queries
- **Cursor FOR loops** for implicit cursor management
- **REF CURSOR** for returning result sets to applications

### Triggers (7 triggers)
- `trg_validate_sowing_date` - Validates sowing date range
- `trg_compute_fertilizer_cost` - Auto-computes fertilizer cost
- `trg_compute_yield_revenue` - Auto-computes yield revenue
- `trg_close_cycle_on_harvest` - Auto-marks cycle as HARVESTED
- `trg_audit_farmers` - Audit trail for farmers table
- `trg_audit_crop_cycles` - Logs status changes on crop cycles
- `trg_check_water_overuse` - Prevents excessive single water entries

## Database Schema
The database is normalized to 3NF/BCNF with the following tables:
- `seasons` - Agricultural seasons (Kharif, Rabi, Zaid)
- `farmers` - Farmer registration and land details
- `crops` - Crop varieties with growth requirements
- `fertilizers` - Fertilizer types with NPK ratios and costs
- `crop_cycles` - Individual crop planting cycles
- `water_usage` - Water usage records per cycle
- `fertilizer_usage` - Fertilizer application records
- `yield_records` - Harvest yield and revenue data
- `audit_log` - Audit trail populated by triggers

## File Structure
- `01_schema.sql` - Tables, sequences, constraints
- `02_indexes.sql` - Performance indexes
- `03_sample_data.sql` - Sample data for testing
- `04_views.sql` - Analytical views
- `05_procedures.sql` - PL-SQL stored procedures
- `06_functions.sql` - PL-SQL functions
- `07_triggers.sql` - Database triggers
- `08_queries.sql` - Analytical query library
- `09_demo.sql` - End-to-end demonstration
- `run_all.sql` - Master script to run everything

## How to Run
### Using SQL*Plus or SQLcl:
```bash
sqlplus username/password@database @run_all.sql
```

### Individual Execution:
Execute files in order:
1. `@01_schema.sql`
2. `@02_indexes.sql`
3. `@06_functions.sql`
4. `@07_triggers.sql`
5. `@03_sample_data.sql`
6. `@04_views.sql`
7. `@05_procedures.sql`
8. `@08_queries.sql`
9. `@09_demo.sql`

## Key Features
- **Data Integrity**: Constraints, triggers, and validation procedures
- **Audit Trail**: Automatic logging of critical operations
- **Auto-computation**: Triggers automatically calculate costs and revenues
- **Business Logic**: Procedures enforce land availability and cycle status rules
- **Analytics**: Views and queries provide insights on performance
- **Water Efficiency**: Functions classify water usage efficiency

## Testing
Run the demo script to verify all components:
```bash
@09_demo.sql
```

This demonstrates:
- Farmer registration with audit logging
- Crop cycle creation with validation
- Function calls for calculations
- Cursor-based reporting
- Trigger validation (error handling)
- Audit log inspection

## Notes
- Uses standard Oracle PL-SQL (no advanced DBMS features)
- Compatible with Oracle 11g and later
- Sequences used for primary key generation
- Cascading deletes maintain referential integrity
- All dates use ANSI DATE literal format for portability