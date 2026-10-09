import { useEffect, useState } from "react";
import { cn } from "@/utils/cn";
import { Icon } from "@/lib/icons";
import { Phone, type FrameKind } from "@/components/Phone";
import { SplashScreen, OnboardingScreen, LoginScreen } from "@/screens/auth";
import { HomeScreen, RepoListScreen, RepoDetailScreen, FileViewerScreen } from "@/screens/browse";
import { IssuesScreen, PullRequestsScreen, NotificationsScreen } from "@/screens/work";
import { ProfileScreen, SettingsScreen } from "@/screens/account";

type Entry = {
  n: string;
  name: string;
  desc: string;
  emoji: string;
  tint: string;
  Comp: () => React.ReactElement;
};

const ENTRIES: Entry[] = [
  { n: "01", name: "Splash", desc: "Rainbow gradient · bouncing dots", emoji: "✨", tint: "#6366F1", Comp: SplashScreen },
  { n: "02", name: "Onboarding", desc: "3 gradient slides · auto-advance", emoji: "🎨", tint: "#F59E0B", Comp: OnboardingScreen },
  { n: "03", name: "Login", desc: "OAuth · PAT · biometrics · 👋", emoji: "👋", tint: "#EC4899", Comp: LoginScreen },
  { n: "04", name: "Dashboard", desc: "Gradient hero · colorful stats", emoji: "🏠", tint: "#6366F1", Comp: HomeScreen },
  { n: "05", name: "Repositories", desc: "Colorful chips · emoji cards", emoji: "📦", tint: "#8B5CF6", Comp: RepoListScreen },
  { n: "06", name: "Repo Detail", desc: "Gradient hero · 5 colorful tabs", emoji: "🚀", tint: "#EC4899", Comp: RepoDetailScreen },
  { n: "07", name: "File Viewer", desc: "Cream canvas · light syntax", emoji: "💻", tint: "#F59E0B", Comp: FileViewerScreen },
  { n: "08", name: "Issues", desc: "Emerald open · gray closed", emoji: "🐛", tint: "#10B981", Comp: IssuesScreen },
  { n: "09", name: "Pull Requests", desc: "Emerald / purple / red states", emoji: "🔀", tint: "#8B5CF6", Comp: PullRequestsScreen },
  { n: "10", name: "Notifications", desc: "Every type has its own hue", emoji: "🔔", tint: "#EF4444", Comp: NotificationsScreen },
  { n: "11", name: "Profile", desc: "4-stop gradient cover · badges", emoji: "🌈", tint: "#EC4899", Comp: ProfileScreen },
  { n: "12", name: "Settings", desc: "Colorful sections · gradient toggles", emoji: "⚙️", tint: "#06B6D4", Comp: SettingsScreen },
];

export function SectionHead({
  kicker,
  title,
  body,
}: {
  kicker: string;
  title: React.ReactNode;
  body?: string;
}) {
  return (
    <div className="mx-auto max-w-2xl text-center">
      <span className="inline-flex items-center gap-1.5 rounded-full px-3 py-1.5 font-mono text-[11.5px] font-extrabold uppercase tracking-[0.2em] text-indigo-700"
        style={{ background: "rgba(99,102,241,.08)", border: "1px solid rgba(99,102,241,.2)" }}>
        {kicker}
      </span>
      <h2 className="mt-4 font-display text-balance text-[clamp(1.9rem,4vw,3rem)] font-extrabold leading-[1.05] tracking-[-0.035em] text-[#111827]">
        {title}
      </h2>
      {body && <p className="mt-4 text-balance text-[16px] font-medium leading-relaxed text-[#6B7280]">{body}</p>}
    </div>
  );
}

function useResponsiveScale(base: number) {
  const [scale, setScale] = useState(base);
  useEffect(() => {
    const on = () => {
      const w = window.innerWidth;
      const f = w < 480 ? 0.6 : w < 768 ? 0.7 : w < 1280 ? 0.76 : base;
      setScale(f * base);
    };
    on();
    window.addEventListener("resize", on);
    return () => window.removeEventListener("resize", on);
  }, [base]);
  return scale;
}

export function ScreensGallery() {
  const [i, setI] = useState(3);
  const [frame, setFrame] = useState<FrameKind>("iphone");
  const scale = useResponsiveScale(0.82);
  const active = ENTRIES[i];

  return (
    <section id="screens" className="relative border-t border-[#F3F4F6] py-24">
      <div className="mx-auto max-w-7xl px-6">
        <SectionHead
          kicker="The screens"
          title={<>Every screen. Bright &amp; friendly.<br />Both platforms.</>}
          body="Twelve production-ready screens rendered from one token set. Tap through and flip the device — everything you see is live UI, not a screenshot. ☀️ Light mode only, by design."
        />

        {/* controls */}
        <div className="mt-10 flex flex-wrap items-center justify-center gap-2.5">
          <div className="flex items-center gap-1 rounded-full border border-[#E5E7EB] bg-white p-1 sh-sm">
            {([
              ["iphone", "📱 iPhone 15 Pro"],
              ["pixel", "🤖 Pixel 8"],
            ] as [FrameKind, string][]).map(([f, l]) => (
              <button
                key={f}
                onClick={() => setFrame(f)}
                className={cn(
                  "press rounded-full px-4 py-2 text-[12.5px] font-extrabold transition",
                  frame === f ? "text-white grad-brand sh-sm" : "text-[#6B7280] hover:text-[#111827]",
                )}
              >
                {l}
              </button>
            ))}
          </div>
          <span
            className="inline-flex items-center gap-1.5 rounded-full border border-[#E5E7EB] bg-white px-3.5 py-2.5 text-[12.5px] font-bold text-[#6B7280] sh-sm"
          >
            ☀️ Light mode only
          </span>
        </div>

        {/* main viewer */}
        <div className="mt-12 grid items-center gap-10 lg:grid-cols-[minmax(0,1fr)_auto_minmax(0,1fr)]">
          {/* screen list */}
          <div className="order-2 space-y-1.5 lg:order-1">
            {ENTRIES.map((e, idx) => (
              <button
                key={e.n}
                onClick={() => setI(idx)}
                className={cn(
                  "press group flex w-full items-center gap-3.5 rounded-[18px] border px-3.5 py-3 text-left transition",
                  idx === i ? "bg-white" : "border-[#F3F4F6] bg-white/60 hover:bg-white",
                )}
                style={
                  idx === i
                    ? { borderColor: `${e.tint}44`, boxShadow: `0 8px 24px ${e.tint}1f` }
                    : undefined
                }
              >
                <span
                  className={cn("font-mono text-[11px] font-extrabold", idx === i ? "" : "text-[#D1D5DB]")}
                  style={idx === i ? { color: e.tint } : undefined}
                >
                  {e.n}
                </span>
                <span
                  className="grid h-11 w-11 shrink-0 place-items-center rounded-[14px] text-[19px] transition"
                  style={
                    idx === i
                      ? { background: `linear-gradient(135deg,${e.tint},${e.tint}B0)`, boxShadow: `0 6px 14px ${e.tint}44` }
                      : { background: `${e.tint}14` }
                  }
                >
                  {e.emoji}
                </span>
                <span className="min-w-0 flex-1">
                  <span
                    className={cn(
                      "block truncate text-[14.5px] font-extrabold",
                      idx === i ? "text-[#111827]" : "text-[#374151]",
                    )}
                  >
                    {e.name}
                  </span>
                  <span className="block truncate text-[12px] font-semibold text-[#9CA3AF]">{e.desc}</span>
                </span>
                <Icon
                  name="chevronRight"
                  size={15}
                  strokeWidth={3}
                  className="shrink-0 transition"
                  style={{ color: idx === i ? e.tint : "#E5E7EB" }}
                />
              </button>
            ))}
          </div>

          {/* device */}
          <div className="order-1 flex justify-center lg:order-2">
            <div className="relative">
              <div
                className="pointer-events-none absolute left-1/2 top-1/2 h-[460px] w-[460px] -translate-x-1/2 -translate-y-1/2 rounded-full opacity-60 blur-[90px]"
                style={{ background: `radial-gradient(50% 50% at 50% 50%,${active.tint}55,transparent 70%)` }}
              />
              <Phone key={`${frame}-${i}`} frame={frame} scale={scale} className="relative">
                <active.Comp />
              </Phone>
            </div>
          </div>

          {/* spec panel */}
          <div className="order-3 space-y-4">
            <div className="rounded-[24px] border border-[#E5E7EB] bg-white p-6 sh-md"
              style={{ boxShadow: `0 10px 30px ${active.tint}1a` }}>
              <div className="flex items-center gap-3">
                <span
                  className="grid h-12 w-12 place-items-center rounded-[16px] text-[22px] text-white"
                  style={{ background: `linear-gradient(135deg,${active.tint},${active.tint}B0)`, boxShadow: `0 8px 18px ${active.tint}44` }}
                >
                  {active.emoji}
                </span>
                <div>
                  <div className="font-mono text-[11px] font-extrabold text-[#9CA3AF]">
                    SCREEN {active.n}
                  </div>
                  <div className="font-display text-[18px] font-extrabold tracking-[-0.02em] text-[#111827]">
                    {active.name}
                  </div>
                </div>
              </div>
              <p className="mt-4 text-[13.5px] font-medium leading-relaxed text-[#6B7280]">{active.desc}</p>
              <div className="mt-5 space-y-2.5 border-t border-[#F3F4F6] pt-5">
                {[
                  ["Canvas", frame === "iphone" ? "393 × 852 pt" : "412 × 915 dp"],
                  ["Theme", "Light · #FFFFFF"],
                  ["Safe area", frame === "iphone" ? "59 / 34 pt" : "24 / 16 dp"],
                  ["Accent", active.tint],
                ].map(([k, v]) => (
                  <div key={k} className="flex items-center justify-between text-[12.5px]">
                    <span className="font-semibold text-[#9CA3AF]">{k}</span>
                    <span className="font-mono font-bold text-[#374151]">{v}</span>
                  </div>
                ))}
              </div>
            </div>

            <div className="rounded-[24px] border border-[#E5E7EB] bg-white p-5 sh-sm">
              <div className="mb-3 text-[11.5px] font-extrabold uppercase tracking-wider text-[#9CA3AF]">
                Micro-interactions
              </div>
              <div className="space-y-2">
                {[
                  "Card press → scale 0.98 + color glow",
                  "Screen push → slide 22px + fade 240ms",
                  "Bottom sheet → slide-up + soft backdrop",
                  "Unread badge → 2.2s pulse ring loop",
                ].map((m) => (
                  <div key={m} className="flex items-start gap-2 text-[12.5px] font-semibold text-[#6B7280]">
                    <Icon name="check" size={13} strokeWidth={3.2} className="mt-[3px] shrink-0" style={{ color: active.tint }} />
                    {m}
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>

        {/* ---------- full grid of all 12 ---------- */}
        <div className="mt-24">
          <div className="mb-8 flex items-end justify-between gap-6">
            <div>
              <h3 className="font-display text-[22px] font-extrabold tracking-[-0.02em] text-[#111827]">
                The full delivery — 12 screens 📦
              </h3>
              <p className="mt-1.5 text-[14px] font-medium text-[#9CA3AF]">
                Every screen bright, every screen light. No dark variant, ever.
              </p>
            </div>
            <span className="hidden font-mono text-[11px] font-bold text-[#D1D5DB] sm:block">
              iPhone 15 Pro · 393×852 · @3x
            </span>
          </div>

          <div className="flex flex-wrap justify-center gap-x-8 gap-y-14">
            {ENTRIES.map((e) => (
              <div key={e.n} className="group">
                <div className="relative">
                  <div
                    className="absolute -inset-7 rounded-[36px] opacity-0 blur-2xl transition group-hover:opacity-100"
                    style={{ background: `${e.tint}33` }}
                  />
                  <Phone frame="iphone" scale={0.34} className="relative">
                    <e.Comp />
                  </Phone>
                </div>
                <div className="mt-5 flex items-center justify-center gap-2">
                  <span className="font-mono text-[10.5px] font-extrabold text-[#D1D5DB]">{e.n}</span>
                  <span className="text-[13px] font-extrabold text-[#374151]">{e.name}</span>
                  <span className="text-[12px]">{e.emoji}</span>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}
