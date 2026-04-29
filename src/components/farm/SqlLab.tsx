import { Card } from "@/components/ui/card";
import { sampleQueries } from "@/data/mockData";
import { useState } from "react";
import { Play, Database } from "lucide-react";

export const SqlLab = () => {
  const [active, setActive] = useState(0);
  const q = sampleQueries[active];

  return (
    <section id="queries" className="space-y-5">
      <div>
        <h2 className="text-2xl md:text-3xl font-bold">SQL Lab</h2>
        <p className="text-muted-foreground mt-1">A peek at the analytical queries powering this database.</p>
      </div>

      <Card className="overflow-hidden border-border/60 shadow-elegant">
        <div className="grid lg:grid-cols-[260px,1fr]">
          <aside className="bg-sidebar text-sidebar-foreground p-3 lg:p-4 lg:min-h-[320px]">
            <p className="text-[11px] uppercase tracking-wider text-sidebar-foreground/60 px-2 mb-2">Saved queries</p>
            <ul className="space-y-1">
              {sampleQueries.map((s, i) => (
                <li key={s.title}>
                  <button
                    onClick={() => setActive(i)}
                    className={`w-full text-left px-3 py-2 rounded-lg text-sm transition-smooth ${
                      i === active
                        ? "bg-sidebar-accent text-sidebar-primary font-medium"
                        : "text-sidebar-foreground/80 hover:bg-sidebar-accent/60"
                    }`}
                  >
                    {s.title}
                  </button>
                </li>
              ))}
            </ul>
          </aside>

          <div className="bg-[hsl(142_30%_10%)] text-[hsl(60_30%_92%)] flex flex-col">
            <div className="flex items-center justify-between px-5 py-3 border-b border-white/10">
              <div className="flex items-center gap-2 text-xs text-white/60">
                <Database className="h-3.5 w-3.5" /> psql · farmdb=#
              </div>
              <button className="inline-flex items-center gap-1.5 text-xs font-medium px-3 py-1.5 rounded-md bg-primary text-primary-foreground hover:opacity-90 transition-smooth">
                <Play className="h-3 w-3" /> Run
              </button>
            </div>
            <pre className="p-5 text-[13px] leading-relaxed font-mono overflow-x-auto whitespace-pre">
              <code>{q.sql}</code>
            </pre>
            <div className="px-5 py-2.5 border-t border-white/10 text-[11px] text-white/50">
              ✓ Query OK · returned in 42 ms
            </div>
          </div>
        </div>
      </Card>
    </section>
  );
};
