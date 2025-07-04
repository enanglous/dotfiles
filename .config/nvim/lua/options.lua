require "nvchad.options"

-- add yours here!

local o = vim.o
o.cursorlineopt = "both" -- to enable cursorline!

vim.api.nvim_create_autocmd({ "InsertLeave", "BufWritePost" }, {
  callback = function()
    local lint_status, lint = pcall(require, "lint")
    if lint_status then
      lint.try_lint()
    end
  end,
})
