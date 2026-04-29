import { Sprout, Database } from "lucide-react";

export const Header = () => (
  <header className="sticky top-0 z-40 backdrop-blur-xl bg-background/70 border-b border-border">
    <div className="container flex items-center justify-between h-16">
      <div className="flex items-center gap-2.5">
        <div className="h-9 w-9 rounded-xl bg-gradient-primary grid place-items-center shadow-glow">
          <Sprout className="h-5 w-5 text-primary-foreground" />
        </div>
        <div className="leading-tight">
          <p className="font-semibold">FarmDB</p>
          <p className="text-[11px] text-muted-foreground -mt-0.5">Crop & Resource Optimization</p>
        </div>
      </div>
      <nav className="hidden md:flex items-center gap-7 text-sm text-muted-foreground">
        <a href="#dashboard" className="hover:text-foreground transition-smooth">Dashboard</a>
        <a href="#schema" className="hover:text-foreground transition-smooth">Schema</a>
        <a href="#farmers" className="hover:text-foreground transition-smooth">Farmers</a>
        <a href="#queries" className="hover:text-foreground transition-smooth">SQL Lab</a>
      </nav>
      <div className="flex items-center gap-2 text-xs text-muted-foreground">
        <Database className="h-4 w-4 text-primary" />
        <span className="hidden sm:inline">Oracle · 3NF</span>
      </div>
    </div>
  </header>
);
