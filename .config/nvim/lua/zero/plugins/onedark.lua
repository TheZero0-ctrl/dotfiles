return {
  'navarasu/onedark.nvim',
  priority = 1000,
  config = function()
    require('onedark').setup {
      style = 'darker',
      transparent = true,
      colors = {
        bright_orange = "#ff8800",    -- define a new color
        green = '#00ffaa',            -- redefine an existing color
      },
      highlights = {
        TSKeyword = {fg = '$green'},
        TSString = {fg = '$bright_orange', bg = '#00ff00', fmt = 'bold'},
        TSFunction = {fg = '#0000ff', sp = '$cyan', fmt = 'underline,italic'},
        TSFuncBuiltin = {fg = '#0059ff'}
      }
    }
    require('onedark').load()
  end
}
