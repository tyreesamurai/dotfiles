return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      eslint = false, -- don't register eslint at all
    },
    setup = {
      eslint = function()
        return true
      end, -- no-op if anything tries to set it up
    },
  },
}
