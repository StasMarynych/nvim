local progress_handle
local bss_progress_handle
local resolve_pkg_job

local resolve_pkg_bufnr = nil

local function get_or_create_resolve_buf()
  if resolve_pkg_bufnr and vim.api.nvim_buf_is_valid(resolve_pkg_bufnr) then
    return resolve_pkg_bufnr
  end
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].filetype = "xcodebuildlog"
  vim.bo[buf].bufhidden = "hide"
  vim.api.nvim_buf_set_name(buf, "Resolve Package Dependencies")
  resolve_pkg_bufnr = buf
  return buf
end

local function open_resolve_buf()
  local buf = get_or_create_resolve_buf()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == buf then
      vim.api.nvim_set_current_win(win)
      return
    end
  end
  vim.cmd("botright 15split")
  vim.api.nvim_win_set_buf(0, buf)
  vim.wo[0].wrap = false
  vim.wo[0].number = false
  vim.wo[0].relativenumber = false
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true })
end

local function resolve_package_dependencies()
  if resolve_pkg_job then
    vim.fn.jobstop(resolve_pkg_job)
    resolve_pkg_job = nil
  end

  local settings = require("xcodebuild.project.config").settings
  local project_file = settings.projectFile or settings.xcodeproj

  if not project_file then
    vim.notify(
      "xcodebuild: no project file in settings. Run XcodebuildSelectProject first.",
      vim.log.levels.ERROR
    )
    return
  end

  local cwd = settings.workingDirectory or vim.fn.fnamemodify(project_file, ":h")
  local derived = cwd .. "/.nvim/DerivedData"

  local args = {
    "xcodebuild",
    "-resolvePackageDependencies",
    "-project", project_file,
    "-derivedDataPath", derived,
  }

  local scheme = settings.scheme
  if scheme then
    vim.list_extend(args, { "-scheme", scheme })
  end

  local buf = get_or_create_resolve_buf()
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
    "$ xcodebuild -resolvePackageDependencies",
    "  project: " .. project_file,
    "  scheme:  " .. (settings.scheme or "(none)"),
    string.rep("─", 60),
    "",
  })

  open_resolve_buf()

  local handle = require("fidget.progress").handle.create({
    title = "xcodebuild",
    message = "Resolving package dependencies…",
    lsp_client = { name = "xcodebuild.nvim" },
  })

  local function append_lines(data)
    if not vim.api.nvim_buf_is_valid(buf) then return end
    vim.bo[buf].modifiable = true
    local count = vim.api.nvim_buf_line_count(buf)
    vim.api.nvim_buf_set_lines(buf, count, count, false, data)
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(win) == buf then
        vim.api.nvim_win_set_cursor(win, { vim.api.nvim_buf_line_count(buf), 0 })
      end
    end
  end

  resolve_pkg_job = vim.fn.jobstart(args, {
    cwd = cwd,
    stdout_buffered = false,
    stderr_buffered = false,
    on_stdout = function(_, data) append_lines(data) end,
    on_stderr = function(_, data) append_lines(data) end,
    on_exit = function(_, code)
      resolve_pkg_job = nil
      local summary = code == 0
        and "✓ Package dependencies resolved"
        or "✗ Resolution failed (exit " .. code .. ")"
      append_lines({ string.rep("─", 60), summary })
      handle.message = code == 0 and "Package dependencies resolved" or "Resolution failed (exit " .. code .. ")"
      handle:finish()
    end,
  })
end

local function run_build_server_config(scheme, cwd, on_exit)
  local settings = require("xcodebuild.project.config").settings
  local project_file = settings.projectFile or settings.xcodeproj

  if not project_file then
    vim.notify("xcode-build-server: no project file in xcodebuild.nvim settings. Run XcodebuildSelectProject first.", vim.log.levels.ERROR)
    if on_exit then on_exit(1) end
    return
  end

  local dir = vim.fn.fnamemodify(project_file, ":h")
  local name = vim.fn.fnamemodify(project_file, ":t:r")
  local standalone_workspace = dir .. "/" .. name .. ".xcworkspace"
  -- xcode-build-server only emits the workspace/project key reliably with -workspace.
  -- Prefer a standalone .xcworkspace next to the .xcodeproj; fall back to the
  -- embedded project.xcworkspace inside the .xcodeproj bundle (always present).
  local workspace
  if vim.fn.isdirectory(standalone_workspace) == 1 then
    workspace = standalone_workspace
  else
    workspace = project_file .. "/project.xcworkspace"
  end

  local args = { "xcode-build-server", "config", "-scheme", scheme, "-workspace", workspace, "--build_root", cwd .. "/.nvim/DerivedData" }
  -- Always run from the nvim cwd (repo root) so buildServer.json is written there,
  -- regardless of whether the .xcodeproj is in a subdirectory (e.g. WidgetToolkitDemo/).
  -- The workspace path is absolute, so cwd only affects output location.

  if bss_progress_handle then
    bss_progress_handle:cancel()
  end
  bss_progress_handle = require("fidget.progress").handle.create({
    title = "xcode-build-server",
    message = "Generating config for " .. scheme,
    lsp_client = { name = "xcodebuild.nvim" },
  })
  vim.fn.jobstart(args, {
    cwd = cwd,
    on_exit = function(_, code)
      if bss_progress_handle then
        bss_progress_handle.message = code == 0 and "Done" or "Failed"
        bss_progress_handle:finish()
        bss_progress_handle = nil
      end
      if on_exit then on_exit(code) end
    end,
  })
end

return {
  {
    "wojciech-kulik/xcodebuild.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
      "nvim-tree/nvim-tree.lua",
      "stevearc/oil.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      -- Patch vim.fn.jobstart to inject -derivedDataPath into every xcodebuild call.
      -- This covers build, test, and get_build_settings in one place.
      local orig_jobstart = vim.fn.jobstart
      local DERIVEDDATA_SUBCOMMANDS = {
        build = true,
        test = true,
        ["build-for-testing"] = true,
        ["test-without-building"] = true,
        archive = true,
      }
      vim.fn.jobstart = function(cmd, opts)
        if type(cmd) == "table" and cmd[1] == "xcodebuild" and not vim.tbl_contains(cmd, "-derivedDataPath") then
          -- Only inject -derivedDataPath for subcommands that support it
          local subcommand = cmd[2]
          if subcommand and DERIVEDDATA_SUBCOMMANDS[subcommand] then
            local derived = vim.fn.getcwd() .. "/.nvim/DerivedData"
            cmd = vim.list_extend(vim.deepcopy(cmd), { "-derivedDataPath", derived })
          end
        end
        return orig_jobstart(cmd, opts)
      end

      -- Patch get_build_settings to rewrite appPath/buildDir to local DerivedData path
      local xcode = require("xcodebuild.core.xcode")
      local orig_get_build_settings = xcode.get_build_settings

      xcode.get_build_settings = function(platform, projectFile, scheme, xcodeprojPath, callback)
        local cwd = vim.fn.getcwd()
        local derived = cwd .. "/.nvim/DerivedData"

        local wrapped_callback = function(result)
          if result and result.buildDir then
            local default = vim.fn.expand("~/Library/Developer/Xcode/DerivedData")
            result.buildDir = result.buildDir:gsub(vim.pesc(default) .. "/[^/]+", derived)
            if result.appPath then
              result.appPath = result.appPath:gsub(vim.pesc(default) .. "/[^/]+", derived)
            end
          end
          callback(result)
        end

        local ok, err = pcall(orig_get_build_settings, platform, projectFile, scheme, xcodeprojPath, wrapped_callback)
        if not ok then error(err) end
      end

      require("xcodebuild").setup({
        restore_on_start = true,
        auto_save = true,
        show_build_progress_bar = true,
        integrations = {
          pymobiledevice = {
            enabled = true,
          },
        },
        code_coverage = {
          enabled = true,
        },
        commands = {},
        logs = {
          notify = function(message, severity)
            local fidget = require("fidget")
            if progress_handle then
              progress_handle.message = message

              if not message:find("Loading") then
                progress_handle:finish()
                progress_handle = nil

                if vim.trim(message) ~= "" then
                  fidget.notify(message, severity)
                end
              end
            else
              fidget.notify(message, severity)
            end
          end,
          notify_progress = function(message)
            local progress = require("fidget.progress")

            if progress_handle then
              progress_handle.title = ""
              progress_handle.message = message
            else
              progress_handle = progress.handle.create({
                message = message,
                lsp_client = { name = "xcodebuild.nvim" },
              })
            end
          end,
        },
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "XcodebuildProjectSettingsUpdated",
        callback = function()
          local scheme = require("xcodebuild.project.config").settings.scheme
          if not scheme then return end
          run_build_server_config(scheme, vim.fn.getcwd())
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = { "XcodebuildBuildFinished", "XcodebuildTestsFinished" },
        callback = function(event)
          if event.data.cancelled then return end
          if next(vim.fn.getqflist()) then
            require("trouble").open("quickfix")
          else
            require("trouble").close()
          end
        end,
      })
    end,
    keys = {
      { "<leader>xd", "<cmd>XcodebuildSelectDevice<cr>", desc = "Select Device/Simulator" },
      { "<leader>xp", "<cmd>XcodebuildSelectProject<cr>", desc = "Select Project" },
      { "<leader>xq", "<cmd>XcodebuildSelectScheme<cr>", desc = "Select Scheme" },
      {
        "<leader>xs",
        function()
          local scheme = require("xcodebuild.project.config").settings.scheme
          if not scheme then
            vim.notify("No scheme selected", vim.log.levels.WARN)
            return
          end
          run_build_server_config(scheme, vim.fn.getcwd(), function(code)
            if code ~= 0 then
              vim.notify("buildServer.json generation failed for: " .. scheme, vim.log.levels.ERROR)
            end
          end)
        end,
        desc = "Regenerate buildServer.json",
      },
      { "<leader>xb", "<cmd>XcodebuildBuild<cr>", desc = "Build Project" },
      { "<leader>xr", "<cmd>XcodebuildBuildRun<cr>", desc = "Build & Run" },
      { "<leader>xl", "<cmd>XcodebuildToggleLogs<cr>", desc = "Toggle xcodebuild Logs" },
      { "<leader>xc", "<cmd>XcodebuildToggleCodeCoverage<cr>", desc = "Toggle Code Coverage" },
      { "<leader>xR", resolve_package_dependencies, desc = "Resolve Package Dependencies" },
      {
        "<leader>xo",
        function()
          if not resolve_pkg_bufnr or not vim.api.nvim_buf_is_valid(resolve_pkg_bufnr) then
            vim.notify("No resolve output yet. Run <leader>xR first.", vim.log.levels.WARN)
            return
          end
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_get_buf(win) == resolve_pkg_bufnr then
              vim.api.nvim_win_close(win, false)
              return
            end
          end
          open_resolve_buf()
        end,
        desc = "Toggle Resolve Output",
      },
      { "<leader>X", "<cmd>XcodebuildPicker<cr>", desc = "Show xcodebuild Actions" },
    },
  },
}
