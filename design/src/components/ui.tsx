import { useState, type ReactNode } from "react";
import { cn } from "@/utils/cn";
import { Icon, type IconName } from "@/lib/icons";
import { LANG_COLORS } from "@/lib/data";

/* ============================================================
   COLOR HELPERS
   ============================================================ */

export const hex = (c: string, a: number) => {
  const n = Math.round(a * 255)
    .toString(16)
    .padStart(2, "0");
  return `${c}${n}`;
};

export const GRADS: Record<string, string> = {
  brand: "linear-gradient(135deg,#6366F1,#8B5CF6)",
  mint: "linear-gradient(135deg,#10B981,#06B6D4)",
  warm: "linear-gradient(135deg,#F59E0B,#EC4899)",
  cool: "linear-gradient(135deg,#3B82F6,#8B5CF6)",
  sun: "linear-gradient(135deg,#F59E0B,#F97316)",
  blush: "linear-gradient(135deg,#EC4899,#F472B6)",
  rainbow: "linear-gradient(135deg,#6366F1,#EC4899,#F59E0B)",
};

/* ============================================================
   CARD — soft, white, colorful shadow
   ============================================================ */

export function Card({
  className,
  children,
  tint,
  ...rest
}: { className?: string; children?: ReactNode; tint?: string } & React.HTMLAttributes<HTMLDivElement>) {
  return (
    <div
      className={cn(
        "relative rounded-[20px] border border-line bg-surface",
        tint ? "sh-md" : "sh-sm",
        className,
      )}
      style={tint ? { boxShadow: `0 6px 20px ${hex(tint, 0.14)}`, borderColor: hex(tint, 0.18) } : undefined}
      {...rest}
    >
      {children}
    </div>
  );
}

/* ============================================================
   AVATAR
   ============================================================ */

export function Avatar({
  img,
  name,
  color = "#6366F1",
  size = 36,
  online,
  ring,
}: {
  img?: string;
  name?: string;
  color?: string;
  size?: number;
  online?: boolean;
  ring?: string;
}) {
  const [broken, setBroken] = useState(false);
  const initials = (name ?? "?")
    .split(/[\s-]+/)
    .map((w) => w[0])
    .slice(0, 2)
    .join("")
    .toUpperCase();
  const src = img && !broken ? img : undefined;
  return (
    <span className="relative inline-block shrink-0" style={{ width: size, height: size }}>
      <span
        className="flex h-full w-full items-center justify-center overflow-hidden rounded-full"
        style={
          ring
            ? {
                padding: 2.5,
                background: ring,
              }
            : undefined
        }
      >
        <span
          className="flex h-full w-full items-center justify-center overflow-hidden rounded-full"
          style={
            src
              ? undefined
              : { background: `linear-gradient(140deg,${color},${hex(color, 0.55)})`, color: "#fff" }
          }
        >
          {src ? (
            <img
              src={src}
              alt={name ?? ""}
              onError={() => setBroken(true)}
              className="h-full w-full object-cover"
            />
          ) : (
            <span className="font-bold tracking-tight" style={{ fontSize: Math.max(10, size * 0.36) }}>
              {initials}
            </span>
          )}
        </span>
      </span>
      {online && (
        <span
          className="absolute -bottom-0.5 -right-0.5 rounded-full border-[2.5px] border-white"
          style={{ width: Math.max(10, size * 0.3), height: Math.max(10, size * 0.3), background: "#10B981" }}
        />
      )}
    </span>
  );
}

/* ============================================================
   LANGUAGE DOT
   ============================================================ */

export function LanguageDot({ lang, size = 9 }: { lang: string; size?: number }) {
  const c = LANG_COLORS[lang] ?? "#9CA3AF";
  return (
    <span
      className="inline-block shrink-0 rounded-full"
      style={{ width: size, height: size, background: c, boxShadow: `0 0 0 3px ${hex(c, 0.16)}` }}
    />
  );
}

/* ============================================================
   CHIPS / BADGES / LABELS
   ============================================================ */

export function Chip({
  children,
  selected,
  icon,
  emoji,
  tint = "#6366F1",
  onClick,
  className,
}: {
  children: ReactNode;
  selected?: boolean;
  icon?: IconName;
  emoji?: string;
  tint?: string;
  onClick?: () => void;
  className?: string;
}) {
  return (
    <button
      onClick={onClick}
      className={cn(
        "press inline-flex shrink-0 items-center gap-1.5 rounded-full px-3.5 py-2 text-[13px] font-semibold",
        selected ? "text-white" : "bg-canvas-2 text-muted hover:text-ink",
        className,
      )}
      style={
        selected
          ? { background: GRADS.brand, boxShadow: `0 6px 16px ${hex(tint, 0.32)}` }
          : { border: `1px solid ${hex(tint, 0.18)}`, background: hex(tint, 0.07), color: tint }
      }
    >
      {emoji ? <span className="text-[13px] leading-none">{emoji}</span> : null}
      {icon && <Icon name={icon} size={14} strokeWidth={2.2} />}
      {children}
    </button>
  );
}

export function LabelChip({ name, color }: { name: string; color: string }) {
  return (
    <span
      className="inline-flex shrink-0 items-center gap-1 rounded-full px-2.5 py-[4px] text-[11px] font-semibold leading-none"
      style={{ color, background: hex(color, 0.11), border: `1px solid ${hex(color, 0.26)}` }}
    >
      {name}
    </span>
  );
}

export function VisibilityBadge({ v }: { v: "Public" | "Private" }) {
  const c = v === "Private" ? "#F59E0B" : "#6B7280";
  return (
    <span
      className="inline-flex items-center gap-1 rounded-full px-2 py-[3px] text-[10px] font-bold uppercase tracking-wide"
      style={{ color: c, background: hex(c, 0.11), border: `1px solid ${hex(c, 0.22)}` }}
    >
      <Icon name={v === "Private" ? "lock" : "globe"} size={10} strokeWidth={2.6} />
      {v}
    </span>
  );
}

export function StarBadge({ stars, tint = "#F59E0B" }: { stars: string; tint?: string }) {
  return (
    <span
      className="inline-flex items-center gap-1 rounded-full px-2 py-[3px] text-[11px] font-bold"
      style={{ color: tint, background: hex(tint, 0.12) }}
    >
      <Icon name="star" size={11} strokeWidth={2.6} />
      {stars}
    </span>
  );
}

/* ============================================================
   SECTION HEADER
   ============================================================ */

export function SectionHeader({
  title,
  emoji,
  action,
  onAction,
}: {
  title: string;
  emoji?: string;
  action?: string;
  onAction?: () => void;
}) {
  return (
    <div className="mb-3 flex items-baseline justify-between px-4">
      <h3 className="flex items-center gap-1.5 text-[16px] font-bold tracking-[-0.01em] text-ink">
        {emoji && <span className="text-[15px]">{emoji}</span>}
        {title}
      </h3>
      {action && (
        <button
          onClick={onAction}
          className="press inline-flex items-center gap-0.5 text-[13px] font-bold text-brand"
        >
          {action}
          <Icon name="chevronRight" size={13} strokeWidth={2.8} />
        </button>
      )}
    </div>
  );
}

/* ============================================================
   SEARCH BAR
   ============================================================ */

export function SearchBar({
  placeholder = "Search repos, issues, code…",
  value,
  compact,
  onFilter,
}: {
  placeholder?: string;
  value?: string;
  compact?: boolean;
  onFilter?: boolean;
}) {
  return (
    <div
      className={cn(
        "flex items-center gap-2.5 rounded-[14px] border border-line bg-canvas-2 px-3.5 sh-sm",
        compact ? "h-10" : "h-11",
      )}
    >
      <Icon name="search" size={17} className="shrink-0 text-faint" strokeWidth={2.1} />
      <span className="flex-1 truncate text-[14px] text-muted">
        {value ? <span className="font-medium text-ink">{value}</span> : placeholder}
      </span>
      {onFilter && (
        <span
          className="press grid h-7 w-7 shrink-0 place-items-center rounded-[10px] text-white"
          style={{ background: GRADS.brand }}
        >
          <Icon name="filter" size={14} strokeWidth={2.4} />
        </span>
      )}
    </div>
  );
}

/* ============================================================
   STAT CARD — colorful gradient icon tile
   ============================================================ */

export function StatCard({
  icon,
  emoji,
  value,
  label,
  gradient,
  tint,
  delta,
  onClick,
  style,
}: {
  icon?: IconName;
  emoji?: string;
  value: string;
  label: string;
  gradient?: string;
  tint: string;
  delta?: string;
  onClick?: () => void;
  style?: React.CSSProperties;
}) {
  return (
    <button
      onClick={onClick}
      style={style}
      className="press relative w-[136px] shrink-0 overflow-hidden rounded-[20px] border border-line bg-surface p-3.5 text-left sh-md"
    >
      <span
        className="pointer-events-none absolute -right-7 -top-7 h-20 w-20 rounded-full opacity-70 blur-2xl"
        style={{ background: hex(tint, 0.28) }}
      />
      <span
        className="relative mb-3 grid h-10 w-10 place-items-center rounded-[14px] text-white"
        style={{ background: gradient ?? GRADS.brand, boxShadow: `0 6px 14px ${hex(tint, 0.34)}` }}
      >
        {emoji ? (
          <span className="text-[17px] leading-none">{emoji}</span>
        ) : (
          <Icon name={icon!} size={19} strokeWidth={2.2} />
        )}
      </span>
      <div className="relative text-[24px] font-extrabold leading-none tracking-[-0.03em] text-ink">
        {value}
      </div>
      <div className="relative mt-1 text-[12px] font-semibold text-muted">{label}</div>
      {delta && (
        <div
          className="relative mt-1.5 inline-flex items-center gap-0.5 rounded-full px-1.5 py-[2px] text-[10.5px] font-bold"
          style={{ color: "#10B981", background: hex("#10B981", 0.12) }}
        >
          <Icon name="arrowUp" size={9} strokeWidth={3.2} />
          {delta}
        </div>
      )}
    </button>
  );
}

/* ============================================================
   REPO CARDS
   ============================================================ */

export function RepoCardCompact({
  repo,
  onClick,
  style,
}: {
  repo: {
    owner: string;
    name: string;
    desc: string;
    lang: string;
    stars: string;
    forks: string;
    visibility?: "Public" | "Private";
    emoji?: string;
    tint?: string;
  };
  onClick?: () => void;
  style?: React.CSSProperties;
}) {
  const tint = repo.tint ?? "#6366F1";
  return (
    <button
      onClick={onClick}
      style={{ ...style, borderColor: hex(tint, 0.2), boxShadow: `0 5px 16px ${hex(tint, 0.1)}` }}
      className="press flex h-full flex-col rounded-[20px] border bg-surface p-3.5 text-left"
    >
      <div className="mb-2 flex items-start justify-between gap-2">
        <span
          className="grid h-10 w-10 shrink-0 place-items-center rounded-[14px] text-[18px]"
          style={{ background: hex(tint, 0.12) }}
        >
          {repo.emoji ?? "📦"}
        </span>
        {repo.visibility === "Private" ? (
          <VisibilityBadge v="Private" />
        ) : (
          <StarBadge stars={repo.stars} />
        )}
      </div>
      <div className="min-w-0">
        <div className="truncate text-[15px] font-bold leading-tight tracking-[-0.01em] text-ink">
          {repo.name}
        </div>
        <div className="mt-0.5 truncate text-[11.5px] font-medium text-faint">{repo.owner}</div>
      </div>
      <p className="mt-1.5 line-clamp-2 flex-1 text-[12px] font-medium leading-[1.5] text-muted">
        {repo.desc}
      </p>
      <div className="mt-3 flex items-center gap-2 text-[11px] font-semibold text-muted">
        <span className="inline-flex items-center gap-1.5">
          <LanguageDot lang={repo.lang} size={8} />
          {repo.lang}
        </span>
        <span className="inline-flex items-center gap-0.5">
          <Icon name="fork" size={11} strokeWidth={2.4} />
          {repo.forks}
        </span>
      </div>
    </button>
  );
}

export function RepoCardDetailed({
  repo,
  style,
}: {
  repo: {
    owner: string;
    name: string;
    desc: string;
    lang: string;
    stars: string;
    forks: string;
    visibility: "Public" | "Private";
    updated: string;
    emoji?: string;
    tint?: string;
  };
  style?: React.CSSProperties;
}) {
  const tint = repo.tint ?? "#6366F1";
  return (
    <div
      style={{ ...style, borderColor: hex(tint, 0.18), boxShadow: `0 6px 20px ${hex(tint, 0.09)}` }}
      className="press rounded-[20px] border bg-surface p-4"
    >
      <div className="flex items-start gap-3">
        <span
          className="grid h-11 w-11 shrink-0 place-items-center rounded-[14px] text-[20px]"
          style={{ background: hex(tint, 0.12) }}
        >
          {repo.emoji ?? "📦"}
        </span>
        <div className="min-w-0 flex-1">
          <div className="flex flex-wrap items-center gap-1.5">
            <span className="truncate text-[15.5px] font-bold tracking-[-0.01em] text-ink">
              <span className="font-semibold text-faint">{repo.owner}/</span>
              {repo.name}
            </span>
            <VisibilityBadge v={repo.visibility} />
          </div>
          <p className="mt-1.5 line-clamp-2 text-[13px] font-medium leading-[1.5] text-muted">
            {repo.desc}
          </p>
        </div>
      </div>
      <div className="mt-3.5 flex items-center gap-2.5 text-[11.5px] font-semibold text-muted">
        <span className="inline-flex items-center gap-1.5">
          <LanguageDot lang={repo.lang} size={8} />
          {repo.lang}
        </span>
        <StarBadge stars={repo.stars} />
        <span className="inline-flex items-center gap-1">
          <Icon name="fork" size={12} strokeWidth={2.4} />
          {repo.forks}
        </span>
        <span className="ml-auto inline-flex items-center gap-1 whitespace-nowrap text-faint">
          <Icon name="clock" size={11} strokeWidth={2.4} />
          {repo.updated}
        </span>
      </div>
    </div>
  );
}

/* ============================================================
   ISSUE CARD
   ============================================================ */

export function IssueCard({ issue, style }: { issue: {
  n: number;
  title: string;
  state: "open" | "closed";
  labels: { name: string; color: string }[];
  author: string;
  avatar: string;
  time: string;
  comments: number;
}; style?: React.CSSProperties }) {
  const open = issue.state === "open";
  const c = open ? "#10B981" : "#6B7280";
  return (
    <div
      style={{ ...style, borderColor: hex(c, 0.2), boxShadow: `0 5px 16px ${hex(c, 0.08)}` }}
      className="press rounded-[20px] border bg-surface p-4"
    >
      <div className="flex gap-3">
        <span
          className="mt-0.5 grid h-9 w-9 shrink-0 place-items-center rounded-full text-white"
          style={{
            background: open ? GRADS.mint : "#E5E7EB",
            boxShadow: `0 4px 12px ${hex(c, open ? 0.3 : 0.1)}`,
          }}
        >
          <Icon name={open ? "issueOpen" : "issueClosed"} size={17} strokeWidth={2.3} />
        </span>
        <div className="min-w-0 flex-1">
          <div className="text-[14.5px] font-bold leading-snug tracking-[-0.01em] text-ink">
            {issue.title}
          </div>
          <div className="mt-0.5 text-[12px] font-medium text-faint">
            #{issue.n} · {issue.time}
          </div>
          <div className="mt-2.5 flex flex-wrap gap-1.5">
            {issue.labels.map((l) => (
              <LabelChip key={l.name} name={l.name} color={l.color} />
            ))}
          </div>
          <div className="mt-3 flex items-center gap-2">
            <Avatar name={issue.author} color={issue.avatar} size={20} />
            <span className="text-[12px] font-bold text-muted">{issue.author}</span>
            <span
              className="ml-auto inline-flex items-center gap-1 rounded-full px-2 py-[3px] text-[11.5px] font-bold"
              style={{ color: "#3B82F6", background: hex("#3B82F6", 0.1) }}
            >
              <Icon name="comment" size={12} strokeWidth={2.4} />
              {issue.comments}
            </span>
          </div>
        </div>
      </div>
    </div>
  );
}

/* ============================================================
   PR CARD
   ============================================================ */

export function PRCard({ pr, style }: { pr: {
  n: number;
  title: string;
  state: "open" | "merged" | "closed";
  from: string;
  to: string;
  author: string;
  avatar: string;
  time: string;
  checks: "pass" | "fail" | "running";
  reviews: number;
  comments: number;
  draft?: boolean;
}; style?: React.CSSProperties }) {
  const map = {
    open: { c: "#10B981", g: GRADS.mint, icon: "prOpen" as IconName, label: "Open" },
    merged: { c: "#8B5CF6", g: GRADS.brand, icon: "prMerged" as IconName, label: "Merged" },
    closed: { c: "#EF4444", g: "linear-gradient(135deg,#EF4444,#F43F5E)", icon: "prClosed" as IconName, label: "Closed" },
  }[pr.state];
  const checkMap = {
    pass: { c: "#10B981", icon: "check" as IconName, t: "12 checks passed ✓" },
    fail: { c: "#EF4444", icon: "x" as IconName, t: "2 checks failed ✗" },
    running: { c: "#F59E0B", icon: "refresh" as IconName, t: "Running 7/12…" },
  }[pr.checks];

  return (
    <div
      style={{ ...style, borderColor: hex(map.c, 0.22), boxShadow: `0 5px 18px ${hex(map.c, 0.09)}` }}
      className="press rounded-[20px] border bg-surface p-4"
    >
      <div className="flex gap-3">
        <span
          className="mt-0.5 grid h-9 w-9 shrink-0 place-items-center rounded-full text-white"
          style={{ background: map.g, boxShadow: `0 4px 12px ${hex(map.c, 0.3)}` }}
        >
          <Icon name={map.icon} size={17} strokeWidth={2.3} />
        </span>
        <div className="min-w-0 flex-1">
          <div className="flex items-start gap-2">
            <div className="text-[14.5px] font-bold leading-snug tracking-[-0.01em] text-ink">
              {pr.title}
            </div>
            {pr.draft && (
              <span className="mt-[3px] shrink-0 rounded-full bg-canvas-2 px-2 py-[2px] text-[10px] font-bold uppercase tracking-wide text-faint">
                Draft
              </span>
            )}
          </div>
          <div className="mt-0.5 text-[12px] font-medium text-faint">
            #{pr.n} · {pr.time} ago
          </div>

          <div className="mt-3 flex items-center gap-1.5 rounded-[12px] px-2.5 py-2 font-mono text-[11px] font-medium"
            style={{ background: hex("#6366F1", 0.07), border: `1px dashed ${hex("#6366F1", 0.24)}` }}
          >
            <span className="truncate text-muted">{pr.from}</span>
            <Icon name="arrowRight" size={11} strokeWidth={3} className="shrink-0" style={{ color: "#6366F1" }} />
            <span className="truncate font-bold text-brand">{pr.to}</span>
          </div>

          <div className="mt-3 flex items-center gap-2.5">
            <Avatar name={pr.author} color={pr.avatar} size={20} />
            <span
              className="inline-flex items-center gap-1 rounded-full px-2 py-[3px] text-[11px] font-bold"
              style={{ color: checkMap.c, background: hex(checkMap.c, 0.11) }}
            >
              <Icon
                name={checkMap.icon}
                size={11}
                strokeWidth={3}
                className={pr.checks === "running" ? "anim-spin" : ""}
              />
              {checkMap.t}
            </span>
            <span className="ml-auto inline-flex items-center gap-2 text-[11.5px] font-bold text-faint">
              <span className="inline-flex items-center gap-0.5">
                <Icon name="users" size={12} strokeWidth={2.3} />
                {pr.reviews}
              </span>
              <span className="inline-flex items-center gap-0.5">
                <Icon name="comment" size={12} strokeWidth={2.3} />
                {pr.comments}
              </span>
            </span>
          </div>
        </div>
      </div>
    </div>
  );
}

/* ============================================================
   NOTIFICATION CARD
   ============================================================ */

export function NotificationCard({
  n,
  reveal,
  style,
}: {
  n: {
    kind: "pr" | "issue" | "comment" | "star" | "ci" | "follow";
    title: string;
    preview: string;
    repo: string;
    time: string;
    unread: boolean;
    avatar: string;
  };
  reveal?: "read" | "mute" | null;
  style?: React.CSSProperties;
}) {
  const meta: Record<string, { icon: IconName; color: string; grad: string; emoji: string }> = {
    pr: { icon: "prOpen", color: "#8B5CF6", grad: GRADS.brand, emoji: "🔀" },
    issue: { icon: "issueOpen", color: "#F59E0B", grad: GRADS.sun, emoji: "🐛" },
    comment: { icon: "comment", color: "#3B82F6", grad: GRADS.cool, emoji: "💬" },
    star: { icon: "star", color: "#F59E0B", grad: GRADS.sun, emoji: "⭐" },
    ci: { icon: "cpu", color: "#EF4444", grad: "linear-gradient(135deg,#EF4444,#F43F5E)", emoji: "⚙️" },
    follow: { icon: "users", color: "#EC4899", grad: GRADS.blush, emoji: "💜" },
  };
  const m = meta[n.kind];
  return (
    <div style={style} className="relative overflow-hidden rounded-[20px]">
      {/* swipe action layer */}
      <div className="absolute inset-0 flex items-stretch justify-end">
        <div
          className="flex items-center gap-1.5 px-3.5 text-white"
          style={{ background: "linear-gradient(135deg,#10B981,#06B6D4)" }}
        >
          <Icon name="check" size={16} strokeWidth={3} />
          <span className="text-[12px] font-bold">Read</span>
        </div>
        <div
          className="flex items-center gap-1.5 px-3.5 text-white"
          style={{ background: "linear-gradient(135deg,#EF4444,#F43F5E)" }}
        >
          <Icon name="bellOff" size={16} strokeWidth={2.3} />
          <span className="text-[12px] font-bold">Mute</span>
        </div>
      </div>
      <div
        className={cn(
          "press relative flex gap-3 rounded-[20px] border bg-surface p-4 sh-sm",
        )}
        style={{
          borderColor: n.unread ? hex(m.color, 0.28) : "var(--gf-line)",
          transform: reveal ? "translateX(-140px)" : "translateX(0)",
          transition: "transform .4s cubic-bezier(.16,1,.3,1)",
          boxShadow: n.unread ? `0 6px 20px ${hex(m.color, 0.12)}` : undefined,
        }}
      >
        <span
          className="mt-0.5 grid h-10 w-10 shrink-0 place-items-center rounded-[14px] text-[18px]"
          style={{ background: hex(m.color, 0.13), color: m.color }}
        >
          {m.emoji}
        </span>
        <div className="min-w-0 flex-1">
          <div className="flex items-start gap-2">
            <div className="min-w-0 flex-1">
              <div
                className={cn(
                  "truncate text-[13.5px] leading-tight",
                  n.unread ? "font-bold text-ink" : "font-semibold text-muted",
                )}
              >
                {n.title}
              </div>
              <div className="mt-1 line-clamp-2 text-[12px] font-medium leading-snug text-faint">
                {n.preview}
              </div>
            </div>
            {n.unread && (
              <span
                className="anim-pulse-cherry mt-1 h-2.5 w-2.5 shrink-0 rounded-full"
                style={{ background: "#EF4444" }}
              />
            )}
          </div>
          <div className="mt-2.5 flex items-center gap-1.5">
            <Avatar name={n.repo.split("/")[0]} color={n.avatar} size={18} />
            <span className="truncate font-mono text-[11px] font-semibold text-muted">{n.repo}</span>
            <span className="ml-auto shrink-0 text-[11px] font-bold text-faint">{n.time}</span>
          </div>
        </div>
      </div>
    </div>
  );
}

/* ============================================================
   TABS
   ============================================================ */

export function TabRow({
  tabs,
  active,
  onChange,
  counts,
  tints,
  className,
}: {
  tabs: string[];
  active: number;
  onChange?: (i: number) => void;
  counts?: (string | number)[];
  tints?: string[];
  className?: string;
}) {
  return (
    <div className={cn("flex gap-1.5 px-4 py-2.5", className)}>
      {tabs.map((t, i) => {
        const c = tints?.[i] ?? "#6366F1";
        const on = i === active;
        return (
          <button
            key={t}
            onClick={() => onChange?.(i)}
            className={cn(
              "press relative flex-1 rounded-[13px] px-2 py-2 text-[12.5px] font-bold transition-all",
              on ? "text-white" : "text-muted",
            )}
            style={
              on
                ? { background: `linear-gradient(135deg,${c},${c}CC)`, boxShadow: `0 6px 16px ${hex(c, 0.3)}` }
                : { background: hex(c, 0.07), color: c }
            }
          >
            <span className="inline-flex items-center justify-center gap-1">
              {t}
              {!!counts?.[i] && (
                <span
                  className={cn(
                    "rounded-full px-1.5 py-[1px] text-[10px] font-extrabold",
                    on ? "bg-white/25 text-white" : "bg-white text-ink",
                  )}
                >
                  {counts[i]}
                </span>
              )}
            </span>
          </button>
        );
      })}
    </div>
  );
}

/* ============================================================
   BOTTOM NAV — gradient active pill
   ============================================================ */

export function BottomNav({
  items,
  active,
  onChange,
  badge,
}: {
  items: { icon: IconName; label: string; emoji?: string }[];
  active: number;
  onChange?: (i: number) => void;
  badge?: number;
}) {
  const tint = ["#6366F1", "#8B5CF6", "#EC4899", "#10B981"];
  return (
    <div className="absolute inset-x-0 bottom-0 z-20 border-t border-line bg-white/85 backdrop-blur-xl">
      <div className="flex items-stretch justify-around px-2 pb-[18px] pt-2">
        {items.map((it, i) => {
          const on = i === active;
          const c = tint[i % tint.length];
          return (
            <button
              key={it.label}
              onClick={() => onChange?.(i)}
              className="press relative flex w-[70px] flex-col items-center gap-1 py-1"
            >
              {on && (
                <span
                  className="absolute -top-2 h-1 w-8 rounded-full"
                  style={{ background: `linear-gradient(90deg,${c},${c}55)` }}
                />
              )}
              <span
                className="relative grid h-9 w-9 place-items-center rounded-[13px] transition-all"
                style={
                  on
                    ? { background: `linear-gradient(135deg,${c},${c}BB)`, boxShadow: `0 6px 14px ${hex(c, 0.35)}`, color: "#fff" }
                    : { color: "#9CA3AF" }
                }
              >
                <Icon name={it.icon} size={19} strokeWidth={on ? 2.4 : 2} />
                {it.label === "Notifications" && badge ? (
                  <span
                    className="anim-pulse-cherry absolute -right-1 -top-1 grid h-4 min-w-4 place-items-center rounded-full px-1 text-[9.5px] font-extrabold text-white"
                    style={{ background: "#EF4444" }}
                  >
                    {badge}
                  </span>
                ) : null}
              </span>
              <span
                className={cn("text-[10.5px] font-bold", on ? "text-ink" : "text-faint")}
              >
                {it.label}
              </span>
            </button>
          );
        })}
      </div>
    </div>
  );
}

/* ============================================================
   FAB — bright yellow / gradient
   ============================================================ */

export function Fab({
  label,
  emoji = "＋",
  gradient,
  onClick,
  open,
  className,
}: {
  label: string;
  emoji?: string;
  gradient?: string;
  onClick?: () => void;
  open?: boolean;
  className?: string;
}) {
  const g = gradient ?? GRADS.sun;
  return (
    <div className={cn("absolute bottom-[86px] right-4 z-30 flex flex-col items-end gap-2.5", className)}>
      {open && (
        <>
          {[
            ["📝", "New issue"],
            ["📦", "New repository"],
            ["🔐", "New gist"],
          ].map(([e, m], i) => (
            <button
              key={m}
              className="anim-pop press flex items-center gap-2 rounded-full border border-line bg-white px-3.5 py-2 text-[12.5px] font-bold text-ink sh-md"
              style={{ animationDelay: `${i * 55}ms` }}
            >
              <span className="text-[14px] leading-none">{e}</span>
              {m}
            </button>
          ))}
        </>
      )}
      <button
        onClick={onClick}
        className="press flex items-center gap-2 rounded-full pl-4 pr-5 text-[14px] font-extrabold text-white"
        style={{
          background: g,
          height: 52,
          boxShadow: "0 12px 30px -8px rgba(245,158,11,.65)",
        }}
      >
        <span
          className="grid h-7 w-7 place-items-center rounded-full bg-white/25 text-[17px] leading-none transition-transform duration-300"
          style={{ transform: open ? "rotate(135deg)" : "none" }}
        >
          {emoji}
        </span>
        {label}
      </button>
    </div>
  );
}

/* ============================================================
   SKELETON
   ============================================================ */

export function Skeleton({ w, h, r = 10, className }: { w?: string | number; h?: string | number; r?: number; className?: string }) {
  return (
    <div
      className={cn("shimmer", className)}
      style={{ width: w ?? "100%", height: h ?? 12, borderRadius: r }}
    />
  );
}

export function RepoSkeleton() {
  return (
    <div className="rounded-[20px] border border-line bg-surface p-4 sh-sm">
      <div className="flex items-start gap-3">
        <Skeleton w={44} h={44} r={14} />
        <div className="flex-1 space-y-2 pt-1">
          <Skeleton w="62%" h={13} />
          <Skeleton w="38%" h={10} />
        </div>
      </div>
      <div className="mt-3 space-y-2">
        <Skeleton h={10} />
        <Skeleton w="72%" h={10} />
      </div>
      <div className="mt-3.5 flex gap-2">
        <Skeleton w={58} h={9} r={99} />
        <Skeleton w={44} h={9} r={99} />
        <Skeleton w={44} h={9} r={99} />
      </div>
    </div>
  );
}

/* ============================================================
   EMPTY STATE
   ============================================================ */

export function EmptyState({
  title,
  body,
  action,
  emoji = "✨",
  tint = "#6366F1",
}: {
  title: string;
  body: string;
  action?: string;
  emoji?: string;
  tint?: string;
}) {
  return (
    <div className="flex flex-col items-center px-8 py-10 text-center">
      <div className="relative mb-5 grid h-[84px] w-[84px] place-items-center">
        <span
          className="absolute inset-0 rounded-[28px] opacity-90"
          style={{ background: `linear-gradient(135deg,${hex(tint, 0.16)},${hex(tint, 0.05)})`, border: `1.5px dashed ${hex(tint, 0.35)}` }}
        />
        <span
          className="absolute inset-2.5 rounded-[20px] blur-lg"
          style={{ background: hex(tint, 0.35) }}
        />
        <span className="relative text-[34px] leading-none">{emoji}</span>
      </div>
      <div className="text-[17px] font-bold tracking-[-0.01em] text-ink">{title}</div>
      <p className="mt-2 max-w-[250px] text-[13px] font-medium leading-relaxed text-muted">{body}</p>
      {action && (
        <button
          className="press mt-5 rounded-full px-5 py-2.5 text-[13.5px] font-extrabold text-white"
          style={{ background: `linear-gradient(135deg,${tint},${tint}C0)`, boxShadow: `0 8px 20px ${hex(tint, 0.34)}` }}
        >
          {action}
        </button>
      )}
    </div>
  );
}

/* ============================================================
   TOAST
   ============================================================ */

const toastTint = {
  success: { c: "#10B981", g: GRADS.mint, i: "check" as IconName, e: "🎉" },
  error: { c: "#EF4444", g: "linear-gradient(135deg,#EF4444,#F43F5E)", i: "warning" as IconName, e: "😖" },
  info: { c: "#3B82F6", g: GRADS.cool, i: "info" as IconName, e: "💡" },
  warning: { c: "#F59E0B", g: GRADS.sun, i: "warning" as IconName, e: "⚠️" },
};

export function Toast({
  variant = "success",
  title,
  body,
  style,
}: {
  variant?: keyof typeof toastTint;
  title: string;
  body?: string;
  style?: React.CSSProperties;
}) {
  const t = toastTint[variant];
  return (
    <div
      style={{ ...style, borderColor: hex(t.c, 0.24), boxShadow: `0 16px 40px -10px ${hex(t.c, 0.4)}` }}
      className="flex w-[330px] items-start gap-3 rounded-[20px] border bg-surface p-3.5"
    >
      <span
        className="grid h-9 w-9 shrink-0 place-items-center rounded-[13px] text-[17px]"
        style={{ background: t.g, boxShadow: `0 6px 14px ${hex(t.c, 0.32)}` }}
      >
        {t.e}
      </span>
      <div className="min-w-0 flex-1">
        <div className="text-[13.5px] font-bold text-ink">{title}</div>
        {body && <div className="mt-0.5 text-[12px] font-medium leading-snug text-muted">{body}</div>}
      </div>
      <button className="press grid h-6 w-6 shrink-0 place-items-center rounded-full bg-canvas-2 text-faint">
        <Icon name="x" size={13} strokeWidth={3} />
      </button>
    </div>
  );
}

/* ============================================================
   CONFIRMATION DIALOG
   ============================================================ */

export function ConfirmDialog({
  title,
  body,
  confirm = "Delete",
  danger = true,
  emoji = "🤔",
  style,
}: {
  title: string;
  body: string;
  confirm?: string;
  danger?: boolean;
  emoji?: string;
  style?: React.CSSProperties;
}) {
  const c = danger ? "#EF4444" : "#6366F1";
  return (
    <div
      style={{ ...style, boxShadow: `0 30px 70px -16px ${hex(c, 0.4)}` }}
      className="w-[300px] rounded-[24px] border border-line bg-surface p-5"
    >
      <span
        className="mb-4 grid h-12 w-12 place-items-center rounded-[18px] text-[24px]"
        style={{ background: hex(c, 0.13) }}
      >
        {emoji}
      </span>
      <div className="text-[18px] font-extrabold tracking-[-0.02em] text-ink">{title}</div>
      <p className="mt-2 text-[13px] font-medium leading-relaxed text-muted">{body}</p>
      <div className="mt-5 flex gap-2.5">
        <button className="press h-11 flex-1 rounded-[14px] border border-line bg-canvas-2 text-[13.5px] font-bold text-ink">
          Cancel
        </button>
        <button
          className="press h-11 flex-1 rounded-[14px] text-[13.5px] font-extrabold text-white"
          style={{
            background: `linear-gradient(135deg,${c},${c}C4)`,
            boxShadow: `0 8px 20px ${hex(c, 0.34)}`,
          }}
        >
          {confirm}
        </button>
      </div>
    </div>
  );
}

/* ============================================================
   BOTTOM SHEET
   ============================================================ */

export function BottomSheet({
  title,
  children,
  className,
}: {
  title?: string;
  children: ReactNode;
  className?: string;
}) {
  return (
    <div className={cn("absolute inset-0 z-40", className)}>
      <div className="anim-fade-in absolute inset-0 bg-[#111827]/25 backdrop-blur-[3px]" />
      <div className="anim-sheet absolute inset-x-0 bottom-0 rounded-t-[28px] border-t border-line bg-white pb-[26px] pt-2.5 sh-lift">
        <div className="mx-auto mb-3 h-1.5 w-10 rounded-full bg-line-2" />
        {title && (
          <div className="mb-2 flex items-center justify-between px-5">
            <span className="text-[16px] font-extrabold tracking-[-0.01em] text-ink">{title}</span>
            <button className="press grid h-8 w-8 place-items-center rounded-full bg-canvas-2 text-muted">
              <Icon name="x" size={15} strokeWidth={3} />
            </button>
          </div>
        )}
        {children}
      </div>
    </div>
  );
}

export function SheetRow({
  icon,
  emoji,
  label,
  hint,
  tint = "#6366F1",
}: {
  icon?: IconName;
  emoji?: string;
  label: string;
  hint?: string;
  tint?: string;
}) {
  return (
    <button className="press flex w-full items-center gap-3 px-5 py-3 text-left">
      <span
        className="grid h-10 w-10 shrink-0 place-items-center rounded-[14px] text-[17px] text-white"
        style={{ background: hex(tint, 0.14), color: tint }}
      >
        {emoji ?? (icon ? <Icon name={icon} size={18} strokeWidth={2.2} /> : null)}
      </span>
      <span className="flex-1 text-[14px] font-bold text-ink">{label}</span>
      {hint && <span className="text-[12px] font-semibold text-faint">{hint}</span>}
      <Icon name="chevronRight" size={15} strokeWidth={2.8} className="shrink-0 text-faint" />
    </button>
  );
}

/* ============================================================
   CONTRIBUTION GRAPH — bright green
   ============================================================ */

const LEVEL = ["var(--gf-graph0)", "#BBF7D0", "#6EE7A8", "#34D399", "#10B981"];

export function ContributionGraph({
  seed = 0,
  cols = 26,
  cell = 9,
  gap = 2.5,
}: {
  seed?: number;
  cols?: number;
  cell?: number;
  gap?: number;
}) {
  const rnd = (i: number, j: number) => {
    const x = Math.sin(seed + i * 12.9898 + j * 78.233) * 43758.5453;
    return x - Math.floor(x);
  };
  return (
    <div
      className="grid"
      style={{ gridTemplateColumns: `repeat(${cols}, ${cell}px)`, gap, width: cols * (cell + gap) - gap }}
    >
      {Array.from({ length: cols * 7 }).map((_, k) => {
        const i = Math.floor(k / 7);
        const j = k % 7;
        const r = rnd(i, j);
        let lvl = 0;
        if (r > 0.3) lvl = 1;
        if (r > 0.56) lvl = 2;
        if (r > 0.79) lvl = 3;
        if (r > 0.92) lvl = 4;
        if (j === 0 || j === 6) lvl = Math.max(0, lvl - 1);
        return (
          <span
            key={k}
            style={{
              width: cell,
              height: cell,
              borderRadius: 3,
              background: LEVEL[lvl],
              border: lvl === 0 ? "1px solid var(--gf-line)" : "none",
            }}
          />
        );
      })}
    </div>
  );
}

/* ============================================================
   MARKDOWN PREVIEW
   ============================================================ */

export function MarkdownPreview() {
  return (
    <div className="space-y-3.5 text-[13.5px] font-medium leading-relaxed text-muted">
      <h1 className="text-[22px] font-extrabold tracking-[-0.02em] text-ink">GitFlow 🚀</h1>
      <p>
        A <strong className="font-extrabold text-ink">bright, friendly GitHub client</strong> for
        mobile. Built with Flutter, offline-first and{" "}
        <em className="font-bold text-brand">blazing fast</em>.
      </p>
      <div
        className="rounded-[14px] px-3.5 py-3 font-mono text-[12px] font-medium leading-relaxed"
        style={{ background: "#FEFCE8", border: "1px solid #FDE68A" }}
      >
        <div>
          <span className="font-bold text-brand">$</span>{" "}
          <span className="text-ink">flutter pub add gitflow</span>
        </div>
      </div>
      <div>
        <div className="mb-2 text-[11.5px] font-extrabold uppercase tracking-wider text-faint">
          Features
        </div>
        <ul className="space-y-2">
          {[
            ["⚡", "Offline-first with background sync"],
            ["🎨", "Native-feeling diff viewer"],
            ["🔐", "Biometric lock & token vault"],
            ["🔔", "Real-time push notifications"],
          ].map(([e, f]) => (
            <li key={f} className="flex items-start gap-2">
              <span className="text-[13px] leading-5">{e}</span>
              <span>{f}</span>
            </li>
          ))}
        </ul>
      </div>
      <div className="flex flex-wrap gap-1.5">
        {[
          ["dart", "#06B6D4"],
          ["flutter", "#6366F1"],
          ["github", "#111827"],
          ["mobile", "#EC4899"],
        ].map(([t, c]) => (
          <span
            key={t}
            className="rounded-full px-2.5 py-1 text-[11.5px] font-bold"
            style={{ color: c, background: hex(c, 0.11), border: `1px solid ${hex(c, 0.22)}` }}
          >
            {t}
          </span>
        ))}
      </div>
    </div>
  );
}
