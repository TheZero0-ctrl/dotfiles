return  {
  -- Highlight, edit, and navigate code
  'nvim-treesitter/nvim-treesitter',
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    'nvim-treesitter/nvim-treesitter-textobjects',
  },
  build = ':TSUpdate',
  config = function()
    require('nvim-treesitter.configs').setup {
      -- A list of parser names, or "all" (the five listed parsers should always be installed)
      ensure_installed = {
        "ruby",
        "lua",
        "javascript",
        "html",
        "css",
        "python",
        "rust"
      },

      -- Install parsers synchronously (only applied to `ensure_installed`)
      sync_install = false,

      -- Automatically install missing parsers when entering buffer
      -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
      auto_install = true,

      highlight = {
        enable = true,

        additional_vim_regex_highlighting = false,
      },
      indent = {
        enable = true
      },

      autotag = {
        enable = true,
      },

      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
    }
    local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
    parser_config.embedded_template = {
      install_info = {
        url = 'https://github.com/tree-sitter/tree-sitter-embedded-template',
        files =  { 'src/parser.c' },
        requires_generate_from_grammar  = true,
      },
      used_by = {'erb'}
    }
  end
}
