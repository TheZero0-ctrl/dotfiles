return {
  'dense-analysis/ale',
  config = function()
    -- What do we use for linting
    vim.g.ale_linters = {
      ruby = {"rubocop"},
    }

    vim.g.ale_linters_explicit = 1

    -- Lint Ruby files with binstub
    -- vim.g.ale_ruby_rubocop_executable = 'bin/rubocop'

    -- Tune linter's error and warning signs
    vim.g.ale_sign_error = '•'
    vim.g.ale_sign_warning = '•'

    -- Let's leave a column for the signs so that the left side of the window doesn't move
    vim.g.ale_sign_column_always = 1
    vim.g.ale_fixers = {
      ruby = {"rubocop"},
    }

    vim.keymap.set('n', '<leader>rf', vim.cmd.ALEFix, {})
    vim.keymap.set('n', '<leader>ca', vim.cmd.ALECodeAction, {})

    -- don't show warning on right side of code
    vim.g.ale_virtualtext_cursor = 'disabled'
  end
}
