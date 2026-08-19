return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha",
      transparent_background = true,
      term_colors = true,
      integrations = {
        snacks = true,
        telescope = {
          enabled = true,
          style = "nvchad",
        },
        mason = true,
        neotree = true,
      },
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
      custom_highlights = function(colors)
        return {
          LineNr = { fg = colors.overlay1 },
          LineNrAbove = { fg = colors.overlay0 },
          LineNrBelow = { fg = colors.overlay0 },
          CursorLineNr = { fg = colors.lavender, bold = true },
        }
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-mocha",
    },
  },
}
