return {
  {
    "folke/snacks.nvim",
    opts = {
      bigfile = {
        size = 10 * 1024 * 1024, -- 10MB
        line_length = 10000, -- allow long lines (e.g. minified JSON)
      },
    },
  },
}
