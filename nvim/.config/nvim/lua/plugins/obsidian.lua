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
        path = "~/desktop/work/zettelkasten/",
      },
    },
    notes_subdir = "inbox",
    new_notes_location = "notes_subdir",

    disable_frontmatter = true,

    templates = {
      folder = "~/desktop/work/zettelkasten/templates",
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
  },
}
