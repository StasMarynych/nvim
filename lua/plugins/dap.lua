return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "wojciech-kulik/xcodebuild.nvim",
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      local xcodebuild = require("xcodebuild.integrations.dap")

      xcodebuild.setup()

      dapui.setup()

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
    keys = {
      { "<leader>dd", function() require("xcodebuild.integrations.dap").build_and_debug() end, desc = "Build & Debug" },
      { "<leader>dr", function() require("xcodebuild.integrations.dap").debug_without_build() end, desc = "Debug Without Build" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
      { "<leader>dc", function() require("dap").continue() end, desc = "Continue" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
      { "<leader>do", function() require("dap").step_over() end, desc = "Step Over" },
      { "<leader>dO", function() require("dap").step_out() end, desc = "Step Out" },
      { "<leader>dq", function() require("dap").terminate() end, desc = "Stop Debugger" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle DAP UI" },
      { "<leader>dl", function() require("dap").repl.toggle() end, desc = "Toggle LLDB Console" },
      {
        "<leader>ds",
        function()
          vim.ui.input({ prompt = "Symbolic breakpoint (function name): " }, function(name)
            if not name or name == "" then return end
            require("dap").set_breakpoint(nil, nil, nil, { name = name })
            vim.notify("Symbolic breakpoint set: " .. name)
          end)
        end,
        desc = "Set Symbolic Breakpoint",
      },
      {
        "<leader>dU",
        function()
          require("dapui").toggle()
          require("xcodebuild.integrations.dap").clear_console()
        end,
        desc = "Toggle DAP UI & Clear Console",
      },
    },
  },
}
