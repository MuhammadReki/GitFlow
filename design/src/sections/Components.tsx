import { cn } from "@/utils/cn";
import { Icon, GitFlowMark, type IconName } from "@/lib/icons";
import {
  Avatar,
  BottomNav,
  Chip,
  ContributionGraph,
  ConfirmDialog,
  EmptyState,
  IssueCard,
  LabelChip,
  LanguageDot,
  MarkdownPreview,
  NotificationCard,
  PRCard,
  RepoCardCompact,
  RepoCardDetailed,
  RepoSkeleton,
  SearchBar,
  SheetRow,
  StatCard,
  TabRow,
  Toast,
  GRADS,
  hex,
} from "@/components/ui";
import { repos, issues, prs, notifications } from "@/lib/data";
import { SectionHead } from "@/sections/ScreensGallery";

function Tile({
  n,
  title,
  spec,
  pad = true,
  tint = "#6366F1",
  children,
}: {
  n: string;
  title: string;
  spec?: string;
  pad?: boolean;
  tint?: string;
  children: React.ReactNode;
}) {
  return (
    <div
      className="overflow-hidden rounded-[24px] border border-[#E5E7EB] bg-white sh-md"
      style={{ boxShadow: `0 8px 24px ${tint}17` }}
    >
      <div className="flex items-center justify-between px-5 pt-4">
        <div className="flex items-center gap-2.5">
          <span
            className="grid h-6 w-6 place-items-center rounded-[8px] text-[10px] font-extrabold text-white"
            style={{ background: tint }}
          >
            {n}
          </span>
          <span className="font-display text-[13.5px] font-extrabold text-[#374151]">{title}</span>
        </div>
      </div>
      {spec && <div className="px-5 pt-1 font-mono text-[10.5px] font-semibold text-[#9CA3AF]">{spec}</div>}
      <div
        className={cn(
          "gf-ui mx-4 mt-4 mb-4 overflow-hidden rounded-[20px] border border-[#F3F4F6]",
          pad && "p-4",
        )}
        style={{ background: "#F9FAFB" }}
      >
        {children}
      </div>
    </div>
  );
}

/* ---------- buttons ---------- */
function Buttons() {
  return (
    <div className="space-y-2.5">
      <button className="press relative flex h-12 w-full items-center justify-center gap-2 overflow-hidden rounded-[14px] text-[14px] font-extrabold text-white grad-brand sh-md">
        <span className="absolute inset-0 bg-gradient-to-b from-white/20 to-transparent" />
        <Icon name="github" size={17} strokeWidth={1.6} className="relative" />
        <span className="relative">Continue with GitHub</span>
      </button>
      <div className="grid grid-cols-2 gap-2.5">
        <button className="press h-11 rounded-[14px] text-[13px] font-extrabold text-white grad-mint sh-sm">
          Success
        </button>
        <button className="press h-11 rounded-[14px] text-[13px] font-extrabold text-white grad-warm sh-sm">
          Warm
        </button>
      </div>
      <button className="press h-11 w-full rounded-[14px] border border-[#E5E7EB] bg-white text-[13px] font-bold text-[#111827] sh-sm">
        Secondary · white
      </button>
      <button
        className="press h-11 w-full rounded-[14px] border-2 border-dashed text-[13px] font-extrabold"
        style={{ borderColor: hex("#EF4444", 0.32), background: hex("#EF4444", 0.05), color: "#EF4444" }}
      >
        Destructive · dashed
      </button>
    </div>
  );
}

function CodeBlock() {
  return (
    <div className="overflow-hidden rounded-[18px] border border-[#FDE68A] sh-sm" style={{ background: "#FEFCE8" }}>
      <div className="flex items-center gap-2 border-b border-[#FDE68A] bg-amber-50/60 px-3 py-2">
        <span className="flex gap-1">
          {["#EF4444", "#F59E0B", "#10B981"].map((c) => (
            <span key={c} className="h-2.5 w-2.5 rounded-full" style={{ background: c }} />
          ))}
        </span>
        <span className="font-mono text-[10.5px] font-bold text-amber-700">main.dart</span>
        <Icon name="copy" size={12} strokeWidth={2.6} className="ml-auto text-amber-600" />
      </div>
      <pre className="thin-scroll overflow-x-auto p-3 font-mono text-[11px] font-medium leading-relaxed">
        <span className="tok-key">await</span> <span className="tok-fn">runApp</span>(
        {"\n  "}
        <span className="tok-key">const</span> <span className="tok-tag">GitFlowApp</span>(
        {"\n    "}
        <span className="tok-attr">theme</span>: <span className="tok-tag">AppTheme</span>.<span className="tok-tag">light</span>
        {"\n  "}
        ),
        {"\n"}
        );<span className="anim-blink ml-0.5 inline-block h-3 w-[6px] translate-y-[2px] bg-brand" />
      </pre>
    </div>
  );
}

const COMP: { n: string; title: string; spec?: string; tint?: string; pad?: boolean; node: React.ReactNode }[] = [
  { n: "01", title: "Buttons", spec: "gradient · white · dashed", tint: "#6366F1", node: <Buttons /> },
  {
    n: "02",
    title: "Repo card · compact",
    spec: "grid 2-col · emoji + tinted border",
    tint: "#8B5CF6",
    node: <RepoCardCompact repo={repos[0]} />,
  },
  {
    n: "03",
    title: "Repo card · detailed",
    spec: "list variant · press → 0.98",
    tint: "#EC4899",
    pad: false,
    node: <RepoCardDetailed repo={repos[1]} />,
  },
  {
    n: "04",
    title: "Repo card · warm tint",
    spec: "per-repo accent color",
    tint: "#F59E0B",
    pad: false,
    node: <RepoCardDetailed repo={repos[2]} />,
  },
  {
    n: "05",
    title: "Issue card",
    spec: "emerald open · gray closed",
    tint: "#10B981",
    pad: false,
    node: (
      <div className="space-y-3">
        <IssueCard issue={issues[0]} />
        <IssueCard issue={issues[2]} />
      </div>
    ),
  },
  {
    n: "06",
    title: "Pull request card",
    spec: "open / merged / closed + CI",
    tint: "#8B5CF6",
    pad: false,
    node: (
      <div className="space-y-3">
        <PRCard pr={prs[0]} />
        <PRCard pr={prs[2]} />
        <PRCard pr={prs[4]} />
      </div>
    ),
  },
  {
    n: "07",
    title: "User avatar",
    spec: "gradient ring · online dot",
    tint: "#EC4899",
    node: (
      <div className="flex flex-wrap items-end gap-3">
        <Avatar img="/img/avatar2.jpg" size={52} ring="linear-gradient(135deg,#F59E0B,#EC4899)" online />
        <Avatar name="Kenji Tanaka" color="#6366F1" size={38} />
        <Avatar name="Luan Apt" color="#EC4899" size={30} />
        <Avatar name="Tobias K" color="#F59E0B" size={24} />
        <Avatar name="Sarah Codes" color="#10B981" size={18} />
        <Avatar img="/img/avatar2.jpg" size={44} ring="linear-gradient(135deg,#6366F1,#8B5CF6)" />
      </div>
    ),
  },
  {
    n: "08",
    title: "Notification card",
    spec: "swipe reveals Read / Mute",
    tint: "#EF4444",
    pad: false,
    node: (
      <div className="space-y-3">
        <NotificationCard n={notifications[0]} />
        <NotificationCard n={notifications[1]} reveal="read" />
      </div>
    ),
  },
  {
    n: "09",
    title: "Stats card",
    spec: "gradient icon tile + delta",
    tint: "#F59E0B",
    pad: false,
    node: (
      <div className="flex gap-3">
        <StatCard emoji="📦" value="147" label="Repos" tint="#6366F1" gradient={GRADS.brand} delta="4 new" />
        <StatCard emoji="⭐" value="38.2k" label="Stars" tint="#F59E0B" gradient={GRADS.sun} delta="212" />
      </div>
    ),
  },
  {
    n: "10",
    title: "Filter chip",
    spec: "each category its own hue",
    tint: "#6366F1",
    node: (
      <div className="flex flex-wrap gap-2">
        <Chip selected emoji="🗂️" tint="#6366F1">
          All
        </Chip>
        <Chip emoji="🌍" tint="#10B981">
          Public
        </Chip>
        <Chip emoji="🔒" tint="#F59E0B">
          Private
        </Chip>
        <Chip emoji="⭐" tint="#EC4899">
          Starred
        </Chip>
        <Chip emoji="🍴" tint="#06B6D4">
          Forked
        </Chip>
      </div>
    ),
  },
  {
    n: "11",
    title: "Search bar",
    spec: "h44 · gradient filter button",
    tint: "#3B82F6",
    node: <SearchBar value="" />,
  },
  {
    n: "12",
    title: "Tabs + bottom nav",
    spec: "gradient active pill · pulse badge",
    tint: "#8B5CF6",
    pad: false,
    node: (
      <div className="relative -mx-4 -mb-4">
        <TabRow
          tabs={["Code", "Issues", "PRs", "Actions"]}
          active={1}
          counts={["", "41", "12", ""]}
          tints={["#6366F1", "#10B981", "#8B5CF6", "#F59E0B"]}
        />
        <div className="relative h-[92px]">
          <BottomNav
            items={[
              { icon: "home" as IconName, label: "Home" },
              { icon: "repo" as IconName, label: "Repos" },
              { icon: "bell" as IconName, label: "Alerts" },
              { icon: "user" as IconName, label: "You" },
            ]}
            active={2}
            badge={3}
          />
        </div>
      </div>
    ),
  },
  {
    n: "13",
    title: "Toast / snackbar",
    spec: "4 variants · auto-dismiss",
    tint: "#10B981",
    pad: false,
    node: (
      <div className="space-y-2.5">
        <Toast variant="success" title="PR #1484 merged 🎉" body="Deployed to production" />
        <Toast variant="error" title="Sync failed 😵" body="Rate limit reached · retrying in 30s" />
        <Toast variant="warning" title="Token expiring ⚠️" body="3 days remaining" />
        <Toast variant="info" title="Offline mode 💡" body="Serving cached repositories" />
      </div>
    ),
  },
  {
    n: "14",
    title: "Confirmation dialog",
    spec: "friendly emoji + gradient action",
    tint: "#EF4444",
    pad: false,
    node: (
      <div className="flex justify-center">
        <ConfirmDialog
          emoji="👋"
          title="Sign out of GitFlow?"
          body="Your offline cache will be cleared. You'll need to sign in again to sync. No hard feelings!"
          confirm="Sign out"
          danger
        />
      </div>
    ),
  },
  {
    n: "15",
    title: "Loading skeleton",
    spec: "light shimmer · 1.5s loop",
    tint: "#9CA3AF",
    pad: false,
    node: (
      <div className="space-y-3">
        <RepoSkeleton />
      </div>
    ),
  },
  {
    n: "16",
    title: "Empty state",
    spec: "emoji illustration + gradient CTA",
    tint: "#A855F7",
    pad: false,
    node: (
      <EmptyState
        emoji="🎉"
        tint="#8B5CF6"
        title="You're all caught up!"
        body="No unread notifications. We'll ping you the moment something needs your attention."
        action="Review settings"
      />
    ),
  },
  {
    n: "17",
    title: "Contribution graph",
    spec: "5 bright green levels",
    tint: "#10B981",
    pad: false,
    node: (
      <div className="gf-scroll overflow-x-auto p-4">
        <ContributionGraph seed={3} cols={28} cell={11} gap={3} />
      </div>
    ),
  },
  {
    n: "18",
    title: "Language dot",
    spec: "18 bright language colors",
    tint: "#06B6D4",
    node: (
      <div className="grid grid-cols-2 gap-y-2.5">
        {["Dart", "TypeScript", "Rust", "Go", "Swift", "Kotlin", "Python", "Ruby"].map((l) => (
          <span key={l} className="flex items-center gap-2.5 text-[12.5px] font-bold text-muted">
            <LanguageDot lang={l} />
            {l}
          </span>
        ))}
      </div>
    ),
  },
  {
    n: "19",
    title: "Label chip",
    spec: "hex-driven · pill shape",
    tint: "#EC4899",
    node: (
      <div className="flex flex-wrap gap-2">
        {[
          ["🐛 bug", "#EF4444"],
          ["✨ enhancement", "#8B5CF6"],
          ["👋 good first issue", "#06B6D4"],
          ["🎨 design", "#EC4899"],
          ["🙏 help wanted", "#3B82F6"],
          ["🔥 high", "#F59E0B"],
        ].map(([n, c]) => (
          <LabelChip key={n} name={n} color={c} />
        ))}
      </div>
    ),
  },
  {
    n: "20",
    title: "Code block",
    spec: "light syntax on soft cream",
    tint: "#F59E0B",
    pad: false,
    node: (
      <div className="p-4">
        <CodeBlock />
      </div>
    ),
  },
  {
    n: "21",
    title: "Markdown preview",
    spec: "rendered GFM subset",
    tint: "#3B82F6",
    pad: false,
    node: (
      <div className="p-4">
        <MarkdownPreview />
      </div>
    ),
  },
  {
    n: "22",
    title: "Bottom sheet rows",
    spec: "emoji icon + hint + chevron",
    tint: "#06B6D4",
    pad: false,
    node: (
      <div className="divide-y divide-divider">
        <SheetRow emoji="🕵️" label="Blame" hint="annotate" tint="#8B5CF6" />
        <SheetRow emoji="🕰️" label="History" hint="34 commits" tint="#3B82F6" />
        <SheetRow emoji="🔗" label="Share file" tint="#06B6D4" />
      </div>
    ),
  },
  {
    n: "23",
    title: "Gradient hero header",
    spec: "indigo → purple → pink",
    tint: "#EC4899",
    pad: false,
    node: (
      <div
        className="relative overflow-hidden p-5"
        style={{ background: "linear-gradient(135deg,#6366F1,#8B5CF6 55%,#EC4899)" }}
      >
        <span className="anim-blob absolute -right-6 -top-6 h-28 w-28 rounded-full bg-white/25 blur-2xl" />
        <div className="relative flex items-center gap-3">
          <span className="grid h-12 w-12 place-items-center rounded-[16px] bg-white/25 text-[22px] backdrop-blur">
            🚀
          </span>
          <div>
            <div className="font-display text-[18px] font-extrabold tracking-[-0.02em] text-white">
              gitflow
            </div>
            <div className="text-[12px] font-bold text-white/80">mrahman · Public</div>
          </div>
        </div>
      </div>
    ),
  },
  {
    n: "24",
    title: "Brand marks",
    spec: "5 gradient variants",
    tint: "#6366F1",
    node: (
      <div className="flex items-center gap-4">
        <GitFlowMark size={54} />
        <GitFlowMark size={40} variant="mint" />
        <GitFlowMark size={30} variant="warm" />
        <GitFlowMark size={22} variant="white" />
      </div>
    ),
  },
];

export function ComponentsSection() {
  return (
    <section id="components" className="relative border-t border-[#F3F4F6] py-24">
      <div className="mx-auto max-w-7xl px-6">
        <SectionHead
          kicker="Component library"
          title={<>42 components. <span className="text-[#D1D5DB]">Zero gray-on-gray.</span></>}
          body="Every piece is composed from the same eight hues and five gradients, shares the same motion curve, and renders identically everywhere. Here are 24 of them, live. 🧩"
        />

        <div className="mt-14 grid gap-5 sm:grid-cols-2 lg:grid-cols-3">
          {compList()}
        </div>
      </div>
    </section>
  );
}

function compList() {
  return COMP.map((c) => (
    <Tile key={c.n} n={c.n} title={c.title} spec={c.spec} tint={c.tint ?? "#6366F1"} pad={c.pad !== false}>
      {c.node}
    </Tile>
  ));
}
