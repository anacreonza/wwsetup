# ---------------------------------------------------------------------------------------------------------
# Downloads and installs PHP and configures it according to the requirements of Woodwing Studio
# It is not possible to automatically install the MMSQL PHP plugin unfortunately as that is inside a binary 
# installer. But the script downloads and runs the installer. If the MSSQL drivers are extracted to the 
# Windows temp folder and the script is run again it will pick them up and isntlal them.
# Written by Stuart Kinnear
# ---------------------------------------------------------------------------------------------------------

$PHPURL = "https://windows.php.net/downloads/releases/php-7.3.26-nts-Win32-VC15-x64.zip"
$PHPPath = "c:\PHP\"
$PHPexe = $PHPPath+"php.exe"
$PHPini = $PHPPath+"php.ini"
$PHPInstalled = Test-Path -Path $PHPexe
$MSSQLURL = "https://download.microsoft.com/download/2/6/a/26a631f3-24e3-4a99-83a3-882ae78f3503/SQLSRV58.EXE"
$ConfigLines = @(
    "upload_max_filesize = 250M",
    "post_max_size = 250M",
    "memory_limit = 750M",
    'request_order = "GPC"',
    'date.timezone = Africa/Johannesburg',
    'session.save_path = C:\PHP\sessiondata',
    'upload_tmp_dir = C:\PHP\uploadtemp'
)
Write-Host "Setting up PHP..."

if (-Not ($PHPInstalled)) {
    Write-Host "Downloading $PHPURL ..."
    Invoke-WebRequest -Uri $PHPURL -OutFile c:\windows\temp\php.zip
    Write-Host "Expanding archive..."
    Expand-Archive -Path c:\windows\temp\php.zip -DestinationPath $PHPPath
    Write-Host "Creating INI file..."
    Copy-Item -Path "C:\php\php.ini-production" $PHPini
    Write-Host "Adding config lines..."
    foreach ($Line in $ConfigLines) {
        $FileContainsString = Select-String -Path $PHPini -Pattern $Line
        if (-Not ($FileContainsString)){
            Add-Content -Path $PHPini -Value $Line
        }
    }
    
} else {
    Write-Host "PHP already installed."
}

$MSSQLInstalled = Test-Path -Path "C:\PHP\ext\php_sqlsrv_73_nts_x64.dll"
$MSSQPDOInstalled = Test-Path -Path "C:\PHP\ext\php_pdo_sqlsrv_73_nts_x64.dll"

if (-Not ($MSSQLInstalled -Or $MSSQPDOInstalled)){
    Write-Host "MSSQL PHP plugins not found."
    Write-Host "Downloading extensions..."
    if (-Not (Test-Path "c:\windows\temp\SQLSRV58.EXE" )){
        Invoke-WebRequest -Uri $MSSQLURL -OutFile "c:\windows\temp\SQLSRV58.EXE"
    }
    if (-Not (Test-Path "C:\Windows\Temp\php_sqlsrv_73_nts_x64.dll")){
        Start-Process "c:\windows\temp\SQLSRV58.EXE"
        Write-Host "Please extract the SQL plugins to c:\Windows\temp\ and run this installer again."
    }
    if (Test-Path -Path "C:\Windows\Temp\php_sqlsrv_73_nts_x64.dll"){
        $PHPExtPath = $PHPPath+"ext\"
        Write-Host "installing MSSQL extensions..."
        Copy-Item "C:\Windows\Temp\php_sqlsrv_73_nts_x64.dll" $PHPExtPath
        Copy-Item "C:\Windows\Temp\php_pdo_sqlsrv_73_nts_x64.dll" $PHPExtPath


    }
    Write-Host "MSSQL PHP Extensions are installed."
}

Write-Host "Checking php.ini"

$ExtLines = @(
    "extension = php_gd2.dll",
    "extension = php_mbstring.dll",
    "extension = php_exif.dll",
    "extension = php_sockets.dll",
    "extension = php_soap.dll",
    "extension = php_curl.dll",
    "extension = php_xsl.dll",
    "extension = php_openssl.dll",   
    "extension = php_sqlsrv_73_nts_x64.dll",
    "extension = php_pdo_sqlsrv_73_nts_x64.dll"
)
$PHPNewLines = 0
foreach ($Line in $ExtLines) {
    $FileContainsString = Select-String -Path $PHPini -Pattern $Line
    if (-not ($FileContainsString)){
        Write-Host "Adding line - $Line - to php.ini"
        Add-Content -Path $PHPini -Value $Line
        $PHPNewLines++
    }
}
if ($PHPNewLines -Gt 0){
    Write-Host "$PHPNewLines lines were added to php.ini"
} else {
    Write-Host "No changes necessary to php.ini"
}

$NecessaryDirs = @(
    "C:\PHP\sessiondata\",
    "C:\PHP\uploadtemp\"
)
foreach ($dir in $NecessaryDirs) {
    if (-Not (Test-Path $dir)){
        Write-Host "Creating $dir"
        New-Item -ItemType Directory -Path $dir
    }
}

C:\PHP\php.exe --version
