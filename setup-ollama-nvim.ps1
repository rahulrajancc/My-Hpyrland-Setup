$NvimDir = "$env:LOCALAPPDATA\nvim"
$PluginDir = "$NvimDir\lua\plugins"

Write-Host "Setting up Ollama AI autocomplete for Neovim..." -ForegroundColor Cyan

New-Item -ItemType Directory -Force -Path $PluginDir | Out-Null

# ------------------------------------------------------------
# Check Ollama
# ------------------------------------------------------------

Write-Host "`nChecking Ollama..." -ForegroundColor Yellow

try {
    $ollamaVersion = ollama --version
    Write-Host "Ollama found: $ollamaVersion" -ForegroundColor Green
}
catch {
    Write-Host "Ollama was not found in PATH." -ForegroundColor Red
    Write-Host "Install Ollama first, then run this script again."
    exit 1
}

# ------------------------------------------------------------
# Check model
# ------------------------------------------------------------

Write-Host "`nChecking Qwen model..." -ForegroundColor Yellow

$models = ollama list

if ($models -match "qwen2.5-coder:1.5b-base") {
    Write-Host "Qwen2.5-Coder 1.5B Base found." -ForegroundColor Green
}
else {
    Write-Host "Model not found. Pulling model..." -ForegroundColor Yellow

    ollama pull qwen2.5-coder:1.5b-base

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to pull model." -ForegroundColor Red
        exit 1
    }
}

# ------------------------------------------------------------
# Make sure Ollama is running
# ------------------------------------------------------------

Write-Host "`nStarting Ollama..." -ForegroundColor Yellow

$ollamaProcess = Get-Process -Name "ollama" -ErrorAction SilentlyContinue

if (-not $ollamaProcess) {
    Start-Process "ollama" -ArgumentList "serve" -WindowStyle Hidden
    Start-Sleep -Seconds 2
}

Write-Host "Ollama server ready." -ForegroundColor Green

# ------------------------------------------------------------
# Create AI plugin config
# ------------------------------------------------------------

$AiConfig = @'
return {

  {
    "milanglacier/minuet-ai.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },

    config = function()

      local minuet = require("minuet")

      minuet.setup({

        -- Local Ollama
        provider = "openai_fim_compatible",

        provider_options = {
          openai_fim_compatible = {
            api_key = "OLLAMA",

            model = "qwen2.5-coder:1.5b-base",

            end_point =
              "http://localhost:11434/v1/completions",

            name = "Ollama",

            stream = true,

            optional = {
              max_tokens = 80,
              temperature = 0.1,
            },
          },
        },

        -- One completion is faster for local CPU
        n_completions = 1,

        -- Keep context small for CPU performance
        context_window = 1024,

        -- Don't send requests for every keystroke
        debounce_delay = 0.3,

        -- Timeout
        request_timeout = 3,

        -- Automatically show ghost-text suggestions
        virtualtext = {
          auto_trigger_ft = {
            "javascript",
            "javascriptreact",
            "typescript",
            "typescriptreact",
            "html",
            "css",
            "json",
            "lua",
          },

          keymap = {
            -- Accept suggestion
            accept = "<Tab>",

            -- Accept one line
            accept_line = "<S-Tab>",

            -- Dismiss
            dismiss = "<Esc>",

            -- Next suggestion
            next = "<M-]>",

            -- Previous suggestion
            prev = "<M-[>",
          },
        },
$NvimDir = "$env:LOCALAPPDATA\nvim"
$PluginDir = "$NvimDir\lua\plugins"

Write-Host "Setting up Ollama AI autocomplete for Neovim..." -ForegroundColor Cyan

New-Item -ItemType Directory -Force -Path $PluginDir | Out-Null

# ------------------------------------------------------------
# Check Ollama
# ------------------------------------------------------------

Write-Host "`nChecking Ollama..." -ForegroundColor Yellow

try {
    $ollamaVersion = ollama --version
    Write-Host "Ollama found: $ollamaVersion" -ForegroundColor Green
}
catch {
    Write-Host "Ollama was not found in PATH." -ForegroundColor Red
    Write-Host "Install Ollama first, then run this script again."
    exit 1
}

# ------------------------------------------------------------
# Check model
# ------------------------------------------------------------

Write-Host "`nChecking Qwen model..." -ForegroundColor Yellow

$models = ollama list

if ($models -match "qwen2.5-coder:1.5b-base") {
    Write-Host "Qwen2.5-Coder 1.5B Base found." -ForegroundColor Green
}
else {
    Write-Host "Model not found. Pulling model..." -ForegroundColor Yellow

    ollama pull qwen2.5-coder:1.5b-base

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to pull model." -ForegroundColor Red
        exit 1
    }
}

# ------------------------------------------------------------
# Make sure Ollama is running
# ------------------------------------------------------------

Write-Host "`nStarting Ollama..." -ForegroundColor Yellow

$ollamaProcess = Get-Process -Name "ollama" -ErrorAction SilentlyContinue

if (-not $ollamaProcess) {
    Start-Process "ollama" -ArgumentList "serve" -WindowStyle Hidden
    Start-Sleep -Seconds 2
}

Write-Host "Ollama server ready." -ForegroundColor Green

# ------------------------------------------------------------
# Create AI plugin config
# ------------------------------------------------------------

$AiConfig = @'
return {

  {
    "milanglacier/minuet-ai.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },

    config = function()

      local minuet = require("minuet")

      minuet.setup({

        -- Local Ollama
        provider = "openai_fim_compatible",

        provider_options = {
          openai_fim_compatible = {
            api_key = "OLLAMA",

            model = "qwen2.5-coder:1.5b-base",

            end_point =
              "http://localhost:11434/v1/completions",

            name = "Ollama",

            stream = true,

            optional = {
              max_tokens = 80,
              temperature = 0.1,
            },
          },
        },

        -- One completion is faster for local CPU
        n_completions = 1,

        -- Keep context small for CPU performance
        context_window = 1024,

        -- Don't send requests for every keystroke
        debounce_delay = 0.3,

        -- Timeout
        request_timeout = 3,

        -- Automatically show ghost-text suggestions
        virtualtext = {
          auto_trigger_ft = {
            "javascript",
            "javascriptreact",
            "typescript",
            "typescriptreact",
            "html",
            "css",
            "json",
            "lua",
          },

          keymap = {
            -- Accept suggestion
            accept = "<Tab>",

            -- Accept one line
            accept_line = "<S-Tab>",

            -- Dismiss
            dismiss = "<Esc>",

            -- Next suggestion
            next = "<M-]>",

            -- Previous suggestion
            prev = "<M-[>",
          },
        },

      })

    end,
  },

}
'@

Set-Content "$PluginDir\ai.lua" $AiConfig

# ------------------------------------------------------------
# Add AI keymaps
# ------------------------------------------------------------

$KeymapFile = "$NvimDir\lua\config\keymaps.lua"

if (Test-Path $KeymapFile) {

    $content = Get-Content $KeymapFile -Raw

    if ($content -notmatch "minuet") {

        Add-Content $KeymapFile @'

-- ==========================================
-- AI Autocomplete
-- ==========================================

map("n", "<leader>ai", function()
  require("minuet").make_completion()
end, { desc = "AI Completion" })

map("i", "<C-\\>", function()
  require("minuet").make_completion()
end, { desc = "AI Completion" })

'@

    }
}

# ------------------------------------------------------------
# Done
# ------------------------------------------------------------

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host " Ollama AI Autocomplete Installed!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Model: qwen2.5-coder:1.5b-base"
Write-Host "Server: http://localhost:11434"
Write-Host ""
Write-Host "Starting Neovim..." -ForegroundColor Cyan

nvim$NvimDir = "$env:LOCALAPPDATA\nvim"
$PluginDir = "$NvimDir\lua\plugins"

Write-Host "Setting up Ollama AI autocomplete for Neovim..." -ForegroundColor Cyan

New-Item -ItemType Directory -Force -Path $PluginDir | Out-Null

# ------------------------------------------------------------
# Check Ollama
# ------------------------------------------------------------

Write-Host "`nChecking Ollama..." -ForegroundColor Yellow

try {
    $ollamaVersion = ollama --version
    Write-Host "Ollama found: $ollamaVersion" -ForegroundColor Green
}
catch {
    Write-Host "Ollama was not found in PATH." -ForegroundColor Red
    Write-Host "Install Ollama first, then run this script again."
    exit 1
}

# ------------------------------------------------------------
# Check model
# ------------------------------------------------------------

Write-Host "`nChecking Qwen model..." -ForegroundColor Yellow

$models = ollama list

if ($models -match "qwen2.5-coder:1.5b-base") {
    Write-Host "Qwen2.5-Coder 1.5B Base found." -ForegroundColor Green
}
else {
    Write-Host "Model not found. Pulling model..." -ForegroundColor Yellow

    ollama pull qwen2.5-coder:1.5b-base

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to pull model." -ForegroundColor Red
        exit 1
    }
}

# ------------------------------------------------------------
# Make sure Ollama is running
# ------------------------------------------------------------

Write-Host "`nStarting Ollama..." -ForegroundColor Yellow

$ollamaProcess = Get-Process -Name "ollama" -ErrorAction SilentlyContinue

if (-not $ollamaProcess) {
    Start-Process "ollama" -ArgumentList "serve" -WindowStyle Hidden
    Start-Sleep -Seconds 2
}

Write-Host "Ollama server ready." -ForegroundColor Green

# ------------------------------------------------------------
# Create AI plugin config
# ------------------------------------------------------------

$AiConfig = @'
return {

  {
    "milanglacier/minuet-ai.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },

    config = function()

      local minuet = require("minuet")

      minuet.setup({

        -- Local Ollama
        provider = "openai_fim_compatible",

        provider_options = {
          openai_fim_compatible = {
            api_key = "OLLAMA",

            model = "qwen2.5-coder:1.5b-base",

            end_point =
              "http://localhost:11434/v1/completions",

            name = "Ollama",

            stream = true,

            optional = {
              max_tokens = 80,
              temperature = 0.1,
            },
          },
        },

        -- One completion is faster for local CPU
        n_completions = 1,

        -- Keep context small for CPU performance
        context_window = 1024,

        -- Don't send requests for every keystroke
        debounce_delay = 0.3,

        -- Timeout
        request_timeout = 3,

        -- Automatically show ghost-text suggestions
        virtualtext = {
          auto_trigger_ft = {
            "javascript",
            "javascriptreact",
            "typescript",
            "typescriptreact",
            "html",
            "css",
            "json",
            "lua",
          },

          keymap = {
            -- Accept suggestion
            accept = "<Tab>",

            -- Accept one line
            accept_line = "<S-Tab>",

            -- Dismiss
            dismiss = "<Esc>",

            -- Next suggestion
            next = "<M-]>",

            -- Previous suggestion
            prev = "<M-[>",
          },
        },

      })

    end,
  },

}
'@

Set-Content "$PluginDir\ai.lua" $AiConfig

# ------------------------------------------------------------
# Add AI keymaps
# ------------------------------------------------------------

$KeymapFile = "$NvimDir\lua\config\keymaps.lua"

if (Test-Path $KeymapFile) {

    $content = Get-Content $KeymapFile -Raw

    if ($content -notmatch "minuet") {

        Add-Content $KeymapFile @'

-- ==========================================
-- AI Autocomplete
-- ==========================================

map("n", "<leader>ai", function()
  require("minuet").make_completion()
end, { desc = "AI Completion" })

map("i", "<C-\\>", function()
  require("minuet").make_completion()
end, { desc = "AI Completion" })

'@

    }
}

# ------------------------------------------------------------
# Done
# ------------------------------------------------------------

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host " Ollama AI Autocomplete Installed!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Model: qwen2.5-coder:1.5b-base"
Write-Host "Server: http://localhost:11434"
Write-Host ""
Write-Host "Starting Neovim..." -ForegroundColor Cyan

nvim
      })

    end,
  },

}
'@

Set-Content "$PluginDir\ai.lua" $AiConfig

# ------------------------------------------------------------
# Add AI keymaps
# ------------------------------------------------------------

$KeymapFile = "$NvimDir\lua\config\keymaps.lua"

if (Test-Path $KeymapFile) {

    $content = Get-Content $KeymapFile -Raw

    if ($content -notmatch "minuet") {

        Add-Content $KeymapFile @'

-- ==========================================
-- AI Autocomplete
-- ==========================================

map("n", "<leader>ai", function()
  require("minuet").make_completion()
end, { desc = "AI Completion" })

map("i", "<C-\\>", function()
  require("minuet").make_completion()
end, { desc = "AI Completion" })

'@

    }
}

# ------------------------------------------------------------
# Done
# ------------------------------------------------------------

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host " Ollama AI Autocomplete Installed!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Model: qwen2.5-coder:1.5b-base"
Write-Host "Server: http://localhost:11434"
Write-Host ""
Write-Host "Starting Neovim..." -ForegroundColor Cyan

nvim
