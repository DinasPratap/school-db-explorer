-- =====================================================================
-- 03_sample_data.sql
-- Sample data for demonstration & testing
-- NOTE: Triggers in 07_triggers.sql auto-compute total_cost & total_revenue,
--       so we leave those columns NULL on INSERT here.
-- =====================================================================

-- Disable triggers during bulk-load so we can use sequences cleanly
-- (we re-enable at end). Comment these out if loading after triggers exist.

-- ===================== SEASONS =====================
INSERT INTO seasons VALUES (1, 'Kharif', 6,  10, 'Monsoon season - June to October');
INSERT INTO seasons VALUES (2, 'Rabi',   11, 4,  'Winter season - November to April');
INSERT INTO seasons VALUES (3, 'Zaid',   3,  6,  'Summer season - March to June');

-- ===================== FARMERS =====================
INSERT INTO farmers VALUES (seq_farmer.NEXTVAL, 'Ramesh Kumar',     '9876543210', 'Khanna',     'Ludhiana',  'Punjab',         12.50, 'ALLUVIAL', 'Y', DATE '2023-01-15');
INSERT INTO farmers VALUES (seq_farmer.NEXTVAL, 'Suresh Singh',     '9876543211', 'Patiala',    'Patiala',   'Punjab',         18.00, 'LOAMY',    'Y', DATE '2023-02-10');
INSERT INTO farmers VALUES (seq_farmer.NEXTVAL, 'Mahesh Patel',     '9876543212', 'Anand',      'Anand',     'Gujarat',        25.75, 'BLACK',    'Y', DATE '2023-03-05');
INSERT INTO farmers VALUES (seq_farmer.NEXTVAL, 'Lakshmi Devi',     '9876543213', 'Warangal',   'Warangal',  'Telangana',      8.25,  'RED',      'N', DATE '2023-04-20');
INSERT INTO farmers VALUES (seq_farmer.NEXTVAL, 'Harpreet Kaur',    '9876543214', 'Bathinda',   'Bathinda',  'Punjab',         22.00, 'ALLUVIAL', 'Y', DATE '2023-05-12');
INSERT INTO farmers VALUES (seq_farmer.NEXTVAL, 'Arjun Reddy',      '9876543215', 'Guntur',     'Guntur',    'Andhra Pradesh', 15.50, 'BLACK',    'Y', DATE '2023-06-18');
INSERT INTO farmers VALUES (seq_farmer.NEXTVAL, 'Pooja Sharma',     '9876543216', 'Karnal',     'Karnal',    'Haryana',        10.00, 'LOAMY',    'Y', DATE '2023-07-22');
INSERT INTO farmers VALUES (seq_farmer.NEXTVAL, 'Vikram Yadav',     '9876543217', 'Meerut',     'Meerut',    'Uttar Pradesh',  6.75,  'ALLUVIAL', 'N', DATE '2023-08-30');

-- ===================== CROPS =====================
INSERT INTO crops VALUES (seq_crop.NEXTVAL, 'Rice',      'Basmati-1121',  1, 130, 1200);
INSERT INTO crops VALUES (seq_crop.NEXTVAL, 'Rice',      'PR-126',        1, 110, 1100);
INSERT INTO crops VALUES (seq_crop.NEXTVAL, 'Maize',     'Pioneer-3396',  1, 100, 600);
INSERT INTO crops VALUES (seq_crop.NEXTVAL, 'Cotton',    'BT-Cotton',     1, 180, 800);
INSERT INTO crops VALUES (seq_crop.NEXTVAL, 'Wheat',     'HD-2967',       2, 140, 450);
INSERT INTO crops VALUES (seq_crop.NEXTVAL, 'Wheat',     'PBW-725',       2, 145, 470);
INSERT INTO crops VALUES (seq_crop.NEXTVAL, 'Mustard',   'Pusa-Bold',     2, 120, 350);
INSERT INTO crops VALUES (seq_crop.NEXTVAL, 'Chickpea',  'Pusa-256',      2, 110, 300);
INSERT INTO crops VALUES (seq_crop.NEXTVAL, 'Watermelon','Sugar-Baby',    3, 80,  500);
INSERT INTO crops VALUES (seq_crop.NEXTVAL, 'Cucumber',  'Malini',        3, 60,  400);

-- ===================== FERTILIZERS =====================
INSERT INTO fertilizers VALUES (seq_fertilizer.NEXTVAL, 'Urea',           46, 0,  0,  100, 6.50);
INSERT INTO fertilizers VALUES (seq_fertilizer.NEXTVAL, 'DAP',            18, 46, 0,  60,  28.00);
INSERT INTO fertilizers VALUES (seq_fertilizer.NEXTVAL, 'MOP',            0,  0,  60, 50,  18.00);
INSERT INTO fertilizers VALUES (seq_fertilizer.NEXTVAL, 'NPK 10-26-26',   10, 26, 26, 80,  24.50);
INSERT INTO fertilizers VALUES (seq_fertilizer.NEXTVAL, 'NPK 12-32-16',   12, 32, 16, 75,  26.00);
INSERT INTO fertilizers VALUES (seq_fertilizer.NEXTVAL, 'SSP',            0,  16, 0,  120, 8.00);
INSERT INTO fertilizers VALUES (seq_fertilizer.NEXTVAL, 'Vermicompost',   2,  1,  1,  500, 4.00);

-- ===================== CROP_CYCLES =====================
-- Farmer 1001 (Ramesh) - Rice Kharif 2023, Wheat Rabi 2023-24
INSERT INTO crop_cycles VALUES (seq_cycle.NEXTVAL, 1001, 101, 1, DATE '2023-06-20', DATE '2023-10-28', DATE '2023-10-30', 8.00,  'HARVESTED', 'Good monsoon year');
INSERT INTO crop_cycles VALUES (seq_cycle.NEXTVAL, 1001, 105, 2, DATE '2023-11-15', DATE '2024-04-04', DATE '2024-04-06', 10.00, 'HARVESTED', 'Standard wheat cycle');

-- Farmer 1002 (Suresh) - Rice + Wheat
INSERT INTO crop_cycles VALUES (seq_cycle.NEXTVAL, 1002, 102, 1, DATE '2023-06-25', DATE '2023-10-13', DATE '2023-10-14', 12.00, 'HARVESTED', NULL);
INSERT INTO crop_cycles VALUES (seq_cycle.NEXTVAL, 1002, 106, 2, DATE '2023-11-20', DATE '2024-04-13', DATE '2024-04-15', 15.00, 'HARVESTED', 'Late sowing');

-- Farmer 1003 (Mahesh) - Cotton Kharif, Mustard Rabi
INSERT INTO crop_cycles VALUES (seq_cycle.NEXTVAL, 1003, 104, 1, DATE '2023-06-15', DATE '2023-12-12', DATE '2023-12-15', 20.00, 'HARVESTED', 'Cotton bumper year');
INSERT INTO crop_cycles VALUES (seq_cycle.NEXTVAL, 1003, 107, 2, DATE '2023-11-10', DATE '2024-03-10', DATE '2024-03-12', 5.00,  'HARVESTED', NULL);

-- Farmer 1004 (Lakshmi) - Maize, Chickpea
INSERT INTO crop_cycles VALUES (seq_cycle.NEXTVAL, 1004, 103, 1, DATE '2023-07-01', DATE '2023-10-09', DATE '2023-10-10', 5.00,  'HARVESTED', NULL);
INSERT INTO crop_cycles VALUES (seq_cycle.NEXTVAL, 1004, 108, 2, DATE '2023-11-05', DATE '2024-02-23', DATE '2024-02-25', 3.00,  'HARVESTED', NULL);

-- Farmer 1005 (Harpreet) - Rice, Wheat (large area)
INSERT INTO crop_cycles VALUES (seq_cycle.NEXTVAL, 1005, 101, 1, DATE '2023-06-22', DATE '2023-10-30', DATE '2023-11-02', 18.00, 'HARVESTED', 'Premium basmati');
INSERT INTO crop_cycles VALUES (seq_cycle.NEXTVAL, 1005, 105, 2, DATE '2023-11-18', DATE '2024-04-07', DATE '2024-04-08', 20.00, 'HARVESTED', NULL);

-- Farmer 1006 (Arjun) - Cotton, Chickpea
INSERT INTO crop_cycles VALUES (seq_cycle.NEXTVAL, 1006, 104, 1, DATE '2023-06-28', DATE '2023-12-25', DATE '2023-12-28', 12.00, 'HARVESTED', NULL);
INSERT INTO crop_cycles VALUES (seq_cycle.NEXTVAL, 1006, 108, 2, DATE '2023-11-08', DATE '2024-02-26', DATE '2024-02-27', 3.50,  'HARVESTED', NULL);

-- Farmer 1007 (Pooja) - Maize, Wheat, Watermelon (Zaid)
INSERT INTO crop_cycles VALUES (seq_cycle.NEXTVAL, 1007, 103, 1, DATE '2023-07-05', DATE '2023-10-13', DATE '2023-10-15', 6.00, 'HARVESTED', NULL);
INSERT INTO crop_cycles VALUES (seq_cycle.NEXTVAL, 1007, 105, 2, DATE '2023-11-22', DATE '2024-04-10', DATE '2024-04-11', 8.00, 'HARVESTED', NULL);
INSERT INTO crop_cycles VALUES (seq_cycle.NEXTVAL, 1007, 109, 3, DATE '2024-03-15', DATE '2024-06-03', DATE '2024-06-05', 2.00, 'HARVESTED', 'Tried zaid season');

-- Farmer 1008 (Vikram) - Mustard, Cucumber (Zaid), Active Wheat
INSERT INTO crop_cycles VALUES (seq_cycle.NEXTVAL, 1008, 107, 2, DATE '2023-11-12', DATE '2024-03-12', DATE '2024-03-14', 4.00, 'HARVESTED', NULL);
INSERT INTO crop_cycles VALUES (seq_cycle.NEXTVAL, 1008, 110, 3, DATE '2024-03-20', DATE '2024-05-19', DATE '2024-05-22', 1.50, 'HARVESTED', NULL);
INSERT INTO crop_cycles VALUES (seq_cycle.NEXTVAL, 1008, 105, 2, DATE '2024-11-18', DATE '2025-04-07', NULL,             5.00, 'ACTIVE',    'Currently growing');

-- ===================== WATER_USAGE =====================
-- Cycle 5001: Rice Ramesh (heavy water)
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5001, DATE '2023-06-22', 'CANAL',    420000, 'FLOOD');
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5001, DATE '2023-07-10', 'CANAL',    380000, 'FLOOD');
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5001, DATE '2023-07-28', 'BOREWELL', 350000, 'FLOOD');
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5001, DATE '2023-08-15', 'CANAL',    400000, 'FLOOD');
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5001, DATE '2023-09-02', 'BOREWELL', 320000, 'FLOOD');

-- Cycle 5002: Wheat Ramesh
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5002, DATE '2023-11-20', 'BOREWELL', 95000,  'SPRINKLER');
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5002, DATE '2023-12-25', 'CANAL',    110000, 'FLOOD');
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5002, DATE '2024-02-10', 'BOREWELL', 100000, 'SPRINKLER');
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5002, DATE '2024-03-15', 'CANAL',    85000,  'FLOOD');

-- Cycle 5003: Rice Suresh
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5003, DATE '2023-06-28', 'CANAL',    580000, 'FLOOD');
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5003, DATE '2023-07-20', 'TUBE_WELL',520000, 'FLOOD');
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5003, DATE '2023-08-18', 'CANAL',    540000, 'FLOOD');
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5003, DATE '2023-09-15', 'TUBE_WELL',490000, 'FLOOD');

-- Cycle 5004: Wheat Suresh
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5004, DATE '2023-11-25', 'TUBE_WELL',150000, 'FLOOD');
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5004, DATE '2024-01-05', 'CANAL',    140000, 'FLOOD');
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5004, DATE '2024-02-20', 'TUBE_WELL',130000, 'FLOOD');

-- Cycle 5005: Cotton Mahesh (drip irrigation, water-efficient)
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5005, DATE '2023-06-20', 'BOREWELL', 90000,  'DRIP');
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5005, DATE '2023-07-25', 'BOREWELL', 95000,  'DRIP');
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5005, DATE '2023-08-30', 'BOREWELL', 100000, 'DRIP');
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5005, DATE '2023-10-10', 'BOREWELL', 85000,  'DRIP');
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5005, DATE '2023-11-15', 'BOREWELL', 80000,  'DRIP');

-- Cycle 5006: Mustard Mahesh
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5006, DATE '2023-11-15', 'BOREWELL', 18000, 'DRIP');
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5006, DATE '2023-12-20', 'BOREWELL', 20000, 'DRIP');
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5006, DATE '2024-02-05', 'BOREWELL', 22000, 'DRIP');

-- Cycle 5007: Maize Lakshmi
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5007, DATE '2023-07-05', 'RAIN',  100,    'MANUAL');
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5007, DATE '2023-08-10', 'POND', 30000,  'FURROW');
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5007, DATE '2023-09-05', 'POND', 28000,  'FURROW');

-- Skip ahead - small writes for remaining cycles
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5008, DATE '2023-11-10', 'POND',     8000,  'FURROW');
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5008, DATE '2023-12-15', 'POND',     7500,  'FURROW');
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5009, DATE '2023-06-25', 'CANAL',    750000,'FLOOD');
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5009, DATE '2023-08-10', 'TUBE_WELL',680000,'FLOOD');
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5009, DATE '2023-09-20', 'CANAL',    700000,'FLOOD');
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5010, DATE '2023-11-22', 'TUBE_WELL',200000,'SPRINKLER');
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5010, DATE '2024-01-10', 'CANAL',    190000,'FLOOD');
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5010, DATE '2024-02-25', 'TUBE_WELL',180000,'SPRINKLER');
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5011, DATE '2023-07-02', 'BOREWELL', 60000, 'DRIP');
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5011, DATE '2023-08-15', 'BOREWELL', 65000, 'DRIP');
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5011, DATE '2023-10-05', 'BOREWELL', 55000, 'DRIP');
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5012, DATE '2023-11-12', 'BOREWELL', 9500,  'DRIP');
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5012, DATE '2024-01-08', 'BOREWELL', 10500, 'DRIP');
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5013, DATE '2023-07-12', 'BOREWELL', 36000, 'SPRINKLER');
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5013, DATE '2023-08-25', 'BOREWELL', 32000, 'SPRINKLER');
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5014, DATE '2023-11-25', 'BOREWELL', 78000, 'SPRINKLER');
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5014, DATE '2024-01-15', 'BOREWELL', 82000, 'SPRINKLER');
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5015, DATE '2024-03-18', 'POND',     35000, 'DRIP');
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5015, DATE '2024-04-25', 'POND',     30000, 'DRIP');
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5016, DATE '2023-11-15', 'POND',     11000, 'FURROW');
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5016, DATE '2024-01-20', 'POND',     12000, 'FURROW');
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5017, DATE '2024-03-22', 'POND',     14000, 'DRIP');
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5017, DATE '2024-04-15', 'POND',     12500, 'DRIP');
INSERT INTO water_usage VALUES (seq_water.NEXTVAL, 5018, DATE '2024-11-20', 'POND',     46000, 'SPRINKLER');

-- ===================== FERTILIZER_USAGE =====================
-- (total_cost left NULL; trigger computes it)
INSERT INTO fertilizer_usage (usage_id, cycle_id, fertilizer_id, application_date, quantity_kg, application_method) VALUES (seq_fert_use.NEXTVAL, 5001, 201, DATE '2023-06-25', 320, 'BROADCAST');
INSERT INTO fertilizer_usage (usage_id, cycle_id, fertilizer_id, application_date, quantity_kg, application_method) VALUES (seq_fert_use.NEXTVAL, 5001, 202, DATE '2023-07-15', 180, 'BAND');
INSERT INTO fertilizer_usage (usage_id, cycle_id, fertilizer_id, application_date, quantity_kg, application_method) VALUES (seq_fert_use.NEXTVAL, 5001, 203, DATE '2023-08-20', 90, 'BROADCAST');
INSERT INTO fertilizer_usage (usage_id, cycle_id, fertilizer_id, application_date, quantity_kg, application_method) VALUES (seq_fert_use.NEXTVAL, 5002, 201, DATE '2023-11-22', 380, 'BROADCAST');
INSERT INTO fertilizer_usage (usage_id, cycle_id, fertilizer_id, application_date, quantity_kg, application_method) VALUES (seq_fert_use.NEXTVAL, 5002, 202, DATE '2023-12-10', 220, 'BAND');
INSERT INTO fertilizer_usage (usage_id, cycle_id, fertilizer_id, application_date, quantity_kg, application_method) VALUES (seq_fert_use.NEXTVAL, 5002, 203, DATE '2024-02-15', 150, 'BROADCAST');
INSERT INTO fertilizer_usage (usage_id, cycle_id, fertilizer_id, application_date, quantity_kg, application_method) VALUES (seq_fert_use.NEXTVAL, 5003, 201, DATE '2023-07-02', 480, 'BROADCAST');
INSERT INTO fertilizer_usage (usage_id, cycle_id, fertilizer_id, application_date, quantity_kg, application_method) VALUES (seq_fert_use.NEXTVAL, 5003, 202, DATE '2023-07-25', 300, 'BAND');
INSERT INTO fertilizer_usage (usage_id, cycle_id, fertilizer_id, application_date, quantity_kg, application_method) VALUES (seq_fert_use.NEXTVAL, 5003, 204, DATE '2023-08-25', 200, 'BROADCAST');
INSERT INTO fertilizer_usage (usage_id, cycle_id, fertilizer_id, application_date, quantity_kg, application_method) VALUES (seq_fert_use.NEXTVAL, 5004, 201, DATE '2023-11-30', 580, 'BROADCAST');
INSERT INTO fertilizer_usage (usage_id, cycle_id, fertilizer_id, application_date, quantity_kg, application_method) VALUES (seq_fert_use.NEXTVAL, 5004, 202, DATE '2023-12-15', 320, 'BAND');
INSERT INTO fertilizer_usage (usage_id, cycle_id, fertilizer_id, application_date, quantity_kg, application_method) VALUES (seq_fert_use.NEXTVAL, 5005, 205, DATE '2023-06-25', 450, 'FERTIGATION');
INSERT INTO fertilizer_usage (usage_id, cycle_id, fertilizer_id, application_date, quantity_kg, application_method) VALUES (seq_fert_use.NEXTVAL, 5005, 207, DATE '2023-07-20', 1000,'BROADCAST');
INSERT INTO fertilizer_usage (usage_id, cycle_id, fertilizer_id, application_date, quantity_kg, application_method) VALUES (seq_fert_use.NEXTVAL, 5005, 201, DATE '2023-09-10', 250, 'FERTIGATION');
INSERT INTO fertilizer_usage (usage_id, cycle_id, fertilizer_id, application_date, quantity_kg, application_method) VALUES (seq_fert_use.NEXTVAL, 5006, 204, DATE '2023-11-15', 80, 'BAND');
INSERT INTO fertilizer_usage (usage_id, cycle_id, fertilizer_id, application_date, quantity_kg, application_method) VALUES (seq_fert_use.NEXTVAL, 5006, 201, DATE '2023-12-20', 50, 'BROADCAST');
INSERT INTO fertilizer_usage (usage_id, cycle_id, fertilizer_id, application_date, quantity_kg, application_method) VALUES (seq_fert_use.NEXTVAL, 5007, 201, DATE '2023-07-12', 120, 'BROADCAST');
INSERT INTO fertilizer_usage (usage_id, cycle_id, fertilizer_id, application_date, quantity_kg, application_method) VALUES (seq_fert_use.NEXTVAL, 5007, 207, DATE '2023-08-05', 250, 'BROADCAST');
INSERT INTO fertilizer_usage (usage_id, cycle_id, fertilizer_id, application_date, quantity_kg, application_method) VALUES (seq_fert_use.NEXTVAL, 5008, 206, DATE '2023-11-10', 120, 'BAND');
INSERT INTO fertilizer_usage (usage_id, cycle_id, fertilizer_id, application_date, quantity_kg, application_method) VALUES (seq_fert_use.NEXTVAL, 5008, 207, DATE '2023-12-05', 150, 'BROADCAST');
INSERT INTO fertilizer_usage (usage_id, cycle_id, fertilizer_id, application_date, quantity_kg, application_method) VALUES (seq_fert_use.NEXTVAL, 5009, 201, DATE '2023-06-28', 720, 'BROADCAST');
INSERT INTO fertilizer_usage (usage_id, cycle_id, fertilizer_id, application_date, quantity_kg, application_method) VALUES (seq_fert_use.NEXTVAL, 5009, 202, DATE '2023-07-22', 420, 'BAND');
INSERT INTO fertilizer_usage (usage_id, cycle_id, fertilizer_id, application_date, quantity_kg, application_method) VALUES (seq_fert_use.NEXTVAL, 5009, 203, DATE '2023-09-05', 200, 'BROADCAST');
INSERT INTO fertilizer_usage (usage_id, cycle_id, fertilizer_id, application_date, quantity_kg, application_method) VALUES (seq_fert_use.NEXTVAL, 5010, 201, DATE '2023-11-25', 760, 'BROADCAST');
INSERT INTO fertilizer_usage (usage_id, cycle_id, fertilizer_id, application_date, quantity_kg, application_method) VALUES (seq_fert_use.NEXTVAL, 5010, 202, DATE '2023-12-12', 440, 'BAND');
INSERT INTO fertilizer_usage (usage_id, cycle_id, fertilizer_id, application_date, quantity_kg, application_method) VALUES (seq_fert_use.NEXTVAL, 5011, 205, DATE '2023-07-02', 280, 'FERTIGATION');
INSERT INTO fertilizer_usage (usage_id, cycle_id, fertilizer_id, application_date, quantity_kg, application_method) VALUES (seq_fert_use.NEXTVAL, 5011, 207, DATE '2023-08-05', 600, 'BROADCAST');
INSERT INTO fertilizer_usage (usage_id, cycle_id, fertilizer_id, application_date, quantity_kg, application_method) VALUES (seq_fert_use.NEXTVAL, 5011, 201, DATE '2023-10-15', 180, 'FERTIGATION');
INSERT INTO fertilizer_usage (usage_id, cycle_id, fertilizer_id, application_date, quantity_kg, application_method) VALUES (seq_fert_use.NEXTVAL, 5012, 204, DATE '2023-11-12', 95, 'BAND');
INSERT INTO fertilizer_usage (usage_id, cycle_id, fertilizer_id, application_date, quantity_kg, application_method) VALUES (seq_fert_use.NEXTVAL, 5013, 201, DATE '2023-07-12', 140, 'BROADCAST');
INSERT INTO fertilizer_usage (usage_id, cycle_id, fertilizer_id, application_date, quantity_kg, application_method) VALUES (seq_fert_use.NEXTVAL, 5013, 202, DATE '2023-08-02', 75, 'BAND');
INSERT INTO fertilizer_usage (usage_id, cycle_id, fertilizer_id, application_date, quantity_kg, application_method) VALUES (seq_fert_use.NEXTVAL, 5014, 201, DATE '2023-11-30', 305, 'BROADCAST');
INSERT INTO fertilizer_usage (usage_id, cycle_id, fertilizer_id, application_date, quantity_kg, application_method) VALUES (seq_fert_use.NEXTVAL, 5014, 202, DATE '2023-12-18', 175, 'BAND');
INSERT INTO fertilizer_usage (usage_id, cycle_id, fertilizer_id, application_date, quantity_kg, application_method) VALUES (seq_fert_use.NEXTVAL, 5015, 204, DATE '2024-03-20', 100, 'BAND');
INSERT INTO fertilizer_usage (usage_id, cycle_id, fertilizer_id, application_date, quantity_kg, application_method) VALUES (seq_fert_use.NEXTVAL, 5015, 207, DATE '2024-04-15', 200, 'BROADCAST');
INSERT INTO fertilizer_usage (usage_id, cycle_id, fertilizer_id, application_date, quantity_kg, application_method) VALUES (seq_fert_use.NEXTVAL, 5016, 204, DATE '2023-11-15', 100, 'BAND');
INSERT INTO fertilizer_usage (usage_id, cycle_id, fertilizer_id, application_date, quantity_kg, application_method) VALUES (seq_fert_use.NEXTVAL, 5017, 207, DATE '2024-03-22', 150, 'BROADCAST');
INSERT INTO fertilizer_usage (usage_id, cycle_id, fertilizer_id, application_date, quantity_kg, application_method) VALUES (seq_fert_use.NEXTVAL, 5017, 204, DATE '2024-04-10', 60, 'BAND');
INSERT INTO fertilizer_usage (usage_id, cycle_id, fertilizer_id, application_date, quantity_kg, application_method) VALUES (seq_fert_use.NEXTVAL, 5018, 201, DATE '2024-11-25', 190, 'BROADCAST');

-- ===================== YIELD_RECORDS =====================
-- (total_revenue left NULL; trigger computes it)
INSERT INTO yield_records (yield_id, cycle_id, harvest_date, yield_quantity_kg, quality_grade, market_price_per_kg) VALUES (seq_yield.NEXTVAL, 5001, DATE '2023-10-30', 28800, 'A', 38.00);
INSERT INTO yield_records (yield_id, cycle_id, harvest_date, yield_quantity_kg, quality_grade, market_price_per_kg) VALUES (seq_yield.NEXTVAL, 5002, DATE '2024-04-06', 42000, 'A', 22.00);
INSERT INTO yield_records (yield_id, cycle_id, harvest_date, yield_quantity_kg, quality_grade, market_price_per_kg) VALUES (seq_yield.NEXTVAL, 5003, DATE '2023-10-14', 39600, 'B', 21.50);
INSERT INTO yield_records (yield_id, cycle_id, harvest_date, yield_quantity_kg, quality_grade, market_price_per_kg) VALUES (seq_yield.NEXTVAL, 5004, DATE '2024-04-15', 60000, 'A', 23.00);
INSERT INTO yield_records (yield_id, cycle_id, harvest_date, yield_quantity_kg, quality_grade, market_price_per_kg) VALUES (seq_yield.NEXTVAL, 5005, DATE '2023-12-15', 16000, 'A', 65.00);
INSERT INTO yield_records (yield_id, cycle_id, harvest_date, yield_quantity_kg, quality_grade, market_price_per_kg) VALUES (seq_yield.NEXTVAL, 5006, DATE '2024-03-12', 5500,  'B', 55.00);
INSERT INTO yield_records (yield_id, cycle_id, harvest_date, yield_quantity_kg, quality_grade, market_price_per_kg) VALUES (seq_yield.NEXTVAL, 5007, DATE '2023-10-10', 17500, 'B', 18.50);
INSERT INTO yield_records (yield_id, cycle_id, harvest_date, yield_quantity_kg, quality_grade, market_price_per_kg) VALUES (seq_yield.NEXTVAL, 5008, DATE '2024-02-25', 4200,  'B', 58.00);
INSERT INTO yield_records (yield_id, cycle_id, harvest_date, yield_quantity_kg, quality_grade, market_price_per_kg) VALUES (seq_yield.NEXTVAL, 5009, DATE '2023-11-02', 72000, 'A', 42.00);
INSERT INTO yield_records (yield_id, cycle_id, harvest_date, yield_quantity_kg, quality_grade, market_price_per_kg) VALUES (seq_yield.NEXTVAL, 5010, DATE '2024-04-08', 88000, 'A', 22.50);
INSERT INTO yield_records (yield_id, cycle_id, harvest_date, yield_quantity_kg, quality_grade, market_price_per_kg) VALUES (seq_yield.NEXTVAL, 5011, DATE '2023-12-28', 9000,  'A', 68.00);
INSERT INTO yield_records (yield_id, cycle_id, harvest_date, yield_quantity_kg, quality_grade, market_price_per_kg) VALUES (seq_yield.NEXTVAL, 5012, DATE '2024-02-27', 4800,  'A', 60.00);
INSERT INTO yield_records (yield_id, cycle_id, harvest_date, yield_quantity_kg, quality_grade, market_price_per_kg) VALUES (seq_yield.NEXTVAL, 5013, DATE '2023-10-15', 19800, 'A', 19.00);
INSERT INTO yield_records (yield_id, cycle_id, harvest_date, yield_quantity_kg, quality_grade, market_price_per_kg) VALUES (seq_yield.NEXTVAL, 5014, DATE '2024-04-11', 32000, 'A', 22.50);
INSERT INTO yield_records (yield_id, cycle_id, harvest_date, yield_quantity_kg, quality_grade, market_price_per_kg) VALUES (seq_yield.NEXTVAL, 5015, DATE '2024-06-05', 18000, 'A', 12.00);
INSERT INTO yield_records (yield_id, cycle_id, harvest_date, yield_quantity_kg, quality_grade, market_price_per_kg) VALUES (seq_yield.NEXTVAL, 5016, DATE '2024-03-14', 4400,  'B', 54.00);
INSERT INTO yield_records (yield_id, cycle_id, harvest_date, yield_quantity_kg, quality_grade, market_price_per_kg) VALUES (seq_yield.NEXTVAL, 5017, DATE '2024-05-22', 11250, 'A', 18.00);

COMMIT;
PROMPT Sample data loaded.
