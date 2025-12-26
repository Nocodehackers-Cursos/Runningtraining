# 🔧 Solución de Errores de TestFlight

## 🔴 Errores a Solucionar:

1. ❌ Falta icono de **120x120 px** (iPhone/iPod Touch)
2. ❌ Falta icono de **152x152 px** (iPad)
3. ❌ Falta valor `CFBundleIconName` en Info.plist

---

## ✅ SOLUCIÓN PASO A PASO

### PASO 1: Generar Iconos de App

Tienes **3 opciones** para generar los iconos:

#### **Opción A: Usar un generador online (MÁS RÁPIDO)** ⭐ RECOMENDADO

1. Ve a **https://www.appicon.co/** o **https://icon.kitchen/**
2. Sube tu logo/icono en formato PNG de alta resolución (mínimo 1024x1024)
3. Descarga el pack completo de iconos
4. Descomprime el archivo ZIP

#### **Opción B: Crear iconos manualmente con Photoshop/Figma**

Si tienes un diseño personalizado, crea las siguientes imágenes:

**iPhone:**
- 40x40 px → `icon-20@2x.png`
- 60x60 px → `icon-20@3x.png`
- 58x58 px → `icon-29@2x.png`
- 87x87 px → `icon-29@3x.png`
- 80x80 px → `icon-40@2x.png`
- 120x120 px → `icon-40@3x.png` ⚠️ **CRÍTICO**
- 120x120 px → `icon-60@2x.png` ⚠️ **CRÍTICO**
- 180x180 px → `icon-60@3x.png`

**iPad:**
- 20x20 px → `icon-20.png`
- 40x40 px → `icon-20@2x-ipad.png`
- 29x29 px → `icon-29.png`
- 58x58 px → `icon-29@2x-ipad.png`
- 40x40 px → `icon-40.png`
- 80x80 px → `icon-40@2x-ipad.png`
- 76x76 px → `icon-76.png`
- 152x152 px → `icon-76@2x.png` ⚠️ **CRÍTICO**
- 167x167 px → `icon-83.5@2x.png`

**App Store:**
- 1024x1024 px → `icon-1024.png` ⚠️ **CRÍTICO**

#### **Opción C: Usar ImageMagick desde terminal**

Si tienes un icono de 1024x1024 px llamado `app-icon.png`:

```bash
# Navegar a la carpeta del icono
cd /ruta/donde/esta/tu/icono

# Generar todos los tamaños (ejecuta cada línea)
convert app-icon.png -resize 40x40 icon-20@2x.png
convert app-icon.png -resize 60x60 icon-20@3x.png
convert app-icon.png -resize 58x58 icon-29@2x.png
convert app-icon.png -resize 87x87 icon-29@3x.png
convert app-icon.png -resize 80x80 icon-40@2x.png
convert app-icon.png -resize 120x120 icon-40@3x.png
convert app-icon.png -resize 120x120 icon-60@2x.png
convert app-icon.png -resize 180x180 icon-60@3x.png
convert app-icon.png -resize 20x20 icon-20.png
convert app-icon.png -resize 40x40 icon-20@2x-ipad.png
convert app-icon.png -resize 29x29 icon-29.png
convert app-icon.png -resize 58x58 icon-29@2x-ipad.png
convert app-icon.png -resize 40x40 icon-40.png
convert app-icon.png -resize 80x80 icon-40@2x-ipad.png
convert app-icon.png -resize 76x76 icon-76.png
convert app-icon.png -resize 152x152 icon-76@2x.png
convert app-icon.png -resize 167x167 icon-83.5@2x.png
cp app-icon.png icon-1024.png
```

---

### PASO 2: Añadir Iconos al Proyecto

1. **Copia todos los archivos PNG generados** a esta carpeta:
   ```
   /Users/alejandrobernardodiaz/Desktop/Runningtraining/RunningTraining/RunningTraining/Assets.xcassets/AppIcon.appiconset/
   ```

2. Verifica que los nombres de archivo coincidan **exactamente** con los del `Contents.json`:
   - `icon-20@2x.png`
   - `icon-20@3x.png`
   - `icon-29@2x.png`
   - ... (todos los listados arriba)

---

### PASO 3: Configurar CFBundleIconName en Xcode

1. Abre el proyecto en **Xcode**
2. Selecciona el target **RunningTraining** en el navegador
3. Ve a la pestaña **Build Settings**
4. Busca **"Asset Catalog Compiler - Options"**
5. Encuentra **"Primary App Icon Set Name"**
6. Escribe: `AppIcon`

**O bien, configurarlo en Info:**

1. Selecciona el target **RunningTraining**
2. Ve a la pestaña **Info**
3. En **Custom iOS Target Properties**, haz clic en **+**
4. Añade:
   - **Key**: `CFBundleIconName`
   - **Type**: String
   - **Value**: `AppIcon`

---

### PASO 4: Verificar en Xcode

1. Abre **Xcode**
2. En el navegador de proyectos, ve a:
   ```
   RunningTraining → Assets.xcassets → AppIcon
   ```

3. Deberías ver **todos los slots llenos** con tus iconos:
   - iPhone Notification (20pt): 2x, 3x ✓
   - iPhone Settings (29pt): 2x, 3x ✓
   - iPhone Spotlight (40pt): 2x, 3x ✓
   - iPhone App (60pt): 2x, 3x ✓
   - iPad Notification (20pt): 1x, 2x ✓
   - iPad Settings (29pt): 1x, 2x ✓
   - iPad Spotlight (40pt): 1x, 2x ✓
   - iPad App (76pt): 1x, 2x ✓
   - iPad Pro (83.5pt): 2x ✓
   - App Store: 1024x1024 ✓

4. Si ves advertencias amarillas o rojas, significa que **faltan iconos**

---

### PASO 5: Compilar y Archivar

1. En Xcode, selecciona **Product → Clean Build Folder** (⇧⌘K)
2. Selecciona **Product → Archive** (⌘B primero para compilar)
3. Una vez archivado, haz clic en **Distribute App**
4. Selecciona **TestFlight & App Store**
5. Sigue los pasos para subir a TestFlight

---

## ✅ Verificación Final

Antes de archivar, verifica que:

- [ ] Todos los iconos PNG están en la carpeta `AppIcon.appiconset/`
- [ ] No hay advertencias en Assets.xcassets → AppIcon
- [ ] `CFBundleIconName` está configurado como `AppIcon`
- [ ] El proyecto compila sin errores (⌘B)
- [ ] Has incrementado el **Build Number** en Xcode (General tab)

---

## 🎨 Recomendaciones de Diseño

Para un icono de app de running:

- **Fondo**: Degradado oscuro (negro → azul oscuro) para match con el tema dark de tu app
- **Símbolo**: Figura corriendo simplificada en blanco/cyan
- **Estilo**: Minimalista, legible incluso a 20x20 px
- **Sin texto**: Los iconos pequeños no deben tener texto

**Inspiración de colores (basado en tu app):**
- Primary: `#00D4FF` (cyan brillante)
- Background: Degradado negro → `#1C1C1E`

---

## 🐛 Troubleshooting

### "Missing CFBundleIconName"
➜ Añade la key en Build Settings → Primary App Icon Set Name = `AppIcon`

### "Icon appears stretched/pixelated"
➜ Asegúrate de que cada icono sea **exactamente** del tamaño especificado

### "Xcode shows yellow warning on icon"
➜ Falta ese tamaño específico de icono, generarlo y añadirlo

### "Archive falla con error de iconos"
➜ Clean Build Folder (⇧⌘K) y vuelve a archivar

---

## 📦 Archivos Generados

Ya he actualizado el `Contents.json` con la configuración correcta. Ahora solo necesitas:

1. Generar los iconos (usa appicon.co)
2. Copiarlos a la carpeta AppIcon.appiconset/
3. Configurar CFBundleIconName
4. Archivar de nuevo

---

**Última actualización**: 25/12/2024
