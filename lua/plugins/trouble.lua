return {
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = { "BufReadPre", "BufNewFile" },
  keys = {
    { "<leader>tt", "<cmd>Trouble quickfix toggle<cr>", desc = "Open a quickfix" },
    { "<leader>xt", false },
    { "<leader>xT", false },
    { "<leader>xx", false },
    { "<leader>xX", false },
  },
  opts = {},
  config = function()
    require("trouble").setup({
      auto_open = false,
      auto_close = false,
      auto_preview = true,
      auto_jump = false,
      mode = "quickfix",
      cycle_results = false,
    })
  end,
}
