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

-- Example using a list of specs with the default options
vim.g.mapleader = " " -- Make sure to set `mapleader` before lazy so your mappings are correct

require("lazy").setup({
	'nvim-tree/nvim-tree.lua',
	'tyrannicaltoucan/vim-quantum',
	'williamboman/mason.nvim',
	'williamboman/mason-lspconfig.nvim',
	'neovim/nvim-lspconfig',
	{
		'nvim-telescope/telescope.nvim', tag = '0.1.2',
		dependencies = { 'nvim-lua/plenary.nvim' }
	},
	{
	 "folke/trouble.nvim", dependencies = { "nvim-tree/nvim-web-devicons" }, opts = { },
	},
	 "hrsh7th/nvim-cmp",
	 "hrsh7th/cmp-nvim-lsp",
	{
	"L3MON4D3/LuaSnip",
	-- follow latest release.
	version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
	-- install jsregexp (optional!).
	build = "make install_jsregexp"
	},
	"saadparwaiz1/cmp_luasnip"
})


vim.opt.guicursor = ""
vim.opt.compatible = false
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.hlsearch = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.tabstop=8
vim.opt.shiftwidth=8
vim.opt.expandtab = false
--highlighting line number
vim.opt.cursorline = true
vim.opt.foldmethod= 'syntax'
vim.opt.foldlevelstart=1
vim.opt.foldnestmax=6
--"keep 10 lines above/below the cursor when moving
vim.opt.scrolloff=8
--"display all matching file when we tab complete
vim.opt.wildmenu=true 
vim.opt.spell = true
vim.opt.colorcolumn = "80"
-- disable mouse
vim.opt.mouse = ""
vim.opt.signcolumn = "yes"

vim.cmd("filetype indent on")
vim.cmd("filetype plugin on")

vim.cmd.colorscheme('quantum')
-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

vim.cmd('syntax enable')

--load file changed outside vim
vim.opt.autoread = true
vim.cmd('autocmd FocusGained,BufEnter,CursorHold,CursorHoldI * :checktime')

-- need a map method to handle the different kinds of key maps
local function map(mode, combo, mapping, opts)
  local options = {noremap = true}
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.api.nvim_set_keymap(mode, combo, mapping, options)
end

--disable Ex mode
map('n', 'Q', '<NOP>', {noremap = true})
map('n', '<space>', '<nop>', {noremap = true})
--Go to normal mode from insert mode
map('i', 'jk', '<esc>', {noremap=true})
--Move the current line down
map('', '-', 'dd _p')
--Close current tab
map('n', 'tc', ':tabclose<cr>', {noremap=true})
--New tab
map('n', 'tn', ':tabnew<cr>', {noremap=true})
--Go to next tab
map('n', 'tj', ':tabnext<CR>', {noremap=true})
--Go to previous tab
map('n', 'tk', ':tabprev<CR>', {noremap=true})
----Go to normal mode from insert mode
map('i','jk', '<esc>',  {noremap=true})
--Go to left window
map('n', '<leader>h', ':wincmd h<CR>', {noremap=true})
--Go to right window
map('n', '<leader>l', ':wincmd l<CR>', {noremap =true})
--Go to top window
map('n', '<leader>j', ':wincmd j<CR>', {noremap =true})
--Go to bottom window
map('n','<leader>k', ':wincmd k<CR>', {noremap = true})
--Disable esc key
map('i', '<esc>', '<nop>',  {noremap = true})
----Disable arrows keys! Use vim correctly
map('n', '<Up>',    '<nop>', {noremap=true})
map('n', '<Down>',  '<nop>', {noremap=true})
map('n', '<Left>',  '<nop>', {noremap=true})
map('n', '<Right>', '<nop>', {noremap=true})
-- Horizontal nav'igation shortcut
--Move 20 characters to the right
map('n', '<C-l>', '20zl', {noremap=true})
--Move 20 characters to the left
map('n', '<C-h>', '20zh', {noremap=true})
-- Copy to clipboard
map('v', '<leader>y', '"+y', {noremap=true})
map('n', '<leader>Y', '"+yg_', {noremap=true})
map('n', '<leader>y', '"+y', {noremap=true})
map('n', '<leader>yy','"+yy', {noremap=true})
-- Paste from clipboard
map('n', '<leader>p', '"+p', {noremap=true})
map('n', '<leader>P', '"+P', {noremap=true})
map('v', '<leader>p', '"+p', {noremap=true})
map('v', '<leader>P', '"+P', {noremap=true})


-- NVIM TREE PLUGIN SETTINGS --
-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1


-- empty setup using defaults
require("nvim-tree").setup()

-- OR setup with some options
require("nvim-tree").setup({
  sort_by = "case_sensitive",
  view = {
    width = 30,
  },
  update_focused_file = {
    enable = true,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = true,
  },
  tab = {
    sync = {
      open = true,
      close = true,
    },
  },
})

local function open_nvim_tree(data)
  -- buffer is a real file on the disk
  local real_file = vim.fn.filereadable(data.file) == 1
  -- buffer is a [No Name]
  local no_name = data.file == "" and vim.bo[data.buf].buftype == ""
  if not real_file and not no_name then
    return
  end

  -- open the tree, find the file but don't focus it
  require("nvim-tree.api").tree.toggle({ focus = false, find_file = true, })
end

vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })

local cmp = require("cmp")

cmp.setup{
	snippet = {
		expand = function(args)
			require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
		end,
	},
	mapping = cmp.mapping.preset.insert({
		['<C-b>'] = cmp.mapping.scroll_docs(-4),
		['<C-f>'] = cmp.mapping.scroll_docs(4),
		['<C-Space>'] = cmp.mapping.complete(),
		['<C-e>'] = cmp.mapping.abort(),
		['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
	}),
	sources = cmp.config.sources({
		{ name = 'nvim_lsp' },
		{ name = 'luasnip' },
	}),
}

-- LSP CONFIG --
require("mason").setup()
require("mason-lspconfig").setup {
    ensure_installed = { "rust_analyzer", "pyright", "gopls" },
    automatic_installation = true,
}
local capabilities = require('cmp_nvim_lsp').default_capabilities()

require("lspconfig").rust_analyzer.setup { capabilities = capabilities, }
require("lspconfig").gopls.setup { capabilities = capabilities, }
require("lspconfig").pyright.setup { capabilities = capabilities, }

-- TELESCOPE PLUGIN --
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.git_files, {})

-- LSP --
vim.api.nvim_create_autocmd('LspAttach', {
	callback = function(args)
		opts = { buffer = args.buf, remap=false }
		vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
		vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
		vim.keymap.set("n", "<leader>ca", function() vim.lsp.buf.code_action() end, opts)
		--vim.keymap.set("n", "gr", function() vim.lsp.buf.references() end, opts)
		vim.keymap.set("n", "gi", function() vim.lsp.buf.implementation() end, opts)
		vim.keymap.set("n", "<leader>rn", function() vim.lsp.buf.rename() end, opts)
		vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
		vim.keymap.set("n", "<leader>q", function() vim.cmd("ccl") end, opts)
		vim.keymap.set("n", "<leader>qs", function() vim.cmd("pc") end, opts)

		vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
		vim.keymap.set("n", "<leader>[", function() vim.diagnostic.goto_next() end, opts)
		vim.keymap.set("n", "<leader>]", function() vim.diagnostic.goto_prev() end, opts)

		vim.keymap.set("n", "gr", function() require("trouble").toggle("lsp_references") end)

	end,
})

vim.keymap.set("n", "<leader>tx", function() require("trouble").toggle() end)
vim.keymap.set("n", "<leader>tw", function() require("trouble").toggle("workspace_diagnostics") end)
vim.keymap.set("n", "<leader>td", function() require("trouble").toggle("document_diagnostics") end)
vim.keymap.set("n", "<leader>tq", function() require("trouble").toggle("quickfix") end)
vim.keymap.set("n", "<leader>tl", function() require("trouble").toggle("loclist") end)
