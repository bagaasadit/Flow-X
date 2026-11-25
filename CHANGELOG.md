# Changelog

## [v0.4.0-s3] - 2026-11-25
### Added
- **Stage 3 (Brutal MM & True Hot-Resume Track):**
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
- Stripped hot-path syscall/allocator/debug overhead for maximal experimental throughput while preserving `CONFIG_AUDIT=y` (SELinux AVC), `CONFIG_FTRACE=y`, and `CONFIG_BPF_EVENTS=y`:
  - `# CONFIG_AUDITSYSCALL is not set`
  - `# CONFIG_HARDEN_BRANCH_PREDICTOR is not set` (also disables Spectre BHB mitigation)
  - `# CONFIG_SLAB_FREELIST_RANDOM is not set` & `# CONFIG_SLAB_FREELIST_HARDENED is not set`
  - `# CONFIG_HARDENED_USERCOPY is not set`
  - `# CONFIG_BUG_ON_DATA_CORRUPTION is not set` & `# CONFIG_DEBUG_LIST is not set`
  - `# CONFIG_DEBUG_KERNEL is not set`
- Bumped `CONFIG_LOCALVERSION` to `-Flow-X-v0.2.0-s1`.

## [v0.1.0] - 2026-11-25
### Added
- Bootstrapped **Flow X** as a completely isolated repository (`bagaasadit/Flow-X`) forked from verified **Flow-Kernel v1.2.4** (`32ed9386`).
- Rebranded kernel UTS (`-Flow-X-v0.1.0`), AnyKernel3 banner/installer/backup paths (`/sdcard/backup_*_pre_flowx.img`), `build.sh` output zip (`Flow-X-*.zip`), and `Flow X CI` (`workflow_dispatch` only).
- Relaxed CI scheduler config guardrails for `CONFIG_SCHED_BORE` and `CONFIG_SCHED_CASS` so Flow X experiments can enable and benchmark them cleanly.
