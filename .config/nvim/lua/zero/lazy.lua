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
require("lazy").setup({
  -- "folke/which-key.nvim",
  { "folke/neoconf.nvim", cmd = "Neoconf" },
  "folke/neodev.nvim",
  -- colors
  -- "rebelot/kanagawa.nvim",
  -- require "zero.plugins.catpuccin",
  -- require "zero.plugins.onedark",
  require "zero.plugins.theme",
  -- general
  require "zero.plugins.lsp-zero",
  require 'zero.plugins.telescope',
  require 'zero.plugins.treesetter',
  require("zero.plugins.lualine"),
  require("zero.plugins.ale"),
  --- require("zero.plugins.autotag"),
  require("zero.plugins.oil"),
  -- rails and ruby specific
  "tpope/vim-rails",
  require 'zero.plugins.vim-rspec',
  -- window
  'christoomey/vim-tmux-navigator',
  'szw/vim-maximizer',
  -- utility
  'tpope/vim-endwise',
  'tpope/vim-commentary',
  require "zero.plugins.fugitive",
  require "zero.plugins.harpoon",
  'tpope/vim-surround',
  require "zero.plugins.indent-blankline",
  require "zero.plugins.ufo",
  require "zero.plugins.treesj",
  require "zero.plugins.trouble",
  -- 'jiangmiao/auto-pairs',
  -- 'm4xshen/autoclose.nvim',
  -- AI
  -- 'David-Kunz/gen.nvim',
  'Exafunction/codeium.vim',
  -- 'github/copilot.vim',
  -- require "zero.plugins.chatgpt",
  -- require "zero.plugins.llm-on-rails",
})

