local Path = require "plenary.path"

local Note = require "obsidian.note"
local echo = require "obsidian.echo"
local util = require "obsidian.util"

local command = {}

---Check the directory for notes with missing/invalid frontmatter.
---
---@param client obsidian.Client
---@param _ table
command.check = function(client, _)
  local scan = require "plenary.scandir"

  local count = 0
  local err_count = 0
  local warn_count = 0

  scan.scan_dir(vim.fs.normalize(tostring(client.dir)), {
    hidden = false,
    add_dirs = false,
    respect_gitignore = true,
    search_pattern = ".*%.md",
    on_insert = function(entry)
      count = count + 1
      Note.from_file(entry, client.dir)
      local ok, note = pcall(Note.from_file, entry, client.dir)
      if not ok then
        err_count = err_count + 1
        echo.err("Failed to parse note at " .. entry)
      elseif note.has_frontmatter == false then
        warn_count = warn_count + 1
        echo.warn(tostring(entry) .. " is missing frontmatter")
      end
    end,
  })

  echo.info("Found " .. tostring(count) .. " notes total")
  if warn_count > 0 then
    echo.warn("There were " .. tostring(warn_count) .. " warnings")
  end
  if err_count > 0 then
    echo.err("There were " .. tostring(err_count) .. " errors")
  end
end

---Create a new daily note.
---
---@param client obsidian.Client
---@param _ table
command.today = function(client, _)
  local note = Note.today(client.dir)
  if not note:exists() then
    note:save()
  end
  vim.api.nvim_command "w"
  vim.api.nvim_command("e " .. tostring(note.path))
end

---Open a note in the Obsidian app.
---
---@param client obsidian.Client
---@param data table
command.open = function(client, data)
  local vault = client:vault()
  if vault == nil then
    echo.err "couldn't find an Obsidian vault"
    return
  end
  local vault_name = vim.fs.basename(vault)

  local path
  if data.args:len() > 0 then
    path = Path:new(data.args):make_relative(vault)
  else
    local bufname = vim.api.nvim_buf_get_name(0)
    path = Path:new(bufname):make_relative(vault)
  end

  local encoded_vault = util.urlencode(vault_name)
  local encoded_path = util.urlencode(tostring(path))

  local app = "/Applications/Obsidian.app"
  if Path:new(app):exists() then
    local cmd = ("open -a %s --background 'obsidian://open?vault=%s&file=%s'"):format(app, encoded_vault, encoded_path)
    os.execute(cmd)
  else
    echo.err "could not detect Obsidian application"
  end
end

local commands = {
  ObsidianCheck = command.check,
  ObsidianToday = command.today,
  ObsidianOpen = command.open,
}

---Register all commands.
---
---@param client obsidian.Client
command.register_all = function(client)
  for command_name, command_func in pairs(commands) do
    local func = function(data)
      command_func(client, data)
    end
    vim.api.nvim_create_user_command(command_name, func, {})
  end
end

return command