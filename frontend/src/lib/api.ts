const API_BASE = 'http://localhost:3001/api';

export interface Farmer {
  FARMER_ID: number;
  NAME: string;
  CONTACT_NUMBER: string;
  VILLAGE: string;
  DISTRICT: string;
  STATE: string;
  TOTAL_LAND_ACRES: number;
  SOIL_TYPE: string;
  HAS_IRRIGATION: string;
  REGISTERED_ON: string;
}

export interface CropCycle {
  CYCLE_ID: number;
  FARMER_ID: number;
  CROP_ID: number;
  SEASON_ID: number;
  SOWING_DATE: string;
  EXPECTED_HARVEST_DATE: string;
  AREA_ACRES: number;
  STATUS: string;
  FARMER_NAME: string;
  CROP_NAME: string;
  SEASON_NAME: string;
}

export interface DashboardStats {
  TOTAL_FARMERS: number;
  TOTAL_CYCLES: number;
  ACTIVE_CYCLES: number;
  TOTAL_REVENUE: number;
  TOTAL_CULTIVATED_ACRES: number;
}

export interface FarmerSummary {
  FARMER_ID: number;
  NAME: string;
  DISTRICT: string;
  CYCLE_COUNT: number;
  TOTAL_YIELD: number;
  TOTAL_REVENUE: number;
  TOTAL_COST: number;
  AVG_YIELD_PER_ACRE: number;
}

export interface SeasonalPerformance {
  SEASON_NAME: string;
  CROP_NAME: string;
  CYCLE_COUNT: number;
  AVG_YIELD_PER_ACRE: number;
  TOTAL_REVENUE: number;
  EFFICIENCY_LABEL: string;
}

export interface CycleEconomics {
  CYCLE_ID: number;
  FARMER_ID: number;
  CROP_NAME: string;
  SOWING_DATE: string;
  AREA_ACRES: number;
  YIELD_QUANTITY_KG: number;
  TOTAL_COST: number;
  TOTAL_REVENUE: number;
}

async function fetchAPI(endpoint: string, options?: RequestInit) {
  const response = await fetch(`${API_BASE}${endpoint}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...options?.headers,
    },
  });

  if (!response.ok) {
    throw new Error(`API error: ${response.statusText}`);
  }

  return response.json();
}

export const api = {
  // Dashboard
  getDashboardStats: (): Promise<DashboardStats> => fetchAPI('/dashboard/stats'),
  
  // Farmers
  getFarmers: (): Promise<Farmer[]> => fetchAPI('/farmers'),
  getFarmer: (id: string): Promise<Farmer> => fetchAPI(`/farmers/${id}`),
  createFarmer: (data: Partial<Farmer>): Promise<{ farmer_id: number; message: string }> =>
    fetchAPI('/farmers', {
      method: 'POST',
      body: JSON.stringify(data),
    }),
  updateFarmer: (id: string, data: Partial<Farmer>): Promise<{ message: string }> =>
    fetchAPI(`/farmers/${id}`, {
      method: 'PUT',
      body: JSON.stringify(data),
    }),
  deleteFarmer: (id: string): Promise<{ message: string }> =>
    fetchAPI(`/farmers/${id}`, {
      method: 'DELETE',
    }),
  
  // Crop Cycles
  getCropCycles: (): Promise<CropCycle[]> => fetchAPI('/crop-cycles'),
  createCropCycle: (data: { farmer_id: number; crop_id: number; sowing_date: string; area_acres: number }): Promise<{ cycle_id: number; message: string }> =>
    fetchAPI('/crop-cycles', {
      method: 'POST',
      body: JSON.stringify(data),
    }),
  updateCropCycle: (id: string, data: { area_acres: number; status: string }): Promise<{ message: string }> =>
    fetchAPI(`/crop-cycles/${id}`, {
      method: 'PUT',
      body: JSON.stringify(data),
    }),
  deleteCropCycle: (id: string): Promise<{ message: string }> =>
    fetchAPI(`/crop-cycles/${id}`, {
      method: 'DELETE',
    }),
  
  // Analytics
  getFarmerSummary: (): Promise<FarmerSummary[]> => fetchAPI('/farmer-summary'),
  getSeasonalPerformance: (): Promise<SeasonalPerformance[]> => fetchAPI('/seasonal-performance'),
  getCycleEconomics: (): Promise<CycleEconomics[]> => fetchAPI('/cycle-economics'),
  
  // Crops
  getCrops: (): Promise<any[]> => fetchAPI('/crops'),
  
  // Water Usage
  getWaterUsage: (cycleId: string): Promise<any[]> => fetchAPI(`/water-usage/${cycleId}`),
  
  // Fertilizer Usage
  getFertilizerUsage: (cycleId: string): Promise<any[]> => fetchAPI(`/fertilizer-usage/${cycleId}`),
  
  // Yield Records
  getYieldRecords: (): Promise<any[]> => fetchAPI('/yield-records'),
  
  // All Water Usage (for charts)
  getAllWaterUsage: (): Promise<any[]> => fetchAPI('/water-usage-all'),
  
  // All Fertilizer Usage (for charts)
  getAllFertilizerUsage: (): Promise<any[]> => fetchAPI('/fertilizer-usage-all'),
  
  // Table statistics
  getTableStats: (): Promise<any[]> => fetchAPI('/table-stats'),
  
  // Execute custom SQL query
  executeSQL: (sql: string): Promise<any> => fetchAPI('/execute-sql', {
    method: 'POST',
    body: JSON.stringify({ sql }),
  }),
};
