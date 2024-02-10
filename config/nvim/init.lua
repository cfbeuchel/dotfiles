--######################--
-- PLUGIN CONFIGURATION --
--######################--

-- Load Plugins from lua/plugins.lua
require('plugins')

-- MASON Setup
require("mason").setup {
    ui = {
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
        }
    }
}

-- Setup LSP installer helper
require("mason-lspconfig").setup {
    ensure_installed = { "lua_ls", "marksman", "pylsp", "texlab", "julials"},
}

-- Setup Quarto
require("quarto").setup{
    lsp_features = {
        chunks = 'all'
    }
}

-- Setup LSP --

-- Declare global config
-- https://vonheikemen.github.io/devlog/tools/setup-nvim-lspconfig-plus-nvim-cmp/
local lsp_defaults = {
  flags = {
    debounce_text_changes = 150,
  },
  capabilities = require('cmp_nvim_lsp').default_capabilities(
    vim.lsp.protocol.make_client_capabilities()
  ),
  on_attach = function(client, bufnr)
    vim.api.nvim_exec_autocmds('User', {pattern = 'LspAttached'})
  end
}

-- Merge lsp_defaults with the lspconfig
local lspconfig = require('lspconfig')

lspconfig.util.default_config = vim.tbl_deep_extend(
  'force',
  lspconfig.util.default_config,
  lsp_defaults -- from the variable above
)

-- Keybindings for LSP
vim.api.nvim_create_autocmd('User', {
  pattern = 'LspAttached',
  desc = 'LSP actions',
  callback = function()
    local bufmap = function(mode, lhs, rhs)
      local opts = {buffer = true}
      vim.keymap.set(mode, lhs, rhs, opts)
    end

    -- Displays hover information about the symbol under the cursor
    bufmap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>')

    -- Jump to the definition
    bufmap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>')

    -- Jump to declaration
    bufmap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>')

    -- Lists all the implementations for the symbol under the cursor
    bufmap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>')

    -- Jumps to the definition of the type symbol
    bufmap('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>')

    -- Lists all the references
    bufmap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>')

    -- Displays a function's signature information
    bufmap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<cr>')

    -- Renames all references to the symbol under the cursor
    bufmap('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>')

    -- Selects a code action available at the current cursor position
    bufmap('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>')
    bufmap('x', '<F4>', '<cmd>lua vim.lsp.buf.range_code_action()<cr>')

        -- Show diagnostics in a floating window
    bufmap('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>')

    -- Move to the previous diagnostic
    bufmap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>')

    -- Move to the next diagnostic
    bufmap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>')
  end
})

-- Setup Rust Tools
lspconfig.rust_analyzer.setup({
    cmd = {"/home/carl/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin/rust-analyzer"},
    single_file_support = true,
    standalone = true,
    on_attach = function(client, bufnr)
      lspconfig.util.default_config.on_attach(client, bufnr)
    end
})

-- Python: black, snakefmt

-- Setup ruff
lspconfig.ruff_lsp.setup{
    cmd = {
        "/home/carl/micromamba/envs/ruff/bin/ruff-lsp"
    }
}

-- Setup Python LS
lspconfig.pylsp.setup{
  settings = {
    pylsp = {
      plugins = {
        pylint = {
          enabled = false
        },
        pyflakes = {
          enabled = false
        }
      }
    }
  }
}

-- Setup Formatter
local util = require "formatter.util"
require("formatter").setup {
    filetype = {
        python = {
            require("formatter.filetypes.python").black
        }
    }
}

-- Setup Latex LS (texlab)
lspconfig.texlab.setup{}

-- Setup Julia LS
lspconfig.julials.setup({
    single_file_support = true,
    on_attach = function(client, bufnr)
      lspconfig.util.default_config.on_attach(client, bufnr)
    end,
    filetypes={"julia"}
})

-- Setup Bash LS
lspconfig.bashls.setup{}

-- Setup LUA LS Sumneko
lspconfig.lua_ls.setup{}

-- Setup R LanguageServer
lspconfig.r_language_server.setup {
    filetypes={"r", "rmd", "quarto"}
}

-- Setup Markdown LS Marksman
lspconfig.marksman.setup({
    cmd = {"/home/carl/.local/share/nvim/mason/packages/marksman/marksman-linux-x64", "server"},
    single_file_support = true,
    standalone = true
})

-- Setup CMP
local cmp = require('cmp')
local luasnip = require('luasnip')
local select_opts = {behavior = cmp.SelectBehavior.Select}

cmp.setup({
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end
    },
    sources = {
  {name = 'path'},
  {name = 'nvim_lsp', keyword_length = 3},
  -- this disables the text completion options
  -- {name = 'buffer', keyword_length = 3},
  {name = 'luasnip', keyword_length = 2},
    },
    window = {
  documentation = cmp.config.window.bordered()
    },
    formatting = {
  fields = {'menu', 'abbr', 'kind'},
  format = function(entry, item)
    local menu_icon = {
      nvim_lsp = 'λ',
      luasnip = '⋗',
      buffer = 'Ω',
      path = '🖫',
    }

    item.menu = menu_icon[entry.source.name]
    return item
  end,
    },
    mapping = {
    ['<CR>'] = cmp.mapping.confirm({select = true}),
    ['<Up>'] = cmp.mapping.select_prev_item(select_opts),
    ['<Down>'] = cmp.mapping.select_next_item(select_opts),
    ['<C-p>'] = cmp.mapping.select_prev_item(select_opts),
    ['<C-n>'] = cmp.mapping.select_next_item(select_opts),
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<C-d>'] = cmp.mapping(function(fallback)
      if luasnip.jumpable(1) then
        luasnip.jump(1)
      else
        fallback()
      end
    end, {'i', 's'}),
    ['<C-b>'] = cmp.mapping(function(fallback)
      if luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, {'i', 's'}),
    ['<Tab>'] = cmp.mapping(function(fallback)
      local col = vim.fn.col('.') - 1

      if cmp.visible() then
        cmp.select_next_item(select_opts)
      elseif col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
        fallback()
      else
        cmp.complete()
      end
    end, {'i', 's'}),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item(select_opts)
      else
        fallback()
      end
    end, {'i', 's'}),
    }
})

-- CMP Diagnostic config
local sign = function(opts)
  vim.fn.sign_define(opts.name, {
    texthl = opts.name,
    text = opts.text,
    numhl = ''
  })
end

sign({name = 'DiagnosticSignError', text = '✘'})
sign({name = 'DiagnosticSignWarn', text = '▲'})
sign({name = 'DiagnosticSignHint', text = '⚑'})
sign({name = 'DiagnosticSignInfo', text = ''})

vim.diagnostic.config({
  virtual_text = false,
  severity_sort = true,
  float = {
    border = 'rounded',
    source = 'always',
    header = '',
    prefix = '',
  },
})

vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
  vim.lsp.handlers.hover,
  {border = 'rounded'}
)

vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
  vim.lsp.handlers.signature_help,
  {border = 'rounded'}
)

-- Recompile lua/plugins.lua after changing automatically
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerCompile
  augroup end
]])

--####################--
-- NVIM CONFIGURATION --
--####################--

local o = vim.opt -- For the globals options
-- local w = vim.wo -- For the window local options
-- local b = vim.bo -- For the buffer local options

o.showmatch = true          -- show matching
o.ignorecase = true        -- case insensitive
o.smartcase = true
o.mouse = 'v'               -- middle-click paste with
o.hlsearch = true           -- highlight search
o.incsearch = true         -- incremental search
o.tabstop = 4               -- number of columns occupied by a tab
o.softtabstop = 4           -- see multiple spaces as tabstops so <BS> does the right thing
o.expandtab = true          -- converts tabs to white space
o.shiftwidth = 4            -- width for autoindents
o.autoindent = true         -- indent a new line the same amount as the line just typed
o.number = true             -- add line numbers
o.colorcolumn = [[80]]     -- set an 80 column border for good coding style
o.mouse ='a'                 -- enable mouse click
o.clipboard = [[unnamedplus]] -- using system clipboard
o.cursorline = true              -- highlight current cursorline
o.ttyfast = true                 -- Speed up scrolling in Vim
o.termguicolors = true
o.spelllang = [[de,en_us]]

-- for omnicompletion
o.completeopt = [[menu,menuone,noselect]]

-- more natural split navigation
o.splitbelow = true
o.splitright = true

-- Colorscheme
o.termguicolors = true
vim.cmd [[colorscheme deus]]

-- o.wildmode=longest,list   -- get bash-like tab completions
-- o.spell                 -- enable spell check (may need to download language package)
-- o.backupdir=~/.cache/vim -- Directory to store backup files.

-- Syntax Highlighting --

vim.cmd([[
    autocmd BufNewFile,BufRead *.snakemake set syntax=snakemake
    autocmd BufNewFile,BufRead Snakefile set filetype=python
    autocmd BufNewFile,BufRead Snakefile set syntax=snakemake
    autocmd BufNewFile,BufRead *.smk set filetype=python
    autocmd BufNewFile,BufRead *.smk set syntax=snakemake
    autocmd BufNewFile,BufRead *.def set filetype=bash
    autocmd BufNewFile,BufRead *.job set syntax=bash
]])

--##################--
-- BASE KEYBINDINGS --
--##################--

-- set the leader to ;
vim.g.mapleader = ';'
vim.g.maplocalleader = ','

-- shortcut for remapping keys
local map = vim.api.nvim_set_keymap

-- FZF LUA
map('n', '<Leader>f', "<cmd>lua require('fzf-lua').files()<CR>",
    { noremap = true, silent = true })

map('n', '<Leader>b', "<cmd>lua require('fzf-lua').buffers()<CR>",
    { noremap = true, silent = true })

map('n', '<Leader>g', "<cmd>lua require('fzf-lua').grep()<CR>",
    { noremap = true, silent = true })

-- Easy-align remapping
map('x', 'ga', '<Plug>(EasyAlign)', {noremap = false})
map('n', 'ga', '<Plug>(EasyAlign)', {noremap = false})

-- Move through tabs
map('n', '<C-Left>', ':tabprevious<CR>', {noremap = true})
map('n', '<C-Right>',  ':tabnext<CR>', {noremap = true})

-- Clipboard Settings
map('v', '<Leader>y', '"*y', {noremap = true})
map('n', '<Leader>y', '"*y', {noremap = true})
map('n', '<Leader>p', '"*p', {noremap = true})

--Map <Space> to / (search) and Ctrl-<Space> to ? (backwards search)
map('n', '<Space>', '/', {noremap = false})
map('n', '<S-Space>', '?', {noremap = false})

-- Toggle maximizer
map('n', '<S-m>', ':call ToggleMaximizeCurrentWindow()<CR>',
    {noremap = true, silent = true})

-- Remap Escape Key for faster use
map('i', 'jj', '<Esc>', {noremap = true})

-- Faster Buffer navigation
map('n', '<C-J>', '<C-W><C-J>', {noremap = true})
map('n', '<C-K>', '<C-W><C-K>', {noremap = true})
map('n', '<C-L>', '<C-W><C-L>', {noremap = true})
map('n', '<C-H>', '<C-W><C-H>', {noremap = true})

map('n', '<C-n>', ':bnext<CR>', {noremap = true})
map('n', '<C-p>', ':bprevious<CR>', {noremap = true})

-- REPL Commands
map('n', '<C-s>', ':TREPLSendLine<CR>', {noremap = true})
map('v', '<C-s>', ':TREPLSendSelection<CR>', {noremap = true})

-- R Shortcuts
map('t', '<A-n>', ' <- ', {noremap = true})
map('i', '<A-n>', ' <- ', {noremap = true})
map('t', '<A-m>', ' %>% ', {noremap = true})
map('i', '<A-m>', ' %>% ', {noremap = true})
-- map('i', ',', ', ', {noremap = true})
-- map('i', '=', ' = ', {noremap = true})

map('i', '<A-i>', '<CR>```{r}<CR><CR>```<up>', {noremap = true})
map('n', '<A-i>', '_i<CR>```{r}<CR><CR>```<up>', {noremap = true})

-- Escape from Terminal mode
map('t', '<Esc>', '<C-\\><C-n>', {noremap = true})

-- Pressing ,ss will toggle and untoggle spell checking
map('n', '<leader>ss', ':setlocal spell!<cr>', {noremap = false})

-- Automatically replace using Spell checking
map('i', '<C-l>', '<c-g>u<Esc>[s1z=`]a<c-g>u', {noremap = true})

-- Spellchecking shortcuts
map('n', '<leader>sn', ']s', {noremap = false})
map('n', '<leader>sp', '[s', {noremap = false})
map('n', '<leader>sa', 'zg', {noremap = false})
map('n', '<leader>s?', 'z=', {noremap = false})

-- This was some colorfix
vim.cmd[[
if &term =~ '256-color'
    set t_ut=
endif
]]

--######################--
-- PLUGIN CONFIGURATION --
--######################--

-- HIGHLIGHTED YANK --
vim.cmd([[
    autocmd TextYankPost * silent! lua vim.highlight.on_yank {higroup=(vim.fn['hlexists']('HighlightedyankRegion') > 0 and 'HighlightedyankRegion' or 'IncSearch'), timeout=500}
]])

-- WEBDEV ICONS --

require'nvim-web-devicons'.setup {
  -- globally enable different highlight colors per icon (default to true)
 -- if set to false all icons will have the default icon's color
 color_icons = true;
 -- globally enable default icons (default to false)
 -- will get overriden by `get_icons` option
 default = true;
}

-- TREESITTER --

-- Prerequisite: Install `tree-sitter-cli`

require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all" (the five listed parsers should always be installed)
  ensure_installed = { "rust", "lua", "r", "vimdoc", "julia" },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = true,

  -- List of parsers to ignore installing (for "all")
  ignore_install = { "javascript" },

  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = {enable = true},
  incremental_selection = {
      enable = true,
      keymaps = {
          init_selection = "gnn", -- set to `false` to disable one of the mappings
          node_incremental = "grn",
          scope_incremental = "grc",
          node_decremental = "grm",
      },
  },
}

-- PLENARY ---
-- For debugging, see rust-tools github page
-- use 'nvim-lua/plenary.nvim'
-- use 'mfussenegger/nvim-dap'

-- VIM-SURROUND --

-- EASY-ALIGN --

-- NETRW --

-- Remove Banner
vim.g['netrw_banner'] = 0

-- set standard windowsize to x
vim.g['netrw_winsize'] = 25

-- open new windows in new vertical split
vim.g['netrw_browse_split'] = 0

