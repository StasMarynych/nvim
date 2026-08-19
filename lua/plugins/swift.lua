local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "swift" },
    },
  },
  {
    "neovim/nvim-lspconfig",
    init = function()
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end
      vim.diagnostic.config({
        float = { border = "rounded" },
        virtual_text = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = signs.Error,
            [vim.diagnostic.severity.WARN] = signs.Warn,
            [vim.diagnostic.severity.HINT] = signs.Hint,
            [vim.diagnostic.severity.INFO] = signs.Info,
          },
          linehl = {
            [vim.diagnostic.severity.ERROR] = "ErrorMsg",
          },
          numhl = {
            [vim.diagnostic.severity.WARN] = "WarningMsg",
          },
        },
      })
    end,
    opts = {
      servers = {
        sourcekit = {
          cmd = {
            "xcrun", "sourcekit-lsp"
          },
          filetypes = { "swift", "objective-c", "objective-cpp" },
          root_dir = function(filename, _)
            local util = require("lspconfig.util")
            return util.root_pattern("buildServer.json")(filename)
              or util.root_pattern("*.xcodeproj", "*.xcworkspace")(filename)
              or util.root_pattern("Package.swift")(filename)
              or vim.fs.dirname(vim.fs.find('.git', { path = filename, upward = true })[1])
          end,
        },
      },
      setup = {
        sourcekit = function(_, opts)
          require("lspconfig").sourcekit.setup(opts)
          return true
        end,
      },
    },
  },
}
