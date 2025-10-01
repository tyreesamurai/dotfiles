return {
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  dependencies = { "williamboman/mason.nvim" },
  event = "VeryLazy",
  opts = {
    ensure_installed = {
      -- LSP servers
      "ansible-language-server",
      "bash-language-server",
      "pyright", -- or "basedpyright"
      "yaml-language-server",
      "json-lsp",
      "dockerfile-language-server",
      "docker-compose-language-service",
      "marksman", -- Markdown LSP

      -- Linters / formatters
      "ansible-lint",
      "yamllint",
      "markdownlint",
      "ruff",
      "black",
      "isort",
      "shellcheck",
      "shfmt",
      "hadolint",
      -- If you like Prettier for md/json/yaml:
      -- "prettierd",
    },
    auto_update = false,
    run_on_start = false, -- we'll install headlessly below
  },
}
