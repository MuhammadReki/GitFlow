import { useState } from "react";
import { Icon, type IconName } from "@/lib/icons";
import { issues, prs, notifications } from "@/lib/data";
import {
  BottomNav,
  Card,
  Chip,
  Fab,
  GRADS,
  hex,
  IssueCard,
  PRCard,
  NotificationCard,
  SearchBar,
  TabRow,
} from "@/components/ui";
import { Screen } from "@/components/Phone";

/* ============================================================
   08 · ISSUES
   ============================================================ */

export function IssuesScreen() {
  const [t, setT] = useState(0);
  const list = issues.filter((i) =>
    t === 0 ? i.state === "open" : t === 1 ? i.state === "closed" : true,
  );
  return (
    <div className="absolute inset-0 bg-canvas-2">
      <div className="absolute inset-x-0 top-0 z-20 bg-white/92 pt-[54px] backdrop-blur-xl">
        <div className="flex items-center gap-2.5 px-4 pb-2.5 pt-1">
          <button
            className="press grid h-9 w-9 place-items-center rounded-[13px] text-white sh-sm"
            style={{ background: GRADS.brand }}
          >
            <Icon name="chevronLeft" size={18} strokeWidth={2.8} />
          </button>
          <div className="min-w-0 flex-1">
            <div className="truncate font-display text-[17px] font-extrabold tracking-[-0.02em] text-ink">
              Issues 🐛
            </div>
            <div className="truncate text-[11.5px] font-semibold text-faint">
              mrahman/gitflow · 41 open
            </div>
          </div>
          <button
            className="press grid h-9 w-9 place-items-center rounded-[13px] text-white sh-sm"
            style={{ background: GRADS.cool }}
          >
            <Icon name="filter" size={16} strokeWidth={2.4} />
          </button>
        </div>
        <TabRow
          tabs={["Open", "Closed", "All"]}
          active={t}
          onChange={setT}
          counts={["41", "1,208", "1,249"]}
          tints={["#10B981", "#6B7280", "#6366F1"]}
        />
        <div className="gf-scroll flex gap-2 overflow-x-auto px-4 pb-3">
          <Chip selected emoji="🏷️" tint="#8B5CF6">
            Labels
          </Chip>
          <Chip emoji="👤" tint="#3B82F6">
            Assignee
          </Chip>
          <Chip emoji="🚩" tint="#EC4899">
            Milestone
          </Chip>
          <Chip emoji="⬇️" tint="#F59E0B">
            Newest
          </Chip>
        </div>
      </div>

      <Screen padTop={210} padBottom={110} bg="var(--gf-canvas-2)">
        <div className="space-y-3 px-4">
          {list.map((i, k) => (
            <IssueCard key={i.n} issue={i} style={{ animation: `gf-fade-up .45s ${k * 55}ms both` }} />
          ))}
        </div>
        <p className="py-6 text-center text-[12px] font-bold text-faint">
          🎉 That's everything · 41 issues
        </p>
      </Screen>

      <Fab label="New Issue" gradient={GRADS.sun} emoji="🐛" />
    </div>
  );
}

/* ============================================================
   09 · PULL REQUESTS
   ============================================================ */

export function PullRequestsScreen() {
  const [t, setT] = useState(0);
  const list = prs.filter((p) =>
    t === 0 ? p.state === "open" : t === 1 ? p.state === "closed" : p.state === "merged",
  );
  return (
    <div className="absolute inset-0 bg-canvas-2">
      <div className="absolute inset-x-0 top-0 z-20 bg-white/92 pt-[54px] backdrop-blur-xl">
        <div className="flex items-center gap-2.5 px-4 pb-2.5 pt-1">
          <button
            className="press grid h-9 w-9 place-items-center rounded-[13px] text-white sh-sm"
            style={{ background: GRADS.brand }}
          >
            <Icon name="chevronLeft" size={18} strokeWidth={2.8} />
          </button>
          <div className="min-w-0 flex-1">
            <div className="truncate font-display text-[17px] font-extrabold tracking-[-0.02em] text-ink">
              Pull requests 🔀
            </div>
            <div className="truncate text-[11.5px] font-semibold text-faint">
              mrahman/gitflow · 3 awaiting review
            </div>
          </div>
          <span
            className="grid h-9 w-9 place-items-center rounded-[13px] text-white sh-sm"
            style={{ background: GRADS.brand }}
          >
            <Icon name="merge" size={17} strokeWidth={2.1} />
          </span>
        </div>
        <TabRow
          tabs={["Open", "Closed", "Merged"]}
          active={t}
          onChange={setT}
          counts={["12", "318", "904"]}
          tints={["#10B981", "#EF4444", "#8B5CF6"]}
        />
        <div className="px-4 py-1.5">
          <SearchBar compact placeholder="Search pull requests…" onFilter />
        </div>
      </div>

      <Screen padTop={212} padBottom={110} bg="var(--gf-canvas-2)">
        <div className="space-y-3 px-4">
          {list.map((p, k) => (
            <PRCard key={p.n} pr={p} style={{ animation: `gf-fade-up .45s ${k * 55}ms both` }} />
          ))}
          {t === 2 && (
            <Card className="anim-pop relative overflow-hidden p-4" tint="#8B5CF6">
              <div className="flex items-center gap-3">
                <span
                  className="grid h-11 w-11 shrink-0 place-items-center rounded-[15px] text-[21px] text-white"
                  style={{ background: GRADS.brand, boxShadow: "0 6px 16px rgba(139,92,246,.4)" }}
                >
                  🎉
                </span>
                <div className="min-w-0 flex-1">
                  <div className="text-[13.5px] font-extrabold text-ink">#1484 was merged</div>
                  <div className="text-[11.5px] font-semibold text-muted">
                    Conflict-free · 4 files · +281 −42
                  </div>
                </div>
              </div>
              {["#6366F1", "#8B5CF6", "#EC4899", "#F59E0B", "#10B981", "#06B6D4", "#3B82F6", "#EF4444"].map(
                (c, i) => (
                  <span
                    key={i}
                    className="absolute left-1/2 top-4 h-2 w-2 rounded-full"
                    style={
                      {
                        background: c,
                        "--dx": `${(i - 3.5) * 44}px`,
                        "--dy": `${-44 - (i % 3) * 34}px`,
                        animation: `gf-confetti 1.5s ${i * 85}ms cubic-bezier(.2,.7,.3,1) infinite`,
                      } as React.CSSProperties
                    }
                  />
                ),
              )}
            </Card>
          )}
        </div>
      </Screen>

      <Fab label="New PR" gradient={GRADS.brand} emoji="🔀" />
    </div>
  );
}

/* ============================================================
   10 · NOTIFICATIONS — every type a different color
   ============================================================ */

export function NotificationsScreen() {
  const [t, setT] = useState(0);
  const list = notifications.filter((n) =>
    t === 0 ? true : t === 1 ? n.unread : n.kind === "comment" || n.kind === "follow",
  );
  return (
    <div className="absolute inset-0 bg-canvas-2">
      <div className="absolute inset-x-0 top-0 z-20 bg-white/92 pt-[54px] backdrop-blur-xl">
        <div className="flex items-center justify-between px-4 pb-2.5 pt-1">
          <div>
            <h1 className="font-display text-[24px] font-extrabold tracking-[-0.03em] text-ink">
              Notifications 🔔
            </h1>
            <p className="text-[12.5px] font-semibold text-faint">3 unread · 2 muted threads</p>
          </div>
          <div className="flex gap-1.5">
            <button
              className="press grid h-10 w-10 place-items-center rounded-[14px] text-white sh-sm"
              style={{ background: GRADS.mint }}
            >
              <Icon name="check" size={17} strokeWidth={2.8} />
            </button>
            <button
              className="press grid h-10 w-10 place-items-center rounded-[14px] border border-line bg-white text-muted sh-sm"
            >
              <Icon name="settings" size={17} strokeWidth={2.1} />
            </button>
          </div>
        </div>
        <TabRow
          tabs={["All", "Unread", "Mentions"]}
          active={t}
          onChange={setT}
          counts={["24", "3", "6"]}
          tints={["#6366F1", "#EF4444", "#EC4899"]}
        />
      </div>

      <Screen padTop={176} padBottom={92} bg="var(--gf-canvas-2)">
        <div className="space-y-3 px-4 pt-3">
          {list.map((n, i) => (
            <NotificationCard
              key={n.id}
              n={n}
              reveal={i === 1 ? "read" : null}
              style={{ animation: `gf-fade-up .45s ${i * 50}ms both` }}
            />
          ))}
        </div>

        <div className="mt-3 px-4">
          <div
            className="rounded-[16px] border px-3.5 py-3 text-center text-[11.5px] font-bold"
            style={{ borderColor: hex("#6366F1", 0.22), background: hex("#6366F1", 0.06), color: "#6B7280" }}
          >
            <Icon name="refresh" size={12} strokeWidth={3} className="mr-1 inline anim-spin text-brand" />
            Pull to refresh · last synced 2m ago
          </div>
        </div>
      </Screen>

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
  );
}
