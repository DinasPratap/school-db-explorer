import { Card } from "@/components/ui/card";
import { useQuery } from "@tanstack/react-query";
import { api } from "@/lib/api";
import { Users, Sprout, Droplets, TrendingUp, ArrowUpRight, ArrowDownRight } from "lucide-react";

const ICONS = { Users, Sprout, Droplets, TrendingUp } as const;
const TINTS: Record<string, string> = {
  primary: "bg-gradient-primary text-primary-foreground",
  harvest: "bg-gradient-harvest text-harvest-foreground",
  water: "bg-gradient-water text-water-foreground",
  accent: "bg-gradient-soil text-accent-foreground",
};

export const KpiGrid = () => {
  const { data: stats, isLoading, error } = useQuery({
    queryKey: ["dashboard-stats"],
    queryFn: api.getDashboardStats,
  });

  if (isLoading) {
    return <div className="grid gap-5 sm:grid-cols-2 lg:grid-cols-4">Loading...</div>;
  }

  if (error) {
    return <div className="grid gap-5 sm:grid-cols-2 lg:grid-cols-4">Error loading stats</div>;
  }

  const kpis = [
    { label: "Registered Farmers", value: stats?.TOTAL_FARMERS?.toLocaleString() || "0", delta: "+12.4%", icon: "Users", tint: "primary" },
    { label: "Active Crop Cycles", value: stats?.ACTIVE_CYCLES?.toLocaleString() || "0", delta: "+5.2%", icon: "Sprout", tint: "harvest" },
    { label: "Total Revenue", value: `₹${(stats?.TOTAL_REVENUE || 0).toLocaleString()}`, delta: "+8.1%", icon: "TrendingUp", tint: "accent" },
    { label: "Cultivated Acres", value: stats?.TOTAL_CULTIVATED_ACRES?.toLocaleString() || "0", delta: "+3.7%", icon: "Droplets", tint: "water" },
  ];

  return (
    <div className="grid gap-5 sm:grid-cols-2 lg:grid-cols-4">
      {kpis.map((k, i) => {
        const Icon = ICONS[k.icon as keyof typeof ICONS];
        const positive = !k.delta.startsWith("−");
        return (
          <Card
            key={k.label}
            className="p-5 bg-gradient-card border-border/60 shadow-soft hover:shadow-elegant transition-smooth animate-fade-up"
            style={{ animationDelay: `${i * 80}ms` }}
          >
            <div className="flex items-start justify-between">
              <div className={`h-11 w-11 rounded-xl grid place-items-center ${TINTS[k.tint]} shadow-soft`}>
                <Icon className="h-5 w-5" />
              </div>
              <span className={`inline-flex items-center text-xs font-medium px-2 py-0.5 rounded-full ${positive ? "text-primary bg-primary/10" : "text-water bg-water/10"}`}>
                {positive ? <ArrowUpRight className="h-3 w-3 mr-0.5" /> : <ArrowDownRight className="h-3 w-3 mr-0.5" />}
                {k.delta}
              </span>
            </div>
            <p className="mt-5 text-3xl font-bold tracking-tight">{k.value}</p>
            <p className="text-sm text-muted-foreground mt-1">{k.label}</p>
          </Card>
        );
      })}
    </div>
  );
};
