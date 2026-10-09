import { cn } from "@/utils/cn";
import { Icon, GitFlowMark, type IconName } from "@/lib/icons";
import { SectionHead } from "@/sections/ScreensGallery";

const COLORS: { group: string; note: string; items: [string, string, string][] }[] = [
  {
    group: "Bright & cheerful",
    note: "the brand ramp — used liberally",
    items: [
      ["Primary · Indigo", "#6366F1", "CTAs, active tabs, links"],
      ["Secondary · Purple", "#8B5CF6", "Creative, PRs, premium"],
      ["Accent · Emerald", "#10B981", "Success, growth, open issues"],
      ["Highlight · Amber", "#F59E0B", "Warm attention, stars, FABs"],
      ["Danger · Red", "#EF4444", "Errors, closed, failing CI"],
      ["Info · Blue", "#3B82F6", "Links, info, comments"],
      ["Pink", "#EC4899", "Special highlights, followers"],
      ["Cyan", "#06B6D4", "Tech feel, forks"],
    ],
  },
  {
    group: "Backgrounds",
    note: "always light, always airy",
    items: [
      ["Main Background", "#FFFFFF", "Pure white app canvas"],
      ["Secondary", "#F9FAFB", "Very light gray sections"],
      ["Card", "#FFFFFF", "Cards, with soft shadow"],
      ["Elevated", "#F3F4F6", "Subtle gray surfaces"],
      ["Code Canvas", "#FEFCE8", "Soft cream for code"],
    ],
  },
  {
    group: "Text, borders & dividers",
    note: "no harsh blacks, no neon",
    items: [
      ["Text Primary", "#111827", "Almost black"],
      ["Text Secondary", "#6B7280", "Medium gray"],
      ["Text Tertiary", "#9CA3AF", "Light gray"],
      ["Text on Primary", "#FFFFFF", "White"],
      ["Border Light", "#E5E7EB", "Default hairlines"],
      ["Border Medium", "#D1D5DB", "Emphasised edges"],
      ["Divider", "#F3F4F6", "Row separators"],
    ],
  },
];

const GRADIENTS: [string, string, string][] = [
  ["Primary", "linear-gradient(135deg,#6366F1,#8B5CF6)", "#6366F1"],
  ["Success", "linear-gradient(135deg,#10B981,#06B6D4)", "#10B981"],
  ["Warm", "linear-gradient(135deg,#F59E0B,#EC4899)", "#F59E0B"],
  ["Cool", "linear-gradient(135deg,#3B82F6,#8B5CF6)", "#3B82F6"],
  ["Sun", "linear-gradient(135deg,#F59E0B,#F97316)", "#F59E0B"],
  ["Rainbow", "linear-gradient(135deg,#6366F1,#EC4899,#F59E0B)", "#EC4899"],
];

const SHADOWS: [string, string][] = [
  ["Small", "0 1px 2px rgba(99,102,241,.05)"],
  ["Medium", "0 4px 12px rgba(99,102,241,.08)"],
  ["Large", "0 8px 24px rgba(99,102,241,.12)"],
  ["Glow", "0 0 20px rgba(99,102,241,.15)"],
];

const TYPE = [
  ["Display / H1", "32 / 38", "Plus Jakarta Sans 800 · -3%", "GitFlow"],
  ["H2", "24 / 30", "Plus Jakarta Sans 800 · -2%", "Repositories"],
  ["H3", "20 / 26", "Plus Jakarta Sans 800", "Pull requests"],
  ["Body", "15 / 22", "Inter Medium", "Merged 4 files into main"],
  ["Caption", "13 / 18", "Inter Semibold", "opened 2 hours ago"],
  ["Micro", "11 / 14", "Inter Extrabold · caps", "PRIVATE"],
  ["Mono / Code", "13 / 23", "JetBrains Mono Medium", "feat(core): offline queue"],
];

const TOKENS = `{
  "color": {
    "bg":  { "base": "#FFFFFF", "subtle": "#F9FAFB", "elevated": "#F3F4F6" },
    "text": { "primary": "#111827", "secondary": "#6B7280", "tertiary": "#9CA3AF" },
    "border": { "light": "#E5E7EB", "medium": "#D1D5DB", "divider": "#F3F4F6" },
    "brand": {
      "primary": "#6366F1", "secondary": "#8B5CF6", "accent": "#10B981",
      "highlight": "#F59E0B", "danger": "#EF4444", "info": "#3B82F6",
      "pink": "#EC4899", "cyan": "#06B6D4"
    }
  },
  "gradient": {
    "primary": "135deg #6366F1 -> #8B5CF6",
    "success": "135deg #10B981 -> #06B6D4",
    "warm":    "135deg #F59E0B -> #EC4899",
    "cool":    "135deg #3B82F6 -> #8B5CF6",
    "rainbow": "135deg #6366F1 -> #EC4899 -> #F59E0B"
  },
  "radius":  { "button": 12, "card": 20, "input": 12, "chip": 999 },
  "shadow":  {
    "sm": "0 1px 2px rgba(99,102,241,.05)",
    "md": "0 4px 12px rgba(99,102,241,.08)",
    "lg": "0 8px 24px rgba(99,102,241,.12)",
    "glow": "0 0 20px rgba(99,102,241,.15)"
  },
  "space":   [4, 8, 12, 16, 20, 24, 32, 48],
  "type":    { "h1": 32, "h2": 24, "h3": 20, "body": 15, "caption": 13 }
}`;

const ICONS: IconName[] = [
  "home", "repo", "bell", "user", "search", "filter", "star", "fork", "eye",
  "issueOpen", "issueClosed", "prOpen", "prMerged", "prClosed", "branch",
  "commit", "merge", "folder", "file", "code", "terminal", "copy", "share",
  "edit", "blame", "history", "fingerprint", "github", "settings", "logout",
  "moon", "sun", "shield", "lock", "globe", "mail", "pin", "building",
  "clock", "comment", "sparkle", "flame", "trending", "cpu", "tag", "users",
  "bolt", "layers", "palette", "book", "graph", "refresh", "warning", "info",
];

function Panel({
  title,
  sub,
  children,
  className,
  tint,
}: {
  title: string;
  sub?: string;
  children: React.ReactNode;
  className?: string;
  tint?: string;
}) {
  return (
    <div
      className={cn("rounded-[24px] border border-[#E5E7EB] bg-white p-6 sh-md", className)}
      style={tint ? { boxShadow: `0 10px 30px ${tint}1a` } : undefined}
    >
      <div className="mb-5 flex items-baseline justify-between">
        <h3 className="font-display text-[16px] font-extrabold tracking-[-0.02em] text-[#111827]">
          {title}
        </h3>
        {sub && <span className="font-mono text-[11px] font-bold text-[#9CA3AF]">{sub}</span>}
      </div>
      {children}
    </div>
  );
}

export function SystemSection() {
  return (
    <section id="system" className="relative border-t border-[#F3F4F6] py-24">
      <div className="mx-auto max-w-7xl px-6">
        <SectionHead
          kicker="Design system"
          title={<>Bright &amp; friendly. <span className="text-[#D1D5DB]">Zero dark mode.</span></>}
          body="One light-first token layer with eight happy hues and five gradients. Generous whitespace, 20px card radii, and soft indigo-tinted shadows instead of harsh black."
        />

        {/* colors */}
        <div className="mt-14 grid gap-5 lg:grid-cols-3">
          {COLORS.map((g, gi) => (
            <Panel key={g.group} title={g.group} sub={g.note} tint={["#6366F1", "#EC4899", "#10B981"][gi]}>
              <div className="space-y-1">
                {g.items.map(([name, hexv, use]) => (
                  <div
                    key={name}
                    className="flex items-center gap-3 rounded-[14px] px-2 py-2 transition hover:bg-[#F9FAFB]"
                  >
                    <span
                      className="grid h-9 w-9 shrink-0 place-items-center rounded-[12px] text-[15px]"
                      style={{
                        background: hexv,
                        boxShadow: `0 6px 14px ${hexv}44`,
                        border: hexv === "#FFFFFF" ? "1px solid #E5E7EB" : undefined,
                      }}
                    >
                      {hexv === "#FFFFFF" ? "☀️" : ""}
                    </span>
                    <div className="min-w-0 flex-1">
                      <div className="truncate text-[12.5px] font-extrabold text-[#374151]">{name}</div>
                      <div className="truncate text-[11px] font-semibold text-[#9CA3AF]">{use}</div>
                    </div>
                    <span className="shrink-0 font-mono text-[10.5px] font-bold text-[#9CA3AF]">{hexv}</span>
                  </div>
                ))}
              </div>
            </Panel>
          ))}
        </div>

        {/* gradients + shadows */}
        <div className="mt-5 grid gap-5 lg:grid-cols-[1.4fr_1fr]">
          <Panel title="Gradients" sub="used liberally ✨" tint="#8B5CF6">
            <div className="grid gap-3 sm:grid-cols-2">
              {GRADIENTS.map(([name, g, c]) => (
                <div key={name} className="overflow-hidden rounded-[18px] border border-[#F3F4F6]">
                  <div className="flex h-20 items-end p-3.5" style={{ background: g }}>
                    <span className="font-display text-[14px] font-extrabold text-white drop-shadow">
                      {name}
                    </span>
                  </div>
                  <div className="flex items-center justify-between bg-[#F9FAFB] px-3.5 py-2">
                    <span className="text-[11.5px] font-bold" style={{ color: c }}>
                      {name}
                    </span>
                    <span className="font-mono text-[10px] font-semibold text-[#9CA3AF]">135°</span>
                  </div>
                </div>
              ))}
            </div>
            <div
              className="mt-3 flex h-16 items-center justify-center rounded-[18px] border border-[#F3F4F6] font-mono text-[11px] font-bold text-[#6B7280]"
              style={{ background: "linear-gradient(135deg,#EEF2FF 0%,#FCE7F3 50%,#FEF3C7 100%)" }}
            >
              Page gradient · #EEF2FF → #FCE7F3 → #FEF3C7
            </div>
          </Panel>

          <div className="space-y-5">
            <Panel title="Soft colorful shadows" sub="never harsh black" tint="#6366F1">
              <div className="space-y-3">
                {SHADOWS.map(([k, v]) => (
                  <div
                    key={k}
                    className="flex items-center gap-3 rounded-[14px] border border-[#F3F4F6] bg-white px-3.5 py-3.5"
                    style={{ boxShadow: v }}
                  >
                    <span className="grid h-8 w-8 shrink-0 place-items-center rounded-[10px] bg-[#F9FAFB] text-[14px]">
                      ✨
                    </span>
                    <span className="flex-1 text-[13px] font-extrabold text-[#374151]">{k}</span>
                    <span className="font-mono text-[10px] font-semibold text-[#9CA3AF]">{v}</span>
                  </div>
                ))}
              </div>
            </Panel>

            <Panel title="Radius" sub="12 · 20 · 24 · 999" tint="#EC4899">
              <div className="flex gap-3">
                {[
                  [12, "btn"],
                  [16, "md"],
                  [20, "card"],
                  [24, "xl"],
                ].map(([r, k]) => (
                  <div key={k as string} className="flex-1 text-center">
                    <div
                      className="h-16 w-full grad-brand"
                      style={{ borderRadius: r as number }}
                    />
                    <div className="mt-2 font-mono text-[10px] font-bold text-[#9CA3AF]">
                      {k} · {r}
                    </div>
                  </div>
                ))}
              </div>
            </Panel>
          </div>
        </div>

        {/* typography + spacing */}
        <div className="mt-5 grid gap-5 lg:grid-cols-[1.35fr_1fr]">
          <Panel title="Typography" sub="Plus Jakarta Sans + Inter + JetBrains Mono" tint="#10B981">
            <div className="divide-y divide-[#F3F4F6]">
              {TYPE.map(([name, size, meta, sample]) => (
                <div key={name} className="flex items-center gap-4 py-3.5">
                  <div className="w-[104px] shrink-0">
                    <div className="text-[11.5px] font-extrabold text-[#374151]">{name}</div>
                    <div className="font-mono text-[10px] font-semibold text-[#9CA3AF]">{size}</div>
                  </div>
                  <div
                    className={cn(
                      "min-w-0 flex-1 truncate text-[#111827]",
                      name.startsWith("Mono") && "font-mono font-medium",
                      name.startsWith("Micro") && "text-[11px] font-extrabold uppercase tracking-widest text-[#6B7280]",
                    )}
                    style={{
                      fontFamily: name.startsWith("Mono")
                        ? undefined
                        : name.startsWith("Body") || name.startsWith("Caption")
                          ? "Inter, sans-serif"
                          : '"Plus Jakarta Sans", Inter, sans-serif',
                      fontSize:
                        name.startsWith("Display")
                          ? 32
                          : name.startsWith("H2")
                            ? 24
                            : name.startsWith("H3")
                              ? 20
                              : name.startsWith("Body")
                                ? 15
                                : name.startsWith("Caption")
                                  ? 13
                                  : 13,
                      fontWeight: name.startsWith("Body") ? 500 : name.startsWith("Caption") ? 600 : 800,
                      letterSpacing: name.startsWith("Display") ? "-0.03em" : undefined,
                    }}
                  >
                    {sample}
                  </div>
                  <span className="hidden shrink-0 font-mono text-[10px] font-semibold text-[#D1D5DB] sm:block">
                    {meta}
                  </span>
                </div>
              ))}
            </div>
          </Panel>

          <div className="space-y-5">
            <Panel title="Spacing" sub="4-pt base grid" tint="#F59E0B">
              <div className="flex items-end gap-2">
                {[4, 8, 12, 16, 20, 24, 32, 48].map((s) => (
                  <div key={s} className="flex flex-1 flex-col items-center gap-2">
                    <span
                      className="rounded-t-[4px]"
                      style={{
                        width: "100%",
                        height: s * 1.6,
                        background: `linear-gradient(180deg,${s >= 20 ? "#8B5CF6" : "#6366F1"},${
                          s >= 20 ? "#6366F1" : "#A5B4FC"
                        })`,
                      }}
                    />
                    <span className="font-mono text-[10px] font-bold text-[#9CA3AF]">{s}</span>
                  </div>
                ))}
              </div>
            </Panel>

            <Panel title="Brand mark" sub="octocat-inspired · 4-pt grid" tint="#EC4899">
              <div className="flex items-center gap-5">
                <GitFlowMark size={64} />
                <GitFlowMark size={44} variant="mint" />
                <GitFlowMark size={28} variant="warm" />
                <div className="ml-auto text-right">
                  <div className="font-display text-[16px] font-extrabold text-[#111827]">GitFlow</div>
                  <div className="text-[11.5px] font-semibold text-[#9CA3AF]">
                    Your GitHub, Reimagined ✨
                  </div>
                </div>
              </div>
            </Panel>
          </div>
        </div>

        {/* icons */}
        <div className="mt-5">
          <Panel title="GitFlow icon set" sub={`${ICONS.length} glyphs · 24px grid · 2.1 stroke`} tint="#06B6D4">
            <div className="grid grid-cols-6 gap-2 sm:grid-cols-9 lg:grid-cols-13">
              {ICONS.map((n, i) => {
                const c = ["#6366F1", "#8B5CF6", "#EC4899", "#F59E0B", "#10B981", "#06B6D4"][i % 6];
                return (
                  <div
                    key={n}
                    title={n}
                    className="flex aspect-square items-center justify-center rounded-[14px] transition"
                    style={{ background: `${c}12`, color: c }}
                    onMouseEnter={(e) => {
                      e.currentTarget.style.background = c;
                      e.currentTarget.style.color = "#fff";
                    }}
                    onMouseLeave={(e) => {
                      e.currentTarget.style.background = `${c}12`;
                      e.currentTarget.style.color = c;
                    }}
                  >
                    <Icon name={n} size={19} strokeWidth={2.1} />
                  </div>
                );
              })}
            </div>
          </Panel>
        </div>

        {/* tokens json */}
        <div className="mt-5 grid gap-5 lg:grid-cols-[1fr_0.9fr]">
          <Panel title="Figma-ready tokens" sub="tokens.json" tint="#6366F1">
            <pre className="thin-scroll max-h-[400px] overflow-auto rounded-[18px] border border-[#FDE68A] bg-[#FEFCE8] p-5 font-mono text-[11.5px] font-medium leading-relaxed text-[#374151]">
              <code
                dangerouslySetInnerHTML={{
                  __html: TOKENS.replace(/&/g, "&amp;")
                    .replace(/</g, "&lt;")
                    .replace(/"#[0-9A-Fa-f]{3,8}"/g, (m) => `<span class="tok-str">${m}</span>`)
                    .replace(/"[a-zA-Z0-9_.\-]+"\s*:/g, (m) => `<span class="tok-attr">${m}</span>`)
                    .replace(/\b(4|8|12|13|15|16|20|24|32|48|999|135)\b/g, (m) => `<span class="tok-num">${m}</span>`),
                }}
              />
            </pre>
          </Panel>

          <Panel title="Platform mapping" sub="Flutter" tint="#8B5CF6">
            <div className="space-y-3">
              {[
                ["ThemeData", "ColorScheme.light + 8-color brand ramp", "#6366F1"],
                ["TextTheme", "Plus Jakarta Sans + Inter via GoogleFonts", "#8B5CF6"],
                ["Gradients", "LinearGradient(begin: topLeft, end: bottomRight)", "#EC4899"],
                ["Radii", "RoundedRectangleBorder(20) on all cards", "#F59E0B"],
                ["Shadows", "BoxShadow(color: indigo.withOpacity(.08))", "#10B981"],
                ["Motion", "420ms · CubicBezier(.16, 1, .3, 1)", "#06B6D4"],
              ].map(([k, v, c]) => (
                <div
                  key={k}
                  className="rounded-[16px] border border-[#F3F4F6] bg-[#F9FAFB] p-3.5"
                  style={{ borderLeft: `3px solid ${c}` }}
                >
                  <div className="font-mono text-[11.5px] font-extrabold" style={{ color: c }}>
                    {k}
                  </div>
                  <div className="mt-1 text-[12.5px] font-semibold text-[#6B7280]">{v}</div>
                </div>
              ))}
            </div>
          </Panel>
        </div>
      </div>
    </section>
  );
}
