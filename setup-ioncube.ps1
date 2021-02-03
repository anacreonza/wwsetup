# Sets up IONCube PHP encryption library as required by Wodwing Studio

$IONCubeInstalled = Test-Path -Path "C:\php\ext\ioncube_loader_win_7.3.dll"
$PHPini = "C:\PHP\php.ini"
if (-Not ($IONCubeInstalled)){
    Write-Host "The IONCube PHP extension is not installed."
    "Downloading extension..."
    Invoke-WebRequest -Uri "http://downloads.woodwing.net/ioncube-loaders/enterprise-server/ioncube-loader-1037.zip" -OutFile "C:\Windows\Temp\ioncube-loader-1037.zip"
    Expand-Archive -Path "C:\Windows\Temp\ioncube-loader-1037.zip" -DestinationPath "C:\Windows\Temp\ioncube-loader\" -Force
    Write-Host "Copying extension to c:\php\ext\" -NoNewline
    Copy-Item -Path "C:\Windows\Temp\ioncube-loader\ioncube_loaders_all_platforms\win_nonts_vc15_x86-64\ioncube_loader_win_7.3.dll" -Destination "C:\PHP\ext\"
    if (Test-Path -Path "C:\php\ext\ioncube_loader_win_7.3.dll" ){
        Write-Host "  [OK]"
    }
    $IonCubeLine = 'zend_extension = ioncube_loader_win_7.3.dll'
    $ConfigLineExists = Select-String -Path $PHPini -Pattern $IonCubeLine
    if (-Not ($ConfigLineExists)){
        Write-Host "Adding config line to php.ini"
        Add-Content -Path $PHPini -Value $IonCubeLine
    }
} else {
    Write-Host "The IONCube PHP extension is already installed."
}