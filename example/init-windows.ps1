param(
    [Parameter(Mandatory = $true)]
    [string]$FrontendPath,

    [Parameter(Mandatory = $true)]
    [string]$BackendPath,

    [Parameter(Mandatory = $false)]
    [string]$GlobalPath = (Join-Path $HOME ".claude-global")
)

$ErrorActionPreference = "Stop"

function Require-Directory {
    param([string]$TargetPath)

    if (-not (Test-Path -LiteralPath $TargetPath -PathType Container)) {
        throw "Directory not found: $TargetPath"
    }
}

function Ensure-Line {
    param(
        [string]$LineValue,
        [string]$FilePath
    )

    if (-not (Test-Path -LiteralPath $FilePath)) {
        New-Item -ItemType File -Path $FilePath | Out-Null
    }

    $currentLines = Get-Content -LiteralPath $FilePath -ErrorAction SilentlyContinue
    if ($currentLines -notcontains $LineValue) {
        Add-Content -LiteralPath $FilePath -Value $LineValue
    }
}

function Set-SymbolicLink {
    param(
        [string]$LinkPath,
        [string]$TargetPath
    )

    if (Test-Path -LiteralPath $LinkPath) {
        $item = Get-Item -LiteralPath $LinkPath -Force
        $isSymlink = ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0

        if ($isSymlink -or $item.PSIsContainer -eq $false) {
            Remove-Item -LiteralPath $LinkPath -Force
        }
        else {
            $children = Get-ChildItem -LiteralPath $LinkPath -Force
            if ($children.Count -gt 0) {
                throw "Path exists and is not empty: $LinkPath"
            }

            Remove-Item -LiteralPath $LinkPath -Force
        }
    }

    New-Item -ItemType SymbolicLink -Path $LinkPath -Target $TargetPath | Out-Null
}

function Copy-ProjectClaude {
    param(
        [string]$SourceDir,
        [string]$DestinationDir
    )

    New-Item -ItemType Directory -Force -Path (Join-Path $DestinationDir ".claude") | Out-Null
    New-Item -ItemType Directory -Force -Path (Join-Path $DestinationDir ".claude\\docs") | Out-Null
    New-Item -ItemType Directory -Force -Path (Join-Path $DestinationDir ".claude\\rules") | Out-Null
    New-Item -ItemType Directory -Force -Path (Join-Path $DestinationDir ".claude\\skills") | Out-Null

    Copy-Item -Path (Join-Path $SourceDir ".claude\\docs\\*") -Destination (Join-Path $DestinationDir ".claude\\docs") -Recurse -Force
    Copy-Item -Path (Join-Path $SourceDir ".claude\\skills\\*") -Destination (Join-Path $DestinationDir ".claude\\skills") -Recurse -Force
    Copy-Item -Path (Join-Path $SourceDir ".claude\\LINKS.md") -Destination (Join-Path $DestinationDir ".claude\\LINKS.md") -Force
}

$TemplateRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ResolvedFrontendPath = (Resolve-Path -LiteralPath $FrontendPath).Path
$ResolvedBackendPath = (Resolve-Path -LiteralPath $BackendPath).Path

Require-Directory $ResolvedFrontendPath
Require-Directory $ResolvedBackendPath
Require-Directory (Join-Path $TemplateRoot ".claude-global")
Require-Directory (Join-Path $TemplateRoot "frontend\\.claude")
Require-Directory (Join-Path $TemplateRoot "backend\\.claude")

New-Item -ItemType Directory -Force -Path $GlobalPath | Out-Null
Copy-Item -Path (Join-Path $TemplateRoot ".claude-global\\*") -Destination $GlobalPath -Recurse -Force

Copy-ProjectClaude -SourceDir (Join-Path $TemplateRoot "frontend") -DestinationDir $ResolvedFrontendPath
Copy-ProjectClaude -SourceDir (Join-Path $TemplateRoot "backend") -DestinationDir $ResolvedBackendPath

Copy-Item -Path (Join-Path $TemplateRoot "frontend\\.claude\\rules\\frontend.md") -Destination (Join-Path $ResolvedFrontendPath ".claude\\rules\\frontend.md") -Force
Copy-Item -Path (Join-Path $TemplateRoot "backend\\.claude\\rules\\backend.md") -Destination (Join-Path $ResolvedBackendPath ".claude\\rules\\backend.md") -Force

Set-SymbolicLink -LinkPath (Join-Path $ResolvedFrontendPath ".claude\\CLAUDE.md") -TargetPath (Join-Path $GlobalPath "CLAUDE.md")
Set-SymbolicLink -LinkPath (Join-Path $ResolvedBackendPath ".claude\\CLAUDE.md") -TargetPath (Join-Path $GlobalPath "CLAUDE.md")
Set-SymbolicLink -LinkPath (Join-Path $ResolvedFrontendPath ".claude\\rules\\global") -TargetPath (Join-Path $GlobalPath "rules")
Set-SymbolicLink -LinkPath (Join-Path $ResolvedBackendPath ".claude\\rules\\global") -TargetPath (Join-Path $GlobalPath "rules")
Set-SymbolicLink -LinkPath (Join-Path $ResolvedFrontendPath "backend") -TargetPath $ResolvedBackendPath
Set-SymbolicLink -LinkPath (Join-Path $ResolvedBackendPath "frontend") -TargetPath $ResolvedFrontendPath

Ensure-Line -LineValue ".claude/CLAUDE.md" -FilePath (Join-Path $ResolvedFrontendPath ".gitignore")
Ensure-Line -LineValue ".claude/rules/global/" -FilePath (Join-Path $ResolvedFrontendPath ".gitignore")
Ensure-Line -LineValue "backend/" -FilePath (Join-Path $ResolvedFrontendPath ".gitignore")
Ensure-Line -LineValue ".claude/CLAUDE.md" -FilePath (Join-Path $ResolvedBackendPath ".gitignore")
Ensure-Line -LineValue ".claude/rules/global/" -FilePath (Join-Path $ResolvedBackendPath ".gitignore")
Ensure-Line -LineValue "frontend/" -FilePath (Join-Path $ResolvedBackendPath ".gitignore")

Write-Host "Initialized Claude template."
Write-Host "Frontend: $ResolvedFrontendPath"
Write-Host "Backend:  $ResolvedBackendPath"
Write-Host "Global:   $GlobalPath"
