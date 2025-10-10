return {
  'nvim-telescope/telescope.nvim', tag = '0.1.5',
  dependencies = {
    'nvim-lua/plenary.nvim',
    {'nvim-telescope/telescope-fzf-native.nvim', build = 'make'},
  },
  config = function()
    require('telescope').setup(
      {
        -- defaults = {
        --   layout_config = {
        --     height = 1,
        --   },
        -- },
        -- pickers = {
        --   find_files = {
        --     theme = "ivy"
        --   }
        -- },
        extensions = {
          fzf = {}
        }
      }
    )
    require('telescope').load_extension('fzf')
    local builtin = require('telescope.builtin')
    vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
    vim.keymap.set('n', '<C-p>', builtin.git_files, {})
    vim.keymap.set('n', '<leader>Ps', function()
      local word = vim.fn.expand("<cWORD>")
      builtin.grep_string({ search =  word })
    end)
    vim.keymap.set('n', '<leader>ps', function()
      local word = vim.fn.expand("<cword>")
      builtin.grep_string({ search =  word })
    end)

    require("zero.plugins.telescope.multigrep").setup()
  end
}
