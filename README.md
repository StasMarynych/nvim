# nvim config

Personal Neovim configuration based on [LazyVim](https://lazyvim.github.io/).

## Setup

### Prerequisites

```bash
# Core
brew install neovim

# iOS development (xcodebuild.nvim)
brew install python3
pip3 install pymobiledevice3
pip3 install xcode-build-server   # or: brew install xcode-build-server

# LSP / tools
brew install ripgrep fd            # telescope
brew install lazygit               # lazygit integration
```

### Install

```bash
git clone git@github.com:StasMarynych/nvim.git ~/.config/nvim
nvim  # lazy.nvim will auto-install all plugins on first launch
```

### iOS 17+ Debugging (physical device)

After installing, run this once to install the `remote_debugger` script with proper sudo permissions:

```bash
DEST="$HOME/Library/xcodebuild.nvim" && \
  SOURCE="$HOME/.local/share/nvim/lazy/xcodebuild.nvim/tools/remote_debugger" && \
  ME="$(whoami)" && \
  sudo install -d -m 755 -o root "$DEST" && \
  sudo install -m 755 -o root "$SOURCE" "$DEST" && \
  sudo bash -c "echo \"$ME ALL = (ALL) NOPASSWD: $DEST/remote_debugger\" >> /etc/sudoers"
```

## Key Bindings

### Xcodebuild (`<leader>x`)

| Key | Action |
|-----|--------|
| `<leader>xp` | Select project |
| `<leader>xq` | Select scheme |
| `<leader>xd` | Select device/simulator |
| `<leader>xb` | Build |
| `<leader>xr` | Build & run |
| `<leader>xR` | Resolve package dependencies |
| `<leader>xs` | Regenerate buildServer.json |
| `<leader>xl` | Toggle build logs |
| `<leader>xc` | Toggle code coverage |
| `<leader>X`  | Xcodebuild action picker |

### Debugger (`<leader>d`)

| Key | Action |
|-----|--------|
| `<leader>dd` | Build & debug |
| `<leader>dr` | Debug without build |
| `<leader>db` | Toggle breakpoint |
| `<leader>dc` | Continue |
| `<leader>di` | Step into |
| `<leader>do` | Step over |
| `<leader>dO` | Step out |
| `<leader>dq` | Stop debugger |
| `<leader>du` | Toggle DAP UI |
| `<leader>dl` | Toggle LLDB console |

## Plugins

- **[xcodebuild.nvim](https://github.com/wojciech-kulik/xcodebuild.nvim)** — Xcode build, run, test, debug
- **[nvim-dap](https://github.com/mfussenegger/nvim-dap)** + **[nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui)** — Debugger
- **[telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)** — Fuzzy finder
- **[oil.nvim](https://github.com/stevearc/oil.nvim)** — File manager
- **[trouble.nvim](https://github.com/folke/trouble.nvim)** — Diagnostics panel
- **[fidget.nvim](https://github.com/j-hui/fidget.nvim)** — LSP progress notifications
- Plus all [LazyVim](https://lazyvim.github.io/) defaults
