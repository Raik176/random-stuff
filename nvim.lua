local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local lang_servers = {
  mesonlsp = {},
  asm_lsp = {},
  vimls = {},
  eslint = {},
  lua_ls = {
    on_init = function(client)
      local path = client.workspace_folders[1].name
      if vim.loop.fs_stat(path..'/.luarc.json') or vim.loop.fs_stat(path..'/.luarc.jsonc') then
        return
      end

      client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
        runtime = {
          version = 'LuaJIT'
        },
        workspace = {
          checkThirdParty = false,
          library = {
            vim.env.VIMRUNTIME
          }
      }
    })
    end,
    settings = {
      Lua = {}
    }
  }
}

require("lazy").setup({
  'dstein64/vim-startuptime',
  {'rcarriga/nvim-notify', config = function()
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
    vim.opt.termguicolors = true
    vim.notify = require('notify')
  end},
  'andweeb/presence.nvim',

  'lewis6991/gitsigns.nvim',
  {'neovim/nvim-lspconfig', config = function()
    local lspconfig = require('lspconfig')

    for lsp, conf in pairs(lang_servers) do
      lspconfig[lsp].setup(vim.tbl_deep_extend('keep', conf, { capabilities = require('cmp_nvim_lsp').default_capabilities() }))
    end
  end},

  {'hrsh7th/nvim-cmp', lazy = true, event = 'BufEnter', dependencies = {
    'hrsh7th/vim-vsnip',
    'hrsh7th/cmp-vsnip',
    'hrsh7th/cmp-nvim-lsp'
  }, config = function()
    local cmp = require('cmp')
    cmp.setup({
      snippet = {
        expand = function(args)
          vim.fn['vsnip#anonymous'](args.body)
        end
      },
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered()
      },
      sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'vsnip' }
      })
    })
  end},

  {'nvim-lualine/lualine.nvim', dependencies = {'nvim-tree/nvim-web-devicons'}, opts = { }},

  { 'wakatime/vim-wakatime', lazy = false },
    
  {'gelguy/wilder.nvim', lazy = true, event = "CmdlineEnter", config = function()
    local wilder = require('wilder')
    wilder.setup({modes = {':', '/', '?'}})

    wilder.set_option('renderer', wilder.renderer_mux({
      [':'] = wilder.popupmenu_renderer(),
      ['/'] = wilder.wildmenu_renderer()
    }))
    wilder.set_option('renderer', wilder.popupmenu_renderer(
      wilder.popupmenu_border_theme({
        highlights = {
          border = 'Normal',
        },
        border = 'rounded',
      })
    ))
    wilder.set_option('renderer', wilder.popupmenu_renderer({
      highlighter = wilder.basic_highlighter(),
      left = {' ', wilder.popupmenu_devicons()},
      right = {' ', wilder.popupmenu_scrollbar()},
    }))
  end},
  'karb94/neoscroll.nvim',

  {'romgrk/barbar.nvim', dependencies = {
    'nvim-tree/nvim-web-devicons',
    'lewis6991/gitsigns.nvim'
  }},

  {'RRethy/vim-illuminate', lazy = true, event = "BufEnter", config = function()
    local illuminate = require('illuminate')
    illuminate.configure({
      providers = {
        'lsp',
        'regex'
      }
    })
    vim.cmd([[IlluminateResume]]) -- Enable illuminate
  end},
  {'m4xshen/autoclose.nvim', opts = {
    keys = { }
  }},
  {'nvim-telescope/telescope.nvim', dependencies = { 'nvim-lua/plenary.nvim' }},
  {'vague2k/huez.nvim', import = "huez-manager.import", opts = {}, dependencies = { 'nvim-telescope/telescope.nvim' }},
  {'obaland/vfiler.vim', config = function() -- not really config but it opens the explorer whenever you start nvim which is quite nice
      require('vfiler').start()
  end},
  --'dasupradyumna/midnight.nvim'
  'folke/tokyonight.nvim',

  {"utilyre/barbecue.nvim", dependencies = { -- has to load after theme
    "SmiteshP/nvim-navic",
    "nvim-tree/nvim-web-devicons",
  }, opts = {}},
}, { -- lazy.nvim options
  checker = {
    enabled = true
  },
  performance = {
    rtp = {
      disabled_plugins = { }
    }
  }
})

vim.cmd([[colorscheme tokyonight-storm]]) -- hardcode even though huez is installed because it doesnt load the last picked theme.
vim.opt.number = true -- Enable line numbers
vim.opt.fillchars = { eob = "~" } --hardcode cuz why not

vim.api.nvim_create_autocmd({"BufWinEnter"}, { -- Open new buffers in a new buffer tab
  pattern = "*",
  callback = function()
    if vim.fn.winnr('$') > 1 then
      vim.cmd('wincmd o')
    end
  end
})
