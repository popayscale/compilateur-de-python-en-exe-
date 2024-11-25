@echo off
setlocal enabledelayedexpansion

:: Configuration
set "IGNORE_FILES=test template"
set "MAIN_OUTPUT=executables"

:: Création du dossier principal pour les exécutables
if not exist "%MAIN_OUTPUT%" mkdir "%MAIN_OUTPUT%"

echo Début de la compilation...
echo.

:: Vérifier si des fichiers .py existent
dir /b *.py >nul 2>&1
if errorlevel 1 (
    echo Aucun fichier .py trouvé dans le dossier.
    timeout /t 3 /nobreak >nul
    exit /b
)

:: Parcourir les fichiers .py
for %%f in (*.py) do (
    :: Vérifier si le fichier doit être ignoré
    set "IGNORE=false"
    for %%i in (%IGNORE_FILES%) do (
        if "%%~nf"=="%%i" set "IGNORE=true"
    )
    
    if "!IGNORE!"=="false" (
        echo Traitement de %%f...
        
        :: Récupérer le nom du fichier sans extension
        set "filename=%%~nf"
        
        :: Créer un dossier spécifique pour ce fichier
        set "OUTPUT_DIR=%MAIN_OUTPUT%\!filename!"
        if not exist "!OUTPUT_DIR!" mkdir "!OUTPUT_DIR!"
        
        :: Compiler le fichier
        pyinstaller --onefile --noconsole --distpath "!OUTPUT_DIR!" "%%f"
        
        echo %%f compilation terminée et fichiers déplacés dans !OUTPUT_DIR!
        echo.
    ) else (
        echo Ignorer %%f
    )
)

echo Nettoyage des fichiers temporaires...

:: Supprimer tous les fichiers et dossiers de compilation
if exist "build" rmdir /s /q "build"
if exist "dist" rmdir /s /q "dist"
for %%f in (*.spec) do del "%%f"
for /d %%d in (__pycache__*) do rmdir /s /q "%%d"

echo Toutes les compilations sont terminées.
echo Les exécutables se trouvent dans le dossier %MAIN_OUTPUT%
timeout /t 3 /nobreak >nul
