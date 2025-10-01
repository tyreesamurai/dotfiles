return {
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    opts = opts or {}
    opts.ensure_installed = {
      -- core
      "lua",
      "vim",
      "vimdoc",

      -- work stack
      "bash",
      "python",
      "yaml",
      "json",
      "markdown",
      "markdown_inline",
      "dockerfile",
      "gitcommit",
      "gitignore",

      "jinja2",
      "toml",
    }
    opts.auto_install = false
    return opts
  end,
}
