return {
  'thoughtbot/vim-rspec',
  config = function()
    vim.api.nvim_set_keymap('n', '<Leader>c', ':call RunCurrentSpecFile()<CR>', { noremap = true })
    vim.api.nvim_set_keymap('n', '<Leader>h', ':call RunNearestSpec()<CR>', { noremap = true })
  end
}
