import { Icon, GitFlowMark } from "@/lib/icons";
import { Phone } from "@/components/Phone";
import { HomeScreen } from "@/screens/browse";
import { OnboardingScreen } from "@/screens/auth";
import { ProfileScreen } from "@/screens/account";

function Tilt({
  children,
  y = 0,
  x = 0,
  z = 0,
  className = "",
}: {
  children: React.ReactNode;
  y?: number;
  x?: number;
  z?: number;
  className?: string;
}) {
  return (
    <div className={className} style={{ perspective: 1800, perspectiveOrigin: "50% 45%" }}>
      <div
        style={{
          transform: `rotateY(${y}deg) rotateX(${x}deg) translateZ(${z}px)`,
          transformStyle: "preserve-3d",
        }}
      >
        {children}
      </div>
    </div>
  );
}

const CHIP_STYLE = {
  border: "1px solid rgba(99,102,241,.22)",
  background: "rgba(99,102,241,.07)",
  color: "#4F46E5",
};

export function Hero() {
  return (
    <header className="relative overflow-hidden pt-28 pb-16">
      <div className="page-grid absolute inset-0" />
      <div className="anim-blob pointer-events-none absolute -left-32 top-10 h-[420px] w-[420px] rounded-full bg-indigo-300/35 blur-[100px]" />
      <div
        className="anim-blob pointer-events-none absolute -right-32 top-32 h-[420px] w-[420px] rounded-full bg-pink-300/35 blur-[100px]"
        style={{ animationDelay: "-6s" }}
      />
      <div
        className="anim-blob pointer-events-none absolute left-1/3 top-[420px] h-[380px] w-[380px] rounded-full bg-amber-200/40 blur-[100px]"
        style={{ animationDelay: "-12s" }}
      />

      <div className="relative mx-auto max-w-7xl px-6">
        <div className="mx-auto flex max-w-3xl flex-col items-center text-center">
          <div
            className="anim-fade-up inline-flex items-center gap-2 rounded-full px-3.5 py-2 sh-sm"
            style={CHIP_STYLE}
          >
            <span className="relative flex h-2 w-2">
              <span className="absolute inline-flex h-full w-full animate-ping rounded-full bg-emerald-400 opacity-75" />
              <span className="relative inline-flex h-2 w-2 rounded-full bg-emerald-500" />
            </span>
            <span className="text-[12.5px] font-bold text-indigo-700">
              v2.1 shipped ✨ Offline-first sync engine
            </span>
            <Icon name="arrowRight" size={13} strokeWidth={3} className="text-indigo-400" />
          </div>

          <h1
            className="anim-fade-up mt-7 font-display text-balance text-[clamp(2.6rem,6.5vw,5rem)] font-extrabold leading-[0.98] tracking-[-0.045em] text-[#111827]"
            style={{ animationDelay: "80ms" }}
          >
            Your GitHub,
            <br />
            <span className="grad-text">Reimagined</span>
          </h1>

          <p
            className="anim-fade-up mt-6 max-w-xl text-balance text-[17px] font-medium leading-relaxed text-[#6B7280]"
            style={{ animationDelay: "160ms" }}
          >
            The bright, friendly GitHub client developers actually enjoy using — native-feeling
            diffs, offline-first repos, real-time CI, and a review queue that fits in one hand. 🚀
          </p>

          <div
            className="anim-fade-up mt-9 flex flex-wrap items-center justify-center gap-3"
            style={{ animationDelay: "240ms" }}
          >
            <a
              href="#screens"
              className="press group inline-flex h-12 items-center gap-2 rounded-full px-6 text-[15px] font-extrabold text-white grad-brand sh-lift"
            >
              <span>🎉</span>
              Explore the 12 screens
            </a>
            <a
              href="#system"
              className="press inline-flex h-12 items-center gap-2 rounded-full border border-[#E5E7EB] bg-white px-6 text-[15px] font-bold text-[#111827] sh-sm"
            >
              🎨 Design system
            </a>
          </div>

          <div
            className="anim-fade-up mt-8 flex flex-wrap items-center justify-center gap-x-6 gap-y-2 text-[12.5px] font-bold text-[#9CA3AF]"
            style={{ animationDelay: "320ms" }}
          >
            <span>🍎 iOS 17+</span>
            <span>🤖 Android 10+</span>
            <span>·</span>
            <span>Flutter 3.27 · Impeller</span>
            <span>·</span>
            <span className="font-mono">4.9 ★ 12.4k reviews</span>
          </div>
        </div>

        {/* ---------- 3D device cluster ---------- */}
        <div className="relative mt-16 flex items-start justify-center">
          <div
            className="pointer-events-none absolute left-1/2 top-1/3 h-[440px] w-[860px] -translate-x-1/2 rounded-full opacity-70 blur-[110px]"
            style={{ background: "radial-gradient(50% 50% at 50% 50%,rgba(99,102,241,.45),transparent 70%)" }}
          />
          <Tilt y={26} x={4} z={-120} className="relative z-10 hidden translate-x-6 -translate-y-4 lg:block">
            <Phone frame="pixel" scale={0.46} label="Pixel 8 · 412×915">
              <OnboardingScreen />
            </Phone>
          </Tilt>

          <Tilt y={0} x={0} z={40} className="relative z-20">
            <Phone frame="iphone" scale={0.66}>
              <HomeScreen />
            </Phone>
          </Tilt>

          <Tilt y={-26} x={4} z={-120} className="relative z-10 hidden -translate-x-6 -translate-y-4 lg:block">
            <Phone frame="iphone" scale={0.46} label="iPhone 15 Pro · 393×852">
              <ProfileScreen />
            </Phone>
          </Tilt>
        </div>

        {/* ---------- stat strip ---------- */}
        <div className="relative mx-auto mt-20 grid max-w-5xl grid-cols-2 gap-4 md:grid-cols-4">
          {[
            ["12", "Screens designed", "📱", "#6366F1"],
            ["42", "Components", "🧩", "#8B5CF6"],
            ["16ms", "Frame budget", "⚡", "#EC4899"],
            ["100%", "Token-driven", "🎨", "#F59E0B"],
          ].map(([v, l, e, c], i) => (
            <div
              key={l}
              className="anim-fade-up rounded-[22px] border border-[#E5E7EB] bg-white p-6 text-center sh-md"
              style={{ animationDelay: `${360 + i * 70}ms`, boxShadow: `0 8px 24px ${c}1f` }}
            >
              <div className="mb-1.5 text-[20px] leading-none">{e}</div>
              <div className="font-display text-[30px] font-extrabold tracking-[-0.03em] text-[#111827]">
                {v}
              </div>
              <div className="mt-1 text-[12.5px] font-bold uppercase tracking-wider text-[#9CA3AF]">
                {l}
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* logo marquee */}
      <div className="relative mt-24 overflow-hidden border-y border-[#F3F4F6] bg-[#F9FAFB] py-5">
        <div className="flex w-max gap-14 opacity-60" style={{ animation: "gf-marquee 32s linear infinite" }}>
          {[...Array(2)].map((_, r) => (
            <div key={r} className="flex shrink-0 gap-14">
              {["NOTION", "LINEAR", "ARC", "DUOLINGO", "STRIPE", "FIGMA", "SUPABASE", "RAYCAST"].map((b) => (
                <span
                  key={b + r}
                  className="font-mono text-[13px] font-extrabold tracking-[0.28em] text-[#9CA3AF]"
                >
                  {b}
                </span>
              ))}
            </div>
          ))}
        </div>
        <div className="pointer-events-none absolute inset-y-0 left-0 w-32 bg-gradient-to-r from-[#F9FAFB] to-transparent" />
        <div className="pointer-events-none absolute inset-y-0 right-0 w-32 bg-gradient-to-l from-[#F9FAFB] to-transparent" />
      </div>
    </header>
  );
}

export function SiteNav() {
  const links = [
    ["Screens", "#screens"],
    ["Flow", "#flow"],
    ["System", "#system"],
    ["Components", "#components"],
    ["Motion", "#motion"],
    ["Compare", "#compare"],
  ];
  return (
    <nav className="fixed inset-x-0 top-0 z-50 border-b border-[#F3F4F6] glass">
      <div className="mx-auto flex h-16 max-w-7xl items-center gap-8 px-6">
        <a href="#top" className="press flex items-center gap-2.5">
          <GitFlowMark size={30} />
          <span className="font-display text-[17px] font-extrabold tracking-[-0.02em] text-[#111827]">
            GitFlow
          </span>
          <span
            className="rounded-full px-2 py-[2px] font-mono text-[9.5px] font-extrabold text-indigo-700"
            style={CHIP_STYLE}
          >
            UI KIT
          </span>
        </a>
        <div className="hidden flex-1 items-center gap-1 md:flex">
          {links.map(([l, h]) => (
            <a
              key={l}
              href={h}
              className="rounded-xl px-3 py-2 text-[13.5px] font-bold text-[#6B7280] transition hover:bg-indigo-50 hover:text-indigo-700"
            >
              {l}
            </a>
          ))}
        </div>
        <div className="ml-auto flex items-center gap-2.5">
          <span className="hidden font-mono text-[11px] font-bold text-[#9CA3AF] sm:block">
            Light mode only ☀️
          </span>
          <a
            href="#screens"
            className="press inline-flex h-9 items-center gap-1.5 rounded-full px-4 text-[13px] font-extrabold text-white grad-brand sh-md"
          >
            <Icon name="download" size={14} strokeWidth={2.6} />
            Get the kit
          </a>
        </div>
      </div>
    </nav>
  );
}


