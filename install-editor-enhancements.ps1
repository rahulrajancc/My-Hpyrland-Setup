$ErrorActionPreference = "Stop"

$NvimDir    = "$env:LOCALAPPDATA\nvim"
$PluginsDir = "$NvimDir\lua\plugins"
$ConfigDir  = "$NvimDir\lua\config"

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host " Neovim Editor Enhancements" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# ---------------------------------------------------------
# Check Neovim
# ---------------------------------------------------------

if (-not (Get-Command nvim -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Neovim not found in PATH." -ForegroundColor Red
    exit 1
}

Write-Host "Neovim found." -ForegroundColor Green

# ---------------------------------------------------------
# Create directories
# ---------------------------------------------------------

New-Item -ItemType Directory -Force -Path $PluginsDir | Out-Null
New-Item -ItemType Directory -Force -Path $ConfigDir | Out-Null

# ---------------------------------------------------------
# Backup
# ---------------------------------------------------------

$BackupDir = "$NvimDir\backup-editor-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null

Write-Host ""
Write-Host "Backup directory:" -ForegroundColor Yellow
Write-Host $BackupDir

# ---------------------------------------------------------
# Backup cmp.lua if it exists
# ---------------------------------------------------------

$CmpFile = "$ConfigDir\cmp.lua"

if (Test-Path $CmpFile) {
    Copy-Item $CmpFile "$BackupDir\cmp.lua" -Force
    Write-Host "Backed up cmp.lua" -ForegroundColor DarkGray
}

# ---------------------------------------------------------
# Create editor-enhancements.lua
# ---------------------------------------------------------

$PluginConfig = @'
return {

    -- =====================================================
    -- SNIPPETS
    -- =====================================================

    {
        "L3MON4D3/LuaSnip",

        dependencies = {
            "rafamadriz/friendly-snippets",
        },

        build = "make install_jsregexp",

        config = function()
            require("luasnip.loaders.from_vscode").lazy_load()

            require("luasnip").config.setup({
                history = true,
                updateevents = "TextChanged,TextChangedI",
                enable_autosnippets = true,
            })
        end,
    },

    -- =====================================================
    -- BETTER ICONS
    -- =====================================================

    {
        "nvim-tree/nvim-web-devicons",

        opts = {
            override = {},
            default = true,
        },
    },

    -- =====================================================
    -- DIAGNOSTICS
    -- Errors / warnings / hints
    -- =====================================================

    {
        "folke/trouble.nvim",

        cmd = "Trouble",

        opts = {
            auto_close = false,
            auto_preview = false,
            focus = true,

            icons = {
                indent = {
                    middle = " ",
                    last = " ",
                    top = " ",
                    ws = "│  ",
                },
            },

            modes = {
                diagnostics = {
                    mode = "diagnostics",

                    win = {
                        position = "right",
                        size = {
                            width = 45,
                        },
                    },
                },
            },
        },

        keys = {

            {
                "<leader>xx",
                "<cmd>Trouble diagnostics toggle<CR>",
                desc = "Diagnostics",
            },

            {
                "<leader>xX",
                "<cmd>Trouble diagnostics toggle filter.buf=0<CR>",
                desc = "Buffer Diagnostics",
            },

            {
                "<leader>cs",
                "<cmd>Trouble symbols toggle focus=false<CR>",
                desc = "Symbols",
            },
        },
    },

    -- =====================================================
    -- CSS / COLOR HIGHLIGHTING
    -- =====================================================

    {
        "catgoose/nvim-colorizer.lua",

        event = {
            "BufReadPre",
            "BufNewFile",
        },

        config = function()

            require("colorizer").setup({

                options = {

                    parsers = {

                        -- CSS colors:
                        -- #fff
                        -- #ffffff
                        -- rgb(...)
                        -- hsl(...)
                        -- oklch(...)
                        css = true,

                        -- Tailwind colors
                        tailwind = {
                            enable = true,
                        },
                    },

                    display = {

                        -- Show the actual color behind the value
                        mode = "background",

                        -- Keep enough contrast for text
                        virtualtext = {
                            position = "eol",
                        },
                    },
                },

                filetypes = {
                    "*",

                    -- Don't color markdown
                    "!markdown",

                    -- CSS
                    css = {
                        parsers = {
                            css = true,
                        },
                    },

                    -- React
                    javascriptreact = {
                        parsers = {
                            css = true,
                            tailwind = {
                                enable = true,
                            },
                        },
                    },

                    typescriptreact = {
                        parsers = {
                            css = true,
                            tailwind = {
                                enable = true,
                            },
                        },
                    },
                },
            })

        end,
    },
}
'@

$PluginFile = "$PluginsDir\editor-enhancements.lua"

Set-Content `
    -Path $PluginFile `
    -Value $PluginConfig `
    -Encoding UTF8

Write-Host ""
Write-Host "Created:" -ForegroundColor Green
Write-Host $PluginFile

# ---------------------------------------------------------
# Add useful keymaps
# ---------------------------------------------------------

$KeymapsFile = "$ConfigDir\keymaps.lua"

if (Test-Path $KeymapsFile) {

    $Keymaps = Get-Content $KeymapsFile -Raw

    if ($Keymaps -notmatch "Trouble diagnostics toggle") {

        $Mappings = @'

-- =====================================================
-- DIAGNOSTICS / TROUBLE
-- =====================================================

map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", {
    desc = "Diagnostics"
})

map("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", {
    desc = "Buffer Diagnostics"
})

-- Next / previous diagnostic
map("n", "]d", vim.diagnostic.goto_next, {
    desc = "Next Diagnostic"
})

map("n", "[d", vim.diagnostic.goto_prev, {
    desc = "Previous Diagnostic"
})

-- Show diagnostic under cursor
map("n", "<leader>e", vim.diagnostic.open_float, {
    desc = "Show Diagnostic"
})
'@

        Add-Content `
            -Path $KeymapsFile `
            -Value $Mappings `
            -Encoding UTF8

        Write-Host "Diagnostic keymaps added." -ForegroundColor Green
    }
    else {
        Write-Host "Diagnostic keymaps already exist." -ForegroundColor Yellow
    }
}

# ---------------------------------------------------------
# Lazy sync
# ---------------------------------------------------------

Write-Host ""
Write-Host "Installing plugins..." -ForegroundColor Cyan
Write-Host ""

nvim --headless "+Lazy! sync" "+qa"

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "Lazy sync returned an error." -ForegroundColor Red
    exit 1
}

# ---------------------------------------------------------
# Done
# ---------------------------------------------------------

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host " Installation complete!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""

Write-Host "Installed:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  LuaSnip              -> Snippet engine"
Write-Host "  friendly-snippets    -> React/TS/JS/CSS snippets"
Write-Host "  Trouble              -> Errors/warnings panel"
Write-Host "  nvim-colorizer       -> CSS color previews"
Write-Host "  nvim-web-devicons    -> Better icons"
Write-Host ""

Write-Host "Restart Neovim:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  nvim"
Write-Host ""

Write-Host "Useful shortcuts:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Space + x + x   -> All errors/warnings"
Write-Host "  Space + x + X   -> Current-file errors"
Write-Host "  Space + e       -> Error under cursor"
Write-Host "  ]d              -> Next error"
Write-Host "  [d              -> Previous error"
Write-Host ""

Write-Host "Test Trouble manually:"
Write-Host ""
Write-Host "  :Trouble diagnostics"
Write-Host ""

Write-Host "Test snippets:"
Write-Host ""
Write-Host "  type: rfc"
Write-Host "  type: rafce"
Write-Host "  type: useState"
Write-Host "  type: useEffect"
Write-Host ""

Read-Host "Press Enter to exit"
