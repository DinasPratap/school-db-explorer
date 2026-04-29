import { Card } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { useQuery } from "@tanstack/react-query";
import { api, Farmer } from "@/lib/api";
import { Search, MapPin } from "lucide-react";
import { useState } from "react";

const statusStyle: Record<string, string> = {
  HARVESTED: "bg-primary/10 text-primary border-primary/20",
  ACTIVE: "bg-water/10 text-water border-water/20",
};

export const FarmersTable = () => {
  const [q, setQ] = useState("");
  const { data: farmers = [], isLoading, error } = useQuery({
    queryKey: ["farmers"],
    queryFn: api.getFarmers,
  });

  const filtered = farmers.filter(
    (f: Farmer) =>
      f.NAME.toLowerCase().includes(q.toLowerCase()) ||
      f.VILLAGE.toLowerCase().includes(q.toLowerCase()) ||
      f.DISTRICT.toLowerCase().includes(q.toLowerCase()),
  );

  if (isLoading) {
    return (
      <section id="farmers" className="space-y-5">
        <div className="flex items-end justify-between flex-wrap gap-3">
          <div>
            <h2 className="text-2xl md:text-3xl font-bold">Registered farmers</h2>
            <p className="text-muted-foreground mt-1">Live SELECT * FROM Farmers · sample view</p>
          </div>
        </div>
        <Card className="p-10 text-center text-muted-foreground">Loading farmers...</Card>
      </section>
    );
  }

  if (error) {
    return (
      <section id="farmers" className="space-y-5">
        <div className="flex items-end justify-between flex-wrap gap-3">
          <div>
            <h2 className="text-2xl md:text-3xl font-bold">Registered farmers</h2>
            <p className="text-muted-foreground mt-1">Live SELECT * FROM Farmers · sample view</p>
          </div>
        </div>
        <Card className="p-10 text-center text-muted-foreground">Error loading farmers</Card>
      </section>
    );
  }

  return (
    <section id="farmers" className="space-y-5">
      <div className="flex items-end justify-between flex-wrap gap-3">
        <div>
          <h2 className="text-2xl md:text-3xl font-bold">Registered farmers</h2>
          <p className="text-muted-foreground mt-1">Live SELECT * FROM Farmers · sample view</p>
        </div>
        <div className="relative w-full sm:w-72">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
          <Input value={q} onChange={(e) => setQ(e.target.value)} placeholder="Search name, village, district…" className="pl-9 bg-card" />
        </div>
      </div>

      <Card className="overflow-hidden bg-gradient-card shadow-soft">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead className="bg-muted/60 text-muted-foreground">
              <tr className="text-left">
                <th className="px-5 py-3 font-medium">Farmer ID</th>
                <th className="px-5 py-3 font-medium">Name</th>
                <th className="px-5 py-3 font-medium">Village</th>
                <th className="px-5 py-3 font-medium">District</th>
                <th className="px-5 py-3 font-medium text-right">Land (acre)</th>
                <th className="px-5 py-3 font-medium">Soil Type</th>
                <th className="px-5 py-3 font-medium">Irrigation</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map((f: Farmer) => (
                <tr key={f.FARMER_ID} className="border-t border-border/60 hover:bg-muted/40 transition-smooth">
                  <td className="px-5 py-3 font-mono text-xs text-muted-foreground">{f.FARMER_ID}</td>
                  <td className="px-5 py-3 font-medium">{f.NAME}</td>
                  <td className="px-5 py-3">
                    <span className="inline-flex items-center gap-1.5 text-muted-foreground">
                      <MapPin className="h-3.5 w-3.5" /> {f.VILLAGE}
                    </span>
                  </td>
                  <td className="px-5 py-3 text-muted-foreground">{f.DISTRICT}</td>
                  <td className="px-5 py-3 text-right tabular-nums">{f.TOTAL_LAND_ACRES.toFixed(1)}</td>
                  <td className="px-5 py-3">{f.SOIL_TYPE}</td>
                  <td className="px-5 py-3">
                    <Badge variant="outline" className={f.HAS_IRRIGATION === 'Y' ? "bg-green-10 text-green border-green/20" : "bg-gray-10 text-gray border-gray/20"}>
                      {f.HAS_IRRIGATION === 'Y' ? 'Yes' : 'No'}
                    </Badge>
                  </td>
                </tr>
              ))}
              {filtered.length === 0 && (
                <tr><td colSpan={7} className="px-5 py-10 text-center text-muted-foreground">No matching rows.</td></tr>
              )}
            </tbody>
          </table>
        </div>
      </Card>
    </section>
  );
};
