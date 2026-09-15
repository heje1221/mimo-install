# mimo-install

Hiwalay na installer para sa **MiMoCode** — ang Xiaomi fork ng OpenCode para sa Termux (aarch64 / Xiaomi Pad 7).

## Quick Start (Fresh Termux)

**Isang command — deps + MiMoCode:**

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/heje1221/mimo-install/master/install-mimo.sh) --bootstrap
```

Restart shell: `source ~/.bashrc`

---

## Usage

```bash
bash install-mimo.sh                 # interactive menu
bash install-mimo.sh --bootstrap     # fresh Termux: deps + mimo
bash install-mimo.sh --mimo          # deps + mimo (default)
bash install-mimo.sh --deps          # dependencies lang (proot, glibc, glibc-runner)
bash install-mimo.sh --env           # API key reminder
```

| Flag | Description |
|------|-------------|
| `--bootstrap` | Fresh install — deps + MiMoCode |
| `--mimo` | Install deps + MiMoCode |
| `--deps` | Dependencies lang |
| `--env` | Show API key setup reminder |

---

## Paano I-Open ang MiMoCode

```bash
mimo                      # interactive chat
mimo "tanong mo"          # one-shot
```

Ang command `mimo` ay isang Wrapper sa `~/.local/bin/mimo` na dumadaan sa `proot -k 0x20000000 grun` — kailangan ito para ma-bypass ang Android seccomp `statx` block sa aarch64.

> **IMPORTANT:** Huwag i-export ang `~/.mimocode/bin` nang direkta sa PATH. Ang raw binary doon ay glibc-based at HINDI ko kayang i-execute ng Termux nang walang grun. Ang wrapper lang sa `~/.local/bin/` ang gumagana.

---

## PAALALA: HiwALAY sa OpenCode

- **OpenCode** installer = [termux-ai-setup](https://github.com/heje1221/termux-ai-setup)
- **MiMoCode** installer = itong repo (mimo-install)

Hindi na kasama ang MiMoCode sa one-liner ng termux-ai-setup.

---

## Requirements

- Termux (from **F-Droid**, not Play Store)
- Xiaomi Pad 7 / aarch64 device
- Internet connection

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `grun not found` | `pkg install glibc-runner` |
| `proot: command not found` | `pkg install proot` |
| `required file not found` kapag nag-run | Raw glibc binary na na-execute — gamitin ang wrapper (`~/.local/bin/mimo`), hindi ang `~/.mimocode/bin` |
| Permission denied | `chmod +x install-mimo.sh` |
| API key not working | Add to `~/.bashrc` then `source ~/.bashrc` |