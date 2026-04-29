export const kpis = [
  { label: "Registered Farmers", value: "1,284", delta: "+12.4%", icon: "Users", tint: "primary" },
  { label: "Active Crop Cycles", value: "342", delta: "+5.2%", icon: "Sprout", tint: "harvest" },
  { label: "Water Saved (KL)", value: "8,910", delta: "−24%", icon: "Droplets", tint: "water" },
  { label: "Avg Yield Gain", value: "21.7%", delta: "+3.1%", icon: "TrendingUp", tint: "accent" },
];

export const yieldTrend = [
  { season: "Kharif '23", wheat: 2.8, rice: 3.4, maize: 2.1 },
  { season: "Rabi '23", wheat: 3.1, rice: 3.6, maize: 2.4 },
  { season: "Kharif '24", wheat: 3.4, rice: 3.9, maize: 2.7 },
  { season: "Rabi '24", wheat: 3.7, rice: 4.1, maize: 3.0 },
  { season: "Kharif '25", wheat: 4.0, rice: 4.4, maize: 3.3 },
  { season: "Rabi '25", wheat: 4.3, rice: 4.7, maize: 3.6 },
];

export const resourceMix = [
  { name: "Urea", value: 38, color: "hsl(var(--primary))" },
  { name: "DAP", value: 24, color: "hsl(var(--harvest))" },
  { name: "MOP", value: 18, color: "hsl(var(--water))" },
  { name: "Organic", value: 20, color: "hsl(var(--accent))" },
];

export const waterUsage = [
  { month: "Jan", drip: 120, flood: 380 },
  { month: "Feb", drip: 140, flood: 360 },
  { month: "Mar", drip: 180, flood: 340 },
  { month: "Apr", drip: 220, flood: 300 },
  { month: "May", drip: 260, flood: 280 },
  { month: "Jun", drip: 300, flood: 240 },
];

export const farmers = [
  { id: "F-1042", name: "Ramesh Patel", village: "Anand, GJ", land: 5.2, crop: "Wheat", yield: 4.3, status: "Harvested" },
  { id: "F-1043", name: "Sunita Devi", village: "Karnal, HR", land: 3.8, crop: "Rice", yield: 4.7, status: "Growing" },
  { id: "F-1044", name: "Mohan Reddy", village: "Guntur, AP", land: 7.1, crop: "Maize", yield: 3.6, status: "Sown" },
  { id: "F-1045", name: "Lakshmi Iyer", village: "Thanjavur, TN", land: 4.4, crop: "Rice", yield: 4.5, status: "Growing" },
  { id: "F-1046", name: "Hardeep Singh", village: "Ludhiana, PB", land: 9.3, crop: "Wheat", yield: 4.6, status: "Harvested" },
  { id: "F-1047", name: "Anita Bose", village: "Burdwan, WB", land: 2.9, crop: "Rice", yield: 4.1, status: "Growing" },
];

export const sampleQueries = [
  {
    title: "Top yielding farmers per season",
    sql: `SELECT s.season_name, f.name, MAX(y.quantity_per_acre) AS best_yield
FROM Yield_Records y
JOIN Crop_Cycles c   ON c.cycle_id = y.cycle_id
JOIN Farmers f       ON f.farmer_id = c.farmer_id
JOIN Seasons s       ON s.season_id = c.season_id
GROUP BY s.season_name, f.name
ORDER BY best_yield DESC
LIMIT 10;`,
  },
  {
    title: "Water efficiency by irrigation method",
    sql: `SELECT w.method,
       AVG(y.quantity_per_acre / NULLIF(w.litres_per_acre, 0)) AS efficiency
FROM Water_Usage w
JOIN Crop_Cycles c ON c.cycle_id = w.cycle_id
JOIN Yield_Records y ON y.cycle_id = c.cycle_id
GROUP BY w.method
HAVING COUNT(*) > 5
ORDER BY efficiency DESC;`,
  },
  {
    title: "Fertilizer ROI per crop (CTE)",
    sql: `WITH cost AS (
  SELECT c.crop_id, SUM(fu.qty_kg * f.price_per_kg) AS spend
  FROM Fertilizer_Usage fu
  JOIN Fertilizers f ON f.fert_id = fu.fert_id
  JOIN Crop_Cycles c ON c.cycle_id = fu.cycle_id
  GROUP BY c.crop_id
)
SELECT cr.name, ROUND(SUM(y.revenue) / cost.spend, 2) AS roi
FROM cost
JOIN Crops cr ON cr.crop_id = cost.crop_id
JOIN Yield_Records y ON y.crop_id = cr.crop_id
GROUP BY cr.name, cost.spend
ORDER BY roi DESC;`,
  },
];

export const tables = [
  { name: "Farmers", rows: 1284, cols: 8, desc: "Profile, contact, land specs" },
  { name: "Crops", rows: 47, cols: 6, desc: "Types, varieties, season req." },
  { name: "Crop_Cycles", rows: 5612, cols: 9, desc: "Sowing → harvest tracking" },
  { name: "Fertilizers", rows: 32, cols: 7, desc: "NPK, dosages, price" },
  { name: "Water_Usage", rows: 18420, cols: 6, desc: "Irrigation logs" },
  { name: "Fertilizer_Usage", rows: 14092, cols: 6, desc: "Application logs" },
  { name: "Yield_Records", rows: 4812, cols: 7, desc: "Harvest & market data" },
  { name: "Seasons", rows: 12, cols: 4, desc: "Temporal definitions" },
];
