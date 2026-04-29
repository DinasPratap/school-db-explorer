import { Card } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { farmers } from "@/data/mockData";
import { Search, MapPin } from "lucide-react";
import { useState } from "react";

const statusStyle: Record<string, string> = {
  Harvested: "bg-primary/10 text-primary border-primary/20",
  Growing: "bg-water/10 text-water border-water/20",
  Sown: "bg-harvest/15 text-[hsl(30_70%_35%)] border-harvest/30",
};

export const FarmersTable = () => {
  const [q, setQ] = useState("");
  const filtered = farmers.filter(
    (f) =>
      f.name.toLowerCase().includes(q.toLowerCase()) ||
      f.village.toLowerCase().includes(q.toLowerCase()) ||
      f.crop.toLowerCase().includes(q.toLowerCase()),
  );

  return (
    <section id="farmers" className="space-y-5">
      <div className="flex items-end justify-between flex-wrap gap-3">
        <div>
          <h2 className="text-2xl md:text-3xl font-bold">Registered farmers</h2>
          <p className="text-muted-foreground mt-1">Live SELECT * FROM Farmers JOIN Crop_Cycles · sample view</p>
        </div>
        <div className="relative w-full sm:w-72">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
          <Input value={q} onChange={(e) => setQ(e.target.value)} placeholder="Search name, village, crop…" className="pl-9 bg-card" />
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
                <th className="px-5 py-3 font-medium text-right">Land (acre)</th>
                <th className="px-5 py-3 font-medium">Crop</th>
                <th className="px-5 py-3 font-medium text-right">Yield (t/acre)</th>
                <th className="px-5 py-3 font-medium">Cycle</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map((f) => (
                <tr key={f.id} className="border-t border-border/60 hover:bg-muted/40 transition-smooth">
                  <td className="px-5 py-3 font-mono text-xs text-muted-foreground">{f.id}</td>
                  <td className="px-5 py-3 font-medium">{f.name}</td>
                  <td className="px-5 py-3">
                    <span className="inline-flex items-center gap-1.5 text-muted-foreground">
                      <MapPin className="h-3.5 w-3.5" /> {f.village}
                    </span>
                  </td>
                  <td className="px-5 py-3 text-right tabular-nums">{f.land.toFixed(1)}</td>
                  <td className="px-5 py-3">{f.crop}</td>
                  <td className="px-5 py-3 text-right tabular-nums font-medium">{f.yield.toFixed(1)}</td>
                  <td className="px-5 py-3">
                    <Badge variant="outline" className={statusStyle[f.status]}>{f.status}</Badge>
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
