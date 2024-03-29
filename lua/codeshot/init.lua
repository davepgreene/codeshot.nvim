local option = require('codeshot.option')
local utils = require('codeshot.utils')
local theme = require('codeshot.theme')
local codeshot = {}

_G.codeshot_settings = {}

local function run_sss_code(codeshot_options, opts)
  local extra_args = vim.tbl_extend('force', codeshot_options, opts)
  local output = { output = utils.replace_placeholders(extra_args.output) }
  local curr_theme = {}

  if codeshot_options.use_current_theme then
    curr_theme = { vim_theme = theme.get() }
  end

  local cmd = table.concat({
    codeshot_options.bin_path,
    table.concat(
      utils.obj_to_args(extra_args, { 'bin_path', 'file', 'raw_input', 'use_current_theme', 'output' }),
      ' '
    ),
    table.concat(utils.obj_to_args(curr_theme), ' '),
    table.concat(utils.obj_to_args(output), ' '),
    -- TODO: support load code lines or file
    opts.file,
  }, ' ')
  cmd = cmd:gsub('#', '\\#')

  vim.notify(cmd)

  vim.cmd { cmd = '!', args = { cmd } }
end

function codeshot.take(file, extension, lines, hi_lines)
  local opts = option.get()
  run_sss_code(opts, { file = file, extension = extension, lines = lines, highlight_lines = hi_lines })
end

function codeshot.current(lines, hi_lines)
  local curr = vim.fn.expand('%:p')
  local extension = vim.fn.expand('%:e')
  codeshot.take(curr, extension, lines, hi_lines)
end

function codeshot.selected_lines()
  local curr = vim.fn.expand('%:p')
  local extension = vim.fn.expand('%:e')
  local s_start = vim.fn.getpos("'<")[2]
  local s_end = vim.fn.getpos("'>")[2]
  local lines = s_start .. '..' .. s_end
  codeshot.take(curr, extension, lines, lines)
end

function codeshot.focus_selected_lines()
  local curr = vim.fn.expand('%:p')
  local extension = vim.fn.expand('%:e')
  local s_start = vim.fn.getpos("'<")[2]
  local s_end = vim.fn.getpos("'>")[2]
  -- Calculate len of lines
  -- local n_lines = math.abs(s_end[2] - s_start[2]) + 1
  local hi_lines = s_start .. '..' .. s_end
  codeshot.take(curr, extension, '..', hi_lines)
end

function codeshot.setup(opts)
  option.set(opts)

  vim.api.nvim_create_user_command('SSFocused', codeshot.focus_selected_lines, { range = true })
  vim.api.nvim_create_user_command('SSSelected', codeshot.selected_lines, { range = true })
end

return codeshot
