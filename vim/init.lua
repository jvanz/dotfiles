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


require("lazy").setup({
	'nvim-tree/nvim-tree.lua',
	'tyrannicaltoucan/vim-quantum',
	'williamboman/mason.nvim',
	'williamboman/mason-lspconfig.nvim',
	'neovim/nvim-lspconfig',
	{
		'nvim-telescope/telescope.nvim', tag = '0.1.8',
		dependencies = { 'nvim-lua/plenary.nvim' }
	},
	{
	 "folke/trouble.nvim", dependencies = { "nvim-tree/nvim-web-devicons" }, opts = { },
	},
	"cappyzawa/starlark.vim",
	"github/copilot.vim",
	{ "catppuccin/nvim", name = "catppuccin", priority = 1000 },
	{"nvim-lualine/lualine.nvim", dependencies =  'nvim-tree/nvim-web-devicons' },
	{ "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
	-- {'akinsho/bufferline.nvim', version = "*", dependencies = 'nvim-tree/nvim-web-devicons'},
	{'hrsh7th/cmp-nvim-lsp'},
	{'hrsh7th/nvim-cmp'},
{
	"L3MON4D3/LuaSnip",
	-- follow latest release.
	version = "v2.3.0", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
	-- install jsregexp (optional!).
	build = "make install_jsregexp"
},
       {
           'numToStr/Comment.nvim',
           opts = {
               -- add any options here
           },
           lazy = false,
        },
	'ahmedkhalf/project.nvim',


})
--
-- Example using a list of specs with the default options
vim.g.mapleader = " " -- Make sure to set `mapleader` before lazy so your mappings are correct

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
vim.opt.foldlevelstart=4
vim.opt.foldnestmax=6
--"keep 10 lines above/below the cursor when moving
vim.opt.scrolloff=8
--"display all matching file when we tab complete
vim.opt.wildmenu=true 
vim.opt.spell = true
vim.opt.colorcolumn = "80,120"
-- disable mouse
vim.opt.mouse = ""
vim.opt.signcolumn = "yes"

vim.cmd("filetype indent on")
vim.cmd("filetype plugin on")

vim.cmd.colorscheme('catppuccin-frappe')
-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

vim.cmd('syntax enable')

--make vim save and load the folding of the document each time it loads
--also places the cursor in the last place that it was left.
vim.cmd("autocmd BufWinLeave * silent! mkview")
vim.cmd("autocmd BufWinEnter * silent! loadview")

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

-- NVIM TREE PLUGIN SETTINGS --
-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1


-- OR setup with some options
require("nvim-tree").setup({
  sort_by = "case_sensitive",
  view = {
    width = 40,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = false,
  },
  tab = {
    sync = {
      open = true,
      close = true,
    },
  },
  diagnostics = {
    enable = true,
  },
  sync_root_with_cwd = true,
  respect_buf_cwd = true,
  update_focused_file = {
    enable = true,
    update_root = true
  },
})

local projects = require("project_nvim").setup {
-- your configuration comes here
-- or leave it empty to use the default settings
-- refer to the configuration section below
  patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json", "=SUSE" },
}

local cmp = require('cmp')
cmp.setup{
  snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        require('luasnip').lsp_expand(args.body)
      end,
    },
	    window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },
	sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
    }, {
      { name = 'buffer' },
    }),
  mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
}

-- LSP CONFIG --
require("mason").setup()
require("mason-lspconfig").setup {
    ensure_installed = { "rust_analyzer", "pyright", "gopls", "vale_ls", "clangd"},
    automatic_installation = true,
}
local capabilities = require('cmp_nvim_lsp').default_capabilities()

require("lspconfig").rust_analyzer.setup { capabilities = capabilities, }
require("lspconfig").gopls.setup { capabilities = capabilities, }
require("lspconfig").pyright.setup { capabilities = capabilities, }
require("lspconfig").vale_ls.setup { capabilities = capabilities, }
require("lspconfig").clangd.setup { capabilities = capabilities, }

require('lualine').setup()
require("ibl").setup()

-- Trouble
require("trouble").setup{
	modes = {
		-- more advanced example that extends the lsp_document_symbols
		symbols = {
			desc = "document symbols",
			mode = "lsp_document_symbols",
			focus = false,
			win = { position = "right" },
			filter = {
				-- remove Package since luals uses it for control flow structures
				["not"] = { ft = "lua", kind = "Package" },
				any = {
					-- all symbol kinds for help / markdown files
					ft = { "help", "markdown" },
					-- default set of symbol kinds
					kind = {
						"Class",
						"Constructor",
						"Enum",
						"Field",
						"Function",
						"Interface",
						"Method",
						"Module",
						"Namespace",
						"Package",
						"Property",
						"Struct",
						"Trait",
					},
				},
			},
		},
	},
}


-- TELESCOPE PLUGIN --
require('telescope').setup {
  defaults = {
    file_ignore_patterns = { "vendor", ".git", ".cargo"},
  }
}
local builtin = require('telescope.builtin')
require('telescope').load_extension('projects')
local extensions = require('telescope').extensions
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.git_files, {})
vim.keymap.set('n', '<leader>fp', extensions.projects.projects, {})

-- LSP --
vim.api.nvim_create_autocmd('LspAttach', {
	callback = function(args)
		opts = { buffer = args.buf, remap=false }
		vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
		vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
		vim.keymap.set("n", "<leader>ca", function() vim.lsp.buf.code_action() end, opts)
		vim.keymap.set("n", "gi", function() vim.lsp.buf.implementation() end, opts)
		vim.keymap.set("n", "<leader>rn", function() vim.lsp.buf.rename() end, opts)
		vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
		vim.keymap.set("n", "gr", function() require("trouble").toggle("lsp_references") end)

		vim.keymap.set("n", "<leader>sd", function() 
			require("trouble").toggle("diagnostics") 
		end)
		vim.keymap.set("n", "<leader>ss", function() 
			require("trouble").toggle("symbols")
		end)
	end,
})

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
-- shortcut to file explorer
map('n', '<leader>e', ':NvimTreeToggle<CR>', {noremap=true})
