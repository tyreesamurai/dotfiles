return {
  {
    "sainnhe/sonokai",
    config = function()
      vim.g.sonokai_style = "espresso"
      vim.g.sonokai_enable_italic = 1
    end,
  },
  {
    "sainnhe/gruvbox-material",
    opts = {
      transparent_background = 1, -- Enable transparency
    },
    config = function()
      vim.g.gruvbox_material_transparent_background = 1
      vim.g.grubbox_material_enable_italic = true
      -- vim.cmd([[
      --     hi Normal guibg=NONE ctermbg=NONE
      --     hi NormalNC guibg=NONE ctermbg=NONE
      --     hi EndOfBuffer guibg=NONE ctermbg=NONE
      --     hi SignColumn guibg=NONE
      --     hi LineNr guibg=NONE
      --     hi CursorLineNr guibg=NONE
      --   ]])
    end,
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox-material",
    },
  },
}
