# Flow X (`miatoll` Experimental Performance Lab)

**Flow X** adalah cabang eksperimental berorientasi performa ekstrem untuk Xiaomi Snapdragon 720G (`miatoll`: `curtana`, `joyeuse`, `excalibur`, `gram`), dibangun di atas fondasi terverifikasi [Flow-Kernel v1.2.4](https://github.com/bagaasadit/Flow-Kernel).

> **Peringatan Penting:**
> Repositori ini terpisah total dari **Flow-Kernel** (jalur stabil harian).
> **Flow X** dirancang untuk menguji batas silikon (`Full Brutal`), sehingga setiap eksperimen wajib didahului backup `boot`/`dtbo` + Recovery siap pakai.

---

### Arsitektur Final **`Flow X v1.0.1`** (Pemenang Stage 1–4 + Compaction Fix)
1. **Stage 1 — ARMv8.2 LSE Atomics & Hot-Path Stripping:**
   * `CONFIG_ARM64_LSE_ATOMICS=y` (dengan `DISABLE_LTO` pada `atomic_ll_sc.o`).
   * Pemangkasan overhead syscall/allocator (`AUDITSYSCALL=n`, `HARDEN_BRANCH_PREDICTOR=n`, `SLAB_FREELIST_HARDENED=n`, `SLAB_FREELIST_RANDOM=n`, `HARDENED_USERCOPY=n`, `BUG_ON_DATA_CORRUPTION=n`, `DEBUG_LIST=n`, `DEBUG_KERNEL=n`) sambil mempertahankan `AUDIT=y`, `FTRACE=y`, dan `BPF_EVENTS=y`.
2. **Stage 2 — Fixed `BORE 5.1.0` Scheduler:**
   * `CONFIG_SCHED_BORE=y` (5 perbaikan port termasuk `DEQUEUE_SLEEP`, `idle_policy`, `misfit_task_load >= 1`, dan toggle runtime `/proc/sys/kernel/sched_bore` `0/1`) + sysfs telemetri read-only `/sys/class/kgsl/kgsl-3d0/flowx_arc`.
3. **Stage 3 — Brutal MM & True Hot-Resume (`6/6`):**
   * `6 GiB` LZ4 `zram0` floor (`>= 5 GiB` RAM), MGLRU `vm_swappiness = 100` (`0..200`), `lru_gen/min_ttl_ms = 2000`, `watermark_scale_factor = 200` (`~112 MiB` runway `kswapd` + `WMARK_LOW ~31 MiB`), proactive compaction target `order-4 (64 KiB)` (`base 2000ms`, scan `4096/16384`, `proactiveness = 25`), dan `vfs_cache_pressure = 60`.
4. **Stage 4 — Adreno 618 GPU + DDR `2133 MHz` (`8137 MiB/s`):**
   * Menjaga clock aman silikon `750 MHz` (`800/825 MHz` dipangkas setelah uji batas GMU `bin 159`) dengan unlock bandwidth memori GPU **`DDR 2133 MHz` (`bus-max = 12`)** pada `750 / 650 MHz`.
5. **Anti-Placebo Rule:**
   * Seluruh perubahan diverifikasi memakai harness deterministik & FlowBench melawan baseline **`Flow-Kernel v1.2.4`**.
