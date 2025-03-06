return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      window = {
        -- Other settings if needed
      },
      default_component_configs = {
        indent = {
          padding = 0,
        },
      },
    },
    config = function()
      vim.cmd([[
        hi NeoTreeNormal guibg=NONE ctermbg=NONE
        hi NeoTreeNormalNC guibg=NONE ctermbg=NONE
        hi NeoTreeEndOfBuffer guibg=NONE ctermbg=NONE
      ]])
    end,
  },
}
