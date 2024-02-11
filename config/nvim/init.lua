-- nvim configuration
-- Carl Beuchel, 2024-02-10
-- Use https://github.com/nvim-lua/kickstart.nvim/blob/master/init.lua as template

-- Ensure lazy.nvim is installed
-- Tutorial for installation: https://www.youtube.com/watch?v=aqlxqpHs-aQ
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
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

-- Leader
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Load configurations from additional files
require('plugins')
require('keymaps')

-- MASON --

-- `Mason` Setup
require("mason").setup {
    ui = {
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
        }
    }
}

-- `mason-lspconfig` bridges mason.nvim with the lspconfig plugin
require("mason-lspconfig").setup {
    ensure_installed = {"lua_ls", "marksman", "texlab"},
}

-- TREESITTER --

-- Prerequisite: Install `tree-sitter-cli`
require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all" (the five listed parsers should always be installed)
  ensure_installed = { "rust", "lua", "r", "vimdoc", "julia" },
  sync_install = false,
  auto_install = true,
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

-- TELESCOPE --

-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
      },
    },
  },
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- Telescope live_grep in git root
-- Function to find the git root directory based on the current buffer's path
local function find_git_root()
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir
  local cwd = vim.fn.getcwd()
  if current_file == '' then
    current_dir = cwd
  else
    current_dir = vim.fn.fnamemodify(current_file, ':h')
  end 
  local git_root = vim.fn.systemlist('git -C ' .. vim.fn.escape(current_dir, ' ') .. ' rev-parse --show-toplevel')[1]
  if vim.v.shell_error ~= 0 then
    print 'Not a git repository. Searching on current working directory'
    return cwd
  end
  return git_root
end

-- Custom live_grep function to search in git root
local function live_grep_git_root()
  local git_root = find_git_root()
  if git_root then
    require('telescope.builtin').live_grep {
      search_dirs = { git_root },
    }
  end
end

vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

local function telescope_live_grep_open_files()
  require('telescope.builtin').live_grep {
    grep_open_files = true,
    prompt_title = 'Live Grep in Open Files',
  }
end
vim.keymap.set('n', '<leader>s/', telescope_live_grep_open_files, { desc = '[S]earch [/] in Open Files' })
vim.keymap.set('n', '<leader>ss', require('telescope.builtin').builtin, { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sG', ':LiveGrepGitRoot<cr>', { desc = '[S]earch by [G]rep on Git Root' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })

-- STATUS LINE
require('lualine').setup {
    theme = 'gruvbox_dark',
}

-- Webdev Icons
require('nvim-web-devicons').setup {
 color_icons = true;
 default = true;
}

-- AUTOCOMPLETION CMP --

-- Cmp
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
    {name = 'rg'}, -- Ripgrep support w/ `cmp-rg`
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

-- Cmp Diagnostic config
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

-- Languagserver diagnostic settings
vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
  vim.lsp.handlers.hover,
  {border = 'rounded'}
)

vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
  vim.lsp.handlers.signature_help,
  {border = 'rounded'}
)

-- LANGUAGESERVER PROTOCOL --

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

    -- Displays a function's signature information
    bufmap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<cr>')

    -- Telescope Keybindings
    -- , '[G]oto [D]efinition'
    bufmap('n', 'gd', require('telescope.builtin').lsp_definitions)
    -- , '[G]oto [R]eferences'
    bufmap('n', 'gr', require('telescope.builtin').lsp_references)
    -- , '[G]oto [I]mplementation'
    bufmap('n', 'gi', require('telescope.builtin').lsp_implementations)
    -- , 'Type [D]efinition'
    bufmap('n', '<leader>D', require('telescope.builtin').lsp_type_definitions)
    -- , '[D]ocument [S]ymbols'
    bufmap('n', '<leader>ds', require('telescope.builtin').lsp_document_symbols)
    -- , '[W]orkspace [S]ymbols'
    bufmap('n', '<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols)

    -- Jump to the definition
    -- bufmap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>')

    -- Lists all the references
    -- bufmap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>')

    -- Lists all the implementations for the symbol under the cursor
    -- bufmap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>')

    -- Jumps to the definition of the type symbol
    -- bufmap('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>')

    -- Jump to declaration
    bufmap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>')

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

-- WHICH KEYS --

-- document existing key chains
require('which-key').register {
  ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
  ['<leader>d'] = { name = '[D]ocument', _ = 'which_key_ignore' },
  -- ['<leader>g'] = { name = '[G]it', _ = 'which_key_ignore' },
  -- ['<leader>h'] = { name = 'Git [H]unk', _ = 'which_key_ignore' },
  ['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
  ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
  ['<leader>t'] = { name = '[T]oggle', _ = 'which_key_ignore' },
  ['<leader>w'] = { name = '[W]orkspace', _ = 'which_key_ignore' },
}
-- register which-key VISUAL mode
-- required for visual <leader>hs (hunk stage) to work
require('which-key').register({
  ['<leader>'] = { name = 'VISUAL <leader>' },
  ['<leader>h'] = { 'Git [H]unk' },
}, { mode = 'v' })

-- LANGUAGE SETUP --

-- Rust
lspconfig.rust_analyzer.setup({
    cmd = {"/home/carl/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin/rust-analyzer"},
    single_file_support = true,
    standalone = true,
    on_attach = function(client, bufnr)
      lspconfig.util.default_config.on_attach(client, bufnr)
    end
})

-- Python
-- TODO: black, ruff, snakefmt
lspconfig.ruff_lsp.setup{
    cmd = {
        "/home/carl/micromamba/envs/ruff/bin/ruff-lsp"
    }
}
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

-- Latex
lspconfig.texlab.setup{}

-- Julia
lspconfig.julials.setup({
    single_file_support = true,
    standalone = true,
    on_attach = function(client, bufnr)
      lspconfig.util.default_config.on_attach(client, bufnr)
    end,
    filetypes={"julia"}
})

-- Bash
lspconfig.bashls.setup{}

-- Lua
lspconfig.lua_ls.setup{}

-- R
lspconfig.r_language_server.setup {
    cmd = { "/usr/bin/R", "--slave", "-e", "languageserver::run()" },
    filetypes={"r", "rmd", "quarto"},
}

-- Marksman
lspconfig.marksman.setup({
    cmd = {"/home/carl/.local/share/nvim/mason/packages/marksman/marksman-linux-x64", "server"},
    single_file_support = true,
    standalone = true
})

-- GUTENTAGS --

-- require("vim-gutentags").setup{}

-- TAGBAR --

-- require("tagbar").setup{}

-- OTTER --

-- TODO (https://github.com/jmbuhr/otter.nvim)


-- VIM SURROUND --

-- TODO

-- EASY ALIGN --

-- TODO

-- Programming Language Support --

-- Quarto
require("quarto").setup{
    lsp_features = {
        chunks = 'all'
    }
}

-- Julia
-- TODO: 'julia-vim'


-- NETRW --

-- Remove Banner
vim.g['netrw_banner'] = 0

-- set standard windowsize to x
vim.g['netrw_winsize'] = 25

-- open new windows in new vertical split
vim.g['netrw_browse_split'] = 0

-- GENERAL SETTINGS --

local o = vim.opt -- For the globals options
-- local w = vim.wo -- For the window local options
-- local b = vim.bo -- For the buffer local options

o.showmatch = true          -- show matching
o.ignorecase = true        -- case insensitive
o.smartcase = true
o.mouse = 'v'               -- middle-click paste with
o.hlsearch = true           -- highlight search
o.incsearch = true         -- incremental search
-- o.tabstop = 4               -- number of columns occupied by a tab
-- o.softtabstop = 4           -- see multiple spaces as tabstops so <BS> does the right thing
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

-- This was some colorfix
vim.cmd[[
if &term =~ '256-color'
    set t_ut=
endif
]]

-- o.wildmode=longest,list  -- get bash-like tab completions
-- o.spell                  -- enable spell check (may need to download language package)
-- o.backupdir=~/.cache/vim -- Directory to store backup files.

-- Highlighting Yank
vim.cmd[[au TextYankPost * silent! lua vim.highlight.on_yank()]]

-- Gutentags Status Line
vim.cmd[[set statusline+=%{gutentags#statusline()}]]

-- FILETYPES --

-- Syntax configuration for specific file types
vim.cmd([[
    autocmd BufNewFile,BufRead *.snakemake set syntax=snakemake
    autocmd BufNewFile,BufRead Snakefile set filetype=python
    autocmd BufNewFile,BufRead Snakefile set syntax=snakemake
    autocmd BufNewFile,BufRead *.smk set filetype=python
    autocmd BufNewFile,BufRead *.smk set syntax=snakemake
    autocmd BufNewFile,BufRead *.def set filetype=bash
    autocmd BufNewFile,BufRead *.job set syntax=bash
]])

