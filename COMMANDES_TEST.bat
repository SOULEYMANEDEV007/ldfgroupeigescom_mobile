@echo off
echo ========================================
echo IGESCOM MOBILE - TEST APRES CORRECTIONS
echo ========================================
echo.

echo [1/4] Nettoyage du projet...
call flutter clean
echo.

echo [2/4] Recuperation des dependances...
call flutter pub get
echo.

echo [3/4] (Optionnel) Regeneration injection...
echo Appuyez sur une touche pour regenerer, ou CTRL+C pour passer
pause
call dart run build_runner build --delete-conflicting-outputs
echo.

echo [4/4] Lancement de l'application...
echo.
echo Choisissez le mode:
echo [1] Debug (mode dev avec hot reload)
echo [2] Release (optimise, sans debug)
echo.
set /p mode="Votre choix (1 ou 2): "

if "%mode%"=="1" (
    echo Lancement en mode DEBUG...
    call flutter run
) else (
    echo Lancement en mode RELEASE...
    call flutter run --release
)

echo.
echo ========================================
echo TEST TERMINE
echo ========================================
pause
