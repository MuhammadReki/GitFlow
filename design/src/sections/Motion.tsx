import { useEffect, useState } from "react";
import { cn } from "@/utils/cn";
import { Icon } from "@/lib/icons";
import { Chip, Fab, GRADS, NotificationCard, Skeleton, Toast, hex } from "@/components/ui";
import { notifications } from "@/lib/data";
import { SectionHead } from "@/sections/ScreensGallery";

function Demo({
  n,
  title,
  spec,
  hint,
  tint = "#6366F1",
  children,
}: {
  n: string;
  title: string;
  spec: string;
  hint?: string;
  tint?: string;
  children: React.ReactNode;
}) {
  return (
    <div
      className="flex flex-col overflow-hidden rounded-[24px] border border-[#E5E7EB] bg-white sh-md"
      style={{ boxShadow: `0 8px 24px ${tint}17` }}
    >
      <div className="flex items-start justify-between gap-3 px-5 pt-4">
        <div>
          <div className="flex items-center gap-2.5">
            <span
              className="grid h-6 w-6 place-items-center rounded-[8px] text-[10px] font-extrabold text-white"
              style={{ background: tint }}
            >
              {n}
            </span>
            <span className="font-display text-[13.5px] font-extrabold text-[#374151]">{title}</span>
          </div>
          <div className="mt-1 font-mono text-[10.5px] font-semibold text-[#9CA3AF]">{spec}</div>
        </div>
      </div>
      <div
        className="gf-ui relative m-4 mt-3 flex flex-1 items-center justify-center overflow-hidden rounded-[20px] border border-[#F3F4F6] p-4"
        style={{ background: "#F9FAFB" }}
      >
        {children}
        {hint && (
          <span
            className="absolute bottom-2 right-3 font-mono text-[9.5px] font-extrabold uppercase tracking-wider"
            style={{ color: hex(tint, 0.5) }}
          >
            {hint}
          </span>
        )}
      </div>
    </div>
  );
}

/* ---------- demos ---------- */

function PressDemo() {
  return (
    <button
      className="press flex w-full max-w-[280px] items-center gap-3 rounded-[20px] border border-[#E5E7EB] bg-white p-3.5 text-left sh-md"
      style={{ borderColor: hex("#6366F1", 0.24) }}
    >
      <span
        className="grid h-11 w-11 place-items-center rounded-[15px] text-[20px] text-white"
        style={{ background: GRADS.brand, boxShadow: "0 6px 16px rgba(99,102,241,.35)" }}
      >
        📦
      </span>
      <span className="min-w-0 flex-1">
        <span className="block truncate text-[14.5px] font-extrabold text-ink">mrahman/gitflow</span>
        <span className="block truncate text-[11.5px] font-semibold text-muted">
          scale 0.98 · 180ms
        </span>
      </span>
      <Icon name="chevronRight" size={16} strokeWidth={3} className="text-faint" />
    </button>
  );
}

function FabDemo() {
  const [open, setOpen] = useState(false);
  return (
    <div className="relative h-[236px] w-full max-w-[300px]">
      <div className="absolute inset-0 rounded-[16px] border border-dashed border-[#E5E7EB]" />
      <Fab label="New PR" emoji="🔀" gradient={GRADS.brand} open={open} onClick={() => setOpen((v) => !v)} />
    </div>
  );
}

function TabDemo() {
  const [i, setI] = useState(0);
  const tabs = ["Code", "Issues", "PRs"];
  const tints = ["#6366F1", "#10B981", "#8B5CF6"];
  return (
    <div className="w-full max-w-[300px]">
      <div className="flex gap-1.5">
        {tabs.map((t, k) => (
          <button
            key={t}
            onClick={() => setI(k)}
            className={cn(
              "press flex-1 rounded-[13px] py-2.5 text-[12.5px] font-extrabold transition-all",
              i === k ? "text-white" : "",
            )}
            style={
              i === k
                ? { background: tints[k], boxShadow: `0 6px 16px ${hex(tints[k], 0.32)}` }
                : { background: hex(tints[k], 0.1), color: tints[k] }
            }
          >
            {t}
          </button>
        ))}
      </div>
      <div
        key={i}
        className="anim-slide-right mt-3 rounded-[18px] border border-[#E5E7EB] bg-white p-4 sh-sm"
      >
        <div className="text-[13.5px] font-extrabold text-ink">{tabs[i]} panel</div>
        <p className="mt-1 text-[11.5px] font-semibold leading-relaxed text-muted">
          Slide 22px from the right + fade, 240ms on the shared ease curve.
        </p>
      </div>
    </div>
  );
}

function SheetDemo() {
  const [open, setOpen] = useState(true);
  return (
    <div className="relative h-[250px] w-full max-w-[300px] overflow-hidden rounded-[18px] border border-[#E5E7EB] bg-white">
      <div className="absolute inset-0 bg-[#F9FAFB]" />
      <div className="absolute inset-x-0 top-0 flex items-center justify-between px-4 pt-4">
        <span className="text-[11.5px] font-bold text-muted">Repository</span>
        <button
          onClick={() => setOpen((v) => !v)}
          className="press rounded-full px-3.5 py-1.5 text-[11.5px] font-extrabold text-white grad-brand sh-sm"
        >
          {open ? "Dismiss" : "Present"}
        </button>
      </div>
      {open && (
        <>
          <div className="anim-fade-in absolute inset-0 bg-[#111827]/25 backdrop-blur-[3px]" />
          <div className="anim-sheet absolute inset-x-0 bottom-0 rounded-t-[28px] border-t border-line bg-white pb-4 pt-2.5 sh-lift">
            <div className="mx-auto mb-3 h-1.5 w-10 rounded-full bg-line-2" />
            <div className="px-5 pb-2 text-[15px] font-extrabold text-ink">Watch settings 👀</div>
            {[
              ["🔔", "All activity", true],
              ["💬", "Participating", false],
              ["🔇", "Ignore", false],
            ].map(([e, l, on]) => (
              <div key={l as string} className="flex items-center gap-3 px-5 py-2.5">
                <span
                  className="grid h-8 w-8 place-items-center rounded-[11px] text-[15px]"
                  style={{ background: hex("#6366F1", 0.1) }}
                >
                  {e as string}
                </span>
                <span className="text-[13px] font-bold text-ink">{l as string}</span>
                {on ? (
                  <span
                    className="ml-auto rounded-full px-2 py-[2px] text-[10px] font-extrabold text-white grad-brand"
                  >
                    ON
                  </span>
                ) : null}
              </div>
            ))}
          </div>
        </>
      )}
    </div>
  );
}

function ConfettiDemo() {
  const [burst, setBurst] = useState(0);
  return (
    <button
      onClick={() => setBurst((b) => b + 1)}
      className="relative h-[200px] w-full max-w-[300px] overflow-hidden rounded-[20px] border sh-md"
      style={{ borderColor: hex("#8B5CF6", 0.26), background: hex("#8B5CF6", 0.07) }}
    >
      <div className="relative z-10 flex h-full flex-col items-center justify-center">
        <span
          className="grid h-14 w-14 place-items-center rounded-[20px] text-[26px] text-white"
          style={{ background: GRADS.brand, boxShadow: "0 10px 22px rgba(139,92,246,.4)" }}
        >
          🎉
        </span>
        <span className="mt-3 text-[14px] font-extrabold text-ink">Merge pull request</span>
        <span className="mt-1 font-mono text-[10.5px] font-bold text-muted">
          tap to replay · 24 particles
        </span>
      </div>
      {Array.from({ length: 24 }).map((_, i) => (
        <span
          key={`${burst}-${i}`}
          className="absolute left-1/2 top-1/2 h-2 w-2 rounded-full"
          style={
            {
              background: ["#6366F1", "#8B5CF6", "#EC4899", "#F59E0B", "#10B981", "#06B6D4"][i % 6],
              "--dx": `${Math.cos((i / 24) * Math.PI * 2) * 112}px`,
              "--dy": `${Math.sin((i / 24) * Math.PI * 2) * 112}px`,
              animation: `gf-confetti 1.5s ${(i % 6) * 60}ms cubic-bezier(.2,.7,.3,1) forwards`,
            } as React.CSSProperties
          }
        />
      ))}
    </button>
  );
}

function SwipeDemo() {
  const [r, setR] = useState(false);
  useEffect(() => {
    const t = setInterval(() => setR((v) => !v), 2200);
    return () => clearInterval(t);
  }, []);
  return (
    <div className="w-full max-w-[300px]">
      <NotificationCard n={notifications[0]} reveal={r ? "read" : null} />
      <div className="mt-3 flex justify-center gap-2">
        <Chip selected={!r} emoji="😴" tint="#6366F1" onClick={() => setR(false)}>
          Resting
        </Chip>
        <Chip selected={r} emoji="👉" tint="#10B981" onClick={() => setR(true)}>
          Swiped
        </Chip>
      </div>
    </div>
  );
}

function SkeletonDemo() {
  return (
    <div className="w-full max-w-[280px] space-y-3">
      {[0, 1].map((k) => (
        <div key={k} className="rounded-[20px] border border-[#F3F4F6] bg-white p-4 sh-sm">
          <div className="flex items-start gap-3">
            <Skeleton w={44} h={44} r={14} />
            <div className="flex-1 space-y-2 pt-1">
              <Skeleton w="65%" h={13} />
              <Skeleton w="40%" h={10} />
            </div>
          </div>
          <div className="mt-3 space-y-2">
            <Skeleton h={10} />
            <Skeleton w="68%" h={10} />
          </div>
        </div>
      ))}
    </div>
  );
}

function PullDemo() {
  return (
    <div className="relative w-full max-w-[280px]">
      <div className="rounded-[20px] border border-[#E5E7EB] bg-white p-6 text-center sh-md">
        <div className="relative mx-auto h-12 w-12">
          <svg viewBox="0 0 48 48" className="absolute inset-0 h-12 w-12">
            <circle cx="24" cy="24" r="20" stroke="#E5E7EB" strokeWidth="4" fill="none" />
            <path
              d="M24 4a20 20 0 0 1 17.3 10"
              stroke="#6366F1"
              strokeWidth="4"
              fill="none"
              strokeLinecap="round"
              strokeDasharray="100"
              style={{ animation: "gf-draw 1.6s linear infinite", transformOrigin: "center" }}
            />
          </svg>
        </div>
        <div className="mt-3 text-[12.5px] font-extrabold text-ink">Release to refresh 🔄</div>
        <div className="mt-1 font-mono text-[10.5px] font-semibold text-faint">
          3 repos · 12 issues · 4 PRs
        </div>
      </div>
    </div>
  );
}

function ToastDemo() {
  const [v, setV] = useState(0);
  const variants = ["success", "info", "warning", "error"] as const;
  const map = {
    success: ["PR #1484 merged 🎉", "main · 4 files · 1.4s", "#10B981"],
    info: ["Offline mode 💡", "Serving cached repositories", "#3B82F6"],
    warning: ["Token expiring ⚠️", "3 days remaining — renew now", "#F59E0B"],
    error: ["CI failed on main 😵", "2 checks · tap to review", "#EF4444"],
  } as const;
  const [t, b, c] = map[variants[v]];
  return (
    <div className="flex w-full flex-col items-center gap-3">
      <Toast key={v} variant={variants[v]} title={t} body={b} style={{ animation: "gf-fade-up .4s both" }} />
      <button
        onClick={() => setV((x) => (x + 1) % 4)}
        className="press rounded-full border px-3.5 py-2 text-[11.5px] font-extrabold"
        style={{ borderColor: hex(c, 0.3), background: hex(c, 0.08), color: c }}
      >
        Cycle variant → {variants[v]}
      </button>
    </div>
  );
}

function BounceDemo() {
  return (
    <div className="flex h-[120px] w-full max-w-[280px] flex-col items-center justify-center gap-4">
      <div className="flex items-center gap-3">
        {["#6366F1", "#8B5CF6", "#EC4899", "#F59E0B", "#10B981", "#06B6D4"].map((c, i) => (
          <span
            key={c}
            className="dot-bounce h-3.5 w-3.5 rounded-full"
            style={{ background: c, animationDelay: `${i * 110}ms`, boxShadow: `0 4px 12px ${hex(c, 0.5)}` }}
          />
        ))}
      </div>
      <span className="text-[12px] font-extrabold text-muted">Bouncing loader · 1.25s</span>
    </div>
  );
}

const HAPTICS: [string, string, string, string][] = [
  ["Tap", "selectionClick · 8ms", "👆", "#6366F1"],
  ["Long-press", "heavyImpact · 24ms", "🖐️", "#8B5CF6"],
  ["Swipe reveal", "lightImpact · 12ms", "👉", "#EC4899"],
  ["Success", "notificationSuccess", "🎉", "#10B981"],
  ["Warning", "notificationWarning", "⚠️", "#F59E0B"],
  ["Error", "notificationError", "😖", "#EF4444"],
];

export function MotionSection() {
  return (
    <section id="motion" className="relative border-t border-[#F3F4F6] py-24">
      <div className="mx-auto max-w-7xl px-6">
        <SectionHead
          kicker="Motion & haptics"
          title={<>Playful, but <span className="text-[#D1D5DB]">never bouncy.</span></>}
          body="One easing curve across the whole app — 240–420ms, decelerating, with just enough overshoot to feel alive. Every interaction is paired with a haptic so the UI confirms itself in your hand. 🎈"
        />

        <div className="mt-14 grid gap-5 lg:grid-cols-[1fr_1.1fr]">
          <div className="rounded-[24px] border border-[#E5E7EB] bg-white p-6 sh-md">
            <div className="mb-1 flex items-baseline justify-between">
              <h3 className="font-display text-[16px] font-extrabold text-[#111827]">Signature ease</h3>
              <span className="font-mono text-[11px] font-bold text-indigo-600">
                cubic-bezier(.16, 1, .3, 1)
              </span>
            </div>
            <p className="mb-5 text-[12.5px] font-medium text-[#6B7280]">
              Fast attack, long glide-out. Used for pushes, sheets, reveals and page transitions.
            </p>
            <svg viewBox="0 0 240 140" className="w-full">
              <defs>
                <linearGradient id="curve-g" x1="0" x2="1">
                  <stop offset="0%" stopColor="#6366F1" stopOpacity=".2" />
                  <stop offset="100%" stopColor="#EC4899" />
                </linearGradient>
              </defs>
              {[0, 1, 2, 3, 4, 5].map((g) => (
                <line key={g} x1="0" y1={g * 24} x2="240" y2={g * 24} stroke="#F3F4F6" />
              ))}
              <path
                d="M6 134 C 44 134, 34 8, 234 6"
                fill="none"
                stroke="url(#curve-g)"
                strokeWidth="3"
                strokeLinecap="round"
              />
              <circle cx="6" cy="134" r="5" fill="#6366F1" />
              <circle cx="234" cy="6" r="5" fill="#EC4899" />
              <text x="8" y="126" fill="#9CA3AF" fontSize="9" fontFamily="monospace" fontWeight="700">
                0
              </text>
              <text x="214" y="20" fill="#9CA3AF" fontSize="9" fontFamily="monospace" fontWeight="700">
                1
              </text>
            </svg>
            <div className="mt-4 grid grid-cols-3 gap-3">
              {[
                ["Fast", "120ms", "#6366F1"],
                ["Standard", "240ms", "#EC4899"],
                ["Expressive", "420ms", "#F59E0B"],
              ].map(([k, v, c]) => (
                <div
                  key={k}
                  className="rounded-[16px] border border-[#F3F4F6] bg-white p-3 text-center sh-sm"
                  style={{ boxShadow: `0 4px 12px ${hex(c, 0.14)}` }}
                >
                  <div className="font-mono text-[13px] font-extrabold" style={{ color: c }}>
                    {v}
                  </div>
                  <div className="mt-0.5 text-[10.5px] font-bold uppercase tracking-wider text-[#9CA3AF]">
                    {k}
                  </div>
                </div>
              ))}
            </div>
          </div>

          <div className="rounded-[24px] border border-[#E5E7EB] bg-white p-6 sh-md">
            <h3 className="mb-1 font-display text-[16px] font-extrabold text-[#111827]">Haptic map</h3>
            <p className="mb-5 text-[12.5px] font-medium text-[#6B7280]">
              HapticFeedback.* on Android &amp; iOS — always paired, never gratuitous.
            </p>
            <div className="space-y-2">
              {HAPTICS.map(([label, spec, e, c]) => (
                <div
                  key={label}
                  className="flex items-center gap-3 rounded-[16px] border border-[#F3F4F6] bg-[#F9FAFB] px-3.5 py-3"
                  style={{ borderLeft: `3px solid ${c}` }}
                >
                  <span
                    className="grid h-9 w-9 shrink-0 place-items-center rounded-[12px] text-[16px]"
                    style={{ background: hex(c, 0.14) }}
                  >
                    {e}
                  </span>
                  <span className="flex-1 text-[13.5px] font-extrabold text-[#374151]">{label}</span>
                  <span className="font-mono text-[11px] font-semibold text-[#9CA3AF]">{spec}</span>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* live demos */}
        <div className="mt-5 grid gap-5 sm:grid-cols-2 lg:grid-cols-4">
          <Demo n="01" title="Card press" spec="scale 0.98 · 180ms" tint="#6366F1" hint="hold">
            <PressDemo />
          </Demo>
          <Demo n="02" title="FAB expand" spec="rotate 135° + cascade 55ms" tint="#8B5CF6" hint="tap">
            <FabDemo />
          </Demo>
          <Demo n="03" title="Tab switch" spec="slide 22 · fade · 240ms" tint="#10B981" hint="tap">
            <TabDemo />
          </Demo>
          <Demo n="04" title="Bottom sheet" spec="translateY 100% → 0 · 380ms" tint="#EC4899" hint="tap">
            <SheetDemo />
          </Demo>
          <Demo n="05" title="Confetti" spec="24 particles · radial 1.5s" tint="#F59E0B" hint="tap">
            <ConfettiDemo />
          </Demo>
          <Demo n="06" title="Swipe reveal" spec="translateX −140 · 400ms" tint="#06B6D4" hint="auto">
            <SwipeDemo />
          </Demo>
          <Demo n="07" title="Skeleton shimmer" spec="1.5s linear loop" tint="#9CA3AF" hint="auto">
            <SkeletonDemo />
          </Demo>
          <Demo n="08" title="Pull to refresh" spec="custom spinner · stroke draw" tint="#3B82F6" hint="auto">
            <PullDemo />
          </Demo>
          <Demo n="09" title="Toast variants" spec="4 states · fade-up 400ms" tint="#EF4444" hint="tap">
            <ToastDemo />
          </Demo>
          <Demo n="10" title="Bouncing loader" spec="6 dots · 1.25s stagger" tint="#8B5CF6" hint="auto">
            <BounceDemo />
          </Demo>
        </div>

        <p className="mt-8 text-center font-mono text-[11px] font-semibold text-[#9CA3AF]">
          all timings use cubic-bezier(.16, 1, .3, 1) · honours prefers-reduced-motion ♿
        </p>
      </div>
    </section>
  );
}
