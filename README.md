# Flow X (`miatoll` Experimental Performance Lab)

**Flow X** adalah cabang eksperimental berorientasi performa ekstrem untuk Xiaomi Snapdragon 720G (`miatoll`: `curtana`, `joyeuse`, `excalibur`, `gram`), dibangun di atas fondasi terverifikasi [Flow-Kernel v1.2.4](https://github.com/bagaasadit/Flow-Kernel).

> **Peringatan Penting:**
> Repositori ini terpisah total dari **Flow-Kernel** (jalur stabil harian).
> **Flow X** dirancang untuk menguji batas silikon (`Full Brutal`), sehingga setiap eksperimen wajib didahului backup `boot`/`dtbo` + Recovery siap pakai.

---

### Peta Eksperimen (`Full Brutal` Lab)
1. **Tahap 1 — Microarchitecture, Scheduler & Zero-Overhead**
   * **ARMv8.2 LSE Hardware Atomics** (`CONFIG_ARM64_LSE_ATOMICS=y`) & tuning compiler Kryo 465 (`cortex-a76.cortex-a55`).
   * Eksperimen & A/B validasi scheduler **`BORE`** / **`CASS`** di atas tuning EAS/MM terverifikasi `v1.2.4` (`uclamp_rt=384`, `55/45`, MGLRU + `kcompactd0` proaktif).
   * Pemangkasan overhead kernel (`AUDITSYSCALL=n`, `FTRACE=n`, Spectre BHB/BP mitigation off, `BBRv2`).
2. **Tahap 2 — GPU Adreno 618 Silicon Limit**
   * Membuka OPP `800 / 825 MHz` + DDR bus `2133 MHz` + eksperimen undervolt bertahap.
3. **Anti-Placebo Rule**
   * Setiap perubahan diuji pakai harness deterministik (`/dev/input/event1`, `gfxinfo`, `vmstat`, `batt_ma`) melawan baseline **`Flow-Kernel v1.2.4`**.
