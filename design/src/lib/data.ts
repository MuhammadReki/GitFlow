/* ============================================================
   GitFlow — Mock content (bright & friendly)
   ============================================================ */

export const LANG_COLORS: Record<string, string> = {
  Dart: "#06B6D4",
  TypeScript: "#6366F1",
  Rust: "#F59E0B",
  Go: "#10B981",
  Python: "#3B82F6",
  Swift: "#EC4899",
  Kotlin: "#8B5CF6",
  Ruby: "#EF4444",
  Shell: "#10B981",
  CSS: "#8B5CF6",
  JavaScript: "#F59E0B",
  C: "#6B7280",
  Java: "#F97316",
  HTML: "#F43F5E",
  Vue: "#22C55E",
  Zig: "#F59E0B",
  Elixir: "#A855F7",
};

export type Repo = {
  owner: string;
  name: string;
  desc: string;
  lang: string;
  stars: string;
  forks: string;
  visibility: "Public" | "Private";
  updated: string;
  emoji: string;
  tint: string;
};

export const user = {
  name: "Muhammad Rahman",
  handle: "mrahman",
  bio: "Building delightful developer tools ✨ Flutter + Rust. Ex-@vercel. Open source maintainer.",
  company: "@gitflow · @flutter",
  location: "Jakarta, Indonesia 🇮🇩",
  blog: "mrahman.dev",
  followers: "12.4k",
  following: "318",
  repos: "147",
  stars: "38.2k",
  status: "Shipping v2.1 🚀",
  online: true,
};

export const repos: Repo[] = [
  {
    owner: "mrahman",
    name: "gitflow",
    desc: "Sleek GitHub client for mobile ✨ Flutter, offline-first, blazing fast.",
    lang: "Dart",
    stars: "24.1k",
    forks: "1.2k",
    visibility: "Public",
    updated: "12m",
    emoji: "🚀",
    tint: "#6366F1",
  },
  {
    owner: "mrahman",
    name: "flutter-anvil",
    desc: "Reactive state management without the boilerplate.",
    lang: "Dart",
    stars: "8.9k",
    forks: "412",
    visibility: "Public",
    updated: "2h",
    emoji: "⚡",
    tint: "#8B5CF6",
  },
  {
    owner: "mrahman",
    name: "rusty-tree",
    desc: "Blazing fast AST parser with tree-sitter bindings.",
    lang: "Rust",
    stars: "3.4k",
    forks: "98",
    visibility: "Public",
    updated: "5h",
    emoji: "🦀",
    tint: "#F59E0B",
  },
  {
    owner: "mrahman",
    name: "orbit-ui",
    desc: "Design system & component kit for Flutter apps.",
    lang: "Dart",
    stars: "6.2k",
    forks: "521",
    visibility: "Public",
    updated: "1d",
    emoji: "🎨",
    tint: "#EC4899",
  },
  {
    owner: "mrahman",
    name: "dotfiles",
    desc: "My macOS / neovim / zsh setup. Use at your own risk 😅",
    lang: "Shell",
    stars: "1.1k",
    forks: "143",
    visibility: "Public",
    updated: "3d",
    emoji: "🌱",
    tint: "#10B981",
  },
  {
    owner: "mrahman",
    name: "aperture-server",
    desc: "Edge proxy with 0-config deployments.",
    lang: "Go",
    stars: "940",
    forks: "56",
    visibility: "Private",
    updated: "4d",
    emoji: "🔒",
    tint: "#06B6D4",
  },
];

export const trending = [
  { owner: "vercel", name: "next.js", desc: "The React framework.", lang: "JavaScript", stars: "128k", emoji: "▲", tint: "#6B7280" },
  { owner: "shadcn-ui", name: "ui", desc: "Beautifully designed components.", lang: "TypeScript", stars: "74.2k", emoji: "◆", tint: "#111827" },
  { owner: "rust-lang", name: "rust", desc: "Empowering everyone to build reliable software.", lang: "Rust", stars: "98.4k", emoji: "🦀", tint: "#F59E0B" },
  { owner: "tailwindlabs", name: "tailwindcss", desc: "A utility-first CSS framework.", lang: "CSS", stars: "82.7k", emoji: "🌊", tint: "#06B6D4" },
  { owner: "ente-io", name: "ente", desc: "Fully open source, end-to-end encrypted photos.", lang: "Dart", stars: "18.3k", emoji: "🔐", tint: "#10B981" },
];

export const activity = [
  { type: "star", text: "Starred **shadcn-ui/ui**", meta: "2 hours ago" },
  { type: "pr", text: "Merged **feat: offline queue** into mrahman/gitflow", meta: "5 hours ago" },
  { type: "issue", text: "Opened **Crash on cold start (Android 15)**", meta: "yesterday" },
  { type: "push", text: "Pushed 6 commits to **main**", meta: "yesterday" },
  { type: "fork", text: "Forked **flutter/flutter**", meta: "3 days ago" },
  { type: "release", text: "Released **v2.0.4** · 42 assets 🎉", meta: "4 days ago" },
];

export type Issue = {
  n: number;
  title: string;
  state: "open" | "closed";
  labels: { name: string; color: string }[];
  author: string;
  avatar: string;
  time: string;
  comments: number;
};

export const issues: Issue[] = [
  {
    n: 1482,
    title: "Cold start crash on Android 15 when biometric prompt is dismissed",
    state: "open",
    labels: [
      { name: "🐛 bug", color: "#EF4444" },
      { name: "🔥 high", color: "#F59E0B" },
      { name: "🤖 android", color: "#10B981" },
    ],
    author: "kenji-dev",
    avatar: "#6366F1",
    time: "opened 2 hours ago",
    comments: 14,
  },
  {
    n: 1479,
    title: "Add support for GitHub Actions artifact uploads in the file viewer",
    state: "open",
    labels: [
      { name: "✨ enhancement", color: "#8B5CF6" },
      { name: "👋 good first issue", color: "#06B6D4" },
    ],
    author: "luanapt",
    avatar: "#EC4899",
    time: "opened 8 hours ago",
    comments: 5,
  },
  {
    n: 1476,
    title: "Diff viewer renders trailing whitespace as a change",
    state: "closed",
    labels: [{ name: "🐛 bug", color: "#EF4444" }],
    author: "mrahman",
    avatar: "#10B981",
    time: "closed yesterday",
    comments: 21,
  },
  {
    n: 1471,
    title: "Syntax highlighting for .astro files",
    state: "open",
    labels: [
      { name: "✨ enhancement", color: "#8B5CF6" },
      { name: "🙏 help wanted", color: "#3B82F6" },
    ],
    author: "sarahcodes",
    avatar: "#F59E0B",
    time: "opened 2 days ago",
    comments: 3,
  },
  {
    n: 1465,
    title: "Reorder bottom nav — Notifications should be index 2",
    state: "closed",
    labels: [{ name: "🎨 design", color: "#EC4899" }],
    author: "tobias",
    avatar: "#06B6D4",
    time: "closed 4 days ago",
    comments: 9,
  },
];

export type PR = {
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
};

export const prs: PR[] = [
  {
    n: 1490,
    title: "feat(core): offline mutation queue with conflict resolution",
    state: "open",
    from: "feat/offline-queue",
    to: "main",
    author: "mrahman",
    avatar: "#6366F1",
    time: "32m",
    checks: "pass",
    reviews: 2,
    comments: 18,
  },
  {
    n: 1488,
    title: "perf(ui): virtualize file tree for monorepos (10x faster)",
    state: "open",
    from: "perf/virtual-tree",
    to: "main",
    author: "kenji-dev",
    avatar: "#3B82F6",
    time: "3h",
    checks: "running",
    reviews: 1,
    comments: 7,
    draft: true,
  },
  {
    n: 1484,
    title: "fix(auth): token refresh race condition on app resume",
    state: "merged",
    from: "fix/token-race",
    to: "main",
    author: "luanapt",
    avatar: "#EC4899",
    time: "yesterday",
    checks: "pass",
    reviews: 3,
    comments: 24,
  },
  {
    n: 1480,
    title: "chore: migrate to Flutter 3.27 + Impeller",
    state: "merged",
    from: "chore/flutter-3.27",
    to: "main",
    author: "mrahman",
    avatar: "#10B981",
    time: "2 days ago",
    checks: "pass",
    reviews: 4,
    comments: 41,
  },
  {
    n: 1477,
    title: "experiment: Kotlin multiplatform core",
    state: "closed",
    from: "exp/kmp",
    to: "main",
    author: "tobias",
    avatar: "#EF4444",
    time: "5 days ago",
    checks: "fail",
    reviews: 0,
    comments: 12,
  },
];

export type Notif = {
  id: number;
  kind: "pr" | "issue" | "comment" | "star" | "ci" | "follow";
  title: string;
  preview: string;
  repo: string;
  time: string;
  unread: boolean;
  avatar: string;
};

export const notifications: Notif[] = [
  {
    id: 1,
    kind: "pr",
    title: "kenji-dev requested your review",
    preview: "feat(core): offline mutation queue with conflict reso…",
    repo: "mrahman/gitflow",
    time: "4m",
    unread: true,
    avatar: "#8B5CF6",
  },
  {
    id: 2,
    kind: "ci",
    title: "CI failed on main 😵",
    preview: "test (linux, stable) — 2 failing checks",
    repo: "mrahman/gitflow",
    time: "22m",
    unread: true,
    avatar: "#EF4444",
  },
  {
    id: 3,
    kind: "comment",
    title: "@sarahcodes mentioned you",
    preview: "“@mrahman can you take a look at the diff renderer?”",
    repo: "mrahman/orbit-ui",
    time: "1h",
    unread: true,
    avatar: "#3B82F6",
  },
  {
    id: 4,
    kind: "issue",
    title: "New issue: Cold start crash on Android 15",
    preview: "Opened by kenji-dev · labeled 🐛 bug, 🔥 high",
    repo: "mrahman/gitflow",
    time: "2h",
    unread: false,
    avatar: "#F59E0B",
  },
  {
    id: 5,
    kind: "star",
    title: "12 people starred gitflow ⭐",
    preview: "Including linustorvalds, gaearon, kentcdodds",
    repo: "mrahman/gitflow",
    time: "6h",
    unread: false,
    avatar: "#F59E0B",
  },
  {
    id: 6,
    kind: "follow",
    title: "luanapt started following you",
    preview: "“Merged — thanks for the quick turnaround!”",
    repo: "mrahman/gitflow",
    time: "yesterday",
    unread: false,
    avatar: "#EC4899",
  },
];

export const fileTree: {
  name: string;
  type: "dir" | "file";
  msg: string;
  time: string;
  tint: string;
  emoji: string;
}[] = [
  { name: ".github", type: "dir", msg: "ci: add linux matrix", time: "2 days ago", tint: "#6366F1", emoji: "⚙️" },
  { name: "lib", type: "dir", msg: "feat(core): offline queue", time: "32 minutes ago", tint: "#8B5CF6", emoji: "📚" },
  { name: "packages", type: "dir", msg: "chore: bump orbit_ui", time: "5 hours ago", tint: "#EC4899", emoji: "📦" },
  { name: "test", type: "dir", msg: "test: golden for file tree", time: "3 hours ago", tint: "#10B981", emoji: "🧪" },
  { name: ".gitignore", type: "file", msg: "chore: ignore .fvm", time: "last month", tint: "#9CA3AF", emoji: "🚫" },
  { name: "analysis_options.yaml", type: "file", msg: "lint: enable strict casts", time: "last month", tint: "#06B6D4", emoji: "🔎" },
  { name: "CHANGELOG.md", type: "file", msg: "release v2.1.0", time: "2 days ago", tint: "#F59E0B", emoji: "📝" },
  { name: "LICENSE", type: "file", msg: "Initial commit", time: "3 years ago", tint: "#6B7280", emoji: "⚖️" },
  { name: "README.md", type: "file", msg: "docs: add screenshots", time: "4 hours ago", tint: "#3B82F6", emoji: "📖" },
  { name: "pubspec.yaml", type: "file", msg: "chore: flutter 3.27", time: "2 days ago", tint: "#EF4444", emoji: "🧩" },
];

/* Light-theme syntax highlighted source */
export const sourceLines: { n: number; html: string }[] = [
  { n: 1, html: `<span class="tok-key">import</span> <span class="tok-str">'package:flutter/material.dart'</span>;` },
  { n: 2, html: `<span class="tok-key">import</span> <span class="tok-str">'package:gitflow/core/token_store.dart'</span>;` },
  { n: 3, html: `` },
  { n: 4, html: `<span class="tok-com">/// Refreshes the GitHub access token, guarded by a</span>` },
  { n: 5, html: `<span class="tok-com">/// single-flight mutex so concurrent callers share it.</span>` },
  { n: 6, html: `<span class="tok-key">class</span> <span class="tok-tag">TokenRefresher</span> {` },
  { n: 7, html: `  <span class="tok-key">final</span> TokenStore _store;` },
  { n: 8, html: `  <span class="tok-key">final</span> <span class="tok-tag">Future</span>&lt;<span class="tok-key">void</span>?&gt;? _inFlight;` },
  { n: 9, html: `` },
  { n: 10, html: `  <span class="tok-key">const</span> <span class="tok-fn">TokenRefresher</span>(<span class="tok-key">this</span>._store);` },
  { n: 11, html: `` },
  { n: 12, html: `  <span class="tok-tag">Future</span>&lt;<span class="tok-key">void</span>&gt; <span class="tok-fn">refresh</span>(<span class="tok-tag">String</span> scope) <span class="tok-key">async</span> {` },
  { n: 13, html: `    <span class="tok-key">final</span> cached = _store.<span class="tok-fn">read</span>(scope);` },
  { n: 14, html: `    <span class="tok-key">if</span> (cached != <span class="tok-key">null</span> &amp;&amp; !cached.<span class="tok-fn">isExpired</span>) {` },
  { n: 15, html: `      <span class="tok-key">return</span>; <span class="tok-com">// fast path, no network</span>` },
  { n: 16, html: `    }` },
  { n: 17, html: `` },
  { n: 18, html: `    <span class="tok-key">final</span> started = DateTime.<span class="tok-fn">now</span>();` },
  { n: 19, html: `    <span class="tok-key">final</span> token = <span class="tok-key">await</span> _store.<span class="tok-fn">fetch</span>(scope);` },
  { n: 20, html: `    _store.<span class="tok-fn">emit</span>(token, at: started);` },
  { n: 21, html: `  }` },
  { n: 22, html: `}` },
  { n: 23, html: `` },
  { n: 24, html: `<span class="tok-com">// TODO(mrahman): add exponential backoff (#1491)</span>` },
];

export const achievements = [
  { icon: "star", label: "Starstruck", sub: "10 starred repos", color: "#F59E0B", emoji: "🌟" },
  { icon: "pull", label: "Pull Shark", sub: "50 PRs merged", color: "#8B5CF6", emoji: "🦈" },
  { icon: "issueOpen", label: "Issue Hunter", sub: "100 closed", color: "#10B981", emoji: "🎯" },
  { icon: "bolt", label: "Quickdraw", sub: "Answered <5 min", color: "#3B82F6", emoji: "⚡" },
  { icon: "flame", label: "Streak", sub: "365 day streak", color: "#EF4444", emoji: "🔥" },
  { icon: "sparkle", label: "Arctic Vault", sub: "2024 contributor", color: "#06B6D4", emoji: "❄️" },
];
