# NeoVim `init.lua`
Use this as your `init.lua`, put it here:
  - Windows: `%localappdata%\nvim\init.lua`
  - Linux: `~/.config/nvim/init.lua`
  - MacOS: `~/.config/nvim/init.lua`
```lua
local file = "nvim.lua"
local path = vim.fn.expand(vim.fn.stdpath('config')..'/'..file)
local url = "https://raw.githubusercontent.com/Raik176/random-stuff/master/"..file.."?cache_bust=timestamp"
local do_update = true

local function update_config()
    if do_update == false then
      dofile(path)
      return
    end
    local response = vim.fn.system({"curl", "-s", url})
    local message = ""
    local function write()
        local fd = vim.loop.fs_open(path, "w+", 438)
        vim.loop.fs_write(fd, response, 0)
        vim.loop.fs_close(fd)
        message = "Updated your config!"
    end
    if vim.loop.fs_stat(path) then
        if response ~= table.concat(vim.fn.readfile(path), '\n') then
            write()
        end
    else
        write()
    end
    dofile(path)
    if message ~= "" then
        vim.notify(message) -- Notify here so if vim.notify is replaced it'll use that instead.
    end
end

vim.loop.new_async(vim.schedule_wrap(update_config)):send()
```
