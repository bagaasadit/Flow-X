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

* **BakaSU Manager APK:** [`BakaSU_v4.2.0-rc3_35252-arm64-v8a-release.apk`](https://github.com/bagaasadit/Flow-X/releases/download/v1.0.2/BakaSU_v4.2.0-rc3_35252-arm64-v8a-release.apk)

---

## Architecture & Engineering Highlights (`v1.0.2`)

1. **ARMv8.2 LSE Atomics & Hot-Path Optimization**
   * `CONFIG_ARM64_LSE_ATOMICS=y` with ThinLTO-safe `DISABLE_LTO` on `atomic_ll_sc.o`.
   * Trims redundant syscall/allocator instrumentation (`AUDITSYSCALL=n`, `HARDEN_BRANCH_PREDICTOR=n`, `SLAB_FREELIST_HARDENED=n`, `SLAB_FREELIST_RANDOM=n`, `HARDENED_USERCOPY=n`, `BUG_ON_DATA_CORRUPTION=n`, `DEBUG_LIST=n`, `DEBUG_KERNEL=n`) while retaining `AUDIT=y` (SELinux AVC), `FTRACE=y`, and `BPF_EVENTS=y`.
2. **`BORE 5.1.0` Scheduler with `PF_KSWAPD` Exemption**
   * `CONFIG_SCHED_BORE=y` with 5 port correctness fixes (`DEQUEUE_SLEEP` placement in `dequeue_task_fair()`, `idle_policy` guard, `burst_score` preservation across weight updates and fork inheritance, `misfit_task_load >= 1` clamp, and `0/1` sysctl bounds).
   * Exempts `PF_KSWAPD` (`kswapd0`) from BORE burst penalties so background memory reclaim retains its scheduling priority under heavy multitasking without starvation.
3. **Memory & Multitasking Architecture**
   * Pure-kernel `6 GiB` LZ4 `zram0` floor on `>= 5 GiB` RAM devices (`4 GiB` devices left untouched).
   * Unlocked MGLRU (`vm_swappiness = 100`, tunable `0..200`, `lru_gen/min_ttl_ms = 2000`) and deep async `kswapd` runway (`watermark_scale_factor = 200`, `~112 MiB` runway with lean `~31 MiB` `WMARK_LOW`).
   * Order-4 (`64 KiB`) budgeted proactive compaction (`COMPACT_PROACTIVE_BASE_MS = 2000ms`, scan budgets `4096 / 16384`, `proactiveness = 25`) and `vfs_cache_pressure = 60` to sustain contiguous allocations during scrolling and task switches.
4. **Adreno 618 GPU & `DDR 2133 MHz` Bandwidth**
   * Silicon-validated `750 MHz` maximum GPU clock paired with unlocked **`DDR 2133 MHz` (`bus-max = 12`, `8137 MiB/s`)** memory bandwidth on the `750 MHz` and `650 MHz` power levels (`speed-bin 159`).
   * Persistent read-only RPMh voltage-level telemetry exposed at `/sys/class/kgsl/kgsl-3d0/flowx_arc`.

---

## Runtime Controls

| Node | Values | Description |
|---|---|---|
| `/proc/sys/kernel/sched_bore` | `0` / `1` *(default: `1`)* | Toggle BORE 5.1.0 burst-oriented scheduling at runtime. |
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
