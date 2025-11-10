return {
  {
    "jakewvincent/mkdnflow.nvim",
    ft = { "markdown" },
    config = function()
      require("mkdnflow").setup {
        mappings = {
          MkdnDestroyLink = { "n", "<C-d>" },
          MkdnTagSpan = { "v", "<C-d>" },
        },
      }
    end,
  },
}
