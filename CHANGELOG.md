# Changelog

## [v0.1.0] - 2026-11-25
### Added
- Bootstrapped **Flow X** as a completely isolated repository (`bagaasadit/Flow-X`) forked from verified **Flow-Kernel v1.2.4** (`32ed9386`).
- Rebranded kernel UTS (`-Flow-X-v0.1.0`), AnyKernel3 banner/installer/backup paths (`/sdcard/backup_*_pre_flowx.img`), `build.sh` output zip (`Flow-X-*.zip`), and `Flow X CI` (`workflow_dispatch` only).
- Relaxed CI scheduler config guardrails for `CONFIG_SCHED_BORE` and `CONFIG_SCHED_CASS` so Flow X experiments can enable and benchmark them cleanly.
