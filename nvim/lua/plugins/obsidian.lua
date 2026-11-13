return {
  "epwalsh/obsidian.nvim",
  version = "*", -- recommended, use latest release instead of latest commit
  keys = {
    { "<leader>oo", "<cmd>ObsidianOpen<cr>", desc = "[O]bsidian [O]pen" },
    { "<leader>otd", "<cmd>ObsidianToday<cr>", desc = "[O]bsidian [T]o[d]ay" },
    { "<leader>oyd", "<cmd>ObsidianYesterday<cr>", desc = "[O]bsidian [Y]ester[d]ay" },
    { "<leader>otm", "<cmd>ObsidianTomorrow<cr>", desc = "[O]bsidian [T]o[m]orrow" },
    { "<leader>os", "<cmd>ObsidianSearch<cr>", desc = "[O]bsidian [S]earch" },
    { "<leader>obl", "<cmd>ObsidianBacklinks<cr>", desc = "[O]bsidian [B]ack[L]inks" },
  },
  lazy = true,

  ft = "markdown",
  -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
  -- event = {
  --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
  --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/**.md"
  --   "BufReadPre path/to/my-vault/**.md",
  --   "BufNewFile path/to/my-vault/**.md",
  -- },
  dependencies = {
    -- Required.
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-telescope/telescope.nvim",
  },
  opts = {
    workspaces = {
      {
        name = "zettelkasten",
        path = "~/desktop/studies/zettelkasten/",
      },
    },
    notes_subdir = "inbox",
    new_notes_location = "notes_subdir",

    disable_frontmatter = true,

    templates = {
      folder = "~/desktop/studies/zettelkasten/templates",
      date_format = "%Y-%m-%d",
      time_format = "%H:%M:%S",
    },

    mappings = {
      ["gf"] = {
        action = function()
          return require("obsidian").util.gf_passthrough()
        end,
        opts = { noremap = false, expr = true, buffer = true },
      },
    },
    -- see below for full list of options 👇
  },
}
