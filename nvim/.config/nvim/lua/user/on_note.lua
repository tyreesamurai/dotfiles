-- lua/user/on_note.lua
-- Helpers + two entry points:
--   M.new_note()  -> project/normal note with LuaSnip placeholders
--   M.new_daily() -> daily note pulled from external template file

local M = {}

-- =========================
-- Helpers
-- =========================
local function title_from_env_or_name()
  -- Prefer explicit title from launcher (e.g., NVIM_NOTE_TITLE="My Title")
  local t = vim.fn.getenv("NVIM_NOTE_TITLE")
  if t ~= vim.NIL and t ~= "" then
    return t
  end
  -- Fallback: derive from filename, turning dashes/underscores into spaces
  local base = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t:r")
  return (base:gsub("[-_]", " "))
end

-- Read a whole file; returns nil if it can't be opened
local function slurp(path)
  local f = io.open(path, "r")
  if not f then
    return nil
  end
  local s = f:read("*a")
  f:close()
  return s
end

-- Check if current buffer is "empty"
local function buf_is_empty()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  return (#lines == 1 and lines[1] == "") or #lines == 0
end

-- =========================
-- Regular note (tags -> folder -> under title)
-- =========================
function M.new_note()
  -- Only auto-insert into an empty buffer
  if not buf_is_empty() then
    return
  end
  vim.bo.filetype = "markdown"

  local ok, ls = pcall(require, "luasnip")
  if not ok then
    return
  end
  local fmt_ok, fmt = pcall(require, "luasnip.extras.fmt")
  if not fmt_ok then
    return
  end

  local s, i, f = ls.snippet, ls.insert_node, ls.function_node

  -- Tab order: i(1) -> i(2) -> i(0) (final stop under title)
  local snip = s(
    "onote",
    fmt.fmt(
      [[---
date: {}
tags:
  - {}
folder:
  - {}
---

# {}

{}
]],
      {
        f(function()
          return os.date("%Y-%m-%d")
        end, {}),
        i(1, "none"), -- 1) tags placeholder
        i(2, "none"), -- 2) folder placeholder
        f(title_from_env_or_name, {}), -- H1 title (spaces not dashes)
        i(0), -- final stop: under the title
      }
    )
  )

  ls.snip_expand(snip)
end

-- =========================
-- Daily note (load external template, replace {{title}}, [[CURSOR]])
-- =========================
function M.new_daily()
  -- Only auto-insert into an empty buffer
  if not buf_is_empty() then
    return
  end
  vim.bo.filetype = "markdown"

  local ok, ls = pcall(require, "luasnip")
  if not ok then
    return
  end

  local s, t, i = ls.snippet, ls.text_node, ls.insert_node

  -- Try to load template path from env, else fallback to an embedded one
  local tpl_path = vim.fn.getenv("NVIM_NOTE_TEMPLATE")
  local content = (tpl_path and tpl_path ~= "" and slurp(tpl_path))
    or [=[
---
date: "{{title}}"
tags:
  - daily
folder:
  - daily
---

# Daily Note for {{title}}

## TODOs:

### Daily Goals:

### TODO Today:

[[CURSOR]]

### What to do tomorrow:

## Reflection / Notes:

## Weekly Goals

## Relevant Links
]=]

  -- Replace {{title}} with env/filename-derived title (e.g., today's date from launcher)
  local title = title_from_env_or_name()
  content = content:gsub("\r\n", "\n"):gsub("{{title}}", title)

  -- Split around [[CURSOR]] to create a placeholder there
  local before, after = content:match("^(.*)%[%[CURSOR%]%](.*)$")
  if not before then
    -- If no [[CURSOR]] marker, put the placeholder at the end
    before, after = content, ""
  end

  -- Convert strings to arrays of lines for text_node
  local function to_lines(s)
    local lines = vim.split(s, "\n", { plain = true })
    if lines[#lines] == "" then
      table.remove(lines, #lines)
    end
    return lines
  end

  local snip = s("daily_from_file", {
    t(to_lines(before)),
    i(1), -- cursor lands here (at [[CURSOR]])
    t(to_lines(after)),
  })

  ls.snip_expand(snip)
end

return M
