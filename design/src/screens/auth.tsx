import { useEffect, useState } from "react";
import { Icon, GitFlowMark } from "@/lib/icons";
import { GRADS, Toast, hex } from "@/components/ui";

/* ============================================================
   01 · SPLASH — soft rainbow gradient + bouncing dots
   ============================================================ */

export function SplashScreen() {
  return (
    <div className="absolute inset-0 overflow-hidden bg-white">
      <div className="grad-page absolute inset-0" />
      <div
        className="anim-blob absolute -left-16 -top-16 h-64 w-64 rounded-full opacity-60 blur-3xl"
        style={{ background: "radial-gradient(circle,#C7D2FE,transparent 70%)" }}
      />
      <div
        className="anim-blob absolute -bottom-20 -right-16 h-72 w-72 rounded-full opacity-60 blur-3xl"
        style={{ background: "radial-gradient(circle,#FDE68A,transparent 70%)", animationDelay: "-6s" }}
      />

      <div className="absolute inset-0 flex flex-col items-center justify-center px-10">
        <div className="anim-pop relative">
          <span className="absolute -inset-8 rounded-full bg-white/50 blur-2xl" />
          <GitFlowMark size={100} className="anim-float relative drop-shadow-[0_16px_28px_rgba(99,102,241,0.4)]" />
        </div>

        <h1
          className="anim-fade-up mt-8 text-[34px] font-extrabold tracking-[-0.04em] text-ink font-display"
          style={{ animationDelay: "120ms" }}
        >
          GitFlow
        </h1>
        <p
          className="anim-fade-up mt-2 text-[15px] font-semibold text-muted"
          style={{ animationDelay: "220ms" }}
        >
          Your GitHub, Reimagined ✨
        </p>

        {/* bouncing dots */}
        <div className="anim-fade-in mt-12 flex items-center gap-2.5" style={{ animationDelay: "420ms" }}>
          {["#6366F1", "#8B5CF6", "#EC4899", "#F59E0B", "#10B981", "#06B6D4"].map((c, i) => (
            <span
              key={c}
              className="dot-bounce h-2.5 w-2.5 rounded-full"
              style={{ background: c, animationDelay: `${i * 110}ms`, boxShadow: `0 4px 10px ${hex(c, 0.5)}` }}
            />
          ))}
        </div>
        <p
          className="anim-fade-in mt-5 font-mono text-[10.5px] font-medium tracking-wide text-faint"
          style={{ animationDelay: "520ms" }}
        >
          syncing 147 repositories…
        </p>
      </div>

      <div
        className="anim-fade-in absolute inset-x-0 bottom-11 flex flex-col items-center gap-1.5"
        style={{ animationDelay: "640ms" }}
      >
        <span className="rounded-full bg-white/70 px-3 py-1 font-mono text-[10px] font-bold tracking-[0.14em] text-muted backdrop-blur">
          v2.1.0 · BUILD 4218
        </span>
        <span className="font-mono text-[10px] tracking-[0.14em] text-faint">MADE WITH FLUTTER 💜</span>
      </div>
    </div>
  );
}

/* ============================================================
   02 · ONBOARDING — 3 bright gradient slides
   ============================================================ */

const SLIDES = [
  {
    img: "/img/l1.png",
    kicker: "Repositories",
    title: "All Your Repos\nin One Place",
    body: "Public, private, forked and starred — beautifully organised, searchable in a keystroke, cached for offline.",
    tint: "#6366F1",
    tint2: "#8B5CF6",
    emoji: "📦",
  },
  {
    img: "/img/l2.png",
    kicker: "Code Review",
    title: "Code, Review,\nMerge — Anywhere",
    body: "A native diff renderer with syntax highlighting, inline comments and one-tap merges from the train.",
    tint: "#F59E0B",
    tint2: "#EC4899",
    emoji: "🔀",
  },
  {
    img: "/img/l3.png",
    kicker: "Notifications",
    title: "Stay Notified\nin Real-Time",
    body: "Mentions, CI failures and reviews pushed the instant they happen — with smart muting that respects focus.",
    tint: "#06B6D4",
    tint2: "#3B82F6",
    emoji: "🔔",
  },
];

/* Vector fallback art — always rendered beneath the raster illustration */
function SlideArt({ tint, tint2, variant }: { tint: string; tint2: string; variant: number }) {
  return (
    <svg viewBox="0 0 280 280" className="absolute inset-0 h-full w-full">
      <defs>
        <linearGradient id={`sa-${variant}`} x1="0" y1="0" x2="1" y2="1">
          <stop offset="0%" stopColor={hex(tint, 0.22)} />
          <stop offset="100%" stopColor={hex(tint2, 0.22)} />
        </linearGradient>
      </defs>
      <rect width="280" height="280" fill={`url(#sa-${variant})`} />
      {[0, 1, 2, 3, 4].map((r) => (
        <rect
          key={r}
          x={30 + (r % 3) * 26}
          y={48 + r * 40}
          width={r % 2 ? 128 : 172}
          height={72}
          rx={20}
          fill="#fff"
          fillOpacity=".72"
          stroke={tint}
          strokeOpacity=".28"
          strokeWidth="2"
        />
      ))}
      {Array.from({ length: 8 }).map((_, k) => (
        <circle key={k} cx={36 + k * 30} cy={k % 2 ? 68 : 216} r="7" fill={k % 2 ? tint2 : tint} fillOpacity=".55" />
      ))}
    </svg>
  );
}

export function OnboardingScreen() {
  const [i, setI] = useState(0);
  const s = SLIDES[i];
  const last = i === SLIDES.length - 1;

  useEffect(() => {
    const t = setInterval(() => setI((v) => (v + 1) % SLIDES.length), 4200);
    return () => clearInterval(t);
  }, []);

  return (
    <div className="absolute inset-0 flex flex-col bg-white">
      {/* soft tinted backdrop matching the slide */}
      <div
        className="pointer-events-none absolute inset-0 transition-all duration-500"
        style={{
          background: `linear-gradient(160deg,${hex(s.tint, 0.12)},${hex(s.tint2, 0.1)} 55%,#fff 100%)`,
        }}
      />

      <div className="relative z-10 flex items-center justify-between px-5 pt-[58px]">
        <div className="flex items-center gap-2.5">
          <GitFlowMark size={26} />
          <span className="font-display text-[15px] font-extrabold tracking-[-0.02em] text-ink">
            GitFlow
          </span>
        </div>
        <button className="press rounded-full border border-line bg-white/80 px-3.5 py-2 text-[12.5px] font-bold text-muted backdrop-blur sh-sm">
          Skip
        </button>
      </div>

      <div className="relative flex-1">
        {SLIDES.map((sl, idx) => (
          <div
            key={sl.title}
            className="absolute inset-0 flex flex-col items-center justify-center px-8"
            style={{
              opacity: idx === i ? 1 : 0,
              transform: idx === i ? "scale(1)" : "scale(.94)",
              transition: "opacity .5s ease, transform .5s cubic-bezier(.16,1,.3,1)",
              pointerEvents: idx === i ? "auto" : "none",
            }}
          >
            <div className="relative mb-6 h-[276px] w-[276px]">
              <span
                className="absolute inset-4 rounded-[46px] blur-2xl"
                style={{ background: hex(sl.tint, 0.42) }}
              />
              <div
                className="absolute inset-0 overflow-hidden rounded-[36px] border-[6px] border-white sh-lift"
                style={{ boxShadow: `0 24px 60px -18px ${hex(sl.tint, 0.6)}` }}
              >
                <SlideArt tint={sl.tint} tint2={sl.tint2} variant={idx} />
                <img
                  src={sl.img}
                  alt=""
                  onError={(e) => (e.currentTarget.style.display = "none")}
                  className="relative h-full w-full object-cover"
                />
              </div>
              <span
                className="absolute -bottom-3 -right-3 grid h-14 w-14 place-items-center rounded-[20px] text-[26px] sh-lift"
                style={{ background: `linear-gradient(135deg,${sl.tint},${sl.tint2})` }}
              >
                {sl.emoji}
              </span>
            </div>
          </div>
        ))}
      </div>

      <div
        className="relative z-10 rounded-t-[32px] border-t border-line bg-white/92 px-7 pb-8 pt-6 backdrop-blur-xl"
        style={{ boxShadow: "0 -12px 40px -20px rgba(17,24,39,.18)" }}
      >
        <div
          className="mb-4 inline-flex items-center gap-1.5 rounded-full px-3 py-1.5 text-[11px] font-extrabold uppercase tracking-wider"
          style={{ color: s.tint, background: hex(s.tint, 0.12), border: `1px solid ${hex(s.tint, 0.24)}` }}
        >
          {s.emoji} {s.kicker}
        </div>
        <h2 className="whitespace-pre-line font-display text-[26px] font-extrabold leading-[1.12] tracking-[-0.03em] text-ink">
          {s.title}
        </h2>
        <p className="mt-2.5 min-h-[60px] text-[14px] font-medium leading-relaxed text-muted">{s.body}</p>

        <div className="mt-6 flex items-center justify-between">
          <div className="flex items-center gap-1.5">
            {SLIDES.map((sl, idx) => (
              <button
                key={idx}
                onClick={() => setI(idx)}
                className="h-2 rounded-full transition-all duration-300"
                style={{
                  width: idx === i ? 26 : 7,
                  background: idx === i ? `linear-gradient(90deg,${sl.tint},${sl.tint2})` : "var(--gf-line-2)",
                }}
              />
            ))}
          </div>
          <button
            onClick={() => setI((v) => (v + 1) % SLIDES.length)}
            className="press flex h-12 items-center gap-1.5 rounded-full px-6 text-[14.5px] font-extrabold text-white"
            style={{
              background: last ? GRADS.brand : `linear-gradient(135deg,${s.tint},${s.tint2})`,
              boxShadow: `0 12px 28px -8px ${hex(last ? "#6366F1" : s.tint, 0.7)}`,
            }}
          >
            {last ? "Get Started 🎉" : "Next"}
            <Icon name={last ? "arrowRight" : "chevronRight"} size={16} strokeWidth={3} />
          </button>
        </div>
        <div className="h-[14px]" />
      </div>
    </div>
  );
}

/* ============================================================
   03 · LOGIN — white + gradient blob
   ============================================================ */

const CODE_LINES = [
  "const app = await GitFlow.bootstrap();",
  "final client = GitHub(token: vault.read());",
  "await client.sync(repos: all, depth: 3);",
  "stream.listen((e) => notify(e));",
  "// offline-first, always",
  "vault.lock(biometric: true);",
];

export function LoginScreen() {
  return (
    <div className="absolute inset-0 overflow-hidden bg-white">
      {/* gradient blob top */}
      <div className="pointer-events-none absolute inset-x-0 -top-40 h-[420px] overflow-hidden">
        <div
          className="anim-blob absolute -left-24 top-10 h-72 w-72 rounded-full blur-3xl"
          style={{ background: "radial-gradient(circle,#C7D2FE,transparent 70%)" }}
        />
        <div
          className="anim-blob absolute left-1/2 top-0 h-72 w-72 -translate-x-1/2 rounded-full blur-3xl"
          style={{ background: "radial-gradient(circle,#FBCFE8,transparent 70%)", animationDelay: "-5s" }}
        />
        <div
          className="anim-blob absolute -right-20 top-16 h-72 w-72 rounded-full blur-3xl"
          style={{ background: "radial-gradient(circle,#FEF3C7,transparent 70%)", animationDelay: "-11s" }}
        />
      </div>
      <div className="page-grid pointer-events-none absolute inset-0 opacity-60" />

      {/* faint code pattern */}
      <div className="pointer-events-none absolute inset-0 overflow-hidden opacity-[0.1]">
        <div className="absolute -left-8 top-[120px] space-y-3 font-mono text-[9px] font-medium leading-relaxed text-brand">
          {CODE_LINES.map((l, i) => (
            <div key={i} style={{ marginLeft: (i % 3) * 16 }}>
              {l}
            </div>
          ))}
        </div>
        <div className="absolute -right-10 top-[440px] space-y-3 font-mono text-[9px] font-medium leading-relaxed text-blush">
          {[...CODE_LINES].reverse().map((l, i) => (
            <div key={i} style={{ marginRight: (i % 3) * 16 }}>
              {l}
            </div>
          ))}
        </div>
      </div>

      <div className="gf-scroll absolute inset-0 overflow-y-auto px-6 pb-8 pt-[96px]">
        <div className="anim-fade-up flex flex-col items-center">
          <GitFlowMark size={68} className="drop-shadow-[0_14px_28px_rgba(99,102,241,0.38)]" />
        </div>

        <div className="anim-fade-up mt-7 text-center" style={{ animationDelay: "80ms" }}>
          <div className="mb-2 text-[38px] leading-none">👋</div>
          <h1 className="font-display text-[30px] font-extrabold tracking-[-0.03em] text-ink">
            Welcome back!
          </h1>
          <p className="mt-2.5 text-[14.5px] font-medium leading-relaxed text-muted">
            Sign in to sync your repositories,
            <br /> notifications and review queue.
          </p>
        </div>

        <div className="anim-fade-up mt-9 space-y-3" style={{ animationDelay: "160ms" }}>
          <button
            className="press relative flex h-[54px] w-full items-center justify-center gap-2.5 overflow-hidden rounded-[16px] text-[15px] font-extrabold text-white"
            style={{ background: GRADS.brand, boxShadow: "0 14px 32px -10px rgba(99,102,241,.75)" }}
          >
            <span className="absolute inset-0 bg-gradient-to-b from-white/20 to-transparent" />
            <Icon name="github" size={20} strokeWidth={1.6} className="relative" />
            <span className="relative">Continue with GitHub</span>
          </button>

          <button className="press flex h-[54px] w-full items-center justify-center gap-2.5 rounded-[16px] border border-line bg-white text-[15px] font-bold text-ink sh-sm">
            <span
              className="grid h-7 w-7 place-items-center rounded-[10px] text-white"
              style={{ background: GRADS.cool }}
            >
              <Icon name="tag" size={15} strokeWidth={2.2} />
            </span>
            Personal Access Token
          </button>

          <div className="flex items-center gap-3 py-1.5">
            <span className="h-px flex-1 bg-line" />
            <span className="text-[11.5px] font-bold uppercase tracking-wider text-faint">or</span>
            <span className="h-px flex-1 bg-line" />
          </div>

          <button className="press flex h-[54px] w-full items-center justify-center gap-2.5 rounded-[16px] border-2 border-dashed border-brand/35 bg-brand/[0.04] text-[15px] font-bold text-brand">
            <Icon name="fingerprint" size={22} strokeWidth={1.5} />
            Unlock with biometrics
          </button>
        </div>

        <div
          className="anim-fade-up mt-7 rounded-[18px] border border-mint/25 bg-mint/[0.06] p-4"
          style={{ animationDelay: "240ms" }}
        >
          <div className="flex items-start gap-3">
            <span
              className="grid h-9 w-9 shrink-0 place-items-center rounded-[13px] text-white"
              style={{ background: GRADS.mint, boxShadow: "0 6px 14px rgba(16,185,129,.35)" }}
            >
              <Icon name="shield" size={17} strokeWidth={2.1} />
            </span>
            <p className="text-[12px] font-medium leading-relaxed text-muted">
              Tokens live in the platform keychain with hardware-backed encryption. GitFlow never
              sees your credentials. 🔐
            </p>
          </div>
        </div>

        <div
          className="anim-fade-up mt-8 flex flex-wrap items-center justify-center gap-1.5 text-[12.5px] font-bold"
          style={{ animationDelay: "300ms" }}
        >
          {["Terms", "Privacy Policy", "Open Source"].map((l, i) => (
            <span key={l} className="flex items-center gap-1.5">
              {i > 0 && <span className="text-faint">·</span>}
              <a className="text-brand">{l}</a>
            </span>
          ))}
        </div>
        <p className="mt-3 text-center font-mono text-[10px] font-bold tracking-widest text-faint">
          V2.1.0
        </p>
      </div>

      <div className="pointer-events-none absolute inset-x-4 bottom-6 z-30 flex justify-center">
        <Toast variant="success" title="Welcome back, Muhammad 👋" body="Synced 147 repos in 1.2s" />
      </div>
    </div>
  );
}
