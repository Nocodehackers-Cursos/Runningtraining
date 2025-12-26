#!/bin/bash

# Script para verificar que todos los iconos de app están presentes
# Uso: bash verify_icons.sh

ICON_DIR="RunningTraining/Assets.xcassets/AppIcon.appiconset"
MISSING_ICONS=()
FOUND_ICONS=()

echo "🔍 Verificando iconos de app..."
echo ""

# Lista de iconos requeridos
REQUIRED_ICONS=(
    "icon-20@2x.png"
    "icon-20@3x.png"
    "icon-29@2x.png"
    "icon-29@3x.png"
    "icon-40@2x.png"
    "icon-40@3x.png"
    "icon-60@2x.png"
    "icon-60@3x.png"
    "icon-20.png"
    "icon-20@2x-ipad.png"
    "icon-29.png"
    "icon-29@2x-ipad.png"
    "icon-40.png"
    "icon-40@2x-ipad.png"
    "icon-76.png"
    "icon-76@2x.png"
    "icon-83.5@2x.png"
    "icon-1024.png"
)

# Verificar cada icono
for ICON in "${REQUIRED_ICONS[@]}"; do
    if [ -f "$ICON_DIR/$ICON" ]; then
        FOUND_ICONS+=("$ICON")
        echo "✅ $ICON"
    else
        MISSING_ICONS+=("$ICON")
        echo "❌ $ICON - FALTA"
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 RESUMEN"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Iconos encontrados: ${#FOUND_ICONS[@]}/18"
echo "❌ Iconos faltantes: ${#MISSING_ICONS[@]}/18"
echo ""

if [ ${#MISSING_ICONS[@]} -eq 0 ]; then
    echo "🎉 ¡PERFECTO! Todos los iconos están presentes."
    echo "✅ Puedes proceder a archivar la app para TestFlight."
    exit 0
else
    echo "⚠️  FALTAN ICONOS. Por favor, genera los siguientes:"
    echo ""
    for ICON in "${MISSING_ICONS[@]}"; do
        # Extraer tamaño del nombre
        if [[ $ICON == *"1024"* ]]; then
            SIZE="1024x1024"
        elif [[ $ICON == *"20@2x"* ]]; then
            SIZE="40x40"
        elif [[ $ICON == *"20@3x"* ]]; then
            SIZE="60x60"
        elif [[ $ICON == *"29@2x"* ]]; then
            SIZE="58x58"
        elif [[ $ICON == *"29@3x"* ]]; then
            SIZE="87x87"
        elif [[ $ICON == *"40@2x"* ]] && [[ $ICON != *"ipad"* ]]; then
            SIZE="80x80"
        elif [[ $ICON == *"40@3x"* ]]; then
            SIZE="120x120"
        elif [[ $ICON == *"60@2x"* ]]; then
            SIZE="120x120"
        elif [[ $ICON == *"60@3x"* ]]; then
            SIZE="180x180"
        elif [[ $ICON == *"20.png"* ]]; then
            SIZE="20x20"
        elif [[ $ICON == *"29.png"* ]]; then
            SIZE="29x29"
        elif [[ $ICON == *"40.png"* ]]; then
            SIZE="40x40"
        elif [[ $ICON == *"76@2x"* ]]; then
            SIZE="152x152"
        elif [[ $ICON == *"76.png"* ]]; then
            SIZE="76x76"
        elif [[ $ICON == *"83.5@2x"* ]]; then
            SIZE="167x167"
        else
            SIZE="??x??"
        fi
        echo "  • $ICON ($SIZE px)"
    done
    echo ""
    echo "📖 Consulta TESTFLIGHT_FIX.md para instrucciones detalladas."
    exit 1
fi
