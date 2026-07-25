<#
.SYNOPSIS
  日次相場観コメントのHTMLファイルをPDFに変換し、daily/ に日付名で保存する。
  Convert a daily market view HTML file to PDF and save it under daily/ named by date.

.PARAMETER HtmlPath
  入力HTMLファイルのパス / Path to the input HTML file.

.PARAMETER Date
  対象日の日付 (yyyy-MM-dd)。出力ファイル名に使用する。
  Target date (yyyy-MM-dd), used in the output filename.

.EXAMPLE
  .\Convert-DailyViewToPdf.ps1 -HtmlPath "..\daily\2026-07-24.html" -Date "2026-07-24"
#>
param(
  [Parameter(Mandatory = $true)][string]$HtmlPath,
  [Parameter(Mandatory = $true)][string]$Date
)

$edge = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
if (-not (Test-Path $edge)) {
  throw "Microsoft Edge not found at $edge"
}

$resolvedHtml = (Resolve-Path $HtmlPath).Path
$outDir = Join-Path $PSScriptRoot "..\daily"
$pdfPath = Join-Path $outDir "$Date`_日次相場観.pdf"

& $edge --headless --disable-gpu --no-sandbox --print-to-pdf-no-header --print-to-pdf="$pdfPath" "file:///$resolvedHtml" 2>$null
Start-Sleep -Seconds 4

if (Test-Path $pdfPath) {
  Write-Output "Saved: $pdfPath"
} else {
  throw "PDF generation failed."
}
