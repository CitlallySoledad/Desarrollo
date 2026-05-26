@echo off
REM Script de despliegue a Railway para Windows

echo.
echo 🚀 Iniciando despliegue a Railway...
echo.

REM Verificar que railway CLI está instalado
where railway >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Railway CLI no está instalado
    echo Instálalo con: npm i -g @railway/cli
    exit /b 1
)

echo 📝 Verificando estado de Git...
git status

echo.
echo ✅ Asegúrate de que:
echo    1. Has hecho commit de todos los cambios
echo    2. Has configurado las variables de entorno en Railway
echo    3. Has agregado una base de datos PostgreSQL en Railway
echo.
pause

echo 🔄 Ejecutando 'railway up'...
call railway up

echo.
echo ✅ Despliegue completado!
echo.
echo Para ver los logs:
echo   railway logs
echo.
echo Para acceder a la app:
echo   railway open
echo.
pause
