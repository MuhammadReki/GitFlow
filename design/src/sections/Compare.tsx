import { Icon } from "@/lib/icons";
import { Phone } from "@/components/Phone";
import { NotificationsScreen } from "@/screens/work";
import { RepoListScreen } from "@/screens/browse";
import { SectionHead } from "@/sections/ScreensGallery";

const DELTAS: [string, string, string, string, string][] = [
  ["Mood", "#010409", "Brooding, terminal-like", "#FFFFFF", "Bright, friendly, welcoming"],
  ["Accent", "#238636", "One hue — GitHub green", "#6366F1", "Eight hues, five gradients"],
  ["Shadows", "#000000", "Hard black drop shadows", "#6366F1", "Soft indigo-tinted shadows"],
  ["Corners", "#30363D", "8–12px, hairline borders", "#6366F1", "16–24px, generous padding"],
  ["Icons", "#8B949E", "Line glyphs only", "#EC4899", "Emoji + glyph, color-coded"],
  ["Code view", "#0D1117", "Dark editor in a dark app", "#FEFCE8", "Soft cream canvas, light syntax"],
];

export function CompareSection() {
  return (
    <section id="compare" className="relative border-t border-[#F3F4F6] py-24">
      <div className="mx-auto max-w-7xl px-6">
        <SectionHead
          kicker="Before / after"
          title={<>Same data. <span className="text-[#D1D5DB]">Opposite mood.</span></>}
          body="We started with a GitHub-dark theme — technically excellent, emotionally cold. Here's what changed when we turned the lights on. ☀️"
        />

        <div className="mt-14 grid items-center gap-10 lg:grid-cols-2">
          <div className="flex flex-col items-center">
            <span className="mb-5 inline-flex items-center gap-2 rounded-full border border-[#E5E7EB] bg-[#F9FAFB] px-3.5 py-2 text-[12px] font-extrabold text-[#6B7280]">
              🌙 Before · v1.0 dark
            </span>
            <Phone frame="pixel" theme="dark" scale={0.52}>
              <RepoListScreen />
            </Phone>
          </div>
          <div className="flex flex-col items-center">
            <span
              className="mb-5 inline-flex items-center gap-2 rounded-full px-3.5 py-2 text-[12px] font-extrabold text-white grad-brand sh-md"
            >
              ☀️ After · v2.1 bright
            </span>
            <Phone frame="pixel" scale={0.52}>
              <RepoListScreen />
            </Phone>
          </div>
        </div>

        {/* delta table */}
        <div className="mt-16 overflow-hidden rounded-[24px] border border-[#E5E7EB] bg-white sh-md">
          <div className="grid grid-cols-[1fr_1fr_1fr] gap-4 border-b border-[#F3F4F6] bg-[#F9FAFB] px-6 py-4 text-[11.5px] font-extrabold uppercase tracking-wider text-[#9CA3AF]">
            <span>Dimension</span>
            <span>🌙 Before · dark</span>
            <span className="text-indigo-600">☀️ After · bright</span>
          </div>
          {DELTAS.map(([k, c1, a, c2, b], i) => (
            <div
              key={k}
              className={`grid grid-cols-[1fr_1fr_1fr] gap-4 px-6 py-4 ${i % 2 ? "bg-[#FAFAFC]" : "bg-white"}`}
            >
              <span className="flex items-center gap-2 text-[13.5px] font-extrabold text-[#111827]">
                <span className="h-3 w-3 rounded-[4px]" style={{ background: c2 }} />
                {k}
              </span>
              <span className="flex items-center gap-2 text-[13px] font-semibold text-[#9CA3AF]">
                <span className="h-3 w-3 rounded-[4px]" style={{ background: c1 }} />
                {a}
              </span>
              <span className="flex items-center gap-2 text-[13px] font-bold text-[#374151]">
                <Icon name="check" size={13} strokeWidth={3.4} className="shrink-0 text-emerald-500" />
                {b}
              </span>
            </div>
          ))}
        </div>

        {/* annotated notification screen */}
        <div className="mt-24">
          <SectionHead
            kicker="Feature annotations"
            title="Anatomy of a notification card 🔔"
            body="Every element earns its pixels — and every type gets its own colour so you know what happened before you read a word."
          />
          <div className="mt-14 grid items-center gap-12 lg:grid-cols-[auto_1fr]">
            <div className="relative mx-auto">
              <div className="pointer-events-none absolute left-1/2 top-1/2 h-[420px] w-[420px] -translate-x-1/2 -translate-y-1/2 rounded-full opacity-50 blur-[90px]"
                style={{ background: "radial-gradient(50% 50% at 50% 50%,rgba(236,72,153,.4),transparent 70%)" }} />
              <Phone frame="iphone" scale={0.62} className="relative">
                <NotificationsScreen />
              </Phone>
            </div>
            <div className="space-y-3">
              {[
                ["Type colour", "PR purple, issue amber, comment blue, star yellow, follow pink — recognisable at a glance.", "#8B5CF6", "🔀"],
                ["Emoji glyph", "A friendly emoji in a tinted tile doubles the recognition signal without extra reading.", "#8B5CF6", "🔀"],
                ["Unread pulse", "A 2.2s red ring loop on the dot plus a gradient badge on the tab.", "#EF4444", "🔴"],
                ["Repo identity", "Owner avatar + monospace repo path, truncated from the left so the repo name survives.", "#3B82F6", "📦"],
                ["Swipe affordance", "Drag reveals Mark read (emerald→cyan) and Mute (red→rose) gradients with a haptic.", "#10B981", "👉"],
                ["Time decay", "Relative timestamps that tick live: 4m → 22m → 1h. No mental math required.", "#F59E0B", "⏰"],
              ].map(([t, d, c, e]) => (
                <div
                  key={t}
                  className="flex gap-4 rounded-[20px] border border-[#E5E7EB] bg-white p-4 transition hover:bg-[#FAFAFC] sh-sm"
                  style={{ borderLeft: `3px solid ${c}` }}
                >
                  <span
                    className="grid h-11 w-11 shrink-0 place-items-center rounded-[14px] text-[19px]"
                    style={{ background: `${c}18` }}
                  >
                    {e}
                  </span>
                  <div>
                    <div className="font-display text-[14px] font-extrabold text-[#111827]">{t}</div>
                    <p className="mt-1 text-[13px] font-medium leading-relaxed text-[#6B7280]">{d}</p>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

/* ============================================================
   PRICING
   ============================================================ */

const TIERS = [
  {
    name: "Free",
    emoji: "🌱",
    price: "$0",
    sub: "forever",
    color: "#10B981",
    features: ["1 account", "Public repositories", "Read-only notifications", "Light theme ☀️"],
    cta: "Download",
  },
  {
    name: "Pro",
    emoji: "🚀",
    price: "$9.99",
    sub: "per month",
    color: "#6366F1",
    gradient: "linear-gradient(135deg,#6366F1,#8B5CF6)",
    features: [
      "Unlimited accounts & orgs",
      "Offline sync · 30-day cache",
      "Code review + inline comments",
      "Biometric token vault 🔐",
      "Real-time CI & push alerts",
    ],
    cta: "Start 14-day trial",
    featured: true,
  },
  {
    name: "Team",
    emoji: "👥",
    price: "$19",
    sub: "per seat / month",
    color: "#EC4899",
    features: ["Everything in Pro", "Shared review queues", "SSO + SCIM", "Audit log export"],
    cta: "Talk to us",
  },
];

export function PricingSection() {
  return (
    <section className="relative border-t border-[#F3F4F6] py-24">
      <div className="mx-auto max-w-7xl px-6">
        <SectionHead
          kicker="Pricing"
          title="Priced like a tool you keep 💜"
          body="No ads, no data brokerage, no engagement tricks. Just a fast, cheerful client and a sustainable subscription."
        />
        <div className="mt-14 grid gap-5 md:grid-cols-3">
          {TIERS.map((t) => (
            <div
              key={t.name}
              className="relative flex flex-col rounded-[26px] border p-7"
              style={
                t.featured
                  ? {
                      borderColor: "rgba(99,102,241,.4)",
                      background: "linear-gradient(180deg,rgba(99,102,241,.07),rgba(255,255,255,1) 55%)",
                      boxShadow: "0 20px 50px -16px rgba(99,102,241,.35)",
                    }
                  : { borderColor: "#E5E7EB", background: "#fff", boxShadow: `0 8px 24px ${t.color}14` }
              }
            >
              {t.featured && (
                <span
                  className="absolute -top-3 left-7 rounded-full px-3 py-1 text-[10.5px] font-extrabold uppercase tracking-wider text-white grad-brand sh-sm"
                >
                  Most popular ⭐
                </span>
              )}
              <div className="flex items-center gap-2.5">
                <span
                  className="grid h-11 w-11 place-items-center rounded-[15px] text-[20px]"
                  style={
                    t.gradient
                      ? { background: t.gradient, boxShadow: `0 8px 18px ${t.color}44` }
                      : { background: `${t.color}18` }
                  }
                >
                  {t.emoji}
                </span>
                <span className="font-display text-[16px] font-extrabold text-[#111827]">{t.name}</span>
              </div>
              <div className="mt-6 flex items-baseline gap-1.5">
                <span className="font-display text-[42px] font-extrabold tracking-[-0.04em] text-[#111827]">
                  {t.price}
                </span>
                <span className="text-[13px] font-bold text-[#9CA3AF]">{t.sub}</span>
              </div>
              <ul className="mt-6 flex-1 space-y-3">
                {t.features.map((f) => (
                  <li key={f} className="flex items-start gap-2.5 text-[13.5px] font-semibold text-[#6B7280]">
                    <Icon name="check" size={14} strokeWidth={3.4} className="mt-[3px] shrink-0" style={{ color: t.color }} />
                    {f}
                  </li>
                ))}
              </ul>
              <button
                className={`press mt-7 h-12 w-full rounded-[16px] text-[14px] font-extrabold ${
                  t.featured ? "text-white grad-brand" : "border border-[#E5E7EB] bg-white text-[#111827]"
                }`}
                style={
                  t.featured
                    ? { boxShadow: "0 14px 32px -12px rgba(99,102,241,.8)" }
                    : { boxShadow: "0 1px 2px rgba(99,102,241,.05)" }
                }
              >
                {t.cta}
              </button>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

export function Footer() {
  return (
    <footer className="relative overflow-hidden border-t border-[#F3F4F6] pt-24">
      <div className="pointer-events-none absolute inset-x-0 -top-32 h-[400px] opacity-80"
        style={{ background: "radial-gradient(50% 60% at 50% 100%,rgba(236,72,153,.18),transparent 70%)" }} />
      <div className="relative mx-auto max-w-7xl px-6">
        <div className="flex flex-col items-center text-center">
          <h2 className="font-display text-balance text-[clamp(2rem,4.6vw,3.4rem)] font-extrabold leading-[1.02] tracking-[-0.04em] text-[#111827]">
            Your GitHub, <span className="grad-text">Reimagined.</span>
          </h2>
          <p className="mt-5 max-w-lg text-balance text-[16px] font-medium leading-relaxed text-[#6B7280]">
            The complete bright &amp; friendly design system — 12 screens, 42 components, 60 icons,
            motion specs and Figma-ready tokens. 🎁
          </p>
          <div className="mt-9 flex flex-wrap justify-center gap-3">
            <a
              href="#top"
              className="press inline-flex h-12 items-center gap-2 rounded-full px-6 text-[15px] font-extrabold text-white grad-brand sh-lift"
            >
              <Icon name="download" size={16} strokeWidth={2.6} />
              Download the UI kit
            </a>
            <a
              href="#screens"
              className="press inline-flex h-12 items-center gap-2 rounded-full border border-[#E5E7EB] bg-white px-6 text-[15px] font-bold text-[#111827] sh-sm"
            >
              <Icon name="github" size={16} strokeWidth={1.8} />
              Star on GitHub
            </a>
          </div>
        </div>

        <div className="mt-20 grid gap-8 border-t border-[#F3F4F6] py-10 sm:grid-cols-2 lg:grid-cols-5">
          {[
            ["Product 📱", ["Overview", "Screens", "Components", "Motion", "Changelog"]],
            ["Design 🎨", ["Tokens", "Typography", "Gradients", "Icons", "Figma library"]],
            ["Develop 💻", ["Flutter", "GitHub OAuth", "Rate limits", "Offline sync", "CLI"]],
            ["Company 💜", ["About", "Blog", "Careers", "Press kit", "Contact"]],
          ].map(([h, items]) => (
            <div key={h as string}>
              <div className="text-[12px] font-extrabold uppercase tracking-wider text-[#9CA3AF]">{h}</div>
              <ul className="mt-4 space-y-2.5">
                {(items as string[]).map((it) => (
                  <li key={it}>
                    <a className="text-[13.5px] font-semibold text-[#6B7280] transition hover:text-indigo-600">
                      {it}
                    </a>
                  </li>
                ))}
              </ul>
            </div>
          ))}
          <div>
            <div className="text-[12px] font-extrabold uppercase tracking-wider text-[#9CA3AF]">
              Status 💚
            </div>
            <div className="mt-4 inline-flex items-center gap-2 rounded-full border border-emerald-200 bg-emerald-50 px-3 py-1.5">
              <span className="h-2 w-2 rounded-full bg-emerald-500" />
              <span className="text-[12px] font-extrabold text-emerald-700">All systems normal</span>
            </div>
          </div>
        </div>

        <div className="flex flex-col items-center justify-between gap-3 border-t border-[#F3F4F6] py-7 sm:flex-row">
          <span className="font-mono text-[11px] font-semibold text-[#9CA3AF]">
            © 2026 GitFlow Labs · Made with Flutter in Jakarta 🇮🇩
          </span>
          <span className="font-mono text-[11px] font-semibold text-[#9CA3AF]">
            v2.1.0 · BUILD 4218 · 60fps ☀️
          </span>
        </div>
      </div>
    </footer>
  );
}
