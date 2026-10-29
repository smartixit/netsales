# ============================================================================
# check_display_only.ps1 — Frontend Display-Only Policy Lint (AGENTS.md §34)
# ============================================================================
# Flags common violations of the display-only policy:
#   1. Arithmetic on monetary fields (*Amount, *Price, *Discount, *Total, *Balance, *Debt)
#      outside formatters and documented display helpers.
#   2. LinearGradient(...) usage outside app_gradients.dart.
#   3. Duration(...) / Curves.* usage outside app_motion.dart.
#   4. SizedBox(width/height: X.w/h) raw spacing outside AppSpacing.
#   5. Raw buttons (ElevatedButton, InkWell, GestureDetector) in features.
# ============================================================================
# Usage: .\scripts\check_display_only.ps1
# Exit code: 0 = clean, 1 = violations found.
# ============================================================================

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$lib = Join-Path $root 'lib'

$violations = @()

function Add-Violation($file, $line, $rule, $snippet) {
    $violations += [PSCustomObject]@{
        File    = $file
        Line    = $line
        Rule    = $rule
        Snippet = $snippet.Trim()
    }
}

# --- 1. LinearGradient outside app_gradients.dart ---
Get-ChildItem -Path $lib -Recurse -Filter *.dart |
    Where-Object { $_.FullName -notmatch 'app_gradients\.dart' } |
    ForEach-Object {
        $file = $_.FullName
        $rel = $file.Substring($root.Length + 1)
        $i = 0
        Get-Content $file | ForEach-Object {
            $i++
            if ($_ -match 'LinearGradient\(') {
                Add-Violation $rel $i 'LinearGradient (use AppGradients.*)' $_
            }
        }
    }

# --- 2. Duration( / Curves. in UI (features presentation) ---
Get-ChildItem -Path (Join-Path $lib 'features') -Recurse -Filter *.dart |
    ForEach-Object {
        $file = $_.FullName
        $rel = $file.Substring($root.Length + 1)
        $i = 0
        Get-Content $file | ForEach-Object {
            $i++
            if ($_ -match 'Duration\(' -and $_ -notmatch 'AppMotion\.') {
                Add-Violation $rel $i 'Duration (use AppMotion.*)' $_
            }
            if ($_ -match 'Curves\.') {
                Add-Violation $rel $i 'Curves (use AppMotion.*)' $_
            }
        }
    }

# --- 3. SizedBox(width/height: X.w/h) raw spacing ---
Get-ChildItem -Path $lib -Recurse -Filter *.dart |
    ForEach-Object {
        $file = $_.FullName
        $rel = $file.Substring($root.Length + 1)
        $i = 0
        Get-Content $file | ForEach-Object {
            $i++
            if ($_ -match 'SizedBox\((width|height):\s*\d+(\.\d+)?\.(w|h)\)') {
                Add-Violation $rel $i 'SizedBox raw spacing (use AppSpacing.h*/v*)' $_
            }
        }
    }

# --- 4. Raw buttons in features ---
$rawButtons = @('ElevatedButton', 'OutlinedButton', 'TextButton', 'IconButton', 'InkWell', 'GestureDetector', 'FloatingActionButton')
Get-ChildItem -Path (Join-Path $lib 'features') -Recurse -Filter *.dart |
    ForEach-Object {
        $file = $_.FullName
        $rel = $file.Substring($root.Length + 1)
        $i = 0
        Get-Content $file | ForEach-Object {
            $i++
            foreach ($btn in $rawButtons) {
                if ($_ -match "$btn\(") {
                    Add-Violation $rel $i "Raw button ($btn)" $_
                }
            }
        }
    }

# --- 5. Arithmetic on monetary fields (heuristic) ---
# Flag lines like: total = a + b;  remaining = x - y;  ratio = a / b;
# Only in controllers (presentation/controllers). Excludes formatters and documented helpers.
$moneyPattern = '\b(\w*(?:Amount|Price|Discount|Total|Balance|Debt)\w*)\s*[\+\-\*\/]='
Get-ChildItem -Path (Join-Path $lib 'features') -Recurse -Filter *_controller.dart |
    ForEach-Object {
        $file = $_.FullName
        $rel = $file.Substring($root.Length + 1)
        $i = 0
        Get-Content $file | ForEach-Object {
            $i++
            if ($_ -match $moneyPattern) {
                # Skip if documented as DISPLAY-ONLY
                if ($_ -notmatch 'DISPLAY-ONLY') {
                    Add-Violation $rel $i 'Monetary arithmetic (verify backend authority)' $_
                }
            }
        }
    }

# --- Report ---
if ($violations.Count -eq 0) {
    Write-Host '✅ No display-only violations found.' -ForegroundColor Green
    exit 0
} else {
    Write-Host "❌ Found $($violations.Count) potential violation(s):" -ForegroundColor Red
    $violations | Format-Table -AutoSize
    exit 1
}
