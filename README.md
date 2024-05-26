# NeoVim `init.lua`
Use this as your `init.lua`, put it here:
  - Windows: `%localappdata%\nvim\init.lua`
  - Linux: `~/.config/nvim/init.lua`
  - MacOS: `~/.config/nvim/init.lua`
```lua
local file = "nvim.lua"
local url = "https://raw.githubusercontent.com/Raik176/random-stuff/master/"..file

local function update_config()
    local response = vim.fn.system({"curl", "-s", url})
    local function write()
        local fd = vim.loop.fs_open(file, "w+", 438)
        vim.loop.fs_write(fd, response, 0)
        vim.loop.fs_close(fd)
        vim.notify("Updated your config!")
    end
    if vim.loop.fs_stat(file) then
        if response ~= table.concat(vim.fn.readfile(file)) then
            write()
        end
    else
        write()
    end
    dofile(file)
end

vim.loop.new_async(vim.schedule_wrap(update_config)):send()
```
