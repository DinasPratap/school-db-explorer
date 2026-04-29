const express = require('express');
const oracledb = require('oracledb');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(cors());
app.use(express.json());

// Oracle Database Connection
async function initializeOracle() {
  try {
    await oracledb.createPool({
      user: 'system',
      password: 'Oracle123',
      connectionString: 'localhost:1521/XE',
      poolMin: 2,
      poolMax: 10,
      poolIncrement: 1
    });
    console.log('Oracle Database connection pool created');
  } catch (err) {
    console.error('Error creating Oracle connection pool:', err);
    process.exit(1);
  }
}

async function executeQuery(sql, params = {}) {
  let connection;
  try {
    connection = await oracledb.getConnection();
    const result = await connection.execute(sql, params, {
      outFormat: oracledb.OUT_FORMAT_OBJECT
    });
    return result.rows;
  } catch (err) {
    console.error('Error executing query:', err);
    throw err;
  } finally {
    if (connection) {
      await connection.close();
    }
  }
}

// API Routes

// Get all farmers
app.get('/api/farmers', async (req, res) => {
  try {
    const sql = `SELECT farmer_id, name, contact_number, village, district, state, 
                        total_land_acres, soil_type, has_irrigation, registered_on 
                 FROM farmers 
                 ORDER BY name`;
    const farmers = await executeQuery(sql);
    res.json(farmers);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get farmer by ID
app.get('/api/farmers/:id', async (req, res) => {
  try {
    const sql = `SELECT * FROM farmers WHERE farmer_id = :id`;
    const farmer = await executeQuery(sql, { id: req.params.id });
    res.json(farmer[0] || {});
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Create farmer
app.post('/api/farmers', async (req, res) => {
  try {
    const { name, contact_number, village, district, state, total_land_acres, soil_type, has_irrigation } = req.body;
    const sql = `INSERT INTO farmers (farmer_id, name, contact_number, village, district, state, 
                                      total_land_acres, soil_type, has_irrigation, registered_on)
                 VALUES (seq_farmer.NEXTVAL, :name, :contact_number, :village, :district, :state,
                         :total_land_acres, :soil_type, :has_irrigation, SYSDATE)
                 RETURNING farmer_id INTO :new_id`;
    
    const connection = await oracledb.getConnection();
    const result = await connection.execute(sql, {
      name, contact_number, village, district, state, 
      total_land_acres, soil_type, has_irrigation,
      new_id: { type: oracledb.NUMBER, dir: oracledb.BIND_OUT }
    });
    await connection.commit();
    await connection.close();
    
    res.json({ farmer_id: result.outBinds.new_id, message: 'Farmer created successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Update farmer
app.put('/api/farmers/:id', async (req, res) => {
  try {
    const { name, contact_number, village, district, state, total_land_acres, soil_type, has_irrigation } = req.body;
    const sql = `UPDATE farmers 
                 SET name = :name, contact_number = :contact_number, village = :village, 
                     district = :district, state = :state, total_land_acres = :total_land_acres,
                     soil_type = :soil_type, has_irrigation = :has_irrigation
                 WHERE farmer_id = :id`;
    
    const connection = await oracledb.getConnection();
    await connection.execute(sql, { 
      id: req.params.id, name, contact_number, village, district, state, 
      total_land_acres, soil_type, has_irrigation 
    });
    await connection.commit();
    await connection.close();
    
    res.json({ message: 'Farmer updated successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Delete farmer
app.delete('/api/farmers/:id', async (req, res) => {
  try {
    const sql = `DELETE FROM farmers WHERE farmer_id = :id`;
    
    const connection = await oracledb.getConnection();
    await connection.execute(sql, { id: req.params.id });
    await connection.commit();
    await connection.close();
    
    res.json({ message: 'Farmer deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get all crops
app.get('/api/crops', async (req, res) => {
  try {
    const sql = `SELECT c.*, s.season_name 
                 FROM crops c 
                 JOIN seasons s ON c.season_id = s.season_id 
                 ORDER BY c.crop_name`;
    const crops = await executeQuery(sql);
    res.json(crops);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get crop cycles
app.get('/api/crop-cycles', async (req, res) => {
  try {
    const sql = `SELECT cc.*, f.name as farmer_name, c.crop_name, s.season_name 
                 FROM crop_cycles cc 
                 JOIN farmers f ON cc.farmer_id = f.farmer_id 
                 JOIN crops c ON cc.crop_id = c.crop_id 
                 JOIN seasons s ON cc.season_id = s.season_id 
                 ORDER BY cc.sowing_date DESC`;
    const cycles = await executeQuery(sql);
    res.json(cycles);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Create crop cycle
app.post('/api/crop-cycles', async (req, res) => {
  try {
    const { farmer_id, crop_id, sowing_date, area_acres } = req.body;
    const sql = `INSERT INTO crop_cycles (cycle_id, farmer_id, crop_id, season_id, sowing_date, 
                                        expected_harvest_date, area_acres, status)
                 SELECT seq_cycle.NEXTVAL, :farmer_id, :crop_id, c.season_id, :sowing_date,
                        :sowing_date + c.avg_growth_days, :area_acres, 'ACTIVE'
                 FROM crops c WHERE c.crop_id = :crop_id
                 RETURNING cycle_id INTO :new_id`;
    
    const connection = await oracledb.getConnection();
    const result = await connection.execute(sql, {
      farmer_id, crop_id, sowing_date, area_acres,
      new_id: { type: oracledb.NUMBER, dir: oracledb.BIND_OUT }
    });
    await connection.commit();
    await connection.close();
    
    res.json({ cycle_id: result.outBinds.new_id, message: 'Crop cycle created successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Update crop cycle
app.put('/api/crop-cycles/:id', async (req, res) => {
  try {
    const { area_acres, status } = req.body;
    const sql = `UPDATE crop_cycles 
                 SET area_acres = :area_acres, status = :status
                 WHERE cycle_id = :id`;
    
    const connection = await oracledb.getConnection();
    await connection.execute(sql, { id: req.params.id, area_acres, status });
    await connection.commit();
    await connection.close();
    
    res.json({ message: 'Crop cycle updated successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Delete crop cycle
app.delete('/api/crop-cycles/:id', async (req, res) => {
  try {
    const sql = `DELETE FROM crop_cycles WHERE cycle_id = :id`;
    
    const connection = await oracledb.getConnection();
    await connection.execute(sql, { id: req.params.id });
    await connection.commit();
    await connection.close();
    
    res.json({ message: 'Crop cycle deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get water usage for a cycle
app.get('/api/water-usage/:cycleId', async (req, res) => {
  try {
    const sql = `SELECT * FROM water_usage WHERE cycle_id = :cycle_id ORDER BY usage_date`;
    const water = await executeQuery(sql, { cycle_id: req.params.cycleId });
    res.json(water);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get fertilizer usage for a cycle
app.get('/api/fertilizer-usage/:cycleId', async (req, res) => {
  try {
    const sql = `SELECT fu.*, f.fertilizer_name 
                 FROM fertilizer_usage fu 
                 JOIN fertilizers f ON fu.fertilizer_id = f.fertilizer_id 
                 WHERE fu.cycle_id = :cycle_id 
                 ORDER BY fu.application_date`;
    const fertilizer = await executeQuery(sql, { cycle_id: req.params.cycleId });
    res.json(fertilizer);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get yield records
app.get('/api/yield-records', async (req, res) => {
  try {
    const sql = `SELECT yr.*, cc.farmer_id, f.name as farmer_name, c.crop_name 
                 FROM yield_records yr 
                 JOIN crop_cycles cc ON yr.cycle_id = cc.cycle_id 
                 JOIN farmers f ON cc.farmer_id = f.farmer_id 
                 JOIN crops c ON cc.crop_id = c.crop_id 
                 ORDER BY yr.harvest_date DESC`;
    const yields = await executeQuery(sql);
    res.json(yields);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get farmer summary (view)
app.get('/api/farmer-summary', async (req, res) => {
  try {
    const sql = `SELECT * FROM v_farmer_summary ORDER BY total_revenue DESC`;
    const summary = await executeQuery(sql);
    res.json(summary);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get cycle economics (view)
app.get('/api/cycle-economics', async (req, res) => {
  try {
    const sql = `SELECT * FROM v_cycle_economics ORDER BY sowing_date DESC`;
    const economics = await executeQuery(sql);
    res.json(economics);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get seasonal performance (view)
app.get('/api/seasonal-performance', async (req, res) => {
  try {
    const sql = `SELECT * FROM v_seasonal_performance ORDER BY season_name, total_revenue DESC`;
    const performance = await executeQuery(sql);
    res.json(performance);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get dashboard stats
app.get('/api/dashboard/stats', async (req, res) => {
  try {
    const sql = `
      SELECT 
        (SELECT COUNT(*) FROM farmers) as total_farmers,
        (SELECT COUNT(*) FROM crop_cycles) as total_cycles,
        (SELECT COUNT(*) FROM crop_cycles WHERE status = 'ACTIVE') as active_cycles,
        (SELECT NVL(SUM(total_revenue), 0) FROM yield_records) as total_revenue,
        (SELECT NVL(SUM(area_acres), 0) FROM crop_cycles) as total_cultivated_acres
      FROM DUAL
    `;
    const stats = await executeQuery(sql);
    res.json(stats[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get all water usage aggregated
app.get('/api/water-usage-all', async (req, res) => {
  try {
    const sql = `
      SELECT 
        TO_CHAR(w.usage_date, 'Mon') as month,
        SUM(CASE WHEN w.irrigation_method = 'DRIP' THEN w.quantity_liters ELSE 0 END) as drip,
        SUM(CASE WHEN w.irrigation_method = 'FLOOD' THEN w.quantity_liters ELSE 0 END) as flood
      FROM water_usage w
      JOIN crop_cycles cc ON w.cycle_id = cc.cycle_id
      GROUP BY TO_CHAR(w.usage_date, 'Mon')
      ORDER BY MIN(w.usage_date)
    `;
    const waterData = await executeQuery(sql);
    res.json(waterData);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get all fertilizer usage aggregated
app.get('/api/fertilizer-usage-all', async (req, res) => {
  try {
    const sql = `
      SELECT 
        f.fertilizer_name as name,
        SUM(fu.quantity_kg) as value,
        ROW_NUMBER() OVER (ORDER BY SUM(fu.quantity_kg) DESC) as rn
      FROM fertilizer_usage fu
      JOIN fertilizers f ON fu.fertilizer_id = f.fertilizer_id
      GROUP BY f.fertilizer_name
      ORDER BY SUM(fu.quantity_kg) DESC
    `;
    const fertilizerData = await executeQuery(sql);
    const total = fertilizerData.reduce((sum, item) => sum + item.VALUE, 0);
    const formattedData = fertilizerData.map(item => ({
      name: item.NAME,
      value: Math.round((item.VALUE / total) * 100),
      color: item.RN === 1 ? 'hsl(var(--primary))' : 
             item.RN === 2 ? 'hsl(var(--harvest))' : 
             item.RN === 3 ? 'hsl(var(--water))' : 'hsl(var(--accent))'
    }));
    res.json(formattedData);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get table statistics
app.get('/api/table-stats', async (req, res) => {
  try {
    const tables = [
      { name: 'Farmers', query: 'SELECT COUNT(*) as count FROM farmers', cols: 8, desc: 'Profile, contact, land specs' },
      { name: 'Crops', query: 'SELECT COUNT(*) as count FROM crops', cols: 6, desc: 'Types, varieties, season req.' },
      { name: 'Crop_Cycles', query: 'SELECT COUNT(*) as count FROM crop_cycles', cols: 9, desc: 'Sowing → harvest tracking' },
      { name: 'Fertilizers', query: 'SELECT COUNT(*) as count FROM fertilizers', cols: 7, desc: 'NPK, dosages, price' },
      { name: 'Water_Usage', query: 'SELECT COUNT(*) as count FROM water_usage', cols: 6, desc: 'Irrigation logs' },
      { name: 'Fertilizer_Usage', query: 'SELECT COUNT(*) as count FROM fertilizer_usage', cols: 6, desc: 'Application logs' },
      { name: 'Yield_Records', query: 'SELECT COUNT(*) as count FROM yield_records', cols: 7, desc: 'Harvest & market data' },
      { name: 'Seasons', query: 'SELECT COUNT(*) as count FROM seasons', cols: 4, desc: 'Temporal definitions' },
    ];

    const tableStats = await Promise.all(tables.map(async (table) => {
      try {
        const result = await executeQuery(table.query);
        return {
          name: table.name,
          rows: result[0].COUNT,
          cols: table.cols,
          desc: table.desc
        };
      } catch (err) {
        return {
          name: table.name,
          rows: 0,
          cols: table.cols,
          desc: table.desc
        };
      }
    }));

    res.json(tableStats);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Execute custom SQL query
app.post('/api/execute-sql', async (req, res) => {
  try {
    const { sql } = req.body;
    
    if (!sql) {
      return res.status(400).json({ error: 'SQL query is required' });
    }

    // Basic SQL injection prevention - only allow SELECT queries
    const normalizedSql = sql.trim().toUpperCase();
    if (!normalizedSql.startsWith('SELECT')) {
      return res.status(400).json({ error: 'Only SELECT queries are allowed for security' });
    }

    const result = await executeQuery(sql);
    res.json({ 
      success: true, 
      data: result,
      rowCount: result.length 
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Start server
initializeOracle().then(() => {
  app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
  });
});
