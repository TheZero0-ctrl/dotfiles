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
    solargraph = function ()
         require('lspconfig').solargraph.setup({
            settings = {
                solargraph = {
                    diagnostics = false
                }
            }
        })
    end,
    eslint = function ()
        require('lspconfig').eslint.setup({})
    end,
    lua_ls = function ()
        require('lspconfig').lua_ls.setup({
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

