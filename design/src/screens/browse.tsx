import { useState } from "react";
import { cn } from "@/utils/cn";
import { Icon, type IconName } from "@/lib/icons";
import { repos, trending, activity, issues, user, fileTree, sourceLines } from "@/lib/data";
import {
  Avatar,
  BottomNav,
  Card,
  Chip,
  Fab,
  GRADS,
  hex,
  MarkdownPreview,
  RepoCardCompact,
  RepoCardDetailed,
  SearchBar,
  SectionHeader,
  StatCard,
  TabRow,
  BottomSheet,
  SheetRow,
  EmptyState,
  RepoSkeleton,
  LanguageDot,
  StarBadge,
} from "@/components/ui";
import { Screen } from "@/components/Phone";

const NAV = [
  { icon: "home" as IconName, label: "Home" },
  { icon: "repo" as IconName, label: "Repos" },
  { icon: "bell" as IconName, label: "Alerts" },
  { icon: "user" as IconName, label: "You" },
];

const ACT_ICON: Record<string, { emoji: string; color: string }> = {
  star: { emoji: "⭐", color: "#F59E0B" },
  pr: { emoji: "🔀", color: "#8B5CF6" },
  issue: { emoji: "🐛", color: "#10B981" },
  push: { emoji: "⬆️", color: "#3B82F6" },
  fork: { emoji: "🍴", color: "#06B6D4" },
  release: { emoji: "🎉", color: "#6366F1" },
};

function renderRich(t: string) {
  return t.split(/(\*\*[^*]+\*\*)/g).map((p, i) =>
    p.startsWith("**") ? (
      <span key={i} className="font-bold text-ink">
        {p.slice(2, -2)}
      </span>
    ) : (
      <span key={i}>{p}</span>
    ),
  );
}

/* ============================================================
   04 · HOME / DASHBOARD
   ============================================================ */

export function HomeScreen() {
  const [tab, setTab] = useState(0);
  return (
    <div className="absolute inset-0 bg-white">
      <Screen padTop={0} padBottom={96}>
        {/* gradient hero header */}
        <div
          className="relative overflow-hidden px-4 pb-20 pt-[58px]"
          style={{ background: "linear-gradient(135deg,#6366F1 0%,#8B5CF6 55%,#EC4899 100%)" }}
        >
          <span className="anim-blob absolute -right-10 -top-10 h-44 w-44 rounded-full bg-white/20 blur-2xl" />
          <span className="anim-blob absolute -left-12 top-24 h-36 w-36 rounded-full bg-amber-300/25 blur-2xl" style={{ animationDelay: "-7s" }} />
          <div className="relative flex items-center gap-3">
            <Avatar img="/img/avatar2.jpg" name={user.name} size={44} online />
            <div className="min-w-0 flex-1">
              <div className="font-display text-[18px] font-extrabold leading-tight tracking-[-0.02em] text-white">
                Hi, {user.name.split(" ")[0]} 👋
              </div>
              <div className="text-[12.5px] font-semibold text-white/75">
                3 new notifications · 4 PRs to review
              </div>
            </div>
            <button
              className="press relative grid h-11 w-11 place-items-center rounded-[15px] bg-white/20 text-white backdrop-blur"
              style={{ boxShadow: "0 6px 18px rgba(17,24,39,.18)" }}
            >
              <Icon name="bell" size={19} strokeWidth={2.1} />
              <span
                className="anim-pulse-cherry absolute -right-1 -top-1 grid h-[19px] min-w-[19px] place-items-center rounded-full px-1 text-[10px] font-extrabold text-white"
                style={{ background: "#F59E0B", border: "2px solid #fff" }}
              >
                3
              </span>
            </button>
          </div>

          <div className="relative mt-4">
            <SearchBar value="" />
          </div>
        </div>

        {/* quick stats — overlap the hero */}
        <div className="-mt-14 px-4">
          <div className="gf-scroll -mx-4 flex gap-3 overflow-x-auto px-4 pb-1">
            <StatCard emoji="📦" value="147" label="Repositories" tint="#6366F1" gradient={GRADS.brand} delta="4 new" />
            <StatCard emoji="⭐" value="38.2k" label="Stars earned" tint="#F59E0B" gradient={GRADS.sun} delta="212" />
            <StatCard emoji="💜" value="12.4k" label="Followers" tint="#EC4899" gradient={GRADS.blush} delta="86" />
            <StatCard emoji="🌱" value="214" label="Contributions" tint="#10B981" gradient={GRADS.mint} delta="this week" />
          </div>
        </div>

        {/* your repositories */}
        <div className="mt-7">
          <SectionHeader emoji="📁" title="Your Repositories" action="View All" />
          <div className="grid grid-cols-2 gap-3 px-4">
            {repos.slice(0, 4).map((r, i) => (
              <RepoCardCompact key={r.name} repo={r} style={{ animation: `gf-fade-up .5s ${i * 60}ms both` }} />
            ))}
          </div>
        </div>

        {/* recent activity */}
        <div className="mt-7">
          <SectionHeader emoji="⚡" title="Recent Activity" action="Timeline" />
          <div className="px-4">
            <Card className="divide-y divide-divider overflow-hidden">
              {activity.map((a) => {
                const m = ACT_ICON[a.type];
                return (
                  <div key={a.text} className="flex items-center gap-3 px-3.5 py-3">
                    <span
                      className="grid h-10 w-10 shrink-0 place-items-center rounded-[14px] text-[17px]"
                      style={{ background: hex(m.color, 0.13) }}
                    >
                      {m.emoji}
                    </span>
                    <div className="min-w-0 flex-1">
                      <div className="truncate text-[13px] font-semibold text-muted">{renderRich(a.text)}</div>
                      <div className="text-[11px] font-semibold text-faint">{a.meta}</div>
                    </div>
                    <Icon name="chevronRight" size={15} strokeWidth={2.8} className="shrink-0 text-faint" />
                  </div>
                );
              })}
            </Card>
          </div>
        </div>

        {/* trending */}
        <div className="mt-7">
          <SectionHeader emoji="🔥" title="Trending Today" action="Explore" />
          <div className="gf-scroll flex gap-3 overflow-x-auto px-4 pb-2">
            {trending.map((t) => (
              <div
                key={t.name}
                className="press w-[176px] shrink-0 rounded-[20px] border border-line bg-surface p-3.5 sh-sm"
              >
                <div className="flex items-center gap-2">
                  <span
                    className="grid h-8 w-8 place-items-center rounded-[11px] text-[15px]"
                    style={{ background: hex(t.tint, 0.13) }}
                  >
                    {t.emoji}
                  </span>
                  <span className="truncate text-[11.5px] font-bold text-faint">{t.owner}</span>
                </div>
                <div className="mt-2 truncate text-[15px] font-extrabold tracking-[-0.01em] text-ink">
                  {t.name}
                </div>
                <p className="mt-1 line-clamp-2 h-[34px] text-[11.5px] font-medium leading-snug text-muted">
                  {t.desc}
                </p>
                <div className="mt-2.5 flex items-center gap-2">
                  <LanguageDot lang={t.lang} size={7} />
                  <span className="text-[11px] font-bold text-muted">{t.lang}</span>
                  <span className="ml-auto">
                    <StarBadge stars={t.stars} />
                  </span>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* syncing skeletons */}
        <div className="mt-7">
          <SectionHeader emoji="🔄" title="Syncing" />
          <div className="space-y-3 px-4">
            <RepoSkeleton />
          </div>
        </div>
      </Screen>

      <BottomNav items={NAV} active={tab} onChange={setTab} badge={3} />
    </div>
  );
}

/* ============================================================
   05 · REPOSITORY LIST
   ============================================================ */

const FILTERS: [string, string, string][] = [
  ["All", "🗂️", "#6366F1"],
  ["Public", "🌍", "#10B981"],
  ["Private", "🔒", "#F59E0B"],
  ["Starred", "⭐", "#EC4899"],
  ["Forked", "🍴", "#06B6D4"],
];

export function RepoListScreen() {
  const [f, setF] = useState(0);
  const [open, setOpen] = useState(false);
  const shown = repos.filter((r) =>
    f === 0 ? true : f === 1 ? r.visibility === "Public" : f === 2 ? r.visibility === "Private" : true,
  );
  return (
    <div className="absolute inset-0 bg-canvas-2">
      <div className="absolute inset-x-0 top-0 z-20 bg-white/92 pt-[54px] backdrop-blur-xl">
        <div className="flex items-center justify-between px-4 pb-3 pt-1">
          <div>
            <h1 className="font-display text-[24px] font-extrabold tracking-[-0.03em] text-ink">
              Repositories
            </h1>
            <p className="text-[12.5px] font-semibold text-faint">147 total · 12 private 🔒</p>
          </div>
          <button className="press flex items-center gap-1.5 rounded-full border border-line bg-white px-3.5 py-2 text-[12px] font-bold text-muted sh-sm">
            <Icon name="layers" size={13} strokeWidth={2.4} />
            Recent
            <Icon name="chevronDown" size={12} strokeWidth={3} />
          </button>
        </div>
        <div className="px-4 pb-3">
          <SearchBar compact placeholder="Filter repositories…" onFilter />
        </div>
        <div className="gf-scroll flex gap-2 overflow-x-auto px-4 pb-3">
          {FILTERS.map(([x, e, c], i) => (
            <Chip key={x} emoji={e} tint={c} selected={i === f} onClick={() => setF(i)}>
              {x}
            </Chip>
          ))}
        </div>
      </div>

      <Screen padTop={222} padBottom={110} bg="var(--gf-canvas-2)">
        <div className="space-y-3 px-4">
          {shown.map((r, i) => (
            <RepoCardDetailed key={r.name} repo={r} style={{ animation: `gf-fade-up .45s ${i * 55}ms both` }} />
          ))}
        </div>
        <div className="mt-6">
          <EmptyState
            emoji="📡"
            tint="#F59E0B"
            title="You're offline — showing cache"
            body="Everything you've opened recently is available. Pull to refresh once you're back on the network."
            action="Retry sync"
          />
        </div>
      </Screen>

      <Fab label="New Repo" emoji="＋" gradient={GRADS.brand} open={open} onClick={() => setOpen((v) => !v)} />
    </div>
  );
}

/* ============================================================
   06 · REPOSITORY DETAIL
   ============================================================ */

const REPO_TABS = ["Code", "Issues", "PRs", "Actions", "More"];
const REPO_TINTS = ["#6366F1", "#10B981", "#8B5CF6", "#F59E0B", "#EC4899"];

export function RepoDetailScreen() {
  const [t, setT] = useState(0);
  const repo = repos[0];
  return (
    <div className="absolute inset-0 bg-white">
      <Screen padTop={0} padBottom={34}>
        {/* gradient hero */}
        <div
          className="relative overflow-hidden px-4 pb-6 pt-[56px]"
          style={{ background: "linear-gradient(135deg,#6366F1,#8B5CF6 60%,#EC4899)" }}
        >
          <span className="anim-blob absolute -right-8 top-8 h-40 w-40 rounded-full bg-white/20 blur-2xl" />
          <div className="relative flex items-center gap-2">
            <button className="press grid h-9 w-9 place-items-center rounded-full bg-white/20 text-white backdrop-blur">
              <Icon name="chevronLeft" size={19} strokeWidth={2.6} />
            </button>
            <div className="ml-auto flex items-center gap-2">
              <button
                className="press flex h-9 items-center gap-1.5 rounded-full bg-white px-3.5 text-[12.5px] font-extrabold text-brand sh-sm"
              >
                <Icon name="star" size={14} strokeWidth={2.6} /> Star
              </button>
              <button className="press grid h-9 w-9 place-items-center rounded-full bg-white/20 text-white backdrop-blur">
                <Icon name="fork" size={16} strokeWidth={2.2} />
              </button>
              <button className="press grid h-9 w-9 place-items-center rounded-full bg-white/20 text-white backdrop-blur">
                <Icon name="eye" size={16} strokeWidth={2.2} />
              </button>
            </div>
          </div>

          <div className="relative mt-4 flex items-center gap-3">
            <span className="grid h-14 w-14 shrink-0 place-items-center rounded-[18px] bg-white/25 text-[26px] backdrop-blur">
              🚀
            </span>
            <div className="min-w-0">
              <div className="truncate font-display text-[22px] font-extrabold leading-tight tracking-[-0.03em] text-white">
                {repo.name}
              </div>
              <div className="truncate text-[13px] font-semibold text-white/80">
                {repo.owner} · Public · Dart
              </div>
            </div>
          </div>
        </div>

        {/* colorful tabs */}
        <div className="sticky top-0 z-20 -mt-1 bg-white/94 backdrop-blur-xl">
          <TabRow tabs={REPO_TABS} active={t} onChange={setT} tints={REPO_TINTS} counts={["", "41", "12", "", ""]} />
        </div>

        {t === 0 && (
          <div className="anim-slide-right">
            <div className="px-4 pt-3">
              <button className="press flex h-11 w-full items-center gap-2 rounded-[14px] border border-line bg-canvas-2 px-3.5 sh-sm">
                <span
                  className="grid h-7 w-7 place-items-center rounded-[9px] text-white"
                  style={{ background: GRADS.brand }}
                >
                  <Icon name="branch" size={14} strokeWidth={2.4} />
                </span>
                <span className="font-mono text-[13px] font-bold text-ink">main</span>
                <span
                  className="ml-1 rounded-full px-2 py-[2px] text-[10.5px] font-extrabold"
                  style={{ color: "#10B981", background: hex("#10B981", 0.12) }}
                >
                  default
                </span>
                <Icon name="chevronDown" size={13} strokeWidth={3} className="ml-auto text-faint" />
              </button>
            </div>

            <div className="mt-3 px-4">
              <Card className="flex items-center gap-3 p-3.5" tint="#6366F1">
                <Avatar img="/img/avatar2.jpg" size={34} />
                <div className="min-w-0 flex-1">
                  <div className="truncate text-[12.5px] font-bold text-ink">
                    feat(core): offline mutation queue
                  </div>
                  <div className="text-[11px] font-semibold text-faint">
                    mrahman · 32 minutes ago ·{" "}
                    <span className="font-mono text-brand">a1f9c3e</span>
                  </div>
                </div>
                <span
                  className="grid h-8 w-8 shrink-0 place-items-center rounded-full text-white"
                  style={{ background: GRADS.mint, boxShadow: "0 4px 12px rgba(16,185,129,.4)" }}
                >
                  <Icon name="check" size={14} strokeWidth={3.2} />
                </span>
              </Card>
            </div>

            {/* file tree with colorful icons */}
            <div className="mt-3 px-4">
              <Card className="divide-y divide-divider overflow-hidden">
                {fileTree.map((f) => (
                  <div key={f.name} className="flex items-center gap-3 px-3.5 py-2.5">
                    <span
                      className="grid h-9 w-9 shrink-0 place-items-center rounded-[12px] text-[15px]"
                      style={{ background: hex(f.tint, 0.13) }}
                    >
                      {f.emoji}
                    </span>
                    <div className="min-w-0 flex-1">
                      <div className="truncate text-[13.5px] font-bold text-ink">{f.name}</div>
                      <div className="truncate text-[11px] font-semibold text-faint">{f.msg}</div>
                    </div>
                    <span className="shrink-0 text-[11px] font-semibold text-faint">{f.time}</span>
                  </div>
                ))}
              </Card>
            </div>

            {/* readme */}
            <div className="mt-5 px-4">
              <div className="mb-2.5 flex items-center gap-2">
                <span
                  className="grid h-8 w-8 place-items-center rounded-[11px] text-[15px]"
                  style={{ background: hex("#3B82F6", 0.13) }}
                >
                  📖
                </span>
                <span className="text-[15px] font-extrabold tracking-[-0.01em] text-ink">README.md</span>
                <span
                  className="ml-auto rounded-full px-2.5 py-1 text-[10.5px] font-extrabold"
                  style={{ color: "#3B82F6", background: hex("#3B82F6", 0.11) }}
                >
                  rendered ✨
                </span>
              </div>
              <Card className="p-4">
                <MarkdownPreview />
              </Card>
            </div>
          </div>
        )}

        {t === 1 && (
          <div className="anim-slide-right space-y-3 px-4 pt-3">
            {issues.map((i) => (
              <Card key={i.n} className="p-3.5">
                <div className="text-[13.5px] font-bold text-ink">{i.title}</div>
                <div className="mt-1 text-[11.5px] font-semibold text-faint">
                  #{i.n} · {i.time}
                </div>
              </Card>
            ))}
          </div>
        )}

        {t === 2 && (
          <div className="anim-slide-right px-4 pt-3">
            <EmptyState
              emoji="🔀"
              tint="#8B5CF6"
              title="12 open pull requests"
              body="Review diffs, leave inline comments and merge with a single tap."
              action="Open review queue"
            />
          </div>
        )}

        {t === 3 && (
          <div className="anim-slide-right space-y-3 px-4 pt-3">
            {[
              { n: "CI · linux", s: "pass", t: "4m 12s", e: "🐧" },
              { n: "CI · android", s: "run", t: "1m 08s", e: "🤖" },
              { n: "analyze", s: "pass", t: "38s", e: "🔎" },
              { n: "golden tests", s: "fail", t: "6m 40s", e: "🧪" },
            ].map((w) => {
              const c = w.s === "pass" ? "#10B981" : w.s === "run" ? "#F59E0B" : "#EF4444";
              return (
                <Card key={w.n} className="flex items-center gap-3 p-3.5" tint={c}>
                  <span
                    className="grid h-10 w-10 shrink-0 place-items-center rounded-[14px] text-[18px]"
                    style={{ background: hex(c, 0.13) }}
                  >
                    {w.e}
                  </span>
                  <div className="min-w-0 flex-1">
                    <div className="text-[13.5px] font-bold text-ink">{w.n}</div>
                    <div className="font-mono text-[11px] font-semibold text-faint">{w.t}</div>
                  </div>
                  <span
                    className="rounded-full px-2.5 py-1 text-[10.5px] font-extrabold"
                    style={{ color: c, background: hex(c, 0.12) }}
                  >
                    {w.s === "pass" ? "passed" : w.s === "run" ? "running" : "failed"}
                  </span>
                </Card>
              );
            })}
          </div>
        )}

        {t === 4 && (
          <div className="anim-slide-right px-4 pt-3">
            <Card className="divide-y divide-divider overflow-hidden">
              <SheetRow emoji="⚙️" label="General" hint="name, topics" tint="#6366F1" />
              <SheetRow emoji="👥" label="Collaborators" hint="8" tint="#8B5CF6" />
              <SheetRow emoji="🏷️" label="Releases" hint="v2.1.0" tint="#F59E0B" />
              <SheetRow emoji="🌍" label="Visibility" hint="Public" tint="#10B981" />
              <SheetRow emoji="🛡️" label="Security" hint="1 alert" tint="#EF4444" />
            </Card>
          </div>
        )}
      </Screen>
    </div>
  );
}

/* ============================================================
   07 · FILE VIEWER — cream code canvas
   ============================================================ */

export function FileViewerScreen() {
  const [sheet, setSheet] = useState(true);
  return (
    <div className="absolute inset-0 bg-white">
      <div className="absolute inset-x-0 top-0 z-20 bg-white/93 pt-[54px] backdrop-blur-xl">
        <div className="flex items-center gap-2 px-3 pb-2.5 pt-1">
          <button
            className="press grid h-9 w-9 place-items-center rounded-[13px] text-white sh-sm"
            style={{ background: GRADS.brand }}
          >
            <Icon name="chevronLeft" size={18} strokeWidth={2.8} />
          </button>
          <div className="min-w-0 flex-1">
            <div className="flex items-center gap-1 font-mono text-[11.5px] font-semibold text-faint">
              <span>gitflow</span>
              <Icon name="chevronRight" size={10} strokeWidth={3} />
              <span>lib</span>
              <Icon name="chevronRight" size={10} strokeWidth={3} />
              <span>core</span>
              <Icon name="chevronRight" size={10} strokeWidth={3} />
              <span className="font-extrabold text-ink">token_refresher.dart</span>
            </div>
            <div className="mt-1 flex items-center gap-1.5">
              <span
                className="rounded-full px-1.5 py-[1px] text-[9.5px] font-extrabold"
                style={{ color: "#10B981", background: hex("#10B981", 0.13) }}
              >
                ● 24 lines
              </span>
              <span className="text-[10px] font-bold text-faint">Dart · UTF-8 · LF</span>
            </div>
          </div>
        </div>
        {/* friendly toolbar with gradient buttons */}
        <div className="flex items-center gap-1.5 px-3 py-2">
          {(
            [
              ["copy", "Copy", GRADS.brand, "#6366F1"],
              ["share", "Share", GRADS.cool, "#3B82F6"],
              ["edit", "Edit", GRADS.mint, "#10B981"],
              ["download", "Raw", GRADS.sun, "#F59E0B"],
            ] as [string, string, string, string][]
          ).map(([ic, l, g, tint], i) => (
            <button
              key={l}
              className="press flex h-10 flex-1 items-center justify-center gap-1.5 rounded-[13px] text-[12px] font-extrabold text-white"
              style={{
                background: g,
                boxShadow: `0 6px 16px ${hex(i % 2 ? "#3B82F6" : "#6366F1", 0.28)}`,
                opacity: tint ? 1 : 1,
              }}
            >
              <Icon name={ic as IconName} size={13} strokeWidth={2.6} />
              {l}
            </button>
          ))}
        </div>
      </div>

      <Screen padTop={174} padBottom={20}>
        <div className="code-canvas mx-4 overflow-hidden rounded-[20px] border border-amber-200 sh-md">
          <div className="flex items-center gap-2 border-b border-amber-200 bg-amber-50/70 px-3.5 py-2.5">
            <span className="flex gap-1">
              {["#EF4444", "#F59E0B", "#10B981"].map((c) => (
                <span key={c} className="h-2.5 w-2.5 rounded-full" style={{ background: c }} />
              ))}
            </span>
            <span className="font-mono text-[10.5px] font-bold text-amber-700">
              token_refresher.dart
            </span>
            <span
              className="ml-auto rounded-full bg-white px-2 py-[2px] text-[9.5px] font-extrabold text-amber-700"
              style={{ border: "1px solid #FDE68A" }}
            >
              94% warm
            </span>
          </div>
          <div className="flex font-mono text-[11.5px] font-medium leading-[1.8]">
            <div className="select-none border-r border-amber-200 bg-amber-50/50 px-3 py-3 text-right text-amber-600/70">
              {sourceLines.map((l) => (
                <div
                  key={l.n}
                  className={cn("w-[24px]", (l.n === 12 || l.n === 14) && "font-extrabold text-brand")}
                >
                  {l.n}
                </div>
              ))}
            </div>
            <div className="flex-1 overflow-x-auto py-3 pl-3 pr-3">
              {sourceLines.map((l) => (
                <div
                  key={l.n}
                  className={cn(
                    "-mx-2 px-2",
                    (l.n === 12 || l.n === 14) && "bg-indigo-50 border-l-[3px] border-brand/60",
                  )}
                >
                  {l.html ? <span dangerouslySetInnerHTML={{ __html: l.html }} /> : <span>&nbsp;</span>}
                </div>
              ))}
              <div className="mt-1 h-4 w-[2px] bg-brand anim-blink" />
            </div>
          </div>
        </div>
      </Screen>

      {sheet && (
        <BottomSheet title="token_refresher.dart">
          <div className="space-y-0.5">
            <SheetRow emoji="🕵️" label="Blame" hint="annotate" tint="#8B5CF6" />
            <SheetRow emoji="🕰️" label="History" hint="34 commits" tint="#3B82F6" />
            <SheetRow emoji="🔗" label="Copy permalink" hint="a1f9c3e" tint="#06B6D4" />
            <SheetRow emoji="💻" label="Open in Codespace" tint="#10B981" />
          </div>
          <div className="mt-2 px-5">
            <button
              onClick={() => setSheet(false)}
              className="press h-11 w-full rounded-[14px] border border-line bg-canvas-2 text-[14px] font-bold text-ink"
            >
              Close
            </button>
          </div>
        </BottomSheet>
      )}
    </div>
  );
}
