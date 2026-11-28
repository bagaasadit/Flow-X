# Flow X — Custom Linux Kernel for Xiaomi `miatoll` (SM7125)

Precision-tuned Linux `4.14.357` kernel (`5.15.207` UTS) for Xiaomi Snapdragon 720G (`miatoll`: `curtana`, `joyeuse`, `excalibur`, `gram`), engineered for **sustained responsiveness, thermal stability, and daily efficiency**.

---

## Supported Devices & Compatibility

| Item | Details |
|---|---|
| **Platform** | Qualcomm SM7125 (`atoll` / Snapdragon 720G) |
| **Devices** | `curtana`, `joyeuse`, `excalibur`, `gram` (`miatoll`) |
| **Android Versions** | Android 11 – Android 17 (AOSP / Custom ROMs) |
| **Kernel Base** | Linux `4.14.357` (`5.15.207` UTS) |
| **Root & Hiding** | **BakaSU** (`KernelSU` + `SUSFS` + `NoMount`) |

* **BakaSU Manager APK:** [`BakaSU_v4.2.0-rc3_35252-arm64-v8a-release.apk`](https://github.com/bagaasadit/Flow-X/releases/download/v1.0.3/BakaSU_v4.2.0-rc3_35252-arm64-v8a-release.apk)

---

## Architecture & Engineering Highlights (`v1.0.3`)

1. **ARMv8.2 LSE Atomics & Hardened Runtime Integrity**
   * `CONFIG_ARM64_LSE_ATOMICS=y` with ThinLTO-safe `DISABLE_LTO` on `atomic_ll_sc.o`.
   * Retains full upstream security and audit hardening (`AUDITSYSCALL=y`, `HARDEN_BRANCH_PREDICTOR=y`, `SLAB_FREELIST_HARDENED=y`, `SLAB_FREELIST_RANDOM=y`, `HARDENED_USERCOPY=y`, `BUG_ON_DATA_CORRUPTION=y`, `DEBUG_KERNEL=y`) alongside `AUDIT=y`, `FTRACE=y`, and `BPF_EVENTS=y`.
2. **A/B-Validated WALT Scheduler Defaults (`95/85`, Toggleable `BORE 5.1.0`)**
   * Defaults to `sched_bore = 0`, `sched_autogroup_enabled = 0`, and WALT up/down-migration thresholds of **`95% / 85%`** (`sched_util_clamp_min_rt_default = 384` preserved for UI/RT smoothness).
   * `BORE 5.1.0` (`PF_KSWAPD` exempted) stays compiled in and runtime-toggleable via `/proc/sys/kernel/sched_bore`.
3. **Memory & Multitasking Architecture**
   * Pure-kernel `6 GiB` LZ4 `zram0` floor on `>= 5 GiB` RAM devices (`4 GiB` devices left untouched).
   * Unlocked MGLRU (`vm_swappiness = 100`, tunable `0..200`, `lru_gen/min_ttl_ms = 2000`) and deep async `kswapd` runway (`watermark_scale_factor = 200`, `~112 MiB` runway with lean `~31 MiB` `WMARK_LOW`).
   * Order-4 (`64 KiB`) budgeted proactive compaction (`COMPACT_PROACTIVE_BASE_MS = 2000ms`, scan budgets `4096 / 16384`, `proactiveness = 25`) and `vfs_cache_pressure = 60` to sustain contiguous allocations during scrolling and task switches.
4. **Adreno 618 GPU Power Collapse & On-Demand `DDR 2133 MHz`**
   * Fixes the `msm-adreno-tz` `MIN_BUSY` idle-latch bug (`>=50 ms` `<2%` load steps cleanly back down to `267 MHz`) and removes `qcom,no-nap` (`force_no_nap = 0`) so the GPU rests at low clock/NAP state between UI frames.
   * Sets `750 MHz` default bus vote to `11` (`DDR 1804 MHz`) while keeping `bus-max = 12` (`DDR 2133 MHz`, `8137 MiB/s`) unlocked on demand for heavy gaming loads.
   * Persistent read-only RPMh voltage-level telemetry exposed at `/sys/class/kgsl/kgsl-3d0/flowx_arc`.
5. **Deep Sleep `s2idle` Guard (`smb1398`)**
   * Guards `smb1398_resume()` and `charge_pump_master` uevent emissions when USB/switcher is inactive, preventing spurious wake storms after unplugging fast chargers.

---

## Runtime Controls

| Node | Values | Description |
|---|---|---|
| `/proc/sys/kernel/sched_bore` | `0` / `1` *(default: `0`)* | Toggle BORE 5.1.0 burst-oriented scheduling at runtime. |
| `/proc/sys/kernel/sched_bore_exempt_kswapd` | `0` / `1` *(default: `1`)* | Toggle `PF_KSWAPD` (`kswapd0`) burst-penalty exemption. |
| `/sys/class/kgsl/kgsl-3d0/flowx_arc` | Read-only | Inspect RPMh `gfx.lvl`, `cx.lvl`, and `mx.lvl` VLVL tables. |

---

## Verification Methodology

Every subsystem change in **Flow X** is validated using controlled same-boot A/B and balanced ABBA testing paired with continuous real-world device telemetry (`FlowMonitor` / `FlowBench`). Tweaks that cannot demonstrate measurable improvements or introduce thermal/reclaim regressions are rejected or reverted.

---

## Installation & Module Compatibility

1. Reboot to Recovery (OrangeFox / TWRP).
2. *(Recommended)* Create manual backups of `boot` and `dtbo` — AnyKernel3 also attempts automatic pre-flash backups to `/sdcard/backup_boot_pre_flowx.img` and `/sdcard/backup_dtbo_pre_flowx.img` when `/data` is mounted.
3. Flash `Flow-X-<version>-miatoll-BakaSU.zip` and reboot.

> **Module Compatibility Notice:**
> **Do NOT stack third-party kernel or system tuning modules** (scheduler, CPU/GPU, memory, or sleep tweak scripts and all-in-one tweak packs) on top of Flow X. Overriding validated scheduler, memory, or thermal parameters frequently causes lockscreen freezes, excessive heat, or battery drain.

---

## Disclaimer

Custom kernels modify low-level hardware scheduling, power, and memory behavior. Keep verified `boot` and `dtbo` backups ready in Recovery and flash at your own risk.
