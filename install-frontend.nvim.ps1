$NvimConfig = "$env:LOCALAPPDATA\nvim"
$PluginDir = "$NvimConfig\lua\plugins"

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host " Neovim Electron / MERN Plugin Installer" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# ---------------------------------------------------------
# Check Neovim
# ---------------------------------------------------------

if (-not (Get-Command nvim -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Neovim was not found in PATH." -ForegroundColor Red
    exit 1
}

# ---------------------------------------------------------
# Check Node / npm
# ---------------------------------------------------------

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Node.js was not found in PATH." -ForegroundColor Red
    Write-Host "Install Node.js first." -ForegroundColor Yellow
    exit 1
}

if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: npm was not found in PATH." -ForegroundColor Red
    exit 1
}

Write-Host "Node:" -ForegroundColor Green
node --version

Write-Host "npm:" -ForegroundColor Green
npm --version

# ---------------------------------------------------------
# Create plugin directory
# ---------------------------------------------------------

New-Item -ItemType Directory -Force -Path $PluginDir | Out-Null

# ---------------------------------------------------------
# Backup existing frontend config
# ---------------------------------------------------------

$FrontendFile = "$PluginDir\frontend.lua"

if (Test-Path $FrontendFile) {
    $Backup = "$FrontendFile.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Copy-Item $FrontendFile $Backup
    Write-Host "Existing frontend.lua backed up to:" -ForegroundColor Yellow
    Write-Host $Backup
}

# ---------------------------------------------------------
# Create frontend.lua
# ---------------------------------------------------------

@'
return {

    -- =====================================================
    -- Treesitter
    -- =====================================================

    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        build = ":TSUpdate",

        config = function()
            require("nvim-treesitter").setup({
                install_dir = vim.fn.stdpath("data") .. "/site",
            })

            -- Install common Electron / MERN parsers
            require("nvim-treesitter").install({
                "javascript",
                "typescript",
                "tsx",
                "html",
                "css",
                "json",
                "jsonc",
                "bash",
                "markdown",
                "markdown_inline",
            })
        end,
    },


    -- =====================================================
    -- Conform - Formatting
    -- =====================================================

    {
        "stevearc/conform.nvim",

        event = {
            "BufWritePre",
            "BufReadPost",
            "BufNewFile",
        },

        opts = {

            formatters_by_ft = {

                javascript = { "prettier" },
                javascriptreact = { "prettier" },

                typescript = { "prettier" },
                typescriptreact = { "prettier" },

                html = { "prettier" },

                css = { "prettier" },
                scss = { "prettier" },

                json = { "prettier" },
                jsonc = { "prettier" },

            },

            format_on_save = {
                timeout_ms = 3000,
                lsp_fallback = true,
            },
        },

        keys = {

            {
                "<leader>f",
                function()
                    require("conform").format({
                        async = true,
                        lsp_fallback = true,
                    })
                end,
                mode = { "n", "v" },
                desc = "Format file",
            },

        },
    },


    -- =====================================================
    -- ESLint
    -- =====================================================

    {
        "mfussenegger/nvim-lint",

        event = {
            "BufReadPost",
            "BufNewFile",
        },

        config = function()

            local lint = require("lint")

            lint.linters_by_ft = {

                javascript = {
                    "eslint_d",
                },

                javascriptreact = {
                    "eslint_d",
                },

                typescript = {
                    "eslint_d",
                },

                typescriptreact = {
                    "eslint_d",
                },

            }

            vim.api.nvim_create_autocmd(
                {
                    "BufWritePost",
                    "InsertLeave",
                },
                {
                    callback = function()
                        require("lint").try_lint()
                    end,
                }
            )

        end,

        keys = {

            {
                "<leader>ll",
                function()
                    require("lint").try_lint()
                end,
                desc = "Run ESLint",
            },

        },
    },


    -- =====================================================
    -- TypeScript project checker
    -- =====================================================

    {
        "dmmulroy/tsc.nvim",

        cmd = {
            "TSC",
            "TSCStop",
        },

        config = function()
            require("tsc").setup({})
        end,

        keys = {

            {
                "<leader>tc",
                "<cmd>TSC<CR>",
                desc = "TypeScript check",
            },

            {
                "<leader>ts",
                "<cmd>TSCStop<CR>",
                desc = "Stop TypeScript check",
            },

        },
    },

}
'@ | Set-Content -Encoding UTF8 $FrontendFile

Write-Host ""
Write-Host "Created:" -ForegroundColor Green
Write-Host $FrontendFile

# ---------------------------------------------------------
# Install Prettier
# ---------------------------------------------------------

Write-Host ""
Write-Host "Installing Prettier..." -ForegroundColor Cyan

npm install -g prettier

# ---------------------------------------------------------
# Install eslint_d
# ---------------------------------------------------------

Write-Host ""
Write-Host "Installing eslint_d..." -ForegroundColor Cyan

npm install -g eslint_d

# ---------------------------------------------------------
# Finish
# ---------------------------------------------------------

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host " Installation configuration complete!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""

Write-Host "Plugin file:" -ForegroundColor Cyan
Write-Host $FrontendFile

Write-Host ""
Write-Host "Now start Neovim and run:" -ForegroundColor Yellow

Write-Host ""
Write-Host ":Lazy sync" -ForegroundColor White
Write-Host ""

Write-Host "Then restart Neovim." -ForegroundColor Yellow

Write-Host ""
Write-Host "Useful commands:" -ForegroundColor Cyan
Write-Host ""
Write-Host ":TSInstall javascript"
Write-Host ":TSInstall typescript"
Write-Host ":TSInstall tsx"
Write-Host ":TSC"
Write-Host ":TSCStop"
Write-Host ":ConformInfo"
Write-Host ""

Write-Host "Keymaps:" -ForegroundColor Cyan
Write-Host ""
Write-Host "<Space>f  = Format file"
Write-Host "<Space>ll = ESLint"
Write-Host "<Space>tc = TypeScript check"
Write-Host "<Space>ts = Stop TypeScript check"
Write-Host ""

Write-Host "Done." -ForegroundColor Green
