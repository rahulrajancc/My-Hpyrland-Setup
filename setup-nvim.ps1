$NvimDir = "$env:LOCALAPPDATA\nvim"
$ConfigDir = "$NvimDir"

Write-Host "Creating Neovim configuration..." -ForegroundColor Cyan

# Create directories
New-Item -ItemType Directory -Force -Path $ConfigDir | Out-Null
New-Item -ItemType Directory -Force -Path "$ConfigDir\lua\config" | Out-Null
New-Item -ItemType Directory -Force -Path "$ConfigDir\lua\plugins" | Out-Null

# ------------------------------------------------------------
# init.lua
# ------------------------------------------------------------

@'
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"

vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true

vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.wrap = false
vim.opt.scrolloff = 8

vim.opt.updatetime = 250
vim.opt.timeoutlen = 400

vim.opt.undofile = true

require("config.lazy")
'@ | Set-Content "$ConfigDir\init.lua"

# ------------------------------------------------------------
# lazy.lua
# ------------------------------------------------------------

@'
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins")
'@ | Set-Content "$ConfigDir\lua\config\lazy.lua"

# ------------------------------------------------------------
# plugins
# ------------------------------------------------------------

@'
return {

  -- VS Code-like theme
  {
    "Mofiqul/vscode.nvim",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("vscode")
    end,
  },

  -- File explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
  },

  -- Icons
  {
    "nvim-tree/nvim-web-devicons",
  },

  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },

  -- LSP
  {
    "neovim/nvim-lspconfig",
  },

  -- Install LSP servers
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
  },

  -- Autocomplete
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
  },

  -- Git
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end,
  },

  -- Status bar
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("lualine").setup()
    end,
  },

  -- Syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
  },

}
'@ | Set-Content "$ConfigDir\lua\plugins\init.lua"

# ------------------------------------------------------------
# LSP configuration
# ------------------------------------------------------------

@'
local lspconfig = require("lspconfig")

local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- TypeScript / JavaScript / React
lspconfig.ts_ls.setup({
  capabilities = capabilities,
})

-- HTML
lspconfig.html.setup({
  capabilities = capabilities,
})

-- CSS
lspconfig.cssls.setup({
  capabilities = capabilities,
})

-- JSON
lspconfig.jsonls.setup({
  capabilities = capabilities,
})

-- Lua
lspconfig.lua_ls.setup({
  capabilities = capabilities,
})
'@ | Set-Content "$ConfigDir\lua\config\lsp.lua"

# ------------------------------------------------------------
# Autocomplete
# ------------------------------------------------------------

@'
local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },

  mapping = cmp.mapping.preset.insert({

    ["<C-Space>"] = cmp.mapping.complete(),

    ["<CR>"] = cmp.mapping.confirm({
      select = true,
    }),

    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, {"i", "s"}),

    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, {"i", "s"}),

  }),

  sources = {
    { name = "nvim_lsp" },
    { name = "buffer" },
    { name = "path" },
  },
})
'@ | Set-Content "$ConfigDir\lua\config\cmp.lua"

# ------------------------------------------------------------
# Keymaps
# ------------------------------------------------------------

@'
local map = vim.keymap.set

-- Save
map("n", "<C-s>", "<cmd>w<CR>", { desc = "Save" })
map("i", "<C-s>", "<Esc><cmd>w<CR>a", { desc = "Save" })

-- Quit
map("n", "<C-q>", "<cmd>q<CR>", { desc = "Quit" })

-- File explorer
map("n", "<C-b>", "<cmd>Neotree toggle<CR>", { desc = "Explorer" })

-- Find file
map("n", "<C-p>", "<cmd>Telescope find_files<CR>", { desc = "Find File" })

-- Search in project
map("n", "<C-S-f>", "<cmd>Telescope live_grep<CR>", { desc = "Search" })

-- Buffers
map("n", "<Tab>", "<cmd>bnext<CR>", { desc = "Next Buffer" })
map("n", "<S-Tab>", "<cmd>bprevious<CR>", { desc = "Previous Buffer" })

-- Close buffer
map("n", "<C-w>", "<cmd>bdelete<CR>", { desc = "Close Buffer" })

-- Terminal
map("n", "<C-`>", "<cmd>split | terminal<CR>", { desc = "Terminal" })

-- Clear search
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- LSP
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to Definition" })
map("n", "gr", vim.lsp.buf.references, { desc = "References" })
map("n", "K", vim.lsp.buf.hover, { desc = "Hover" })
map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
map("n", "<leader>f", function()
  vim.lsp.buf.format()
end, { desc = "Format" })

-- Split navigation
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")
'@ | Set-Content "$ConfigDir\lua\config\keymaps.lua"

# ------------------------------------------------------------
# Load config modules
# ------------------------------------------------------------

@'
require("config.lazy")
require("config.lsp")
require("config.cmp")
require("config.keymaps")
'@ | Set-Content "$ConfigDir\lua\config\init.lua"

# Update init.lua
@'
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"

vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true

vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.wrap = false
vim.opt.scrolloff = 8

vim.opt.updatetime = 250
vim.opt.timeoutlen = 400

vim.opt.undofile = true

require("config")
'@ | Set-Content "$ConfigDir\init.lua"

Write-Host ""
Write-Host "=====================================" -ForegroundColor Green
Write-Host " Neovim configuration created!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""
Write-Host "Starting Neovim..." -ForegroundColor Cyan

nvim
