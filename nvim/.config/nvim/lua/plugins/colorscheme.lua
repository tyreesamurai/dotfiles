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
      transparent_background = 1,
    },
    config = function()
      vim.g.gruvbox_material_transparent_background = 1
      vim.g.grubbox_material_enable_italic = true
    end,
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox-material",
    },
  },
}
