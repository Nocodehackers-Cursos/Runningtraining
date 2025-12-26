# Configuración de HealthKit - RunningTraining

## 📋 Pasos Necesarios para Completar la Integración

### 1. Añadir Capability de HealthKit

1. Abre el proyecto en Xcode
2. Selecciona el target **RunningTraining**
3. Ve a la pestaña **Signing & Capabilities**
4. Haz clic en **+ Capability**
5. Busca y añade **HealthKit**

### 2. Añadir Permisos de Privacidad

Necesitas añadir las descripciones de uso de HealthKit al proyecto:

1. En Xcode, selecciona el target **RunningTraining**
2. Ve a la pestaña **Info**
3. En **Custom iOS Target Properties**, añade las siguientes entradas:

#### Privacy - Health Share Usage Description
- **Key**: `NSHealthShareUsageDescription`
- **Type**: String
- **Value**: `RunningTraining necesita acceso a tus entrenamientos para sincronizar automáticamente tus carreras y comparar tu rendimiento con tu plan.`

#### Privacy - Health Update Usage Description (opcional, pero recomendado)
- **Key**: `NSHealthUpdateUsageDescription`
- **Type**: String
- **Value**: `RunningTraining solo lee datos de salud, no escribe información nueva.`

### 3. Verificar la Configuración

1. Compila el proyecto (`Cmd+B`)
2. Ejecuta en simulador o dispositivo físico
3. Ve a Ajustes > Apple Health
4. Activa el toggle "Sincronizar con Health"
5. Deberías ver el diálogo de permisos de Apple Health

### 4. Testing en Dispositivo Físico (Recomendado)

⚠️ **IMPORTANTE**: HealthKit tiene funcionalidad limitada en el simulador. Para probar completamente:

1. Conecta un iPhone físico
2. Ejecuta la app en el dispositivo
3. Registra un entrenamiento usando Apple Watch o la app de Salud
4. Abre RunningTraining
5. Habilita HealthKit en Ajustes
6. Presiona "Sincronizar últimos 30 días"
7. Verifica que los entrenamientos se marquen como completados

### 5. Verificar en Health App

Para probar el matching de workouts:

1. Abre la app **Salud** (Health) en iPhone
2. Ve a **Explorar** > **Actividad** > **Entrenamientos**
3. Registra un entrenamiento de carrera
4. Abre RunningTraining
5. Ve a **Ajustes** > **Apple Health**
6. Habilita la sincronización
7. Presiona "Sincronizar últimos 30 días"
8. Vuelve al **Calendario** y verifica que el entrenamiento tenga:
   - Badge verde "Sincronizado"
   - Marcado como completado automáticamente

## ✅ Funcionalidad Implementada

### Backend (100% completo)
- ✅ HealthKitService con autorización y queries
- ✅ WorkoutMatcher con algoritmo de scoring
- ✅ Extracción de métricas (distancia, duración, ritmo, FC)
- ✅ Sincronización automática en TrainingPlanService
- ✅ Modelos extendidos (WorkoutMetrics, PerformanceStatus)

### UI (100% completo)
- ✅ Toggle de HealthKit en Settings
- ✅ Botón de sincronización manual
- ✅ HealthKitBadge component
- ✅ Badge en TodayWorkoutCard
- ✅ Badge en CalendarView workouts
- ✅ Estados de carga y feedback

## 🔜 Próximos Pasos (Fase 3.3)

1. **Frecuencia Cardíaca Avanzada**
   - Distribución de tiempo en zonas de FC
   - Comparación FC real vs objetivo
   - Gráficas de FC en WorkoutDetailView

2. **Auto-Sync & Background (Fase 3.4)**
   - Sincronización automática al abrir app
   - Pull-to-refresh en TodayView
   - Background sync observer

## 📝 Notas Técnicas

- HealthKit requiere dispositivo físico para testing completo
- Los permisos se solicitan solo cuando el usuario activa el toggle
- La sincronización es solo lectura (no escribimos a HealthKit)
- El matching usa scoring: distancia (40%) + duración (30%) + tipo (30%)
- Threshold de matching: 0.5 (50%)

## 🐛 Troubleshooting

### "HealthKit no está disponible"
- HealthKit no está disponible en iPad ni simulador antiguo
- Usa iPhone físico para testing

### "Autorización denegada"
- Ve a Ajustes iOS > Privacidad > Salud > RunningTraining
- Habilita permisos de lectura para Entrenamientos

### "No se sincronizan entrenamientos"
- Verifica que los entrenamientos sean de tipo "Running"
- Verifica que la fecha coincida con un entrenamiento planificado
- Revisa los logs en Xcode Console para ver el scoring de matching

---

**Última actualización**: 25/12/2024
**Fase completada**: 3.2 - Sincronización Básica (100%)
