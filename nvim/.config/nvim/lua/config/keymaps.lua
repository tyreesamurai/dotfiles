vim.keymap.set("n", "<leader>fs", ":Telescope find_files<cr>")

vim.keymap.set("n", "<leader>on", function()
  require("user.on_note").new_note()
end, { desc = "Create new note" })

vim.keymap.set("n", "<leader>odn", function()
  require("user.on_note").daily_note()
end, { desc = "Create daily note" })

vim.keymap.set("n", "<leader>of", ":s/\\(# \\)[^_]*_/\\1/ | s/-/ /g<cr>")

vim.keymap.set(
  "n",
  "<leader>os",
  ':Telescope find_files search_dirs={"/Users/tcarpenter/Desktop/work/zettelkasten/"}<cr>'
)

vim.keymap.set(
  "n",
  "<leader>o/",
  ':Telescope live_grep search_dirs={"/Users/tcarpenter/Desktop/work/zettelkasten/"}<cr>'
)

vim.keymap.set("n", "<leader>ok", ":!mv '%:p' /Users/tcarpenter/Desktop/work/zettelkasten/zettelkasten<cr>:bd<cr>")

vim.keymap.set("n", "<leader>odd", ":!rm '%:p'<cr>:bd<cr>")
