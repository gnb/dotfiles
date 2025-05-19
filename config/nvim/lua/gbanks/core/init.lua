vim.opt.autoindent = true
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.tabstop = 8
vim.opt.expandtab = true
vim.opt.textwidth = 72
vim.opt.formatoptions = vim.opt.formatoptions + "cro"
-- " Remember:  gq]/  formats to the end of the comment
vim.opt.wrap = false
vim.opt.modelines = 5
vim.opt.hidden = true
vim.opt.list = true
vim.opt.listchars = 'tab:\\u25b6 ,leadmultispace:\\u25b8   ,trail:\\u00b7'
-- Neovim needs this to choose non-garish colors
vim.opt.background = 'light'
vim.opt.termguicolors = true
vim.cmd('colorscheme ironman')
vim.opt.smartindent = true

vim.g.mapleader = ' '

vim.api.nvim_create_autocmd("FileType", {
    pattern = "java",
    callback = function()
        vim.opt_local.shiftwidth = 2
        vim.opt.listchars = 'tab:\\u25b6 ,leadmultispace:\\u25b8 ,trail:\\u00b7'
    end
})
