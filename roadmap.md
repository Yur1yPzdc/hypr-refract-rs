# 🗺️ hypr-refract Roadmap & Development Plan

Development is broken down into low-pressure, incremental micro-phases (MVP 0.1 to 1.0).

---

## 🟢 Phase 1: IPC Foundations & Direct Socket Communication (MVP 0.1) — *[IN PROGRESS]*
- [x] Initialize Rust project with `tokio`, `image`, `serde`.
- [x] Connect directly to Hyprland's `.socket.sock` via `tokio::net::UnixStream`.
- [ ] Connect to `.socket2.sock` and subscribe to live window events (`movewindow`, `resizewindow`, `activewindow`).
- [ ] Parse window addresses `0x...` and coordinates `[X, Y, W, H]` from socket stream events.

---

## 🟡 Phase 2: In-Memory Wallpaper Engine & Sampling (MVP 0.2)
- [ ] Implement wallpaper loader (read current wallpaper file or `awww` output into RAM buffer).
- [ ] Create `geometry.rs`: Generate $N$ sampling coordinates along perimeter given $(X, Y, W, H)$ and `border_size`.
- [ ] Create `image_proc.rs`: Extract RGBA values for sample points.
- [ ] Implement $N \times N$ local matrix convolution (spatial averaging) for noise-free colors.

---

## 🟠 Phase 3: Live Refraction Loop (MVP 0.3)
- [ ] Construct Hyprland gradient string: `"rgba(...) rgba(...) ... 45deg"`.
- [ ] Send `setprop address:0x... active_bordercol ...` directly through `.socket.sock`.
- [ ] Test real-time border updates while dragging/resizing windows.
- [ ] Profile CPU usage during high-frequency window drags (target: < 0.5% CPU load).

---

## 🔵 Phase 4: Polish & Advanced Aesthetics (v0.4 - 1.0)
- [ ] Add support for inner-edge darkening (Bevel / Shadow effect against dark application windows).
- [ ] Automatic wallpaper reload detection (listen to `awww` / `swww` events or file watcher).
- [ ] Add NixOS Flake (`flake.nix`) and Home-Manager module for seamless installation.
- [ ] Add TOML config parser (`~/.config/hypr/hypr-refract.toml`).

---

## 🧪 Testing Checklist
- [ ] Single monitor 1080p setup.
- [ ] Multi-monitor support (offset calculations per display output).
- [ ] Fullscreen window handling (skip calculation to save CPU).
