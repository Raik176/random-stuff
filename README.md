# Nvim `init.lua`
```
local function download_config()
  vim.fn.system({
    "curl",
    "-o",
    "nvim.lua",
    "https://raw.githubusercontent.com/Raik176/random-stuff/master/nvim.lua"
  })
  dofile("nvim.lua")
end

coroutine.wrap(download_config)()
```
