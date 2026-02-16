
Add-Type -AssemblyName System.Drawing

$srcDir = "c:\Users\LAB\Documents\trae_projects\readme\src"
$readmePath = "c:\Users\LAB\Documents\trae_projects\readme\README.md"

$logosMap = @{
    "wazuh" = "Wazuh_blue.ico"
    "suricata" = "suricata.ico"
    "zabbix" = "zabbix.ico"
    "zeek" = "zeek.ico"
    "devops" = "devops.ico"
}

if (-not (Test-Path $readmePath)) {
    Write-Error "README.md not found at $readmePath"
    exit 1
}

$content = Get-Content -Path $readmePath -Raw -Encoding UTF8

foreach ($key in $logosMap.Keys) {
    $filename = $logosMap[$key]
    $fullPath = Join-Path $srcDir $filename

    if (Test-Path $fullPath) {
        try {
            # Load icon and resize/extract to 32x32
            # Attempt to load specific size first
            try {
                $icon = New-Object System.Drawing.Icon($fullPath, 32, 32)
            } catch {
                # Fallback to default if size not found in file (unlikely for .ico but possible)
                $icon = New-Object System.Drawing.Icon($fullPath)
            }
            
            $bitmap = $icon.ToBitmap()
            
            # Ensure it's 32x32 (resize if necessary)
            if ($bitmap.Width -ne 32 -or $bitmap.Height -ne 32) {
                $resized = New-Object System.Drawing.Bitmap($bitmap, 32, 32)
                $bitmap.Dispose()
                $bitmap = $resized
            }
            
            # Save to MemoryStream as PNG
            $ms = New-Object System.IO.MemoryStream
            $bitmap.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
            $bytes = $ms.ToArray()
            $b64 = [Convert]::ToBase64String($bytes)
            $ms.Dispose()
            $bitmap.Dispose()
            $icon.Dispose()

            $dataUri = "data:image/png;base64,$b64"
            
            Write-Host "Processed $key ($filename) -> Size: $($bytes.Length) bytes"

            # Replace in README
            # Special case for devops
            if ($key -eq "devops") {
                 # Search for logo=azuredevops OR logo=data:image/x-icon...
                 # We want to replace whatever is there for the DevOps badge
                 # The badge line usually contains "DevOps-000000"
                 
                 # Regex to find the badge line and replace the logo parameter
                 # Pattern: (badge/DevOps-.*?logo=)([^&"]+)
                 
                 $pattern = '(badge/DevOps-.*?logo=)([^&"]+)'
                 if ($content -match $pattern) {
                     $content = $content -replace $pattern, '${1}' + $dataUri
                     Write-Host "Updated DevOps badge logo"
                 }
            } else {
                 # For others: badge/Key- or similar. 
                 # Wazuh: badge/Wazuh-
                 # Suricata: badge/Suricata-
                 # Zeek: badge/Zeek-
                 # Zabbix: badge/Zabbix-
                 
                 # Case insensitive match for key
                 $pattern = "(badge/$key-.*?logo=)([^&""]+)"
                 if ($content -match $pattern) {
                     $content = $content -replace $pattern, '${1}' + $dataUri
                     Write-Host "Updated $key badge logo"
                 } else {
                     # Fallback: maybe the case is different in the badge name?
                     # Try generic search for logo=$key
                     $patternGeneric = "logo=$key([&""])?"
                     if ($content -match $patternGeneric) {
                         $content = $content -replace "logo=$key", "logo=$dataUri"
                         Write-Host "Updated generic $key logo"
                     }
                 }
            }
            
        }
        catch {
            Write-Error "Error processing $filename : $_"
        }
    }
    else {
        Write-Warning "File not found: $fullPath"
    }
}

Set-Content -Path $readmePath -Value $content -Encoding UTF8
Write-Host "README updated with optimized icons."
