return {
  {
    "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
      local ls = require("luasnip")
      local s = ls.snippet
      local t = ls.text_node

      -- Define your custom snippets
      local markdown_snippets = {
        s("sharp", t("♯")), -- Musical sharp symbol
        s("flat", t("♭")), -- Musical flat symbol
      }

      -- Add the snippets to the markdown filetype
      ls.add_snippets("markdown", markdown_snippets)

      -- Optional: Additional LuaSnip configuration
      ls.setup({
        -- Your LuaSnip setup options here
      })
    end,
  },
}
