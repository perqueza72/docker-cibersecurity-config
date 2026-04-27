# AI Agent Sandbox

A Docker-based sandbox for running AI CLI tools (`llxprt` and `claude`) in an isolated, secure environment. It protects sensitive files from the AI agent while giving it access to your project.

## Prerequisites

- Docker and Docker Compose v2
- Bash
- `setfacl` (package `acl` on Debian/Ubuntu)

## First-time Setup

`.llxprt-config/` is not tracked in git — it lives only on the host machine and is mounted into the container as a volume. You need to create it once from the provided example:

```bash
cp -r .llxprt-config.example .llxprt-config
```

Then edit `.llxprt-config/profiles/deepseek.json` and replace `YOUR_DEEPSEEK_API_KEY` with your actual key.

For other providers, add a profile JSON under `.llxprt-config/profiles/` and update `settings.json` to set it as `defaultProfile`.

## Project Structure

```
.
├── Dockerfile                  # Container image (Node 22 via nvm, llxprt, claude)
├── docker-compose.yml          # Container config (read-only FS, host network, volumes)
├── llxprt-terminal-script.sh   # Entry point — run this to start a session
├── start-llxprt.sh             # Core setup and launch script
├── set_private_files.sh        # Protects .env files via ACLs
├── .llxprt-config/             # llxprt profiles, settings, prompts (mounted as /.llxprt)
└── .claude-config/             # Claude Code settings and OAuth credentials (mounted as ~/.claude)
```

---

## Scripts

### `llxprt-terminal-script.sh` — main entry point

```
Usage: ./llxprt-terminal-script.sh [project-folder] [-m <mode>]
```

| Argument | Default | Description |
|---|---|---|
| `project-folder` | current directory (`$PWD`) | Path to the project the AI agent will work on |
| `-m llxprt` | ✓ default | Start session with `llxprt --yolo` using the deepseek profile |
| `-m claude` | | Start session with `claude --dangerously-skip-permissions` with caveman mode |

**Examples:**

```bash
# llxprt session on current directory (default)
./llxprt-terminal-script.sh

# llxprt session on a specific project
./llxprt-terminal-script.sh ~/projects/my-app

# claude session on a specific project
./llxprt-terminal-script.sh ~/projects/my-app -m claude
```

---

### `start-llxprt.sh` — core launch script (called by llxprt-terminal-script.sh)

```
Usage: ./start-llxprt.sh <project-folder> <username> <group> [-m <mode>]
```

| Argument | Description |
|---|---|
| `project-folder` | Path to the project directory to mount into the container |
| `username` | OS user the container runs as (default: `ai_user`) |
| `group` | OS group for shared file access (default: `ai_group`) |
| `-m llxprt` | Run `llxprt --yolo` inside the container (default) |
| `-m claude` | Run `claude --dangerously-skip-permissions` inside the container |

What it does on each run:
1. Creates `ai_user` / `ai_group` if they don't exist
2. Adds your user (`$USER`) to `ai_group` for access to files the agent creates
3. Sets ownership of `.llxprt-config` and `.claude-config` to the container user/group
4. Runs `set_private_files.sh` to apply ACLs on the project folder
5. Exports `CONTAINER_CMD` and launches Docker Compose
6. Waits for the container to be ready, then attaches

---

### `set_private_files.sh` — file permission manager (called by start-llxprt.sh)

```
Usage: ./set_private_files.sh <project-folder> <group-id>
```

| Argument | Description |
|---|---|
| `project-folder` | Project directory to apply ACLs to |
| `group-id` | GID of the container group (`ai_group`) |

What it does:
- Grants the container group `rwx` on all files in the project (current and new files via default ACLs)
- Strips group access (`---`) from any `.env*` file (except `.env.sample`) to protect secrets

---

## Modes

### llxprt (default)

Runs `llxprt --yolo` inside the container. Uses the `deepseek` profile by default (configured in `.llxprt-config/settings.json`). `--yolo` skips confirmation prompts.

AI provider profiles are stored in `.llxprt-config/profiles/`.

### claude

Runs `claude --dangerously-skip-permissions` inside the container. The `--dangerously-skip-permissions` flag allows the agent to run without asking for confirmation on file and shell operations.

**First run:** Claude will prompt for OAuth login in the terminal. Credentials are saved to `.claude-config/` and reused on subsequent runs.

Caveman mode is enabled globally via `.claude-config/CLAUDE.md`.

---

## Security

- **Read-only container filesystem** — only `/tmp` and mounted volumes are writable
- **Non-root execution** — container runs as `ai_user:ai_group`
- **`.env` file protection** — ACLs remove group access from `.env*` files; the agent cannot read secrets
- **Volume isolation** — the agent only sees the mounted project folder and its own config dirs
- **Host network** — required for internet access and connecting to local services (e.g. LocalStack on port 4566)

---

## Troubleshooting

**Permission denied on files created by the agent:**
Re-login or run `newgrp ai_group` — group membership takes effect at session start.

**Container fails to start:**
```bash
docker logs ai-agents-container
docker compose --file ~/workspace/docker-cibersecurity-config/docker-compose.yml logs
```

**Container already running from a previous session:**
The script uses `--force-recreate`, so it will replace the existing container automatically.
