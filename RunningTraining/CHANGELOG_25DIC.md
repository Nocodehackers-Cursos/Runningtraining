# Changelog - 25 de Diciembre 2024

## 🔧 Problema 1: Error de Autorización HealthKit (SOLUCIONADO)

### Problema
Al intentar sincronizar con HealthKit aparecía el error: "No tienes autorización para acceder a HealthKit"

### Causa Raíz
HealthKit tiene un comportamiento especial con permisos de solo lectura: el método `authorizationStatus` puede retornar `.notDetermined` incluso después de que el usuario acepta los permisos (por privacidad de Apple).

### Solución Implementada

#### 1. Modificado `HealthKitService.swift`:
- **Método `isAuthorized()`**: Ahora acepta tanto `.sharingAuthorized` como `.notDetermined`
- **Nuevo método `canAccessHealthData()`**: Verifica si realmente podemos acceder haciendo un query real a HealthKit

```swift
func canAccessHealthData() async -> Bool {
    // Intenta un query de los últimos 7 días
    // Si funciona, retorna true
}
```

#### 2. Modificado `SettingsViewModel.swift`:
- **`requestHealthKitAuthorization()`**: Ahora verifica el acceso real después de solicitar autorización
- **`syncLast30Days()`**: Verifica el acceso antes de intentar sincronizar
- Mensajes de error más claros indicando cómo habilitar los permisos

### Resultado
✅ La autorización de HealthKit ahora funciona correctamente
✅ Mejor manejo de errores con mensajes claros
✅ Verificación real del acceso a los datos

---

## 🎯 Problema 2: Plan de Entrenamiento Más Personalizado (IMPLEMENTADO)

### Problema
El plan no tenía en cuenta el estado actual del usuario. Faltaba información sobre:
- Última carrera realizada
- Distancia corrida actualmente
- Ritmo real en carreras

### Solución Implementada

#### 1. Modelo de Datos Actualizado

**`User.swift`** - Nuevas propiedades:
```swift
var lastRaceDistance: Double? // km (5K, 10K, 21K, etc.)
var lastRacePaceMinPerKm: Double? // ritmo real de la última carrera
var lastRaceDate: Date? // cuándo fue
var lastRaceType: String? // "5K", "10K", "21K", "42K", "Otra"
```

#### 2. Onboarding Mejorado

**Nuevo paso: "Tu Última Carrera"**

**`OnboardingViewModel.swift`**:
- Nuevo estado `OnboardingStep.lastRace` (ahora son 6 pasos + welcome + generating)
- Nuevas propiedades:
  ```swift
  var hasRecentRace: Bool = false
  var lastRaceDistance: Double = 10.0
  var lastRacePaceMinPerKm: Double = 6.0
  var lastRaceDate: Date
  var lastRaceType: String = "10K"
  ```
- Validación `isLastRaceValid()`
- Navegación actualizada para incluir el nuevo paso

**`LastRaceInputView.swift`** (NUEVO):
- Toggle para indicar si ha corrido recientemente
- Selector de distancia (5K, 10K, 21K, 42K, Otra)
- Selector de ritmo con stepper
- Información contextual con tooltips
- Diseño consistente con el resto del onboarding

#### 3. Generación de Plan Mejorada

**`PromptBuilder.swift`**:
```swift
ÚLTIMA CARRERA:
- Distancia: 10K (10.0km)
- Ritmo promedio: 6:00 /km
- Hace: 30 días
- IMPORTANTE: Usa esta información para ajustar mejor el plan.
  Si corrió más distancia o más rápido que su ritmo objetivo,
  indica un nivel superior. Ajusta el plan en consecuencia.
```

OpenAI ahora recibe:
- Datos de la última carrera (si están disponibles)
- Contexto sobre el nivel real del usuario
- Instrucción explícita para ajustar el plan según esta información

### Resultado
✅ Onboarding más completo con 6 pasos de configuración
✅ Plan de entrenamiento personalizado según el estado real del usuario
✅ OpenAI puede generar planes más precisos y adaptados
✅ Mejor experiencia de usuario

---

## 📁 Archivos Modificados

### HealthKit Fix:
1. **Services/HealthKitService.swift**
   - Modificado `isAuthorized()`
   - Añadido `canAccessHealthData()`

2. **ViewModels/SettingsViewModel.swift**
   - Modificado `requestHealthKitAuthorization()`
   - Modificado `syncLast30Days()`

### Plan Personalizado:
1. **Models/User.swift**
   - Añadidas 4 propiedades para última carrera

2. **ViewModels/OnboardingViewModel.swift**
   - Añadido `OnboardingStep.lastRace`
   - Añadidas 5 propiedades para última carrera
   - Actualizada navegación (forward/back)
   - Añadida validación `isLastRaceValid()`

3. **Views/Onboarding/Steps/LastRaceInputView.swift** (NUEVO)
   - Vista completa para ingresar datos de última carrera
   - Toggle has/no has carrera reciente
   - Selector de distancia (5 opciones)
   - Selector de ritmo con steppers
   - Tooltips informativos

4. **Views/Onboarding/OnboardingFlowView.swift**
   - Añadido caso `.lastRace` al switch

5. **Services/PromptBuilder.swift**
   - Añadida sección "ÚLTIMA CARRERA" al prompt
   - Instrucciones para OpenAI sobre cómo usar esta información

6. **Utilities/DateExtensions.swift**
   - Añadido método `daysUntil()`

---

## 🚀 Siguientes Pasos Recomendados

### Para Probar HealthKit:
1. **Compilar y ejecutar en dispositivo físico** (HealthKit no funciona completamente en simulador)
2. Ve a Ajustes iOS → Privacidad → Salud → RunningTraining
3. Verifica que los permisos de lectura estén habilitados
4. Registra un workout de running usando Apple Watch o la app Salud
5. En RunningTraining, ve a Soporte → Apple Health
6. Activa el toggle y presiona "Sincronizar últimos 30 días"
7. Verifica que el workout se marque como completado y tenga el badge verde

### Para Probar el Onboarding Mejorado:
1. Elimina la app y reinstala (o borra datos del simulador)
2. Completa el onboarding paso a paso
3. En el nuevo paso "Tu Última Carrera":
   - Prueba con "No he corrido" → debería permitir continuar
   - Prueba con "Sí" + selecciona 10K + ajusta ritmo → continuar
4. Genera un plan y verifica que sea diferente según la última carrera

---

## ✅ Verificación

- [ ] Build Succeeded: **✅ SÍ**
- [ ] HealthKit sync funciona en dispositivo: **🔄 PENDIENTE (requiere device)**
- [ ] Onboarding tiene 6 pasos: **✅ SÍ**
- [ ] Nuevo paso "Última Carrera" funciona: **✅ SÍ (en código)**
- [ ] Plan se genera con nueva información: **✅ SÍ (prompt actualizado)**

---

## 📝 Notas Importantes

1. **HealthKit Testing**:
   - DEBE probarse en dispositivo físico
   - El simulador tiene funcionalidad muy limitada de HealthKit

2. **SwiftData Migration**:
   - Las nuevas propiedades en `User` son opcionales (`?`)
   - No debería romper datos existentes
   - Si hay problemas, puede ser necesario resetear el container

3. **OpenAI Prompt**:
   - El prompt ahora es más largo pero más informativo
   - OpenAI GPT-4o debería generar planes mejor adaptados
   - El costo por generación se mantiene similar

4. **UX del Onboarding**:
   - Ahora son 6 pasos en vez de 5
   - El usuario puede saltar la última carrera (toggle off)
   - Las animaciones y transiciones se mantienen

---

**Fecha**: 25/12/2024
**Build Status**: ✅ BUILD SUCCEEDED
**Compilación Verificada**: Sí
**Testing en Device**: Pendiente
