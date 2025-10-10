return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  opts = {},
  config = function()
    local highlight = {
      "CursorColumn",
      "Whitespace",
    }
    require("ibl").setup {
      indent = { char = "┆" },
      whitespace = {
        remove_blankline_trail = false,
      },
      scope = { enabled = false },
    }
  end
}
