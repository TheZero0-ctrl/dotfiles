return {
  'dense-analysis/ale',
  config = function()
    -- What do we use for linting
    vim.g.ale_linters = {
      ruby = {"rubocop"},
      go = {"gopls"},
    }

    vim.g.ale_linters_explicit = 1
    -- vim.g:ale_use_neovim_diagnostics_api = 1

    -- vim.g.ale_ruby_rubocop_executable = 'bundle'
    -- vim.g.ale_ruby_rubocop_options = 'exec rubocop'

    -- Tune linter's error and warning signs
    vim.g.ale_sign_error = '•'
    vim.g.ale_sign_warning = '•'

    -- Let's leave a column for the signs so that the left side of the window doesn't move
    vim.g.ale_sign_column_always = 1
    vim.g.ale_fixers = {
      ruby = {"rubocop"},
      go = {"gofmt"},
    }

    -- vim.g.ale_disable_lsp = 1
    -- vim.g.ale_completion_autoimport = 0

    vim.keymap.set('n', '<leader>rf', vim.cmd.ALEFix, {})
    vim.keymap.set('n', '<leader>ca', vim.cmd.ALECodeAction, {})

    -- don't show warning on right side of code
    vim.g.ale_virtualtext_cursor = 'disabled'
  end
}
