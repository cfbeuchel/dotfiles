return require('packer').startup(function()

  -- Packer package manager
  use 'wbthomason/packer.nvim'

  -- Mason
  use 'williamboman/mason.nvim'
  use 'williamboman/mason-lspconfig.nvim'

  -- LSP configuration
  use 'neovim/nvim-lspconfig'

  -- Rust configuration
  -- use 'simrat39/rust-tools.nvim'

  use 'kassio/neoterm'

  -- Easy-align tool
  use 'junegunn/vim-easy-align'

  -- Awesome colorschemes
  use 'rafi/awesome-vim-colorschemes'

  -- Toggle Maximize
  use 'pmalek/toogle-maximize.vim'

  -- Surround with Parenthesis etc.
  use 'tpope/vim-surround'

  -- Comment out
  use 'tpope/vim-commentary'

  -- Vimtex
  use 'lervag/vimtex'

  -- CMP Autocompletion
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-cmdline'
  use 'hrsh7th/nvim-cmp'
  use 'rafamadriz/friendly-snippets'

  -- For luasnip users
  use 'L3MON4D3/LuaSnip'
  use 'saadparwaiz1/cmp_luasnip'

  -- Fuzzy Seach
  use 'vijaymarupudi/nvim-fzf'
  use 'ibhagwan/fzf-lua'

  -- Icons
  use 'nvim-tree/nvim-web-devicons'

  -- Ripgrep
  use 'duane9/nvim-rg'

  -- Formatter for Mason
  use 'mhartington/formatter.nvim'

  -- Status Line

  -- Navigation
  -- use 'nvim-neo-tree/neo-tree.nvim'

  -- telescope -> replace fzf? use with rg, fd
  -- https://github.com/nvim-telescope/telescope.nvim
  -- https://github.com/nvim-telescope/telescope-file-browser.nvim
  -- https://github.com/nvim-lua/plenary.nvim

  -- TODO
  -- Test, DBG

  -- Treesitter
  use {
      'nvim-treesitter/nvim-treesitter',
      run = ':TSUpdate'
  }

  -- Syntax Plugins
  use 'vim-pandoc/vim-pandoc-syntax'
  use 'quarto-dev/quarto-nvim'
  use 'jmbuhr/otter.nvim'
  use 'LukeGoodsell/nextflow-vim'

  -- https://github.com/jose-elias-alvarez/null-ls.nvim

end)
