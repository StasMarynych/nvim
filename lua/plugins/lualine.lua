local function xcodebuild_device()
  if not vim.g.xcodebuild_platform or not vim.g.xcodebuild_device_name then
    return ""
  end

  if vim.g.xcodebuild_platform == "macOS" then
    return " macOS"
  end

  local deviceIcon = ""
  if vim.g.xcodebuild_platform:match("watch") then
    deviceIcon = "􀟤"
  elseif vim.g.xcodebuild_platform:match("tv") then
    deviceIcon = "􀡴 "
  elseif vim.g.xcodebuild_platform:match("vision") then
    deviceIcon = "􁎖 "
  end

  if vim.g.xcodebuild_os then
    return deviceIcon .. " " .. vim.g.xcodebuild_device_name .. " (" .. vim.g.xcodebuild_os .. ")"
  end

  return deviceIcon .. " " .. vim.g.xcodebuild_device_name
end

return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    options = {
      disabled_filetypes = {
        winbar = { "snacks_picker_list", "snacks_picker_input" },
      },
    },
    sections = {
      lualine_x = {
        { function() return " " .. (vim.g.xcodebuild_last_status or "") end, color = { fg = "Gray" } },
        { function() return "󰙨 " .. (vim.g.xcodebuild_test_plan or "") end, color = { fg = "#a6e3a1", bg = "#1e1e2e" } },
        { xcodebuild_device, color = { fg = "#f9e2af", bg = "#1e1e2e" } },
        { function() return " " .. (vim.g.xcodebuild_scheme or "") end, color = { fg = "#89b4fa", bg = "#1e1e2e" } },
      },
    },
  },
}
