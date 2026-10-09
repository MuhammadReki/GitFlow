import type { ReactNode, CSSProperties } from "react";
import { cn } from "@/utils/cn";

export type FrameKind = "iphone" | "pixel";
export type ThemeKind = "dark" | "light";

const FRAMES = {
  iphone: { w: 393, h: 852, bezel: 11, radius: 54 },
  pixel: { w: 412, h: 915, bezel: 8, radius: 34 },
} as const;

/* ============================================================
   STATUS BARS
   ============================================================ */

function StatusBar({ os, theme }: { os: FrameKind; theme: ThemeKind }) {
  const fg = theme === "dark" ? "#E6EDF3" : "#111827";
  if (os === "iphone") {
    return (
      <div className="pointer-events-none absolute inset-x-0 top-0 z-50 flex h-[54px] items-end justify-between px-[30px] pb-[9px]">
        <span className="w-[62px] text-[15px] font-semibold tracking-tight" style={{ color: fg }}>
          9:41
        </span>
        <span className="flex items-center gap-[5px]" style={{ color: fg }}>
          {/* cellular */}
          <svg width="18" height="12" viewBox="0 0 18 12" fill="currentColor">
            <rect x="0" y="8" width="3" height="4" rx="1" />
            <rect x="5" y="5.5" width="3" height="6.5" rx="1" />
            <rect x="10" y="3" width="3" height="9" rx="1" />
            <rect x="15" y="0" width="3" height="12" rx="1" opacity=".35" />
          </svg>
          {/* wifi */}
          <svg width="16" height="12" viewBox="0 0 16 12" fill="currentColor">
            <path d="M8 10.8 6.2 8.9a2.6 2.6 0 0 1 3.6 0L8 10.8Z" />
            <path
              d="M3.9 6.6a5.9 5.9 0 0 1 8.2 0l-1.3 1.4a4.1 4.1 0 0 0-5.6 0L3.9 6.6Z"
              opacity=".95"
            />
            <path d="M1.3 4a9.6 9.6 0 0 1 13.4 0l-1.3 1.4a7.8 7.8 0 0 0-10.8 0L1.3 4Z" opacity=".9" />
          </svg>
          {/* battery */}
          <svg width="26" height="13" viewBox="0 0 26 13">
            <rect x=".5" y=".5" width="21" height="12" rx="3.5" fill="none" stroke="currentColor" opacity=".4" />
            <rect x="2" y="2" width="15" height="9" rx="2" fill="currentColor" />
            <path d="M23.5 4.5v4a2.2 2.2 0 0 0 0-4Z" fill="currentColor" opacity=".5" />
          </svg>
        </span>
      </div>
    );
  }
  return (
    <div className="pointer-events-none absolute inset-x-0 top-0 z-50 flex h-[38px] items-center justify-between px-6">
      <span className="text-[13px] font-medium" style={{ color: fg }}>
        9:41
      </span>
      <span className="flex items-center gap-1.5" style={{ color: fg }}>
        <svg width="15" height="12" viewBox="0 0 16 12" fill="currentColor">
          <path d="M8 10.8 6.2 8.9a2.6 2.6 0 0 1 3.6 0L8 10.8Z" />
          <path d="M3.9 6.6a5.9 5.9 0 0 1 8.2 0l-1.3 1.4a4.1 4.1 0 0 0-5.6 0L3.9 6.6Z" opacity=".95" />
          <path d="M1.3 4a9.6 9.6 0 0 1 13.4 0l-1.3 1.4a7.8 7.8 0 0 0-10.8 0L1.3 4Z" opacity=".9" />
        </svg>
        <svg width="22" height="11" viewBox="0 0 26 13">
          <rect x=".5" y=".5" width="21" height="12" rx="3.5" fill="none" stroke="currentColor" opacity=".4" />
          <rect x="2" y="2" width="15" height="9" rx="2" fill="currentColor" />
          <path d="M23.5 4.5v4a2.2 2.2 0 0 0 0-4Z" fill="currentColor" opacity=".5" />
        </svg>
      </span>
    </div>
  );
}

/* ============================================================
   DEVICE FRAME
   ============================================================ */

export function Phone({
  frame = "iphone",
  theme = "light",
  scale = 1,
  children,
  className,
  chassisStyle,
  label,
}: {
  frame?: FrameKind;
  theme?: ThemeKind;
  scale?: number;
  children: ReactNode;
  className?: string;
  chassisStyle?: CSSProperties;
  label?: string;
}) {
  const f = FRAMES[frame];
  const ow = f.w + f.bezel * 2;
  const oh = f.h + f.bezel * 2;
  const isIOS = frame === "iphone";

  return (
    <div
      className={cn("relative shrink-0", className)}
      style={{ width: ow * scale, height: oh * scale }}
    >
      <div
        style={{
          width: ow,
          height: oh,
          transform: `scale(${scale})`,
          transformOrigin: "top left",
        }}
      >
        <div
          className="device-shadow relative"
          style={{
            width: ow,
            height: oh,
            borderRadius: f.radius + f.bezel * 0.65,
            padding: f.bezel,
            background: isIOS
              ? "linear-gradient(150deg,#3a3f46 0%,#14171b 22%,#0b0d10 50%,#181c21 78%,#33383f 100%)"
              : "linear-gradient(150deg,#2a2d31 0%,#14161a 30%,#0d0f12 60%,#24272c 100%)",
            boxShadow: isIOS
              ? "inset 0 0 0 1.5px rgba(255,255,255,.14), inset 0 0 2px 2px rgba(255,255,255,.06), 0 0 0 1px rgba(0,0,0,.9), 0 40px 90px -25px rgba(0,0,0,.95), 0 0 120px -40px rgba(35,134,54,.35)"
              : "inset 0 0 0 1.5px rgba(255,255,255,.09), 0 0 0 1px rgba(0,0,0,.9), 0 40px 90px -25px rgba(0,0,0,.95)",
            ...chassisStyle,
          }}
        >
          {/* side buttons */}
          {isIOS ? (
            <>
              <span className="absolute -left-[3px] top-[112px] h-[30px] w-[3px] rounded-l-sm bg-gradient-to-b from-[#4a5058] to-[#22262b]" />
              <span className="absolute -left-[3px] top-[168px] h-[56px] w-[3px] rounded-l-sm bg-gradient-to-b from-[#4a5058] to-[#22262b]" />
              <span className="absolute -left-[3px] top-[234px] h-[56px] w-[3px] rounded-l-sm bg-gradient-to-b from-[#4a5058] to-[#22262b]" />
              <span className="absolute -right-[3px] top-[196px] h-[86px] w-[3px] rounded-r-sm bg-gradient-to-b from-[#4a5058] to-[#22262b]" />
            </>
          ) : (
            <>
              <span className="absolute -right-[3px] top-[168px] h-[64px] w-[3px] rounded-r-sm bg-gradient-to-b from-[#4a5058] to-[#22262b]" />
              <span className="absolute -left-[3px] top-[200px] h-[42px] w-[3px] rounded-l-sm bg-gradient-to-b from-[#4a5058] to-[#22262b]" />
            </>
          )}

          {/* screen */}
          <div
            className={cn(
              "relative overflow-hidden",
              theme === "dark" ? "gf-legacy-dark" : "gf-ui",
            )}
            style={{ width: f.w, height: f.h, borderRadius: f.radius, background: "var(--gf-canvas)" }}
          >
            {children}
            <StatusBar os={frame} theme={theme} />

            {/* dynamic island / punch hole */}
            {isIOS ? (
              <div className="pointer-events-none absolute left-1/2 top-[11px] z-50 h-[33px] w-[122px] -translate-x-1/2 rounded-full bg-black">
                <span className="absolute right-[11px] top-1/2 h-[9px] w-[9px] -translate-y-1/2 rounded-full bg-[#0d1520]">
                  <span className="absolute inset-[2px] rounded-full bg-[#1b2b3d]" />
                </span>
              </div>
            ) : (
              <div className="pointer-events-none absolute left-1/2 top-[11px] z-50 h-[13px] w-[13px] -translate-x-1/2 rounded-full bg-black ring-1 ring-white/10" />
            )}

            {/* screen glass sheen */}
            <div
              className="pointer-events-none absolute inset-0 z-[60]"
              style={{
                borderRadius: f.radius,
                background:
                  "linear-gradient(115deg, rgba(255,255,255,.055) 0%, rgba(255,255,255,0) 28%, rgba(255,255,255,0) 72%, rgba(255,255,255,.03) 100%)",
              }}
            />
            {/* home indicator */}
            {isIOS && (
              <div className="pointer-events-none absolute bottom-[7px] left-1/2 z-[61] h-[5px] w-[140px] -translate-x-1/2 rounded-full bg-ink/35" />
            )}
          </div>
        </div>
      </div>
      {label && (
        <div className="absolute -bottom-7 left-1/2 -translate-x-1/2 whitespace-nowrap font-mono text-[11px] text-white/35">
          {label}
        </div>
      )}
    </div>
  );
}

/* ============================================================
   SCROLLABLE SCREEN BODY
   ============================================================ */

export function Screen({
  children,
  className,
  padTop = 54,
  padBottom = 0,
  bg,
}: {
  children: ReactNode;
  className?: string;
  padTop?: number;
  padBottom?: number;
  bg?: string;
}) {
  return (
    <div
      className={cn("gf-scroll absolute inset-0 overflow-y-auto", className)}
      style={{
        paddingTop: padTop,
        paddingBottom: padBottom,
        background: bg ?? "var(--gf-canvas)",
      }}
    >
      {children}
    </div>
  );
}
