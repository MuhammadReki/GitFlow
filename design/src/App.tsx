import { useEffect, useState } from "react";
import { SiteNav, Hero } from "@/sections/Hero";
import { ScreensGallery } from "@/sections/ScreensGallery";
import { FlowSection } from "@/sections/Flow";
import { SystemSection } from "@/sections/System";
import { ComponentsSection } from "@/sections/Components";
import { MotionSection } from "@/sections/Motion";
import { CompareSection, PricingSection, Footer } from "@/sections/Compare";

function Reveal({ children }: { children: React.ReactNode }) {
  const [el, setEl] = useState<HTMLDivElement | null>(null);
  const [seen, setSeen] = useState(false);

  useEffect(() => {
    if (!el || seen) return;
    const io = new IntersectionObserver(
      ([e]) => {
        if (e.isIntersecting) {
          setSeen(true);
          io.disconnect();
        }
      },
      { rootMargin: "-40px" },
    );
    io.observe(el);
    return () => io.disconnect();
  }, [el, seen]);

  return (
    <div
      ref={setEl}
      style={{
        opacity: seen ? 1 : 0,
        transform: seen ? "none" : "translateY(30px)",
        transition:
          "opacity .8s cubic-bezier(.16,1,.3,1), transform .8s cubic-bezier(.16,1,.3,1)",
      }}
    >
      {children}
    </div>
  );
}

export default function App() {
  return (
    <div
      id="top"
      className="relative min-h-screen overflow-x-hidden bg-white text-[#111827] antialiased"
    >
      {/* ambient bright background */}
      <div
        className="pointer-events-none fixed inset-0 z-0"
        style={{
          background:
            "radial-gradient(900px 520px at 88% -8%, rgba(99,102,241,.10), transparent 62%)," +
            "radial-gradient(760px 460px at 4% 18%, rgba(236,72,153,.08), transparent 62%)," +
            "radial-gradient(700px 460px at 58% 108%, rgba(245,158,11,.09), transparent 62%)," +
            "linear-gradient(180deg,#FFFFFF 0%,#FCFCFD 40%,#FFFFFF 100%)",
        }}
      />

      <div className="relative z-10">
        <SiteNav />
        <Hero />

        <Reveal>
          <ScreensGallery />
        </Reveal>
        <Reveal>
          <FlowSection />
        </Reveal>
        <Reveal>
          <SystemSection />
        </Reveal>
        <Reveal>
          <ComponentsSection />
        </Reveal>
        <Reveal>
          <MotionSection />
        </Reveal>
        <Reveal>
          <CompareSection />
        </Reveal>
        <Reveal>
          <PricingSection />
        </Reveal>
        <Reveal>
          <Footer />
        </Reveal>
      </div>
    </div>
  );
}
