local lsp_zero = require('lsp-zero')

-- require'lspconfig'.stimulus_ls.setup{
--   settings = {
--     filetypes = { "stimulus", "html", "css", "scss", "js", "jsx", "ts", "tsx", "erb" },
--   }
-- }

lsp_zero.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({buffer = bufnr})
end)

require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = {},
  handlers = {
    lsp_zero.default_setup,
    gopls = function()
      return
    end,
    eslint = function ()
        vim.lsp.enable('eslint')
    end,
    -- gopls = function ()
    --     require('lspconfig').gopls.setup({
    --       settings = {
    --         gopls = {
    --           diagnostics = false
    --         }
    --       }
    --     })
    -- end,
    lua_ls = function ()
        vim.lsp.config('lua_ls', {
          settings = {
            Lua = {
              diagnostics = {
                globals = {
                  'vim',
                  'require',
                }
              },
              workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
              },
              telemetry = {
                enable = false,
              }
            }
          }
        })

        vim.lsp.enable('lua_ls')
    end,
  },
})

-- require('lspconfig').solargraph.setup({
--     settings = {
--         solargraph = {
--             diagnostics = false
--         }
--     }
-- })

local cmp = require("cmp")
cmp.setup({
  preselect = 'item',
  completion = {
    completeopt = 'menu,menuone,noinsert'
  },
  mapping = cmp.mapping.preset.insert({
    ['<CR>'] = cmp.mapping.confirm({select = false}),
  })
})
