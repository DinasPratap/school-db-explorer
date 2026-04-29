import { Header } from "@/components/farm/Header";
import { Hero } from "@/components/farm/Hero";
import { KpiGrid } from "@/components/farm/KpiGrid";
import { Charts } from "@/components/farm/Charts";
import { SchemaSection } from "@/components/farm/SchemaSection";
import { FarmersTable } from "@/components/farm/FarmersTable";
import { SqlLab } from "@/components/farm/SqlLab";

const Index = () => (
  <div className="min-h-screen bg-background">
    <Header />
    <main>
      <Hero />
      <section id="dashboard" className="container py-16 space-y-12">
        <div>
          <h2 className="text-2xl md:text-3xl font-bold">Live overview</h2>
          <p className="text-muted-foreground mt-1">
            Real-time insights aggregated from the FarmDB relational schema.
          </p>
        </div>
        <KpiGrid />
        <Charts />
      </section>

      <section className="container py-12">
        <SchemaSection />
      </section>

      <section className="container py-12">
        <FarmersTable />
      </section>

      <section className="container py-12">
        <SqlLab />
      </section>

      <footer className="border-t border-border mt-12">
        <div className="container py-8 flex flex-wrap items-center justify-between gap-3 text-sm text-muted-foreground">
          <p>FarmDB · DBMS Project · Crop & Resource Optimization</p>
          <p className="font-mono text-xs">v1.0 · Oracle · 3NF</p>
        </div>
      </footer>
    </main>
  </div>
);

export default Index;
