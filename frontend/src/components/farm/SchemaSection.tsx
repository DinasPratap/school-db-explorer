import { Card } from "@/components/ui/card";
import { useQuery } from "@tanstack/react-query";
import { api } from "@/lib/api";
import { Table2, Key, Link2 } from "lucide-react";

export const SchemaSection = () => {
  const { data: tables = [], isLoading, error } = useQuery({
    queryKey: ["table-stats"],
    queryFn: api.getTableStats,
  });

  if (isLoading) {
    return (
      <section id="schema" className="space-y-6">
        <div className="flex items-end justify-between flex-wrap gap-3">
          <div>
            <h2 className="text-2xl md:text-3xl font-bold">Database schema</h2>
            <p className="text-muted-foreground mt-1">8 normalized tables · 3NF/BCNF · referential integrity enforced</p>
          </div>
          <div className="flex items-center gap-4 text-xs text-muted-foreground">
            <span className="inline-flex items-center gap-1.5"><Key className="h-3.5 w-3.5 text-harvest" /> Primary key</span>
            <span className="inline-flex items-center gap-1.5"><Link2 className="h-3.5 w-3.5 text-water" /> Foreign key</span>
          </div>
        </div>
        <Card className="p-10 text-center text-muted-foreground">Loading schema...</Card>
      </section>
    );
  }

  if (error) {
    return (
      <section id="schema" className="space-y-6">
        <div className="flex items-end justify-between flex-wrap gap-3">
          <div>
            <h2 className="text-2xl md:text-3xl font-bold">Database schema</h2>
            <p className="text-muted-foreground mt-1">8 normalized tables · 3NF/BCNF · referential integrity enforced</p>
          </div>
          <div className="flex items-center gap-4 text-xs text-muted-foreground">
            <span className="inline-flex items-center gap-1.5"><Key className="h-3.5 w-3.5 text-harvest" /> Primary key</span>
            <span className="inline-flex items-center gap-1.5"><Link2 className="h-3.5 w-3.5 text-water" /> Foreign key</span>
          </div>
        </div>
        <Card className="p-10 text-center text-muted-foreground">Error loading schema</Card>
      </section>
    );
  }

  return (
    <section id="schema" className="space-y-6">
      <div className="flex items-end justify-between flex-wrap gap-3">
        <div>
          <h2 className="text-2xl md:text-3xl font-bold">Database schema</h2>
          <p className="text-muted-foreground mt-1">8 normalized tables · 3NF/BCNF · referential integrity enforced</p>
        </div>
        <div className="flex items-center gap-4 text-xs text-muted-foreground">
          <span className="inline-flex items-center gap-1.5"><Key className="h-3.5 w-3.5 text-harvest" /> Primary key</span>
          <span className="inline-flex items-center gap-1.5"><Link2 className="h-3.5 w-3.5 text-water" /> Foreign key</span>
        </div>
      </div>

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {tables.map((t: any, i: number) => (
          <Card
            key={t.name}
            className="group p-5 bg-gradient-card border-border/60 shadow-soft hover:shadow-elegant hover:-translate-y-0.5 transition-smooth animate-fade-up"
            style={{ animationDelay: `${i * 60}ms` }}
          >
            <div className="flex items-center gap-2 mb-3">
              <div className="h-8 w-8 rounded-lg bg-primary/10 grid place-items-center">
                <Table2 className="h-4 w-4 text-primary" />
              </div>
              <h3 className="font-semibold font-mono text-sm">{t.name}</h3>
            </div>
            <p className="text-sm text-muted-foreground mb-4 line-clamp-2">{t.desc}</p>
            <div className="flex items-center justify-between text-xs pt-3 border-t border-border/60">
              <span className="text-muted-foreground">{t.cols} columns</span>
              <span className="font-medium tabular-nums">{t.rows.toLocaleString()} rows</span>
            </div>
          </Card>
        ))}
      </div>
    </section>
  );
};
