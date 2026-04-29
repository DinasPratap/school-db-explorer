import { Card } from "@/components/ui/card";
import { sampleQueries } from "@/data/mockData";
import { useState } from "react";
import { Play, Database, Loader2, Table } from "lucide-react";
import { useMutation } from "@tanstack/react-query";
import { api } from "@/lib/api";

export const SqlLab = () => {
  const [active, setActive] = useState(0);
  const [queryResult, setQueryResult] = useState<any>(null);
  const [isRunning, setIsRunning] = useState(false);
  const q = sampleQueries[active];

  const { mutate: runQuery } = useMutation({
    mutationFn: async (sql: string) => {
      return await api.executeSQL(sql);
    },
    onSuccess: (result) => {
      setQueryResult(result);
      setIsRunning(false);
    },
    onError: (error) => {
      setQueryResult({ error: error.message || "Query execution failed" });
      setIsRunning(false);
    }
  });

  const handleRun = () => {
    setIsRunning(true);
    runQuery(q.sql);
  };

  const renderResults = () => {
    if (!queryResult) return null;
    
    if (queryResult.error) {
      return (
        <div className="px-5 py-2.5 border-t border-white/10 text-[11px] text-red-400">
          ✗ {queryResult.error}
        </div>
      );
    }

    if (!queryResult.data || queryResult.data.length === 0) {
      return (
        <div className="px-5 py-2.5 border-t border-white/10 text-[11px] text-white/50">
          ✓ Query OK · 0 rows returned
        </div>
      );
    }

    const columns = Object.keys(queryResult.data[0]);

    return (
      <>
        <div className="px-5 py-2.5 border-t border-white/10 text-[11px] text-white/50">
          ✓ Query OK · {queryResult.rowCount} row{queryResult.rowCount !== 1 ? 's' : ''} returned
        </div>
        <div className="border-t border-white/10 overflow-x-auto">
          <table className="w-full text-xs">
            <thead className="bg-white/10">
              <tr>
                {columns.map((col, i) => (
                  <th key={i} className="px-4 py-2 text-left text-white/80 font-medium">
                    {col}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {queryResult.data.map((row: any, i: number) => (
                <tr key={i} className="border-t border-white/5">
                  {columns.map((col, j) => (
                    <td key={j} className="px-4 py-2 text-white/70 font-mono">
                      {String(row[col] ?? 'NULL')}
                    </td>
                  ))}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </>
    );
  };

  return (
    <section id="queries" className="space-y-5">
      <div>
        <h2 className="text-2xl md:text-3xl font-bold">SQL Lab</h2>
        <p className="text-muted-foreground mt-1">Execute analytical queries against the Oracle database.</p>
      </div>

      <Card className="overflow-hidden border-border/60 shadow-elegant">
        <div className="grid lg:grid-cols-[260px,1fr]">
          <aside className="bg-sidebar text-sidebar-foreground p-3 lg:p-4 lg:min-h-[320px]">
            <p className="text-[11px] uppercase tracking-wider text-sidebar-foreground/60 px-2 mb-2">Saved queries</p>
            <ul className="space-y-1">
              {sampleQueries.map((s, i) => (
                <li key={s.title}>
                  <button
                    onClick={() => { setActive(i); setQueryResult(null); }}
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
                <Database className="h-3.5 w-3.5" /> sqlplus · farmdb=#
              </div>
              <button 
                onClick={handleRun}
                disabled={isRunning}
                className="inline-flex items-center gap-1.5 text-xs font-medium px-3 py-1.5 rounded-md bg-primary text-primary-foreground hover:opacity-90 transition-smooth disabled:opacity-50"
              >
                {isRunning ? <Loader2 className="h-3 w-3 animate-spin" /> : <Play className="h-3 w-3" />}
                {isRunning ? 'Running...' : 'Run'}
              </button>
            </div>
            <pre className="p-5 text-[13px] leading-relaxed font-mono overflow-x-auto whitespace-pre max-h-48 overflow-y-auto">
              <code>{q.sql}</code>
            </pre>
            {renderResults()}
          </div>
        </div>
      </Card>
    </section>
  );
};
