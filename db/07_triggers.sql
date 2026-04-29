-- =====================================================================
-- 07_triggers.sql
-- Triggers: validation, auto-compute, audit logging, status update
-- Demonstrates: BEFORE/AFTER, ROW-level and STATEMENT-level,
--               compound triggers / multi-event audit
-- =====================================================================

-- =====================================================================
-- TRIGGER 1: trg_validate_sowing_date
-- Prevents sowing dates that are unreasonably old or in the far future.
-- =====================================================================
CREATE OR REPLACE TRIGGER trg_validate_sowing_date
BEFORE INSERT OR UPDATE OF sowing_date ON crop_cycles
FOR EACH ROW
BEGIN
    IF :NEW.sowing_date < ADD_MONTHS(SYSDATE, -36) THEN
        RAISE_APPLICATION_ERROR(-20100,
            'Sowing date too far in the past (max 3 years).');
    END IF;

    IF :NEW.sowing_date > ADD_MONTHS(SYSDATE, 12) THEN
        RAISE_APPLICATION_ERROR(-20101,
            'Sowing date too far in the future (max 1 year).');
    END IF;
END;
/

-- =====================================================================
-- TRIGGER 2: trg_compute_fertilizer_cost
-- Auto-computes total_cost from fertilizer.cost_per_kg * quantity_kg
-- =====================================================================
CREATE OR REPLACE TRIGGER trg_compute_fertilizer_cost
BEFORE INSERT OR UPDATE OF quantity_kg, fertilizer_id ON fertilizer_usage
FOR EACH ROW
DECLARE
    v_cost_per_kg fertilizers.cost_per_kg%TYPE;
BEGIN
    SELECT cost_per_kg
    INTO   v_cost_per_kg
    FROM   fertilizers
    WHERE  fertilizer_id = :NEW.fertilizer_id;

    :NEW.total_cost := ROUND(:NEW.quantity_kg * v_cost_per_kg, 2);
END;
/

-- =====================================================================
-- TRIGGER 3: trg_compute_yield_revenue
-- Auto-computes total_revenue = yield_quantity_kg * market_price_per_kg
-- =====================================================================
CREATE OR REPLACE TRIGGER trg_compute_yield_revenue
BEFORE INSERT OR UPDATE OF yield_quantity_kg, market_price_per_kg ON yield_records
FOR EACH ROW
BEGIN
    :NEW.total_revenue := ROUND(:NEW.yield_quantity_kg * :NEW.market_price_per_kg, 2);
END;
/

-- =====================================================================
-- TRIGGER 4: trg_close_cycle_on_harvest
-- When yield is recorded, auto-mark cycle as HARVESTED with the date.
-- =====================================================================
CREATE OR REPLACE TRIGGER trg_close_cycle_on_harvest
AFTER INSERT ON yield_records
FOR EACH ROW
BEGIN
    UPDATE crop_cycles
    SET    status = 'HARVESTED',
           actual_harvest_date = :NEW.harvest_date
    WHERE  cycle_id = :NEW.cycle_id
      AND  status = 'ACTIVE';
END;
/

-- =====================================================================
-- TRIGGER 5: trg_audit_farmers
-- Audit trail for INSERT/UPDATE/DELETE on farmers
-- =====================================================================
CREATE OR REPLACE TRIGGER trg_audit_farmers
AFTER INSERT OR UPDATE OR DELETE ON farmers
FOR EACH ROW
DECLARE
    v_action  VARCHAR2(10);
    v_details VARCHAR2(500);
    v_id      VARCHAR2(40);
BEGIN
    IF INSERTING THEN
        v_action  := 'INSERT';
        v_id      := TO_CHAR(:NEW.farmer_id);
        v_details := 'New farmer: ' || :NEW.name || ' (' || :NEW.village || ')';
    ELSIF UPDATING THEN
        v_action  := 'UPDATE';
        v_id      := TO_CHAR(:NEW.farmer_id);
        v_details := 'Farmer updated: ' || :NEW.name;
    ELSIF DELETING THEN
        v_action  := 'DELETE';
        v_id      := TO_CHAR(:OLD.farmer_id);
        v_details := 'Farmer deleted: ' || :OLD.name;
    END IF;

    INSERT INTO audit_log (
        log_id, action_type, table_name, record_id, action_date, performed_by, details
    ) VALUES (
        seq_audit.NEXTVAL, v_action, 'FARMERS', v_id, SYSTIMESTAMP, USER, v_details
    );
END;
/

-- =====================================================================
-- TRIGGER 6: trg_audit_crop_cycles
-- Logs every status change on crop_cycles.
-- =====================================================================
CREATE OR REPLACE TRIGGER trg_audit_crop_cycles
AFTER UPDATE OF status ON crop_cycles
FOR EACH ROW
WHEN (OLD.status <> NEW.status)
BEGIN
    INSERT INTO audit_log (
        log_id, action_type, table_name, record_id, details
    ) VALUES (
        seq_audit.NEXTVAL, 'UPDATE', 'CROP_CYCLES', TO_CHAR(:NEW.cycle_id),
        'Status changed: ' || :OLD.status || ' -> ' || :NEW.status
    );
END;
/

-- =====================================================================
-- TRIGGER 7: trg_check_water_overuse
-- Warning trigger - flags very high single-event water usage.
-- =====================================================================
CREATE OR REPLACE TRIGGER trg_check_water_overuse
BEFORE INSERT ON water_usage
FOR EACH ROW
BEGIN
    IF :NEW.quantity_liters > 1000000 THEN
        RAISE_APPLICATION_ERROR(-20200,
            'Single water entry exceeds 1,000,000 L - please split entry.');
    END IF;
END;
/

PROMPT Triggers compiled successfully.
