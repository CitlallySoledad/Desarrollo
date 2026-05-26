#!/bin/bash

# Script de despliegue a Railway
# Uso: bash deploy-railway.sh

echo "🚀 Iniciando despliegue a Railway..."

# Verificar que railway CLI está instalado
if ! command -v railway &> /dev/null; then
    echo "❌ Railway CLI no está instalado"
    echo "Instálalo con: npm i -g @railway/cli"
    exit 1
fi

# Verificar que estamos en la rama main
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "main" ] && [ "$CURRENT_BRANCH" != "master" ]; then
    echo "⚠️  Estás en la rama '$CURRENT_BRANCH'"
    echo "Se recomienda desplegar desde 'main' o 'master'"
fi

echo "📝 Verificando cambios de Git..."
git status

echo ""
echo "✅ Asegúrate de que:"
echo "   1. Has hecho commit de todos los cambios"
echo "   2. Has configurado las variables de entorno en Railway"
echo "   3. Has agregado una base de datos PostgreSQL en Railway"
echo ""
echo "Presiona Enter para continuar o Ctrl+C para cancelar..."
read

echo "🔄 Ejecutando 'railway up'..."
railway up

echo ""
echo "✅ Despliegue completado!"
echo ""
echo "Para ver los logs:"
echo "  railway logs"
echo ""
echo "Para acceder a la app:"
echo "  railway open"
