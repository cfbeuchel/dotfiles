return require('lazy').setup({

  -- LSP configuration
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
    }
  },

  -- Ripgrep
  'duane9/nvim-rg',

  -- Formatter for Mason
  'mhartington/formatter.nvim',

  -- Help with remembering keybindings
  { 'folke/which-key.nvim', opts = {} },

  -- Telescope
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-file-browser.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
      },
    }
  },

  -- CMP Autocompletion
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'lukas-reineke/cmp-rg',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'rafamadriz/friendly-snippets',
    }
  },

  -- TREPL functions to send to terminal
  'kassio/neoterm',

  -- Easy-align tool
  'junegunn/vim-easy-align',

  -- Awesome colorschemes
  'rafi/awesome-vim-colorschemes',

  -- Toggle Maximize
  'pmalek/toogle-maximize.vim',

  -- Deal with Tabstop width etc.
  'tpope/vim-sleuth',

  -- Surround with Parenthesis etc.
  'tpope/vim-surround',

  -- Comment out
  'tpope/vim-commentary',

  -- Status Line
  {
      'nvim-lualine/lualine.nvim',
      dependencies = { 'nvim-tree/nvim-web-devicons', lazy = true }
  },

  -- Navigation
  -- 'nvim-neo-tree/neo-tree.nvim',

  -- Treesitter
  {
      'nvim-treesitter/nvim-treesitter',
      dependencies = {
        "nvim-treesitter/nvim-treesitter-textobjects",
      },
      build = ':TSUpdate',
  },

  -- Tags
  -- Gutentags
  -- Requirement: `Exuberant Ctags`
  'ludovicchabant/vim-gutentags',

  -- Tagbar
  'preservim/tagbar',

  -- Vim Tmux Navigator
  'christoomey/vim-tmux-navigator',

  -- Vimtex
  'lervag/vimtex',

  -- Rust configuration
  -- 'simrat39/rust-tools.nvim',

  -- Julia Support
  'JuliaEditorSupport/julia-vim',

  -- Quarto Support
  {
    'quarto-dev/quarto-nvim',
    dependencies = {
      'vim-pandoc/vim-pandoc-syntax',
      'jmbuhr/otter.nvim',
    }
  },

  -- Syntax Plugins
  'jmbuhr/otter.nvim',
  'LukeGoodsell/nextflow-vim',
})
