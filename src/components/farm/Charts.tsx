import { Card } from "@/components/ui/card";
import { yieldTrend, resourceMix, waterUsage } from "@/data/mockData";
import {
  ResponsiveContainer, AreaChart, Area, XAxis, YAxis, Tooltip, CartesianGrid,
  PieChart, Pie, Cell, BarChart, Bar, Legend,
} from "recharts";

const tooltipStyle = {
  background: "hsl(var(--card))",
  border: "1px solid hsl(var(--border))",
  borderRadius: 12,
  fontSize: 12,
  boxShadow: "var(--shadow-soft)",
};

export const Charts = () => (
  <div className="grid gap-5 lg:grid-cols-3">
    <Card className="lg:col-span-2 p-6 bg-gradient-card shadow-soft">
      <div className="flex items-baseline justify-between mb-4">
        <div>
          <h3 className="text-lg font-semibold">Yield trend per season</h3>
          <p className="text-xs text-muted-foreground">Tonnes per acre · last 6 seasons</p>
        </div>
      </div>
      <ResponsiveContainer width="100%" height={280}>
        <AreaChart data={yieldTrend}>
          <defs>
            <linearGradient id="g1" x1="0" x2="0" y1="0" y2="1">
              <stop offset="0%" stopColor="hsl(var(--primary))" stopOpacity={0.5} />
              <stop offset="100%" stopColor="hsl(var(--primary))" stopOpacity={0} />
            </linearGradient>
            <linearGradient id="g2" x1="0" x2="0" y1="0" y2="1">
              <stop offset="0%" stopColor="hsl(var(--harvest))" stopOpacity={0.5} />
              <stop offset="100%" stopColor="hsl(var(--harvest))" stopOpacity={0} />
            </linearGradient>
            <linearGradient id="g3" x1="0" x2="0" y1="0" y2="1">
              <stop offset="0%" stopColor="hsl(var(--water))" stopOpacity={0.5} />
              <stop offset="100%" stopColor="hsl(var(--water))" stopOpacity={0} />
            </linearGradient>
          </defs>
          <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" vertical={false} />
          <XAxis dataKey="season" stroke="hsl(var(--muted-foreground))" fontSize={12} />
          <YAxis stroke="hsl(var(--muted-foreground))" fontSize={12} />
          <Tooltip contentStyle={tooltipStyle} />
          <Area type="monotone" dataKey="wheat" stroke="hsl(var(--primary))" strokeWidth={2} fill="url(#g1)" />
          <Area type="monotone" dataKey="rice" stroke="hsl(var(--water))" strokeWidth={2} fill="url(#g3)" />
          <Area type="monotone" dataKey="maize" stroke="hsl(var(--harvest))" strokeWidth={2} fill="url(#g2)" />
        </AreaChart>
      </ResponsiveContainer>
    </Card>

    <Card className="p-6 bg-gradient-card shadow-soft">
      <h3 className="text-lg font-semibold">Fertilizer mix</h3>
      <p className="text-xs text-muted-foreground mb-2">Application share %</p>
      <ResponsiveContainer width="100%" height={260}>
        <PieChart>
          <Pie data={resourceMix} dataKey="value" innerRadius={55} outerRadius={90} paddingAngle={3}>
            {resourceMix.map((e) => <Cell key={e.name} fill={e.color} />)}
          </Pie>
          <Tooltip contentStyle={tooltipStyle} />
        </PieChart>
      </ResponsiveContainer>
      <div className="grid grid-cols-2 gap-2 mt-2">
        {resourceMix.map((r) => (
          <div key={r.name} className="flex items-center gap-2 text-xs">
            <span className="h-2.5 w-2.5 rounded-full" style={{ background: r.color }} />
            <span className="text-muted-foreground">{r.name}</span>
            <span className="ml-auto font-medium">{r.value}%</span>
          </div>
        ))}
      </div>
    </Card>

    <Card className="lg:col-span-3 p-6 bg-gradient-card shadow-soft">
      <div className="flex items-baseline justify-between mb-4">
        <div>
          <h3 className="text-lg font-semibold">Water usage: Drip vs Flood irrigation</h3>
          <p className="text-xs text-muted-foreground">Kilolitres / month · drip adoption rising</p>
        </div>
      </div>
      <ResponsiveContainer width="100%" height={260}>
        <BarChart data={waterUsage}>
          <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" vertical={false} />
          <XAxis dataKey="month" stroke="hsl(var(--muted-foreground))" fontSize={12} />
          <YAxis stroke="hsl(var(--muted-foreground))" fontSize={12} />
          <Tooltip contentStyle={tooltipStyle} />
          <Legend wrapperStyle={{ fontSize: 12 }} />
          <Bar dataKey="drip" stackId="a" fill="hsl(var(--water))" radius={[0, 0, 0, 0]} />
          <Bar dataKey="flood" stackId="a" fill="hsl(var(--accent))" radius={[6, 6, 0, 0]} />
        </BarChart>
      </ResponsiveContainer>
    </Card>
  </div>
);
