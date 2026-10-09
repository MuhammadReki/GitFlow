import { useEffect, useState } from "react";
import { Phone } from "@/components/Phone";
import { LoginScreen, OnboardingScreen } from "@/screens/auth";
import { HomeScreen, RepoDetailScreen } from "@/screens/browse";
import { PullRequestsScreen, NotificationsScreen } from "@/screens/work";
import { SectionHead } from "@/sections/ScreensGallery";

const STEPS: {
  n: string;
  title: string;
  body: string;
  emoji: string;
  tint: string;
  tint2: string;
  Comp: () => React.ReactElement;
}[] = [
  {
    n: "01",
    title: "Authenticate",
    body: "OAuth in one tap, or drop a PAT. Keychain-only storage. 🔐",
    emoji: "👋",
    tint: "#6366F1",
    tint2: "#8B5CF6",
    Comp: LoginScreen,
  },
  {
    n: "02",
    title: "Orient",
    body: "Gradient hero, colorful stats, repos and trending in one scroll.",
    emoji: "🏠",
    tint: "#8B5CF6",
    tint2: "#EC4899",
    Comp: HomeScreen,
  },
  {
    n: "03",
    title: "Inspect",
    body: "Gradient hero, five colorful tabs, emoji file tree, README.",
    emoji: "🚀",
    tint: "#EC4899",
    tint2: "#F59E0B",
    Comp: RepoDetailScreen,
  },
  {
    n: "04",
    title: "Review",
    body: "CI checks, branch targets and one-tap merge with confetti. 🎉",
    emoji: "🔀",
    tint: "#F59E0B",
    tint2: "#10B981",
    Comp: PullRequestsScreen,
  },
  {
    n: "05",
    title: "React",
    body: "Swipe to mark read or mute. Haptics confirm every action.",
    emoji: "🔔",
    tint: "#10B981",
    tint2: "#06B6D4",
    Comp: NotificationsScreen,
  },
  {
    n: "06",
    title: "Return",
    body: "Auto-advancing onboarding the next time you open the app. ✨",
    emoji: "🎨",
    tint: "#06B6D4",
    tint2: "#3B82F6",
    Comp: OnboardingScreen,
  },
];

export function FlowSection() {
  const [active, setActive] = useState(0);

  useEffect(() => {
    const t = setInterval(() => setActive((v) => (v + 1) % STEPS.length), 3000);
    return () => clearInterval(t);
  }, []);

  return (
    <section id="flow" className="relative border-t border-[#F3F4F6] py-24">
      <div className="mx-auto max-w-7xl px-6">
        <SectionHead
          kicker="Animated previews"
          title={<>One journey, <span className="text-[#D1D5DB]">six frames.</span></>}
          body="The core loop of the app, storyboarded end to end — the exact frames you'd export as a GIF for the App Store listing. 🎞️"
        />

        <div className="gf-scroll mt-16 overflow-x-auto pb-4">
          <div className="flex items-start">
            {STEPS.map((s, i) => (
              <div key={s.n} className="flex items-start">
                <button
                  onClick={() => setActive(i)}
                  className="group relative flex w-[188px] shrink-0 flex-col items-center px-2 text-center"
                >
                  <div
                    className="relative transition-all duration-500"
                    style={{
                      transform: active === i ? "translateY(-10px) scale(1)" : "translateY(0) scale(.9)",
                      filter: active === i ? "none" : "saturate(.75) brightness(.97)",
                    }}
                  >
                    <span
                      className="pointer-events-none absolute -inset-8 rounded-full blur-2xl transition-opacity duration-500"
                      style={{ background: s.tint, opacity: active === i ? 0.24 : 0.05 }}
                    />
                    <Phone frame="iphone" scale={0.31} className="relative">
                      <s.Comp />
                    </Phone>
                  </div>

                  <div className="mt-5 flex items-center gap-1.5">
                    <span
                      className="grid h-7 w-7 place-items-center rounded-[10px] text-[14px] transition-all"
                      style={
                        active === i
                          ? {
                              background: `linear-gradient(135deg,${s.tint},${s.tint2})`,
                              boxShadow: `0 6px 14px ${s.tint}44`,
                            }
                          : { background: "#F3F4F6" }
                      }
                    >
                      {s.emoji}
                    </span>
                    <span
                      className="font-display text-[13px] font-extrabold transition-colors"
                      style={{ color: active === i ? "#111827" : "#9CA3AF" }}
                    >
                      {s.title}
                    </span>
                  </div>
                  <p className="mt-2 text-[11.5px] font-medium leading-relaxed text-[#9CA3AF]">
                    {s.body}
                  </p>
                </button>

                {i < STEPS.length - 1 && (
                  <div className="relative mt-[150px] h-[3px] w-8 overflow-hidden rounded-full bg-[#F3F4F6] sm:w-12">
                    <span
                      className="absolute inset-y-0 -left-full w-full rounded-full"
                      style={{
                        background: `linear-gradient(90deg,transparent,${STEPS[i].tint},${STEPS[i + 1].tint})`,
                        animation: `gf-progress 2.2s ${i * 0.28}s linear infinite`,
                      }}
                    />
                  </div>
                )}
              </div>
            ))}
          </div>
        </div>

        {/* frame readout */}
        <div className="mx-auto mt-10 flex max-w-3xl flex-wrap items-center justify-center gap-3 rounded-[20px] border border-[#E5E7EB] bg-white p-4 sh-sm">
          <span className="font-mono text-[11px] font-extrabold uppercase tracking-widest text-[#9CA3AF]">
            frame {String(active + 1).padStart(2, "0")} / 06
          </span>
          <div className="flex flex-1 items-center gap-1.5">
            {STEPS.map((s, i) => (
              <button
                key={s.n}
                onClick={() => setActive(i)}
                className="h-2 flex-1 rounded-full transition-all"
                style={{
                  background:
                    i === active ? `linear-gradient(90deg,${s.tint},${s.tint2})` : "#F3F4F6",
                }}
              />
            ))}
          </div>
          <span className="font-mono text-[11px] font-semibold text-[#9CA3AF]">3.0s / frame · 12fps gif</span>
        </div>
      </div>
    </section>
  );
}
