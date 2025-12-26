# Plan de Desarrollo - RunningTraining App

## Estado Actual de la Aplicación

### ✅ COMPLETADO (100% funcional)

#### 1. Arquitectura y Modelos (SwiftData)
- **User**: Modelo de usuario con preferencias de entrenamiento
- **TrainingPlan**: Plan de entrenamiento completo
- **TrainingWeek**: Semana de entrenamiento
- **Workout**: Entrenamiento individual
- **WorkoutType**: Tipos de entrenamientos (enum)
- **HeartRateZone**: Zonas de frecuencia cardíaca

#### 2. Servicios
- **OpenAIService**: Integración completa con GPT-4o
- **TrainingPlanService**: Gestión de planes de entrenamiento
- **TrainingPlanParser**: Parser de JSON de OpenAI a modelos
- **PromptBuilder**: Constructor de prompts para IA

#### 3. ViewModels
- **OnboardingViewModel**: Lógica de onboarding y generación de plan
- **CalendarViewModel**: Lógica de calendario y navegación semanal
- **WorkoutViewModel**: Lógica de detalle de entrenamientos

#### 4. Vistas - Onboarding
- **WelcomeView**: Pantalla de bienvenida con features
- **OnboardingFlowView**: Contenedor del flujo con navegación enum-based
- **Componentes de onboarding**:
  - OnboardingProgressBar: Indicador de progreso visual
  - OnboardingStepContainer: Wrapper reutilizable para pasos
  - InputValidationBadge: Feedback visual de validación
  - InfoTooltip: Tooltips educativos
  - EditableDataCard: Cards editables para resumen
- **Vistas de pasos individuales**:
  - SessionsInputView: Input sesiones por semana
  - RaceDateInputView: Input fecha de carrera
  - PaceInputView: Input ritmo actual
  - HeartRateInputView: Input FC máxima
  - SummaryView: Resumen editable pre-generación
- **GeneratingPlanView**: Pantalla de carga con progreso real
- **UserInputView** (deprecado): Formulario único antiguo

#### 5. Vistas - App Principal
- **ContentView**: Router principal (onboarding ↔ calendario)
- **CalendarView**: Vista de calendario estilo Runna
  - Header con stats del plan
  - Navegación semanal
  - Calendario de 7 días
  - Lista de workouts
- **WorkoutDetailView**: Detalle completo del entrenamiento

#### 6. Componentes Reutilizables
- **PrimaryButton**: Botón personalizado con loading states
- **LoadingView**: Vista de carga reutilizable
- **FormSection**: Sección de formulario
- **FeatureRow**: Fila de características
- **StatCard**: Card de estadísticas
- **BottomNavigationBar**: Barra de navegación inferior

#### 7. Utilities
- **DateExtensions**: Extensiones de Date (semanas, formato, etc.)
- **PaceFormatter**: Formateador de ritmos y distancias
- **ColorTheme (AppTheme)**: Tema de colores estilo Runna

#### 8. Configuración
- **Config**: Configuración de API Key de OpenAI
- **RunningTrainingApp**: Setup de SwiftData

---

## 🎯 PARA TENER LA APP FUNCIONAL

### PASO 1: Verificar que compila
- Compilar el proyecto y corregir errores si los hay
- Verificar que todas las dependencias estén correctas

### PASO 2: Probar el flujo completo
- Probar onboarding → generar plan → ver calendario → marcar workouts

### PASO 3: Gestión de errores
- Añadir manejo de errores más robusto
- Mensajes de error amigables
- Retry logic para fallos de red

---

## 🚀 FUNCIONALIDADES PENDIENTES (Para MVP+)

### A. Vistas faltantes del BottomNavigationBar

#### 1. Vista "Hoy" (Today View)
**Prioridad: ALTA**
- Mostrar entrenamiento de hoy
- Countdown hasta el próximo workout
- Resumen rápido del progreso semanal
- Botón rápido para marcar como completado

#### 2. Vista "Actividades" (Activities/History)
**Prioridad: MEDIA**
- Historial de entrenamientos completados
- Estadísticas acumuladas
- Gráficas de progreso
- Filtros por semana/mes

#### 3. Vista "Comunidad" (Community)
**Prioridad: BAJA**
- Placeholder por ahora
- Futuro: compartir planes, logros

#### 4. Vista "Soporte" (Support/Settings)
**Prioridad: MEDIA**
- Configuración de usuario
- Editar preferencias
- Crear nuevo plan
- Eliminar plan actual
- Información de la app
- FAQ/Ayuda

### B. Funcionalidades de gestión

#### 5. Editar Usuario
- Modificar sesiones por semana
- Actualizar FC máxima
- Cambiar ritmo objetivo
- Cambiar sistema de unidades (km/millas)

#### 6. Gestión de Planes
- Crear nuevo plan (reset onboarding)
- Eliminar plan actual
- Ver historial de planes anteriores
- Duplicar plan

#### 7. Notificaciones
- Recordatorios de entrenamientos
- Notificación del día de la carrera
- Motivación semanal

### C. Mejoras opcionales

#### 8. Integración HealthKit
- Importar FC real de entrenamientos
- Exportar workouts a Apple Health
- Sincronizar datos de actividad

#### 9. Gráficas y Analytics
- Progreso de distancia semanal
- Tendencia de completitud
- Comparativa de ritmos

#### 10. Funciones avanzadas
- Editar workouts individuales
- Añadir notas a entrenamientos
- Subir fotos de entrenamientos
- Exportar plan a PDF
- Compartir plan

---

## 📋 PLAN DE IMPLEMENTACIÓN SUGERIDO

### Fase 1: MVP Funcional (1-2 días)
1. ✅ Verificar compilación
2. ✅ Probar flujo completo
3. ✅ Corregir bugs críticos
4. ✅ Mejorar manejo de errores

### Fase 2: Funcionalidades Core (2-3 días) - ✅ COMPLETADO
1. ✅ Vista "Hoy" (Today View)
   - TodayViewModel implementado
   - TodayView con todos los componentes
   - Workout de hoy con opción de completar
   - Estadísticas de la semana
   - Próximos entrenamientos
2. ✅ Vista "Soporte/Ajustes" con:
   - SettingsViewModel implementado
   - Editar usuario (EditUserView con validaciones)
   - Crear nuevo plan
   - Eliminar plan
   - Info de la app
3. ✅ Integración en ContentView
4. ✅ Compilación exitosa (BUILD SUCCEEDED)

### Fase 2.5: Onboarding Mejorado (1-2 días) - ✅ COMPLETADO
1. ✅ Componentes base de onboarding
   - OnboardingProgressBar (indicador de progreso paso X de 5)
   - InputValidationBadge (feedback visual de validación)
   - InfoTooltip (tooltips educativos contextuales)
   - OnboardingStepContainer (wrapper reutilizable para vistas)
   - EditableDataCard (cards editables para resumen)

2. ✅ Vistas individuales paso a paso
   - SessionsInputView (sesiones por semana con stepper visual)
   - RaceDateInputView (fecha de carrera con validación 8+ semanas)
   - PaceInputView (ritmo actual con formato mm:ss)
   - HeartRateInputView (FC máxima con fórmula sugerida)
   - SummaryView (resumen editable antes de generar)

3. ✅ Mejoras al OnboardingViewModel
   - Enum OnboardingStep con 7 estados (welcome → generating)
   - Navegación bidireccional (navigateNext, navigateBack, navigateToStep)
   - Validación incremental por campo
   - Progreso de generación simulado (0% → 100% con mensajes)

4. ✅ Refactor de OnboardingFlowView
   - Switch-based navigation en lugar de boolean flags
   - Transiciones slide horizontales asimétricas
   - Animaciones spring sutiles (.spring(response: 0.35, dampingFraction: 0.85))
   - Dirección contextual (forward/backward)

5. ✅ Pantalla de carga mejorada (GeneratingPlanView)
   - Progress bar lineal con porcentaje
   - Mensajes dinámicos contextuales
   - Iconos animados con symbolEffect (.pulse, .rotate)
   - Integración con simulación de progreso

6. ✅ Animaciones y polish
   - Entrada staggered de elementos (delay 0.08s)
   - Feedback háptico en momentos clave
   - Validación visual en tiempo real
   - Transiciones profesionales estilo iOS nativo

### Fase 3: Integración Apple HealthKit (4-5 semanas) - 🚧 EN PROGRESO

**Objetivo:** Sincronización automática de entrenamientos desde Apple Health

#### 3.1 Infraestructura Core (Semana 1) - ✅ COMPLETADO
- [x] Crear HealthKitService con autorización y queries
- [x] Implementar extracción de métricas básicas
- [x] Añadir propiedades HealthKit a modelo Workout
- [x] Crear WorkoutMatcher para emparejamiento automático
- [x] Crear modelos auxiliares (WorkoutMetrics, PerformanceStatus)

**Archivos creados:**
- ✅ `Services/HealthKitService.swift` (500 líneas) - Servicio completo con autorización, queries, extracción de métricas y observer
- ✅ `Services/WorkoutMatcher.swift` (250 líneas) - Algoritmo de matching con scoring system
- ✅ `Models/WorkoutMetrics.swift` (100 líneas) - Estructura de métricas de HealthKit
- ✅ `Models/PerformanceStatus.swift` (100 líneas) - Enum de estados de rendimiento
- ✅ `Models/Workout.swift` (MODIFICADO) - Añadidas 10+ propiedades HealthKit y computed properties

**Compilación:** ✅ BUILD SUCCEEDED (25/12/2024)

#### 3.2 Sincronización Básica (Semana 2) - ✅ COMPLETADO (25/12/2024)
- [x] Extracción de métricas (distancia, duración, ritmo) - Ya implementado en HealthKitService
- [x] Métodos sync en TrainingPlanService - syncHealthKitWorkouts(), markWorkoutCompletedWithHealthKitSync()
- [x] UI: Toggle HealthKit en Settings
- [x] UI: Badge de sincronización en workouts (TodayWorkoutCard + CalendarView)
- [x] Sincronización manual desde Settings

**Archivos creados:**
- ✅ `Views/Components/HealthKitBadge.swift` (50 líneas) - Badge visual para workouts sincronizados

**Archivos modificados:**
- ✅ `Services/TrainingPlanService.swift` - Añadidos métodos de sincronización (150 líneas nuevas)
  - `syncHealthKitWorkouts()` - Sincroniza workouts en rango de fechas
  - `fetchPlannedWorkouts()` - Obtiene workouts planificados
  - `updateWorkoutWithHealthKitData()` - Actualiza workout con datos reales
  - `markWorkoutCompletedWithHealthKitSync()` - Completa con sync inteligente
- ✅ `ViewModels/SettingsViewModel.swift` - Añadida lógica HealthKit (80 líneas nuevas)
  - `healthKitEnabled`, `isSyncingHealthKit`, `healthKitSyncStatus` - Propiedades de estado
  - `checkHealthKitStatus()` - Verificar autorización
  - `requestHealthKitAuthorization()` - Solicitar permisos
  - `syncLast30Days()` - Sincronización manual
  - `disableHealthKit()` - Desactivar HealthKit
- ✅ `Views/Settings/SettingsView.swift` - Añadida sección Apple Health (70 líneas nuevas)
  - Toggle de activación/desactivación HealthKit
  - Botón de sincronización manual con indicador de progreso
  - Mensajes de estado de sincronización
- ✅ `Views/Today/Components/TodayWorkoutCard.swift` - Badge de HealthKit en header
- ✅ `Views/Calendar/CalendarView.swift` - Badge de HealthKit en RunnaStyleWorkoutCard

**Documentación:**
- ✅ `HEALTHKIT_SETUP.md` - Guía de configuración de HealthKit en Xcode

**Compilación:** ✅ BUILD SUCCEEDED (25/12/2024)

#### 3.3 Frecuencia Cardíaca (Semana 3)
- [ ] Extracción de datos de FC desde HealthKit
- [ ] Cálculo de distribución por zonas de FC
- [ ] UI: ComparisonRow component
- [ ] UI: Comparación planificado vs real en WorkoutDetailView
- [ ] Mostrar métricas de FC en TodayView

#### 3.4 Auto-sync & Background (Semana 4)
- [ ] Sync automático al abrir app (últimos 30 días)
- [ ] Pull-to-refresh en TodayView
- [ ] HKObserverQuery para updates en tiempo real
- [ ] Background app refresh
- [ ] Scene phase observer

#### 3.5 Pulido & Edge Cases (Semana 5)
- [ ] Algoritmo de matching avanzado con scoring
- [ ] UI de resolución de conflictos (múltiples workouts)
- [ ] Vista de historial de sync en Settings
- [ ] Testing exhaustivo en dispositivo físico
- [ ] Optimizaciones de rendimiento

**Archivos clave:**
- Services/HealthKitService.swift (CREAR)
- Services/WorkoutMatcher.swift (CREAR)
- Services/BackgroundSyncManager.swift (CREAR)
- Models/Workout.swift (MODIFICAR - añadir propiedades HealthKit)
- Models/WorkoutMetrics.swift (CREAR)
- Models/PerformanceStatus.swift (CREAR)
- Views/Components/HealthKitBadge.swift (CREAR)
- Views/Components/ComparisonRow.swift (CREAR)

### Fase 4: Mejoras UX (2-3 días)
1. 🎯 Vista "Actividades/Historial"
2. 🎯 Notificaciones locales
3. 🎯 Mejoras visuales adicionales

### Fase 5: Features Premium (Futuro)
1. 🚀 Gráficas y analytics avanzados
2. 🚀 Comunidad/Social
3. 🚀 Exportar/Compartir
4. 🚀 Apple Watch companion app
5. 🚀 Integración Strava/Garmin

---

## 🐛 POSIBLES BUGS A VERIFICAR

1. **Timezone handling**: Verificar que las fechas se manejen correctamente
2. **SwiftData migrations**: Si cambias modelos, necesitarás migrations
3. **API Key security**: La API key está hardcoded, debería estar en secrets
4. **Error handling**: Qué pasa si OpenAI falla? Retry? Offline?
5. **Empty states**: Qué pasa si no hay plan? Si no hay workouts?
6. **Navigation**: Verificar que la navegación funcione correctamente
7. **Memory leaks**: Verificar retención de objetos
8. **Threading**: Asegurar que UI updates estén en main thread

---

## 💡 RECOMENDACIONES

1. **Testing**: Escribir tests para servicios críticos (OpenAI, Parser)
2. **Error logging**: Implementar logging centralizado
3. **Analytics**: Añadir analytics para entender uso de la app
4. **Feedback**: Añadir forma de enviar feedback
5. **Onboarding skip**: Permitir saltar onboarding en desarrollo
6. **Mock data**: Crear datos de prueba para desarrollo
7. **Localización**: Preparar app para internacionalización
8. **Accessibility**: Verificar accesibilidad (VoiceOver, tamaños de texto)

---

## 🎨 MEJORAS VISUALES OPCIONALES

1. Animaciones más fluidas
2. Haptic feedback
3. Confetti cuando completas workout
4. Badges de logros
5. Progreso visual más llamativo
6. Modo claro (actualmente solo oscuro)
7. Temas de color personalizables

---

## 📝 NOTAS IMPORTANTES

- **API Key**: La API key de OpenAI está hardcoded. NUNCA subir a repositorio público.
- **Costos**: Cada generación de plan consume tokens de OpenAI (~$0.10-0.50 por plan)
- **Timeout**: El timeout está en 60 segundos, puede no ser suficiente
- **Modelo**: Usando gpt-4o, considera gpt-4o-mini para reducir costos
- **Validaciones**: Añadir más validaciones en inputs de usuario
- **Persistencia**: SwiftData maneja la persistencia automáticamente

---

## ✅ SIGUIENTE PASO RECOMENDADO

**OPCIÓN A - Compilar y probar lo que tenemos:**
1. Compilar el proyecto
2. Probar el flujo completo
3. Corregir bugs que encontremos
4. Desplegar en TestFlight

**OPCIÓN B - Añadir funcionalidad crítica:**
1. Implementar Vista "Hoy" (Today View)
2. Implementar Vista "Ajustes" para gestionar usuario/planes
3. Añadir manejo robusto de errores
4. Añadir notificaciones

**OPCIÓN C - Mejorar lo existente:**
1. Mejorar UI/UX actual
2. Añadir animaciones
3. Mejorar feedback visual
4. Optimizar rendimiento

---

## 🎯 TU DECISIÓN

¿Qué quieres hacer ahora?

A) Compilar y probar la app actual
B) Añadir la Vista "Hoy" (Today View)
C) Añadir la Vista "Ajustes/Soporte"
D) Mejorar manejo de errores
E) Otra cosa específica
