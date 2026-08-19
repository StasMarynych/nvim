-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Space + w to open your Workflows (Navi)
vim.keymap.set("n", "<leader>w", function()
  require("snacks").terminal("navi", { win = { width = 0.8, height = 0.8 } })
end, { desc = "Workflows" })

-- Space + k for Kiro
vim.keymap.set("n", "<leader>k", function()
  require("snacks").terminal("kiro-cli")
end, { desc = "Kiro CLI" })

-- Override LazyVim's <leader>xt/xT (Trouble todo) with xcodebuild
vim.keymap.set("n", "<leader>xt", "<cmd>XcodebuildTest<cr>", { desc = "Run Tests" })
vim.keymap.set("n", "<leader>xT", "<cmd>XcodebuildTestClass<cr>", { desc = "Run This Test Class" })

vim.keymap.set("n", "<leader>fm", function()
  require("telescope.builtin").live_grep({
    search_dirs = {
      "/Users/stanislav.marynych/Projects/frontend-workspace/repos/iOS",
    },
    prompt_title = "Search iOS repos",
  })
end, { desc = "Find in iOS repos" })

vim.keymap.set("n", "<leader>fd", function()
  require("telescope.builtin").live_grep({
    cwd = vim.fn.expand("%:p:h"),
    prompt_title = "Search in current file dir",
    additional_args = { "--no-ignore", "--hidden" },
  })
end, { desc = "Find in current dir (regex)" })

vim.keymap.set("n", "<leader>fD", function()
  require("telescope.builtin").live_grep({
    cwd = vim.fn.expand("%:p:h"),
    prompt_title = "Search in current file dir (literal)",
    additional_args = { "--no-ignore", "--hidden", "--fixed-strings" },
  })
end, { desc = "Find in current dir (literal)" })

vim.keymap.set("n", "<leader>ft", function()
  vim.ui.input({ prompt = "File type (e.g. swift, ts, lua): " }, function(ft)
    if not ft or ft == "" then return end
    require("telescope.builtin").live_grep({
      cwd = vim.fn.expand("%:p:h"),
      prompt_title = "Search *." .. ft .. " in current dir",
      additional_args = { "--no-ignore", "--hidden", "--fixed-strings", "--type=" .. ft },
    })
  end)
end, { desc = "Find in current dir (by file type)" })

-- Override LazyVim's <leader>ff to include hidden and git-ignored files
vim.keymap.set("n", "<leader>ff", function()
  require("telescope.builtin").find_files({
    hidden = true,
    no_ignore = true,
    no_ignore_parent = true,
  })
end, { desc = "Find Files (all)" })
