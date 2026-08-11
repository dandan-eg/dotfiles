-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
--
--  ## Telescope
local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local make_entry = require 'telescope.make_entry'
local conf = require('telescope.config').values
local sorters = require 'telescope.sorters'

local M = {}

local live_multigrep = function()
  local opts = {
    cwd = vim.uv.cwd(),
  }

  local finder = finders.new_async_job {
    command_generator = function(prompt)
      if not prompt or prompt == '' then
        return nil
      end

      local pieces = vim.split(prompt, ' | ', { trimempty = true })
      local args = { 'rg' }

      if pieces[1] then
        table.insert(args, '-e')
        table.insert(args, pieces[1])
      end

      if pieces[2] then
        table.insert(args, '-g')
        table.insert(args, pieces[2])
      end

      local default_args = { '--color=never', '--no-heading', '--with-filename', '--line-number', '--column', '--smart-case' }
      for _, value in pairs(default_args) do
        table.insert(args, value)
      end

      return args
    end,
    entry_maker = make_entry.gen_from_vimgrep(opts),
    cwd = opts.cwd,
  }

  pickers
    .new(opts, {
      prompt_title = 'Multi Grep',
      debounce = 300,
      finder = finder,
      previewer = conf.grep_previewer(opts),
      sorter = sorters.empty(),
    })
    :find()
end

M.setup = function()
  vim.keymap.set('n', '<leader>sg', live_multigrep, { desc = '[S]earch by [G]rep' })
end

return M
