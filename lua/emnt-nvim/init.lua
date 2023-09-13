-- Expand "<leader>" to this value
vim.g.mapleader = " "
vim.g.maplocalleader = " "
-- Avoid useless movement with space in normal and visual modes
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Don't limit colors to 256 in terminal
vim.opt.termguicolors = true
-- Instead of closing buffers when changing view - hide them
vim.opt.hidden = true
-- Enable mouse in all modes
vim.opt.mouse = "a"
-- Creates new windows in bottom/right instead of top/left
vim.opt.splitbelow = true
vim.opt.splitright = true
-- Show column with line offsets
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.numberwidth = 1
-- Always show column with diagnostic signs, even if there are no errors
vim.opt.signcolumn = "yes"
-- Tab size equal to 4 spaces by default
vim.opt.tabstop = 4
-- shiftwidth=tabstop
vim.opt.shiftwidth = 0
-- softtabstop=tabstop
vim.opt.softtabstop = 0
-- Replace tabs with spaces
vim.opt.expandtab = true
-- Use persistent undo files for recovery
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true
-- Remove search highlights, but keep highlight while writing regex
vim.opt.hlsearch = false
vim.opt.incsearch = true
-- Replace window title with titlestring
vim.opt.title = true
vim.o.titlestring = "%<%{luaeval('require(\"emnt-nvim.utils\")').project_root_path()}%f"
-- Keeps text stable relative to screen position instead of cursor
vim.opt.splitkeep = "screen"

-- Move between windows
vim.keymap.set("n", "<leader>h", ":wincmd h<cr>")
vim.keymap.set("n", "<leader>j", ":wincmd j<cr>")
vim.keymap.set("n", "<leader>k", ":wincmd k<cr>")
vim.keymap.set("n", "<leader>l", ":wincmd l<cr>")
-- Move windows
vim.keymap.set("n", "<leader>H", ":wincmd H<cr>")
vim.keymap.set("n", "<leader>J", ":wincmd J<cr>")
vim.keymap.set("n", "<leader>K", ":wincmd K<cr>")
vim.keymap.set("n", "<leader>L", ":wincmd L<cr>")
-- Split windows
vim.keymap.set("n", "<leader>-", ":split<cr>")
vim.keymap.set("n", "<leader>|", ":vsplit<cr>")
-- Recenter after moving half a page
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

function P(val)
    print(vim.inspect(val))
end

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

vim.loader.enable()
require("emnt-nvim.plugins")

vim.cmd.colorscheme("solarized8_flat")
