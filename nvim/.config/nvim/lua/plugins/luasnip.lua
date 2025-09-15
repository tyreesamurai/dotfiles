return {
  "L3MON4D3/LuaSnip",
  keys = function(_, keys)
    local ls = require("luasnip")

    -- Smart Tab: jump forward if possible, otherwise insert Tab
    vim.keymap.set({ "i", "s" }, "<Tab>", function()
      if ls.expand_or_jumpable() then
        return "<Plug>luasnip-expand-or-jump"
      else
        return "<Tab>"
      end
    end, { expr = true, silent = true })

    -- Smart Shift-Tab: jump backward if possible
    vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
      if ls.jumpable(-1) then
        return "<Plug>luasnip-jump-prev"
      else
        return "<S-Tab>"
      end
    end, { expr = true, silent = true })

    return keys
  end,
}
