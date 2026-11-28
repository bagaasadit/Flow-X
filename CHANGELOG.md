# Changelog

## [v1.0.4] - 2026-11-28
### Fixed
- **Deep Sleep `s2idle` ADSP Non-Wakeup Sensor Wake Storm (`kernel/power/suspend.c`):**
  - Restored `qcom_smem_state_update_bits(smem_state, AWAKE_BIT, 0)` before `enter_state()` (guarded with `!IS_ERR_OR_NULL(smem_state)` on both suspend entry and resume exit), aligning with Qualcomm KBA-180725024109 and `LineageOS sm6250`.
  - Fixes an inherited upstream merge mistake where `AWAKE_BIT` remained permanently asserted `1`, causing ADSP/SEE to keep streaming non-wakeup sensors (`lsm6ds3c` accelerometer/gyroscope at `~10.5 Hz`) over `IRQ 500 (glink-native)` during `s2idle` and collapsing deep sleep from `~95%` down to `23–31%`.
- **CI Guard (`.github/workflows/build-kernel.yml`):**
  - Added config assertion for `CONFIG_QCOM_SMP2P_SLEEPSTATE=y` and source guard ensuring `AWAKE_BIT` clear remains active in `kernel/power/suspend.c`.

## [v1.0.3] - 2026-11-28
### Fixed
- **Adreno 618 GPU Power & Idle Residency (`governor_msm_adreno_tz.c`, `atoll.dtsi`):**
  - Fixed the `msm-adreno-tz` `MIN_BUSY` idle-latch bug in `tz_get_target_freq()` so ultra-light `<2%` (`<1 ms` busy across `>=50 ms`) screen-on periods cleanly reset TZ DCVS and drop back to `267 MHz` while leaving scrolling and heavy 3D loads untouched.
  - Deleted `qcom,no-nap` from `&msm_gpu` in `atoll.dtsi` (`force_no_nap=0` at boot) so KGSL enters `NAP` power collapse cleanly between light frames.
  - Lowered `750 MHz` (`TURBO`) default `qcom,bus-freq` from `12` (`DDR 2133 MHz`) to `11` (`DDR 1804 MHz`) while preserving `qcom,bus-max = <12>` so `gpubw_mon` unlocks `DDR 2133 MHz` strictly on demand under heavy gaming bandwidth demand.
- **Deep Sleep `s2idle` Charge-Pump Resume Loop (`smb1398-charger.c`):**
  - Tracked deferred `in_suspend` votes via `resume_rerun_needed` and guarded `smb1398_resume()` and `power_supply_changed(div2_cp_master_psy)` so `charge_pump_master` no longer spams vote reruns and `power_supply` uevents on brief `s2idle` wakeups when no USB charger or switcher is active.
- **Banking & Allocator Security Restoration (`miatoll_defconfig`):**
  - Restored `CONFIG_AUDITSYSCALL=y`, `CONFIG_SLAB_FREELIST_HARDENED=y`, `CONFIG_SLAB_FREELIST_RANDOM=y`, `CONFIG_HARDENED_USERCOPY=y`, `CONFIG_HARDEN_BRANCH_PREDICTOR=y`, `CONFIG_BUG_ON_DATA_CORRUPTION=y` (selecting `DEBUG_LIST`), and `CONFIG_DEBUG_KERNEL=y` while keeping `CONFIG_ARM64_LSE_ATOMICS=y` active.

### Changed
- **Scheduler Defaults (`kernel/sched/fair.c`, `kernel/sched/autogroup.c`):**
  - Set `sched_bore = 0` (`CONFIG_SCHED_BORE=y` retained for runtime toggle), `sysctl_sched_autogroup_enabled = 0`, and WALT migration thresholds to **`95% / 85%`** (`1077 / 1204`) after A/B benchmarks showed higher multi-core throughput and lower Gold/idle residency with zero UI scroll regression (keeping `sched_util_clamp_min_rt_default = 384` intact).

## [v1.0.2] - 2026-11-27
### Changed
- **Scheduler (`BORE 5.1.0`)**: Exempt `PF_KSWAPD` (`kswapd0`) from BORE burst penalty (`update_burst_score()`, `enqueue_task_fair()`, and `set_load_weight()`) so background page reclaim retains its configured scheduling priority instead of being pushed down to `nice +19`.
- **Runtime A/B Toggle**: Added `/proc/sys/kernel/sched_bore_exempt_kswapd` (`0/1`, default `1`) to allow same-boot A/B validation of `kswapd` BORE exemption.

## [v1.0.1] - 2026-11-27
### Fixed
- **Order-4 Proactive Compaction (`mm/compaction.c`):** Fixed `PROACTIVE_COMPACT_ORDER` from `pageblock_order` (`order-10` / `4 MiB` on 4K ARM64) down to **`4`** (`64 KiB`), with `sysctl_compaction_proactiveness = 25`, `COMPACT_PROACTIVE_BASE_MS = 2000U`, and scan budgets `4096 / 16384`. Keeps Buddy `order-3` (`32 KiB`) free blocks available during fast-scrolling and Quickstep Recents transitions without wasting `kcompactd` cycles chasing unreachable `4 MiB` blocks.

### Preserved (Validated on Live Telemetry)
- Kept **`sched_util_clamp_min_rt_default = 384`**, **`watermark_scale_factor = 200`**, and **`vm_swappiness = 100`** untouched after live A/B/C testing confirmed lowering them regressed `SurfaceFlinger`/Launcher smoothness and triggered direct reclaim stalls.
- Kept all `v1.0.0` winners (`ARMv8.2 LSE`, `BORE 5.1.0`, `6 GiB zram0`, `MGLRU`, `Adreno 618 750 MHz + DDR 2133 MHz`).

## [v1.0.0] - 2026-11-25
### Added & Locked (All Verified Winners from Stages 1–4)
- **Stage 1 (Arch & Stripping):** Hardware ARMv8.2 LSE atomics (`CONFIG_ARM64_LSE_ATOMICS=y`, ThinLTO-safe `DISABLE_LTO` on `atomic_ll_sc.o`) + hotpath overhead stripping (`AUDITSYSCALL=n`, `HARDEN_BRANCH_PREDICTOR=n`, `SLAB_FREELIST_HARDENED=n`, `SLAB_FREELIST_RANDOM=n`, `HARDENED_USERCOPY=n`, `BUG_ON_DATA_CORRUPTION=n`, `DEBUG_LIST=n`, `DEBUG_KERNEL=n`) while retaining `AUDIT=y`, `FTRACE=y`, and `BPF_EVENTS=y`.
- **Stage 2 (Scheduler & Hardware Telemetry):** Fixed `BORE 5.1.0` scheduler (`CONFIG_SCHED_BORE=y`, 5 port fixes, runtime `0/1` toggle via `/proc/sys/kernel/sched_bore`) + persistent read-only `/sys/class/kgsl/kgsl-3d0/flowx_arc` sysfs attribute.
- **Stage 3 (Memory & Multitasking Architecture):** Pure-kernel `6 GiB` LZ4 `zram0` floor (`>= 5 GiB` RAM), unlocked MGLRU `vm_swappiness = 100` (`0..200`), `lru_gen/min_ttl_ms = 2000`, `watermark_scale_factor = 200` (`~112 MiB` async `kswapd` runway with lean `~31 MiB` `WMARK_LOW`), faster budgeted proactive compaction (`base 1000ms`, `8192/32768` scan budget, `proactiveness = 40`), and `vfs_cache_pressure = 60`.
- **Stage 4 (GPU & DDR 2133 MHz):** Locked stock-safe `750 MHz` Adreno 618 clock + unlocked **`DDR 2133 MHz` (`bus-max = 12`, `8137 MiB/s`)** on `750 / 650 MHz` (`speed-bin 159`).

### Changed / Removed
- Pruned silicon/GMU-rejected `800 / 825 MHz` GPU overclock from `qcom,gpu-pwrlevels-5` (`bin 159`) after live hardware probe confirmed GMU/GX faults at `>= 800 MHz`.
- Removed temporary `/sys/class/kgsl/kgsl-3d0/flowx_oc_unlock` safe-boot probe gate from `drivers/gpu/msm/kgsl_pwrctrl.c` while keeping `flowx_arc` intact.
- Synced `AnyKernel3/banner`, `AnyKernel3/anykernel.sh`, `README.md`, and `CONFIG_LOCALVERSION` to **`-Flow-X-v1.0.0`**.

## [v0.5.1-s4] - 2026-11-25
### Fixed / Changed
- **Stage 4 Safe-Boot Probe (`800 MHz` `TURBO` + `DDR 2133 MHz` + Anti-Bootloop Gate):**
  - Dropped `825 MHz` (`TURBO_L1`, `gfx.lvl 416` > `mx.lvl 384`) and duplicate `750 MHz` (`384` VLVL) after `v0.5.0-s4` white-screen lockscreen reset; aligned `qcom,gpu-pwrlevels-5` (`speed-bin 159`) cleanly to Qualcomm's 7-level `qcom,gpu-pwrlevels-2` layout (`800 / 650 / 565 / 430 / 355 / 267 / XO`, matching `/vendor/etc/powerhint.json` `0..5` indices) with **`DDR 2133 MHz` (`bus-max=12`, `8137 MiB/s`)** unlocked on `800 / 650 MHz`.
  - Added `/sys/class/kgsl/kgsl-3d0/flowx_oc_unlock` (`0` = Safe-Boot cap at `pwrlevel 1 = 650 MHz` in `_adjust_pwrlevel()`, immune to PowerHAL `max_pwrlevel=0` overrides; `1` = unlock `800 MHz` at runtime for stress testing).
- Bumped `CONFIG_LOCALVERSION` to `-Flow-X-v0.5.1-s4`.

## [v0.5.0-s4] - 2026-11-25
### Added
- **Stage 4 (Adreno 618 GPU Overclock + DDR 2133 MHz Unlock):**
  - **Adreno 618 `800 / 825 MHz` (`arch/arm64/boot/dts/qcom/atoll.dtsi`):** Unlocked `825 MHz` (`TURBO_L1`, RPMh ARC `gfx.lvl = 416` verified via `flowx_arc`) and `800 MHz` (`TURBO`, `gfx.lvl = 384`) in `qcom,gpu-pwrlevels-5` (`speed-bin 159`), while retaining the stock `750 MHz` step for smooth thermal/devfreq step-down and single-boot `750 / 800 / 825 MHz` A/B/C testing. Updated `qcom,initial-pwrlevel = <7>` (`267 MHz`) and `qcom,ca-target-pwrlevel = <6>` (`355 MHz`) for the 9-level table (`8 active + XO <= pri_rail->num = 9`), keeping `atoll-thermal.dtsi` relative cooling floor indices (`650 / 565 / 430 MHz`) intact.
  - **DDR `2133 MHz` (`bus-max=12`, `8137 MiB/s`) Unlock:** Raised `qcom,bus-freq = <12>` and `qcom,bus-max = <12>` on `825 / 800 / 750 MHz` levels (and `bus-max = <12>` on `650 MHz`), lifting the stock `1804 MHz` (`6881 MiB/s`) GPU memory bandwidth ceiling.
- Bumped `CONFIG_LOCALVERSION` to `-Flow-X-v0.5.0-s4`.

## [v0.4.0-s3] - 2026-11-25
### Added
- **Stage 3 (Memory & Multitasking Architecture):**
  - **6 GiB `zram0` floor (`drivers/block/zram/zram_drv.c`):** Raised pure-kernel `zram0` `disksize_store` floor from `4 GiB` to `6 GiB` on `>= 5 GiB` RAM `miatoll` devices (zero physical RAM consumed until swapped; eliminates `>86%` zRAM saturation & early `lmkd` swap-low kills while leaving `4 GiB` devices untouched).
  - **Unlocked MGLRU `vm_swappiness = 100` (`mm/vmscan.c`, `kernel/sysctl.c`):** Raised `vm_swappiness` default from `60` to `100` and lifted `MAX_VM_SWAPPINESS` clamp from `60` to `200`, allowing vendor post-boot (`100`) and full `0..200` runtime MGLRU A/B tuning while protecting active `.odex`/`.so` file pages from excessive refaults.
  - **MGLRU working-set TTL (`mm/vmscan.c`):** Increased `lru_gen_min_ttl_ms` default from `1000` to `2000` ms (with `sc->priority <= DEF_PRIORITY - 3` burst bypass preserved and runtime-tunable via `/sys/kernel/mm/lru_gen/min_ttl_ms`).
  - **Deeper async `kswapd` runway (`mm/page_alloc.c`):** Raised default `watermark_scale_factor` to `200` (`~112 MB` `LOW..HIGH` runway), intercepted only vendor post-boot's disable write (`< 10`) while allowing `10..1000` runtime A/B writes, and tightened `WMARK_LOW` formula (`min + low * 5/10 + min >> 4`, `~31 MB`) so `lmkd` does not kill early.
  - **Faster budgeted proactive compaction (`mm/compaction.c`):** Set `COMPACT_PROACTIVE_BASE_MS = 1000` ms (`1s..32s` backoff), doubled scan budgets (`8192` migrate / `32768` free pages), and raised `sysctl_compaction_proactiveness = 40` while keeping `PROACTIVE_COMPACT_ORDER = pageblock_order`, `GFP_HIGHUSER_MOVABLE`, zero `psi_memstall`, and freezable Deep Sleep behavior intact.
  - **Hot VFS cache retention (`fs/dcache.c`):** Lowered default `sysctl_vfs_cache_pressure` from `100` to `60`.
- Bumped `CONFIG_LOCALVERSION` to `-Flow-X-v0.4.0-s3`.

## [v0.3.0-s2] - 2026-11-25
### Added
- **Stage 2 (BORE 5.1.0 Scheduler + Persistent `flowx_arc` Sysfs):**
  - Enabled **`CONFIG_SCHED_BORE=y`** (BORE 5.1.0) with all 5 port bug fixes and clean runtime toggle support via `/proc/sys/kernel/sched_bore` (`0` = stock CFS weight behavior, `1` = BORE active):
    - Moved misplaced `DEQUEUE_SLEEP` `restart_burst()` hook out of `enqueue_task_fair()` into `dequeue_task_fair()`.
    - Added `idle_policy()` guard in `update_burst_score()` and runtime weight restoration when `sched_bore == 0`.
    - Preserved `burst_score` in `set_load_weight()` and applied inherited child burst score/weight in `sched_post_fork_bore()`.
    - Clamped `rq->misfit_task_load >= 1` in `update_misfit_status()` so heavy tasks on Silver cores cannot stall WALT/EAS upmigration under BORE + 8ms PELT.
    - Enabled runtime `0/1` range (`.extra1 = &zero`) for `sched_bore` sysctl.
  - Exposed persistent read-only `/sys/class/kgsl/kgsl-3d0/flowx_arc` sysfs attribute (`flowx_arc_read`) showing RPMh cmd-db `gfx.lvl`, `cx.lvl`, and `mx.lvl` VLVL tables cleanly without `dmesg` ring-buffer wrap loss.
- Bumped `CONFIG_LOCALVERSION` to `-Flow-X-v0.3.0-s2`.

## [v0.2.0-s1] - 2026-11-25
### Added
- **Stage 1 (Arch & Stripping):**
  - Enabled hardware ARMv8.1/8.2 LSE atomic instructions (`CONFIG_ARM64_LSE_ATOMICS=y`) with `CFLAGS_atomic_ll_sc.o += $(DISABLE_LTO)` for safe ThinLTO out-of-line `__ll_sc_*` ABI handling.
  - Added read-only `flowx_arc` boot probe in `drivers/gpu/msm/kgsl_gmu.c` (`rpmh_arc_cmds`) to inspect exact `gfx.lvl`, `cx.lvl`, and `mx.lvl` RPMh cmd-db VLVL corners in `dmesg`.
  - Added Flow X Stage 1 config guardrails in `.github/workflows/build-kernel.yml`.

### Changed
- Stripped hot-path syscall/allocator/debug overhead for sustained hot-path throughput while preserving `CONFIG_AUDIT=y` (SELinux AVC), `CONFIG_FTRACE=y`, and `CONFIG_BPF_EVENTS=y`:
  - `# CONFIG_AUDITSYSCALL is not set`
  - `# CONFIG_HARDEN_BRANCH_PREDICTOR is not set` (also disables Spectre BHB mitigation)
  - `# CONFIG_SLAB_FREELIST_RANDOM is not set` & `# CONFIG_SLAB_FREELIST_HARDENED is not set`
  - `# CONFIG_HARDENED_USERCOPY is not set`
  - `# CONFIG_BUG_ON_DATA_CORRUPTION is not set` & `# CONFIG_DEBUG_LIST is not set`
  - `# CONFIG_DEBUG_KERNEL is not set`
- Bumped `CONFIG_LOCALVERSION` to `-Flow-X-v0.2.0-s1`.

## [v0.1.0] - 2026-11-25
### Added
- Bootstrapped **Flow X** as a standalone repository (`bagaasadit/Flow-X`).
- Rebranded kernel UTS (`-Flow-X-v0.1.0`), AnyKernel3 banner/installer/backup paths (`/sdcard/backup_*_pre_flowx.img`), `build.sh` output zip (`Flow-X-*.zip`), and `Flow X CI` (`workflow_dispatch` only).
- Relaxed CI scheduler config guardrails for `CONFIG_SCHED_BORE` and `CONFIG_SCHED_CASS` so Flow X can enable and validate them cleanly.
