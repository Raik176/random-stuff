# Nvim `init.lua`
```lua
local file = "nvim.lua"
local url = "https://raw.githubusercontent.com/Raik176/random-stuff/master/"..file

local function update_config()
  local out = vim.fn.system({ "curl", "-s", url })
  local message = ""
  local fd = vim.loop.fs_open(file, "w+", 438)
  local function write_config()
    vim.loop.fs_write(fd, out)
    message = "Updated your config! Please restart Neovim."
  end
  if not fd then
    write_config()
  else
    local stat = vim.loop.fs_fstat(fd)
    local content = vim.loop.fs_read(fd, stat.size, 0)
    if content ~= out then
      write_config()
    else
      message = "Your config is up to date."
    end
  end
  vim.loop.fs_close(fd)
  dofile("nvim.lua")
  vim.notify(message)
end

coroutine.wrap(update_config)()
end

coroutine.wrap(download_config)()
```
