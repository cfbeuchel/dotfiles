-- Keybindings & Settings

-- shortcut for remapping keys
local map = vim.api.nvim_set_keymap

-- Easy-align remapping
map('x', 'ga', '<Plug>(EasyAlign)', {noremap = false})
map('n', 'ga', '<Plug>(EasyAlign)', {noremap = false})

-- Move through tabs
map('n', '<C-Left>', ':tabprevious<CR>', {noremap = true})
map('n', '<C-Right>',  ':tabnext<CR>', {noremap = true})

-- Clipboard Settings
map('v', '<Leader>y', '"*y', {noremap = true})
map('n', '<Leader>y', '"*y', {noremap = true})
map('n', '<Leader>p', '"*p', {noremap = true})

-- Toggle maximizer
map('n', '<S-m>', ':call ToggleMaximizeCurrentWindow()<CR>',
    {noremap = true, silent = true})

-- Remap Escape Key for faster use
map('i', 'jj', '<Esc>', {noremap = true})

-- Faster Buffer navigation
map('n', '<C-J>', '<C-W><C-J>', {noremap = true})
map('n', '<C-K>', '<C-W><C-K>', {noremap = true})
map('n', '<C-L>', '<C-W><C-L>', {noremap = true})
map('n', '<C-H>', '<C-W><C-H>', {noremap = true})

map('n', '<C-n>', ':bnext<CR>', {noremap = true})
map('n', '<C-p>', ':bprevious<CR>', {noremap = true})

-- Close buffer in split without closing the split
map('n', '<Leader>bd', ':b#<bar>bd#<CR>', {noremap = true})

-- REPL Commands
map('n', '<C-CR>', ':TREPLSendLine<CR>j', {noremap = true})
map('v', '<C-CR>', ':TREPLSendSelection<CR>j', {noremap = true})

-- R Shortcuts
map('t', '<A-->', ' <- ', {noremap = true})
map('i', '<A-->', ' <- ', {noremap = true})
map('t', '<A-m>', ' %>% ', {noremap = true})
map('i', '<A-m>', ' %>% ', {noremap = true})

-- Insert Quarto Code Chunk (TODO Make makro)
map('i', '<A-i>', '<CR>```{r}<CR><CR>```<up>', {noremap = true})
map('n', '<A-i>', '_i<CR>```{r}<CR><CR>```<up>', {noremap = true})

-- Escape from Terminal mode
map('t', '<Esc>', '<C-\\><C-n>', {noremap = true})

-- Pressing ,ss will toggle and untoggle spell checking
map('n', '<leader>ss', ':setlocal spell!<cr>', {noremap = false})

-- Automatically replace using Spell checking
map('i', '<C-l>', '<c-g>u<Esc>[s1z=`]a<c-g>u', {noremap = true})

-- Quarto Preview
map('n', '<leader>qp', 'require("quarto").quartoPreview', { silent = true, noremap = true })

-- Spellchecking shortcuts
map('n', '<leader>sn', ']s', {noremap = false})
map('n', '<leader>sp', '[s', {noremap = false})
map('n', '<leader>sa', 'zg', {noremap = false})
map('n', '<leader>s?', 'z=', {noremap = false})

-- Tagbar
map('n', '<F8>', ':TagbarToggle<CR>', {noremap = false})

-- Navigation
map('n', '<F7>', ':Lexplore<CR>', {noremap = false})


