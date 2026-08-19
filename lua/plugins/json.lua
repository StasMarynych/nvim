return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        jsonls = {
          root_dir = function(fname)
            if type(fname) ~= "string" then
              fname = vim.api.nvim_buf_get_name(fname)
            end
            return require("lspconfig.util").find_git_ancestor(fname)
              or vim.fn.fnamemodify(fname, ":h")
          end,
        },
      },
    },
  },
}
