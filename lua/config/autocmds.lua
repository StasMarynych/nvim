vim.filetype.add({
  filename = {
    ["Fastfile"] = "ruby",
    ["Appfile"] = "ruby",
    ["Deliverfile"] = "ruby",
    ["Gymfile"] = "ruby",
    ["Matchfile"] = "ruby",
    ["Pluginfile"] = "ruby",
  },
})

-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function()
    vim.fn.mkdir(vim.fn.expand("<afile>:p:h"), "p")
  end,
})

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    vim.api.nvim_set_hl(0, "SnacksPicker", { bg = "none" })
    vim.api.nvim_set_hl(0, "SnacksPickerList", { bg = "none" })
    vim.api.nvim_set_hl(0, "SnacksPickerPreview", { bg = "none" })
    vim.api.nvim_set_hl(0, "SnacksPickerBorder", { bg = "none" })
    vim.api.nvim_set_hl(0, "SnacksPickerTitle", { bg = "none" })
    vim.api.nvim_set_hl(0, "SnacksPickerInput", { bg = "none" })
    vim.api.nvim_set_hl(0, "SnacksPickerInputBorder", { bg = "none" })
    vim.api.nvim_set_hl(0, "SnacksPickerBoxBorder", { bg = "none" })
    vim.api.nvim_set_hl(0, "SnacksPickerPreviewBorder", { bg = "none" })
    vim.api.nvim_set_hl(0, "SnacksPickerPreviewTitle", { bg = "none" })
    vim.api.nvim_set_hl(0, "SnacksPickerFooter", { bg = "none" })
    vim.api.nvim_set_hl(0, "SnacksPickerListTitle", { bg = "none" })
  end,
})
