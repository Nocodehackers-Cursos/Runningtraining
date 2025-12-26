# Guía de Prueba - RunningTraining App

## 🎯 Objetivo
Verificar que todos los flujos de la aplicación funcionen correctamente.

---

## 📱 Paso 1: Ejecutar la App

### En Xcode (Ya abierto):
1. Selecciona un simulador (iPhone 16 recomendado)
2. Presiona `Cmd + R` o el botón ▶️ Play
3. Espera a que la app se instale y arranque

---

## ✅ Paso 2: Flujo de Onboarding

### 2.1 Pantalla de Bienvenida
**Qué esperar**:
- ✅ Fondo oscuro
- ✅ Icono de corredor grande y colorido
- ✅ Título "RunningTraining"
- ✅ Subtítulo "Tu entrenador personal de media maratón"
- ✅ 3 características listadas (IA, Zonas FC, Periodización)
- ✅ Botón "Comenzar" turquesa

**Acción**: Presiona "Comenzar"

---

### 2.2 Formulario de Datos
**Qué esperar**:
- ✅ Título "Configura tu Plan"
- ✅ 4 secciones de formulario:

#### a) Entrenamientos por semana
- Stepper con valor por defecto: 4
- Rango: 3-7 días
- **Prueba**: Ajusta a 4 o 5 días

#### b) Fecha de la carrera
- DatePicker
- Muestra "X semanas de preparación"
- **Prueba**: Selecciona una fecha ~12 semanas en el futuro
- **Mínimo**: 8 semanas desde hoy

#### c) Ritmo actual
- Campo numérico
- Por defecto: 6.0 min/km
- Muestra el ritmo formateado (ej: "6:00 /km")
- **Prueba**: Introduce 6.0 o 6.5

#### d) FC máxima
- Campo numérico
- Por defecto: 180 bpm
- Ayuda: "Si no la conoces, usa: 220 - tu edad"
- **Prueba**: Introduce tu FC máxima (ej: 180)

**Validaciones a probar**:
- ❌ Fecha menor a 8 semanas → Debe mostrar error
- ❌ FC < 140 o > 220 → Debe mostrar error
- ❌ Ritmo < 3 o > 10 → Debe mostrar error

**Acción**: Presiona "Generar Plan"

---

### 2.3 Pantalla de Generación
**Qué esperar**:
- ✅ Icono de corredor animado (pulsando)
- ✅ Spinner de carga
- ✅ Mensaje: "Generando tu plan personalizado de media maratón..."
- ✅ Nota: "Esto puede tardar hasta 60 segundos"

**Duración esperada**: 20-60 segundos

**Posibles problemas**:

#### Si tarda más de 60 segundos:
- La API de OpenAI puede estar lenta
- Espera un poco más (máx 90 segundos)

#### Si muestra error:
Posibles causas:
1. **Sin internet**: Verifica tu conexión
2. **API Key inválida**: La API key en Config.swift puede estar vencida
3. **Sin créditos**: La cuenta de OpenAI no tiene créditos
4. **Timeout**: El request tomó demasiado tiempo

**Qué hace internamente**:
1. Crea un objeto User con tus datos
2. Construye un prompt detallado para GPT-4o
3. Llama a la API de OpenAI (puede tardar 30-60s)
4. Parsea el JSON de respuesta
5. Crea objetos TrainingPlan, TrainingWeek, Workout
6. Guarda todo en SwiftData
7. Navega al calendario

---

## 📅 Paso 3: Vista de Calendario

### 3.1 Header del Plan
**Qué esperar**:
- ✅ Título "Plan de Media Maratón"
- ✅ Fecha de la carrera
- ✅ Badge circular con "X días" hasta la carrera
- ✅ "Semanas completadas: 0/X"
- ✅ "Progreso: 0%"
- ✅ Barra de progreso (inicialmente vacía)

---

### 3.2 Calendario Semanal
**Qué esperar**:
- ✅ Navegación: ← Semana X →
- ✅ Fecha de inicio de la semana
- ✅ Días de la semana: L M X J V S D
- ✅ Círculos de colores para días con workout:
  - 🟢 Verde: Easy Run / Recovery
  - 🟠 Naranja: Tempo Run
  - 🔴 Rojo: Intervals / Hill Repeats
  - 🟣 Morado: Long Run
  - ⚪ Gris: Rest
- ✅ Checkmark en workouts completados

**Acciones a probar**:
- Presiona → para ir a la semana siguiente
- Presiona ← para volver a la semana anterior
- Los botones se deshabilitan si no hay más semanas

---

### 3.3 Card de Enfoque
**Qué esperar**:
- ✅ Icono de objetivo
- ✅ "Enfoque de la semana"
- ✅ Descripción (ej: "Base Building", "Speed Work", "Taper")

---

### 3.4 Lista de Workouts
**Qué esperar para cada workout**:
- ✅ Barra de color lateral (según tipo)
- ✅ Título del workout
- ✅ Tipo de workout (en color)
- ✅ Icono de distancia + distancia (ej: "10.5 km")
- ✅ Icono de velocímetro + ritmo (ej: "5:30 /km")
- ✅ Zona FC con círculo de color (ej: "Zona 2 • 108-126 bpm")
- ✅ Chevron derecho →
- ✅ Checkmark si está completado

**Acción**: Toca cualquier workout

---

## 🏃 Paso 4: Detalle de Workout

### 4.1 Header
**Qué esperar**:
- ✅ Barra de color superior
- ✅ Icono grande del tipo de workout
- ✅ Título del workout
- ✅ Tipo de workout en color
- ✅ Fecha formateada (ej: "lunes, 30 diciembre")

---

### 4.2 Stats Principales
**Qué esperar** (según el tipo de workout):
- ✅ Card "Distancia" (ej: "10.5 km")
- ✅ Card "Duración" (si aplica, ej: "1 h 5 min")
- ✅ Card "Ritmo Objetivo" (ej: "5:30 /km")

---

### 4.3 Zona de Frecuencia Cardíaca
**Qué esperar**:
- ✅ Título "Zona de Frecuencia Cardíaca"
- ✅ Círculo de color según zona
- ✅ Nombre de zona (ej: "Zona 2")
- ✅ Descripción (ej: "Base Aeróbica")
- ✅ Rango BPM (ej: "108-126 bpm")
- ✅ Rango porcentaje (ej: "60-70%")

---

### 4.4 Descripción
**Qué esperar**:
- ✅ Título "Descripción"
- ✅ Texto descriptivo del workout
- ✅ Instrucciones específicas
- ✅ Consideraciones técnicas

---

### 4.5 Objetivos
**Qué esperar**:
- ✅ Título "Objetivos del Entrenamiento"
- ✅ Lista de 2-4 objetivos
- ✅ Cada uno con checkmark circular
- ✅ Texto descriptivo

---

### 4.6 Botón de Completar
**Qué esperar**:
- ✅ Si NO está completado:
  - Botón con color del workout
  - Texto: "Marcar como Completado"
  - Icono: checkmark
- ✅ Si está completado:
  - Botón gris
  - Texto: "Marcar como Pendiente"
  - Icono: X

**Acción**:
1. Presiona "Marcar como Completado"
2. El modal se cierra
3. Verifica en el calendario que el workout ahora tiene un checkmark ✓

---

## 🔄 Paso 5: Verificar Persistencia

### 5.1 Completar varios workouts
**Acciones**:
1. Completa 2-3 workouts de diferentes días
2. Observa que la barra de progreso aumenta
3. Observa que el porcentaje cambia

### 5.2 Cerrar y reabrir la app
**Acciones**:
1. Desde Xcode: Presiona el botón ⏹ Stop
2. Vuelve a presionar ▶️ Play
3. Espera a que arranque

**Qué esperar**:
- ✅ La app va DIRECTO al calendario (sin onboarding)
- ✅ Los workouts completados siguen marcados
- ✅ El progreso se mantiene
- ✅ La semana actual está seleccionada

### 5.3 Desmarcar workout
**Acciones**:
1. Abre un workout completado
2. Presiona "Marcar como Pendiente"
3. Verifica que el checkmark desaparece
4. Verifica que el progreso disminuye

---

## 🧪 Paso 6: Pruebas de Edge Cases

### 6.1 Workout de Descanso (Rest)
**Buscar un workout tipo "Descanso"**:
- ✅ NO debe tener distancia
- ✅ NO debe tener ritmo
- ✅ NO debe tener zona FC
- ✅ Solo debe tener descripción

### 6.2 Navegar todas las semanas
**Acción**: Navega semana por semana hasta el final
**Verificar**:
- ✅ Cada semana tiene workouts
- ✅ La última semana es "Taper" (volumen reducido)
- ✅ La semana antes de la carrera tiene menos entrenamientos
- ✅ Los workouts progresan lógicamente

### 6.3 Verificar Long Run
**Buscar un "Long Run" (Carrera Larga)**:
- ✅ Debe tener la mayor distancia de la semana
- ✅ Debe estar en Zona 2 normalmente
- ✅ Debe tener ritmo conservador
- ✅ Descripción debe mencionar "resistencia" o "aeróbica"

### 6.4 Verificar Intervals
**Buscar un workout de "Intervalos"**:
- ✅ Debe estar en Zona 4 o 5
- ✅ Debe tener ritmo más rápido
- ✅ Descripción debe mencionar series/repeticiones
- ✅ Debe mencionar recuperación

---

## 📊 Paso 7: Verificar Bottom Navigation

**Qué esperar**:
- ✅ 5 pestañas en la parte inferior:
  1. 🏠 Hoy (no funcional aún)
  2. 📅 Plan (activo, color turquesa)
  3. 📈 Actividades (no funcional aún)
  4. 👥 Comunidad (no funcional aún)
  5. ℹ️ Soporte (no funcional aún)

**Nota**: Solo "Plan" está implementado. Las demás son para futuras versiones.

---

## ✅ Checklist de Verificación

### Funcionalidad Core
- [ ] Onboarding se completa sin errores
- [ ] Plan se genera exitosamente (20-60s)
- [ ] Calendario muestra todas las semanas
- [ ] Workouts se muestran correctamente
- [ ] Detalle de workout muestra toda la info
- [ ] Se pueden marcar workouts como completados
- [ ] Se pueden desmarcar workouts
- [ ] Progreso se actualiza correctamente
- [ ] Datos persisten al cerrar/abrir app

### UI/UX
- [ ] Colores se ven correctos
- [ ] Textos legibles
- [ ] Botones responden al toque
- [ ] Animaciones suaves
- [ ] No hay glitches visuales
- [ ] Loading states se ven bien

### Datos
- [ ] Todas las semanas tienen workouts
- [ ] Workouts tienen datos coherentes
- [ ] Zonas FC son correctas
- [ ] Ritmos son razonables
- [ ] Distancias progresan lógicamente
- [ ] La última semana es Taper

---

## 🐛 Problemas Comunes y Soluciones

### Problema 1: "Error generando plan"
**Posibles causas**:
1. Sin internet
2. API Key inválida/vencida
3. Sin créditos en OpenAI
4. Timeout

**Solución**:
1. Verifica conexión a internet
2. Verifica la API key en `Config.swift`
3. Verifica créditos en platform.openai.com
4. Intenta de nuevo con plan más corto (8 semanas)

### Problema 2: "La app se queda en loading infinito"
**Causa**: Timeout de OpenAI
**Solución**:
1. Para la app (⏹)
2. Borra la app del simulador
3. Ejecuta de nuevo
4. Intenta con menos semanas

### Problema 3: "Los datos no persisten"
**Causa**: Error en SwiftData
**Solución**:
1. Device → Erase All Content and Settings en Simulador
2. Ejecuta de nuevo

### Problema 4: "Textos en inglés"
**Causa**: Locale del simulador
**Solución**:
- La app está en español
- Verifica que los textos estén en español
- Si no, revisa DateFormatter locales

---

## 📝 Reportar Issues

Si encuentras algún problema, anota:
1. **Qué paso estabas haciendo**
2. **Qué esperabas que pasara**
3. **Qué pasó en realidad**
4. **Captura de pantalla si es posible**
5. **Console logs si hay errores**

---

## 🎉 Si Todo Funciona

¡Felicidades! Tu app está **100% funcional** para el MVP.

### Próximos pasos sugeridos:
1. **Implementar Vista "Hoy"** - Pantalla principal
2. **Implementar Vista "Ajustes"** - Gestionar usuario/planes
3. **Añadir notificaciones** - Recordatorios de workouts
4. **Mejorar error handling** - Para mejor UX
5. **Añadir tests** - Para asegurar calidad

---

## 💡 Tips de Desarrollo

### Ver Console Logs
En Xcode, mira el panel inferior durante la ejecución.
Verás logs como:
```
✅ SwiftData ModelContainer inicializado correctamente
📝 Generando plan de entrenamiento...
✅ Plan generado exitosamente por OpenAI
✅ Plan parseado exitosamente
✅ Plan guardado en SwiftData
```

### Depurar Problemas
Si algo falla:
1. Lee los console logs
2. Busca líneas con ❌
3. Los errores tienen descripción detallada

### Resetear App
Para empezar de cero:
1. Device → Erase All Content and Settings
2. O borra la app y reinstala

---

¡Buena suerte con las pruebas! 🚀
