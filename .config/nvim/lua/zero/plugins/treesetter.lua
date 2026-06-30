return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  event = { "BufReadPre", "BufNewFile" },
  build = function()
    require("nvim-treesitter").install({
      "ruby",
      "lua",
      "javascript",
      "html",
      "css",
      "python",
      "rust",
      "go",
      "gomod",
      "gosum",
      "gowork",
      "gotmpl",
      "embedded_template",
    }):wait(300000)
  end,
  dependencies = {
    {
      "nvim-treesitter/nvim-treesitter-textobjects",
      branch = "main",
      config = function()
        require("nvim-treesitter-textobjects").setup({
          select = {
            lookahead = true,
          },
          move = {
            set_jumps = true,
          },
        })

        local select = require("nvim-treesitter-textobjects.select")
        local move = require("nvim-treesitter-textobjects.move")
        local swap = require("nvim-treesitter-textobjects.swap")
        local repeatable_move = require("nvim-treesitter-textobjects.repeatable_move")

        vim.keymap.set({ "x", "o" }, "a=", function() select.select_textobject("@assignment.outer", "textobjects") end)
        vim.keymap.set({ "x", "o" }, "i=", function() select.select_textobject("@assignment.inner", "textobjects") end)
        vim.keymap.set({ "x", "o" }, "l=", function() select.select_textobject("@assignment.lhs", "textobjects") end)
        vim.keymap.set({ "x", "o" }, "r=", function() select.select_textobject("@assignment.rhs", "textobjects") end)
        vim.keymap.set({ "x", "o" }, "aa", function() select.select_textobject("@parameter.outer", "textobjects") end)
        vim.keymap.set({ "x", "o" }, "ia", function() select.select_textobject("@parameter.inner", "textobjects") end)
        vim.keymap.set({ "x", "o" }, "ai", function() select.select_textobject("@conditional.outer", "textobjects") end)
        vim.keymap.set({ "x", "o" }, "ii", function() select.select_textobject("@conditional.inner", "textobjects") end)
        vim.keymap.set({ "x", "o" }, "al", function() select.select_textobject("@loop.outer", "textobjects") end)
        vim.keymap.set({ "x", "o" }, "il", function() select.select_textobject("@loop.inner", "textobjects") end)
        vim.keymap.set({ "x", "o" }, "af", function() select.select_textobject("@call.outer", "textobjects") end)
        vim.keymap.set({ "x", "o" }, "if", function() select.select_textobject("@call.inner", "textobjects") end)
        vim.keymap.set({ "x", "o" }, "am", function() select.select_textobject("@function.outer", "textobjects") end)
        vim.keymap.set({ "x", "o" }, "im", function() select.select_textobject("@function.inner", "textobjects") end)
        vim.keymap.set({ "x", "o" }, "ac", function() select.select_textobject("@class.outer", "textobjects") end)
        vim.keymap.set({ "x", "o" }, "ic", function() select.select_textobject("@class.inner", "textobjects") end)
        vim.keymap.set({ "x", "o" }, "ab", function() select.select_textobject("@block.outer", "textobjects") end)
        vim.keymap.set({ "x", "o" }, "ib", function() select.select_textobject("@block.inner", "textobjects") end)

        vim.keymap.set("n", "<leader>na", function() swap.swap_next("@parameter.inner") end)
        vim.keymap.set("n", "<leader>n:", function() swap.swap_next("@property.outer") end)
        vim.keymap.set("n", "<leader>nm", function() swap.swap_next("@function.outer") end)
        vim.keymap.set("n", "<leader>pa", function() swap.swap_previous("@parameter.inner") end)
        vim.keymap.set("n", "<leader>p:", function() swap.swap_previous("@property.outer") end)
        vim.keymap.set("n", "<leader>pm", function() swap.swap_previous("@function.outer") end)

        vim.keymap.set({ "n", "x", "o" }, "]f", function() move.goto_next_start("@call.outer", "textobjects") end)
        vim.keymap.set({ "n", "x", "o" }, "]m", function() move.goto_next_start("@function.outer", "textobjects") end)
        vim.keymap.set({ "n", "x", "o" }, "]c", function() move.goto_next_start("@class.outer", "textobjects") end)
        vim.keymap.set({ "n", "x", "o" }, "]i", function() move.goto_next_start("@conditional.outer", "textobjects") end)
        vim.keymap.set({ "n", "x", "o" }, "]l", function() move.goto_next_start("@loop.outer", "textobjects") end)
        vim.keymap.set({ "n", "x", "o" }, "]s", function() move.goto_next_start("@local.scope", "locals") end)
        vim.keymap.set({ "n", "x", "o" }, "]z", function() move.goto_next_start("@fold", "folds") end)
        vim.keymap.set({ "n", "x", "o" }, "]F", function() move.goto_next_end("@call.outer", "textobjects") end)
        vim.keymap.set({ "n", "x", "o" }, "]M", function() move.goto_next_end("@function.outer", "textobjects") end)
        vim.keymap.set({ "n", "x", "o" }, "]C", function() move.goto_next_end("@class.outer", "textobjects") end)
        vim.keymap.set({ "n", "x", "o" }, "]I", function() move.goto_next_end("@conditional.outer", "textobjects") end)
        vim.keymap.set({ "n", "x", "o" }, "]L", function() move.goto_next_end("@loop.outer", "textobjects") end)
        vim.keymap.set({ "n", "x", "o" }, "[f", function() move.goto_previous_start("@call.outer", "textobjects") end)
        vim.keymap.set({ "n", "x", "o" }, "[m", function() move.goto_previous_start("@function.outer", "textobjects") end)
        vim.keymap.set({ "n", "x", "o" }, "[c", function() move.goto_previous_start("@class.outer", "textobjects") end)
        vim.keymap.set({ "n", "x", "o" }, "[i", function() move.goto_previous_start("@conditional.outer", "textobjects") end)
        vim.keymap.set({ "n", "x", "o" }, "[l", function() move.goto_previous_start("@loop.outer", "textobjects") end)
        vim.keymap.set({ "n", "x", "o" }, "[F", function() move.goto_previous_end("@call.outer", "textobjects") end)
        vim.keymap.set({ "n", "x", "o" }, "[M", function() move.goto_previous_end("@function.outer", "textobjects") end)
        vim.keymap.set({ "n", "x", "o" }, "[C", function() move.goto_previous_end("@class.outer", "textobjects") end)
        vim.keymap.set({ "n", "x", "o" }, "[I", function() move.goto_previous_end("@conditional.outer", "textobjects") end)
        vim.keymap.set({ "n", "x", "o" }, "[L", function() move.goto_previous_end("@loop.outer", "textobjects") end)

        vim.keymap.set({ "n", "x", "o" }, ";", repeatable_move.repeat_last_move)
        vim.keymap.set({ "n", "x", "o" }, ",", repeatable_move.repeat_last_move_opposite)
        vim.keymap.set({ "n", "x", "o" }, "f", repeatable_move.builtin_f_expr, { expr = true })
        vim.keymap.set({ "n", "x", "o" }, "F", repeatable_move.builtin_F_expr, { expr = true })
        vim.keymap.set({ "n", "x", "o" }, "t", repeatable_move.builtin_t_expr, { expr = true })
        vim.keymap.set({ "n", "x", "o" }, "T", repeatable_move.builtin_T_expr, { expr = true })
      end,
    },
  },
  config = function()
    local treesitter = require("nvim-treesitter")

    treesitter.setup({
      install_dir = vim.fn.stdpath("data") .. "/site",
    })

    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        pcall(vim.treesitter.start, args.buf)
      end,
    })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = {
        "ruby",
        "lua",
        "javascript",
        "typescript",
        "tsx",
        "html",
        "css",
        "python",
        "rust",
        "go",
        "gomod",
        "gosum",
        "gowork",
        "gotmpl",
      },
      callback = function()
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
