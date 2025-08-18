vim.keymap.set("n", "<leader>fs", ":Telescope find_files<cr>")

-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
-- convert note to template and remove leading white space
vim.keymap.set("n", "<leader>on", ":ObsidianTemplate note<cr> :lua vim.cmd([[1,/^\\S/s/^\\n\\{1,}//]])<cr>")

vim.keymap.set("n", "<leader>odn", ":ObsidianTemplate daily<cr> :lua vim.cmd([[1,/^\\S/s/^\\n\\{1,}//]])<cr>")

-- strip date from note title and replace dashes with spaces
-- must have cursor on title
vim.keymap.set("n", "<leader>of", ":s/\\(# \\)[^_]*_/\\1/ | s/-/ /g<cr>")
--
-- search for files in full vault
vim.keymap.set(
  "n",
  "<leader>os",
  ':Telescope find_files search_dirs={"/Users/tyreesamurai/Desktop/studies/zettelkasten/"}<cr>'
)

vim.keymap.set(
  "n",
  "<leader>o/",
  ':Telescope live_grep search_dirs={"/Users/tyreesamurai/Desktop/studies/zettelkasten/"}<cr>'
)

-- search for files in notes (ignore zettelkasten)
-- vim.keymap.set("n", "<leader>ois", ":Telescope find_files search_dirs={\"/Users/alex/library/Mobile\\ Documents/iCloud~md~obsidian/Documents/ZazenCodes/notes\"}<cr>")
-- vim.keymap.set("n", "<leader>oiz", ":Telescope live_grep search_dirs={\"/Users/alex/library/Mobile\\ Documents/iCloud~md~obsidian/Documents/ZazenCodes/notes\"}<cr>")
--
-- for review workflow
-- move file in current buffer to zettelkasten folder
vim.keymap.set("n", "<leader>ok", ":!mv '%:p' /Users/tyreesamurai/Desktop/studies/zettelkasten/zettelkasten<cr>:bd<cr>")
-- delete file in current buffer
vim.keymap.set("n", "<leader>odd", ":!rm '%:p'<cr>:bd<cr>")

vim.keymap.set("n", "<leader>rn", "<cmd>IncRename ")

vim.keymap.set("n", "<leader>DD", "<cmd>LazyDocker<cr>")
vim.keymap.set("n", "<leader>Dd", "<cmd>DBUI<cr>")
