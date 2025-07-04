return {
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
      require "configs.pyrightconfig"
    end,
  },
}
