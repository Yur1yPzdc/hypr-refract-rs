# 💎 hypr-refract

> **Adaptive Contour Refraction for Hyprland**  
> A lightweight, ultra-fast Async Rust daemon that dynamically samples wallpaper pixels along window borders to create seamless, ambient edge-light gradients.

![Linux](https://img.shields.io/badge/OS-NixOS%20%7C%20Linux-blue?style=flat-square&logo=nixos)
![Hyprland](https://img.shields.io/badge/WM-Hyprland-00BFFF?style=flat-square)
![Rust](https://img.shields.io/badge/Language-Rust_2021-orange?style=flat-square&logo=rust)

---

## ✨ Overview

`hypr-refract` turns your static Hyprland window borders into **adaptive ambient glass edges**. 

Unlike traditional color tools (*Pywal*, *Wallust*) that generate a single static color palette for the whole desktop, `hypr-refract` tracks the exact coordinates `(X, Y, W, H)` of each window in real-time. It samples the underlying wallpaper along the window's perimeter and feeds localized gradients directly into Hyprland via UNIX sockets.

### Highlights

- **Zero Subprocess Overhead:** Communicates directly with Hyprland's `/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket.sock` using `tokio::net::UnixStream`. No `hyprctl` fork/exec calls on every frame.
- **Pixel-Accurate Sampling:** Samples perimeter pixels with local matrix convolution ($N \times N$ kernel) for smooth color transitions without aliasing.
- **240Hz High-Refresh Ready:** Pure CPU in-memory sampling ($1920 \times 1080$ RGBA buffer in RAM) with nanosecond latency.
- **Border Offset Aware:** Takes `gaps_out`, `gaps_in`, and `border_size` into account to read colors *exactly* where the border physically lays.

---

## 🛠️ Architecture

1. **Wallpaper Engine:** Caches current wallpaper into a raw RGBA memory buffer (`Arc<Vec<u8>>`).
2. **IPC Listener:** Asynchronously listens to `.socket2.sock` for `movewindow`, `resizewindow`, and `activewindow` events.
3. **Contour Convolution:** Computes $N$ perimeter sample points around the window edge, applies a local spatial blur/average.
4. **IPC Writer:** Pushes updated `active_bordercol` gradient strings to `.socket.sock`.

---

## 🚀 Quickstart

### Prerequisites

- **Hyprland** (with IPC enabled, default)
- **Rust Toolchain** (1.75+) or **NixOS** Flake environment

### Build & Run

```bash
# Clone repository
git clone [https://github.com/your-username/hypr-refract.git](https://github.com/your-username/hypr-refract.git)
cd hypr-refract

# Build and run with debug logs
cargo run
