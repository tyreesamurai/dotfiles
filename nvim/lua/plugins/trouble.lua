return {
  "folke/trouble.nvim",
  config = function()
    vim.defer_fn(function()
      vim.cmd([[
        hi TroubleNormal guibg=NONE ctermbg=NONE
        hi TroubleNormalNC guibg=NONE ctermbg=NONE
      ]])
    end, 100)
  end,
}
