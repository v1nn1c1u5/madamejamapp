# Gera truststore Java com CAs corporativos (Grupo TPC) para builds Android/Gradle.
# Necessário quando proxy/antivírus intercepta HTTPS e o Java não confia no certificado.
# Uso: powershell -ExecutionPolicy Bypass -File scripts/setup-android-ssl.ps1

$ErrorActionPreference = "Stop"

$jbrCandidates = @(
    "$env:JAVA_HOME",
    "C:\Program Files\Android\Android Studio\jbr",
    "$env:LOCALAPPDATA\Programs\Android\Android Studio\jbr"
) | Where-Object { $_ -and (Test-Path $_) }

if (-not $jbrCandidates) {
    Write-Error "JDK/JBR não encontrado. Instale Android Studio ou defina JAVA_HOME."
}

$jbr = $jbrCandidates[0]
$keytool = Join-Path $jbr "bin\keytool.exe"
$destDir = Join-Path $env:USERPROFILE ".madamejam"
$truststore = Join-Path $destDir "corporate-truststore.jks"
$tempDir = Join-Path $env:TEMP "madamejam-ssl-setup"

New-Item -ItemType Directory -Force -Path $destDir, $tempDir | Out-Null
Copy-Item (Join-Path $jbr "lib\security\cacerts") $truststore -Force

$seen = @{}
$aliasIndex = 0
foreach ($store in @("Root", "CA")) {
    foreach ($loc in @("LocalMachine", "CurrentUser")) {
        Get-ChildItem "Cert:\$loc\$store" -ErrorAction SilentlyContinue |
            Where-Object {
                $_.Subject -like "*grupotpc*" -or
                $_.Subject -like "*Grupo TPC*" -or
                $_.Subject -like "*gtpc*"
            } |
            ForEach-Object {
                if ($seen.ContainsKey($_.Thumbprint)) { return }
                $seen[$_.Thumbprint] = $true
                $aliasIndex++
                $cerPath = Join-Path $tempDir "gtpc-$aliasIndex.cer"
                Export-Certificate -Cert $_ -FilePath $cerPath -Force | Out-Null
                & $keytool -importcert -keystore $truststore -storepass changeit `
                    -alias "gtpc-$aliasIndex" -file $cerPath -noprompt | Out-Null
            }
    }
}

Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue

$truststorePath = ($truststore -replace "\\", "/")
$jvmArgs = "-Xmx8G -XX:MaxMetaspaceSize=4G -XX:ReservedCodeCacheSize=512m -XX:+HeapDumpOnOutOfMemoryError -Djava.nio.channels.spi.SelectorProvider=sun.nio.ch.WindowsSelectorProvider -Djavax.net.ssl.trustStore=$truststorePath -Djavax.net.ssl.trustStorePassword=changeit"

$projectRoot = Split-Path $PSScriptRoot -Parent
$gradleProps = Join-Path $projectRoot "android\gradle.properties"
$sslBlock = @(
    "# >>> madamejam-ssl-start (gerado por scripts/setup-android-ssl.ps1)"
    "systemProp.javax.net.ssl.trustStore=$truststorePath"
    "systemProp.javax.net.ssl.trustStorePassword=changeit"
    "org.gradle.jvmargs=$jvmArgs"
    "# >>> madamejam-ssl-end"
)
if (Test-Path $gradleProps) {
    $content = Get-Content $gradleProps -Raw
    if ($content -match "(?s)# >>> madamejam-ssl-start.*?# >>> madamejam-ssl-end") {
        $content = [regex]::Replace($content, "(?s)# >>> madamejam-ssl-start.*?# >>> madamejam-ssl-end", ($sslBlock -join "`n"))
    } else {
        $content = $content.TrimEnd() + "`n`n" + ($sslBlock -join "`n") + "`n"
    }
    Set-Content -Path $gradleProps -Value $content -Encoding Ascii -NoNewline
    Add-Content -Path $gradleProps -Value "" -Encoding Ascii
}

Write-Host "Truststore criado: $truststore"
Write-Host "Gradle props: $gradleProps"
Write-Host "Certificados importados: $($seen.Count)"
Write-Host "Reinicie o Gradle daemon: cd android; .\gradlew.bat --stop"
