import heroImg from "@/assets/hero-fields.jpg";
import { Button } from "@/components/ui/button";
import { ArrowRight, Sparkles } from "lucide-react";
import { useQuery } from "@tanstack/react-query";
import { api } from "@/lib/api";

export const Hero = () => {
  const { data: stats } = useQuery({
    queryKey: ["dashboard-stats"],
    queryFn: api.getDashboardStats,
  });

  return (
    <section className="relative overflow-hidden">
      <img
        src={heroImg}
        alt="Aerial view of terraced farmland at sunrise"
        width={1920}
        height={1080}
        className="absolute inset-0 w-full h-full object-cover"
      />
      <div className="absolute inset-0 bg-gradient-hero" />
      <div className="relative container py-28 md:py-40 text-primary-foreground">
        <div className="max-w-3xl animate-fade-up">
          <span className="inline-flex items-center gap-2 px-3 py-1 rounded-full text-xs font-medium bg-primary-foreground/15 backdrop-blur border border-primary-foreground/20">
            <Sparkles className="h-3.5 w-3.5" /> SQL-powered AgriTech
          </span>
          <h1 className="mt-5 text-4xl md:text-6xl font-bold leading-[1.05] tracking-tight">
            Cultivating data, <br />
            <span className="bg-gradient-to-r from-[hsl(38_90%_70%)] to-[hsl(60_90%_85%)] bg-clip-text text-transparent">
              harvesting insight.
            </span>
          </h1>
          <p className="mt-5 text-lg md:text-xl text-primary-foreground/85 max-w-2xl">
            A normalized relational database that helps farmers track crops, water and
            fertilizer usage — turning seasons of raw data into yield-boosting decisions.
          </p>
          <div className="mt-8 flex flex-wrap gap-3">
            <Button size="lg" className="bg-primary-foreground text-primary hover:bg-primary-foreground/90 shadow-elegant">
              <a href="#dashboard" className="inline-flex items-center">Explore Dashboard <ArrowRight className="ml-2 h-4 w-4" /></a>
            </Button>
            <Button size="lg" variant="outline" className="bg-transparent text-primary-foreground border-primary-foreground/40 hover:bg-primary-foreground/10">
              <a href="#schema">View Schema</a>
            </Button>
          </div>
          <dl className="mt-12 grid grid-cols-3 max-w-lg gap-6 text-left">
            <div>
              <dt className="text-3xl font-bold">{stats?.TOTAL_FARMERS || 0}</dt>
              <dd className="text-xs uppercase tracking-wider text-primary-foreground/70 mt-1">Farmers</dd>
            </div>
            <div>
              <dt className="text-3xl font-bold">3NF</dt>
              <dd className="text-xs uppercase tracking-wider text-primary-foreground/70 mt-1">Normalized</dd>
            </div>
            <div>
              <dt className="text-3xl font-bold">{stats?.TOTAL_CYCLES || 0}</dt>
              <dd className="text-xs uppercase tracking-wider text-primary-foreground/70 mt-1">Crop Cycles</dd>
            </div>
          </dl>
        </div>
      </div>
    </section>
  );
};
