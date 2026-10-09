import { useState } from "react";
import { Icon, GitFlowMark, type IconName } from "@/lib/icons";
import { user, achievements, repos } from "@/lib/data";
import {
  Avatar,
  BottomNav,
  Card,
  ContributionGraph,
  GRADS,
  hex,
  RepoCardCompact,
  TabRow,
  SheetRow,
} from "@/components/ui";
import { Screen } from "@/components/Phone";

/* ============================================================
   11 · PROFILE
   ============================================================ */

const PROFILE_TABS = ["Overview", "Repos", "Stars", "Activity"];
const PROFILE_TINTS = ["#6366F1", "#8B5CF6", "#EC4899", "#10B981"];

export function ProfileScreen() {
  const [t, setT] = useState(0);
  return (
    <div className="absolute inset-0 bg-canvas-2">
      <Screen padTop={0} padBottom={132} bg="var(--gf-canvas-2)">
        {/* colorful gradient cover */}
        <div className="relative h-[150px] overflow-hidden">
          <div
            className="absolute inset-0"
            style={{ background: "linear-gradient(135deg,#6366F1 0%,#8B5CF6 34%,#EC4899 66%,#F59E0B 100%)" }}
          />
          <span className="anim-blob absolute -left-10 top-4 h-40 w-40 rounded-full bg-white/25 blur-2xl" />
          <span
            className="anim-blob absolute right-4 top-16 h-36 w-36 rounded-full bg-cyan-300/30 blur-2xl"
            style={{ animationDelay: "-8s" }}
          />
          <div className="page-grid absolute inset-0 opacity-30" />
          <button className="press absolute right-3 top-[58px] grid h-10 w-10 place-items-center rounded-[14px] bg-white/25 text-white backdrop-blur">
            <Icon name="more" size={18} strokeWidth={2.6} />
          </button>
          <button className="press absolute right-[58px] top-[58px] grid h-10 w-10 place-items-center rounded-[14px] bg-white/25 text-white backdrop-blur">
            <Icon name="share" size={16} strokeWidth={2.3} />
          </button>
          <span className="absolute bottom-4 left-5 rounded-full bg-white/20 px-2.5 py-1 text-[10.5px] font-extrabold text-white backdrop-blur">
            🌈 PRO MEMBER
          </span>
        </div>

        {/* identity */}
        <div className="relative -mt-12 px-4">
          <div className="flex items-end gap-3.5">
            <span
              className="rounded-full p-[3.5px]"
              style={{ background: "linear-gradient(135deg,#F59E0B,#EC4899,#8B5CF6,#10B981)" }}
            >
              <span className="block rounded-full border-[3px] border-white">
                <Avatar img="/img/avatar2.jpg" name={user.name} size={82} />
              </span>
            </span>
            <div className="flex-1 pb-1.5">
              <h1 className="font-display text-[20px] font-extrabold leading-tight tracking-[-0.03em] text-ink">
                {user.name}
              </h1>
              <div className="text-[13px] font-bold text-faint">@{user.handle}</div>
            </div>
          </div>

          <p className="mt-3.5 text-[13.5px] font-medium leading-relaxed text-ink">{user.bio}</p>

          <div className="mt-3 flex flex-wrap items-center gap-x-4 gap-y-2 text-[12px] font-semibold text-muted">
            <span className="inline-flex items-center gap-1.5">🏢 {user.company}</span>
            <span className="inline-flex items-center gap-1.5">{user.location}</span>
            <span className="inline-flex items-center gap-1.5">
              🔗 <span className="text-brand">{user.blog}</span>
            </span>
          </div>

          <div
            className="mt-3.5 inline-flex items-center gap-2 rounded-full border px-3.5 py-2"
            style={{ borderColor: hex("#10B981", 0.26), background: hex("#10B981", 0.08) }}
          >
            <span className="h-2 w-2 rounded-full bg-mint" />
            <span className="text-[12px] font-extrabold text-ink">{user.status}</span>
            <span className="text-[11px] font-bold text-faint">· 4h</span>
          </div>
        </div>

        {/* stats row */}
        <div className="mt-5 px-4">
          <Card className="flex items-stretch divide-x divide-divider p-0 sh-md">
            {[
              ["Followers", user.followers, "💜", "#EC4899"],
              ["Following", user.following, "👤", "#8B5CF6"],
              ["Repos", user.repos, "📦", "#6366F1"],
              ["Stars", user.stars, "⭐", "#F59E0B"],
            ].map(([l, v, e, c]) => (
              <div key={l as string} className="flex-1 px-1 py-3.5 text-center">
                <div className="mb-1 text-[14px] leading-none">{e as string}</div>
                <div
                  className="text-[17px] font-extrabold tracking-[-0.02em]"
                  style={{ color: c as string }}
                >
                  {v as string}
                </div>
                <div className="mt-0.5 text-[10px] font-bold uppercase tracking-wide text-faint">
                  {l as string}
                </div>
              </div>
            ))}
          </Card>
        </div>

        {/* contributions — bright green */}
        <div className="mt-5 px-4">
          <div className="mb-2.5 flex items-baseline justify-between">
            <span className="text-[15px] font-extrabold tracking-[-0.01em] text-ink">
              🌱 Contributions
            </span>
            <span className="text-[12px] font-bold text-faint">
              <span className="text-mint">2,148</span> in the last year
            </span>
          </div>
          <Card className="overflow-hidden p-3.5 sh-md">
            <div className="gf-scroll overflow-x-auto">
              <ContributionGraph seed={7} cols={26} cell={10} gap={2.5} />
            </div>
            <div className="mt-3 flex items-center justify-between border-t border-divider pt-3">
              <span className="text-[10.5px] font-semibold text-faint">
                Longest streak · 96 days 🔥
              </span>
              <span className="flex items-center gap-1 text-[10.5px] font-semibold text-faint">
                Less
                {["#F0FDF4", "#BBF7D0", "#6EE7A8", "#34D399", "#10B981"].map((c) => (
                  <span
                    key={c}
                    className="h-[10px] w-[10px] rounded-[3px]"
                    style={{ background: c, border: c === "#F0FDF4" ? "1px solid var(--gf-line)" : "none" }}
                  />
                ))}
                More
              </span>
            </div>
          </Card>
        </div>

        {/* achievements */}
        <div className="mt-5 px-4">
          <div className="mb-2.5 text-[15px] font-extrabold tracking-[-0.01em] text-ink">
            🏆 Achievements
          </div>
          <div className="gf-scroll -mx-4 flex gap-2.5 overflow-x-auto px-4 pb-1">
            {achievements.map((a) => (
              <div
                key={a.label}
                className="press flex w-[106px] shrink-0 flex-col items-center rounded-[20px] border bg-surface p-3.5 text-center sh-sm"
                style={{ borderColor: hex(a.color, 0.24), boxShadow: `0 5px 16px ${hex(a.color, 0.12)}` }}
              >
                <span
                  className="grid h-12 w-12 place-items-center rounded-[18px] text-[24px]"
                  style={{ background: `linear-gradient(135deg,${hex(a.color, 0.22)},${hex(a.color, 0.08)})` }}
                >
                  {a.emoji}
                </span>
                <div className="mt-2.5 text-[12px] font-extrabold text-ink">{a.label}</div>
                <div className="mt-0.5 text-[10px] font-semibold leading-tight text-faint">{a.sub}</div>
              </div>
            ))}
          </div>
        </div>

        {/* pinned repos */}
        <div className="mt-5 px-4">
          <div className="mb-2.5 text-[15px] font-extrabold tracking-[-0.01em] text-ink">
            📌 Pinned repositories
          </div>
          <div className="grid grid-cols-2 gap-3">
            {repos.slice(0, 2).map((r) => (
              <RepoCardCompact key={r.name} repo={r} />
            ))}
          </div>
        </div>
      </Screen>

      {/* sticky tabs */}
      <div className="absolute inset-x-0 bottom-[73px] z-20 border-t border-line bg-white/90 backdrop-blur-xl">
        <TabRow tabs={PROFILE_TABS} active={t} onChange={setT} tints={PROFILE_TINTS} className="py-2" />
      </div>

      <BottomNav
        items={[
          { icon: "home" as IconName, label: "Home" },
          { icon: "repo" as IconName, label: "Repos" },
          { icon: "bell" as IconName, label: "Alerts" },
          { icon: "user" as IconName, label: "You" },
        ]}
        active={3}
      />
    </div>
  );
}

/* ============================================================
   12 · SETTINGS
   ============================================================ */

function Group({
  title,
  emoji,
  children,
  tint,
}: {
  title: string;
  emoji: string;
  children: React.ReactNode;
  tint: string;
}) {
  return (
    <div className="mt-6">
      <div className="mb-2.5 flex items-center gap-2 px-1">
        <span
          className="grid h-7 w-7 place-items-center rounded-[10px] text-[13px]"
          style={{ background: hex(tint, 0.14) }}
        >
          {emoji}
        </span>
        <span
          className="text-[11.5px] font-extrabold uppercase tracking-wider"
          style={{ color: tint }}
        >
          {title}
        </span>
      </div>
      <Card className="divide-y divide-divider overflow-hidden sh-md">{children}</Card>
    </div>
  );
}

function Toggle({ on, tint = "#6366F1" }: { on?: boolean; tint?: string }) {
  return (
    <span
      className="relative h-[26px] w-[46px] shrink-0 rounded-full transition-all"
      style={{
        background: on ? `linear-gradient(135deg,${tint},${tint}C8)` : "#E5E7EB",
        boxShadow: on ? `0 4px 12px ${hex(tint, 0.4)}` : "none",
      }}
    >
      <span
        className="absolute top-[3px] h-5 w-5 rounded-full bg-white transition-all sh-sm"
        style={{ left: on ? 23 : 3 }}
      />
    </span>
  );
}

const SECTION: [string, string, string][] = [
  ["Account", "👤", "#6366F1"],
  ["Appearance", "🎨", "#EC4899"],
  ["Notifications", "🔔", "#F59E0B"],
  ["Privacy & Security", "🛡️", "#10B981"],
  ["About", "💙", "#06B6D4"],
];

export function SettingsScreen() {
  return (
    <div className="absolute inset-0 bg-canvas-2">
      <div className="absolute inset-x-0 top-0 z-20 bg-white/92 pt-[54px] pb-2 backdrop-blur-xl">
        <div className="flex items-center gap-2.5 px-4 pt-1">
          <button
            className="press grid h-9 w-9 place-items-center rounded-[13px] text-white sh-sm"
            style={{ background: GRADS.brand }}
          >
            <Icon name="chevronLeft" size={18} strokeWidth={2.8} />
          </button>
          <h1 className="flex-1 font-display text-[18px] font-extrabold tracking-[-0.02em] text-ink">
            Settings
          </h1>
          <GitFlowMark size={28} variant="brand" />
        </div>
      </div>

      <Screen padTop={104} padBottom={30} bg="var(--gf-canvas-2)">
        {/* account card */}
        <div className="px-4">
          <Card
            className="flex items-center gap-3.5 p-4 sh-md"
            tint="#6366F1"
          >
            <span
              className="rounded-full p-[3px]"
              style={{ background: "linear-gradient(135deg,#6366F1,#EC4899)" }}
            >
              <Avatar img="/img/avatar2.jpg" name={user.name} size={52} />
            </span>
            <div className="min-w-0 flex-1">
              <div className="truncate text-[16px] font-extrabold tracking-[-0.01em] text-ink">
                {user.name}
              </div>
              <div className="truncate text-[12px] font-semibold text-faint">
                {user.handle}@users.noreply.github.com
              </div>
              <span
                className="mt-1.5 inline-flex items-center gap-1 rounded-full px-2 py-[2px] text-[10px] font-extrabold"
                style={{ color: "#10B981", background: hex("#10B981", 0.13) }}
              >
                <Icon name="check" size={9} strokeWidth={3.4} /> OAuth connected
              </span>
            </div>
            <Icon name="chevronRight" size={16} strokeWidth={2.8} className="shrink-0 text-faint" />
          </Card>
        </div>

        <Group title={SECTION[0][0]} emoji={SECTION[0][1]} tint={SECTION[0][2]}>
          <SheetRow emoji="👤" label="Profile" hint="name, bio" tint="#6366F1" />
          <SheetRow emoji="📧" label="Email" hint="private" tint="#3B82F6" />
          <SheetRow emoji="🔗" label="Linked accounts" hint="GitHub" tint="#8B5CF6" />
        </Group>

        <Group title={SECTION[1][0]} emoji={SECTION[1][1]} tint={SECTION[1][2]}>
          <SheetRow emoji="🌞" label="Theme" hint="Light (always)" tint="#EC4899" />
          <SheetRow emoji="🌈" label="Accent color" hint="Indigo" tint="#6366F1" />
          <SheetRow emoji="🔤" label="App icon" hint="Rainbow" tint="#F59E0B" />
          <SheetRow emoji="💻" label="Code font" hint="JetBrains Mono" tint="#06B6D4" />
          <div className="flex items-center gap-3 px-5 py-3">
            <span
              className="grid h-10 w-10 shrink-0 place-items-center rounded-[14px] text-[17px]"
              style={{ background: hex("#EC4899", 0.13) }}
            >
              ✨
            </span>
            <span className="flex-1 text-[14px] font-bold text-ink">Playful animations</span>
            <Toggle on tint="#EC4899" />
          </div>
        </Group>

        <Group title={SECTION[2][0]} emoji={SECTION[2][1]} tint={SECTION[2][2]}>
          <div className="flex items-center gap-3 px-5 py-3">
            <span
              className="grid h-10 w-10 shrink-0 place-items-center rounded-[14px] text-[17px]"
              style={{ background: hex("#F59E0B", 0.14) }}
            >
              🔔
            </span>
            <span className="flex-1 text-[14px] font-bold text-ink">Push notifications</span>
            <Toggle on tint="#F59E0B" />
          </div>
          <div className="flex items-center gap-3 px-5 py-3">
            <span
              className="grid h-10 w-10 shrink-0 place-items-center rounded-[14px] text-[17px]"
              style={{ background: hex("#3B82F6", 0.13) }}
            >
              📧
            </span>
            <span className="flex-1 text-[14px] font-bold text-ink">Email digests</span>
            <Toggle />
          </div>
          <div className="flex items-center gap-3 px-5 py-3">
            <span
              className="grid h-10 w-10 shrink-0 place-items-center rounded-[14px] text-[17px]"
              style={{ background: hex("#EC4899", 0.13) }}
            >
              💬
            </span>
            <span className="flex-1 text-[14px] font-bold text-ink">Mentions only</span>
            <Toggle on tint="#EC4899" />
          </div>
          <div className="flex items-center gap-3 px-5 py-3">
            <span
              className="grid h-10 w-10 shrink-0 place-items-center rounded-[14px] text-[17px]"
              style={{ background: hex("#10B981", 0.13) }}
            >
              🤖
            </span>
            <span className="flex-1 text-[14px] font-bold text-ink">Smart CI alerts</span>
            <Toggle on tint="#10B981" />
          </div>
        </Group>

        <Group title={SECTION[3][0]} emoji={SECTION[3][1]} tint={SECTION[3][2]}>
          <SheetRow emoji="🫆" label="Biometric unlock" hint="On" tint="#10B981" />
          <SheetRow emoji="🔐" label="Two-factor auth" hint="Enabled" tint="#10B981" />
          <SheetRow emoji="🗝️" label="Token vault" hint="3 tokens" tint="#F59E0B" />
          <div className="flex items-center gap-3 px-5 py-3">
            <span
              className="grid h-10 w-10 shrink-0 place-items-center rounded-[14px] text-[17px]"
              style={{ background: hex("#6B7280", 0.13) }}
            >
              📊
            </span>
            <span className="flex-1 text-[14px] font-bold text-ink">Analytics &amp; telemetry</span>
            <Toggle />
          </div>
        </Group>

        <Group title={SECTION[4][0]} emoji={SECTION[4][1]} tint={SECTION[4][2]}>
          <SheetRow emoji="✨" label="Version" hint="2.1.0 (4218)" tint="#06B6D4" />
          <SheetRow emoji="📖" label="Open source licenses" hint="68" tint="#3B82F6" />
          <SheetRow emoji="⭐" label="Rate GitFlow" tint="#F59E0B" />
          <SheetRow emoji="🐙" label="Follow @gitflow" tint="#111827" />
        </Group>

        <div className="mt-7 px-4">
          <button
            className="press flex h-[52px] w-full items-center justify-center gap-2 rounded-[16px] text-[14.5px] font-extrabold text-white"
            style={{
              background: "linear-gradient(135deg,#EF4444,#F43F5E)",
              boxShadow: "0 12px 28px -10px rgba(239,68,68,.65)",
            }}
          >
            <Icon name="logout" size={18} strokeWidth={2.1} />
            Sign out of @{user.handle}
          </button>
        </div>

        <p className="mt-6 text-center font-mono text-[10px] font-bold tracking-widest text-faint">
          MADE WITH FLUTTER 💜 · JAKARTA
        </p>
      </Screen>
    </div>
  );
}


