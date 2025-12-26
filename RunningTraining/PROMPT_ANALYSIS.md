# Análisis del Prompt de Generación de Planes

## 📊 ANÁLISIS DEL PROMPT ACTUAL

### ✅ Fortalezas

1. **Rol claro**: "Entrenador profesional de running especializado en media maratones"
2. **Estructura organizada**: Parámetros → Requisitos → Formato → Reglas
3. **Ejemplos concretos**: Incluye ejemplos de JSON que ayudan al modelo
4. **Formato JSON especificado**: Schema claro con tipos de datos
5. **Reglas importantes**: Especifica validaciones y edge cases

### ❌ Debilidades Identificadas

#### 1. **Falta de Inferencia de Nivel**
```
PROBLEMA:
- No infiere si el usuario es principiante, intermedio o avanzado
- No ajusta el plan según el ritmo objetivo vs última carrera
- No considera el volumen actual del corredor

IMPACTO:
- Planes pueden ser demasiado agresivos para principiantes
- O demasiado conservadores para corredores experimentados
```

#### 2. **Volúmenes Iniciales No Especificados**
```
PROBLEMA:
- No da guidance sobre kilometraje semanal total
- No especifica distancia inicial del long run
- No ajusta según sesiones/semana (3 vs 6 días es MUY diferente)

IMPACTO:
- Riesgo de sobrecarga (over-training)
- Progresión puede ser inadecuada
```

#### 3. **Fases Genéricas**
```
PROBLEMA:
- "Base Building" sin especificar duración
- No ajusta fases según tiempo total disponible
- 8 semanas vs 20 semanas necesitan fases muy diferentes

IMPACTO:
- Plan puede estar mal periodizado
- No aprovecha bien el tiempo disponible
```

#### 4. **No Aprovecha Chain-of-Thought**
```
PROBLEMA:
- GPT-4o es excelente con razonamiento paso a paso
- Pide resultado directo sin "pensar"
- No explica la lógica del plan

IMPACTO:
- Calidad del plan puede ser inconsistente
- Falta de personalización profunda
```

#### 5. **Falta de Safety & Prevención de Lesiones**
```
PROBLEMA:
- No menciona prevención de lesiones
- No enfatiza importancia de recuperación
- No especifica warm-up/cool-down

IMPACTO:
- Planes pueden ser arriesgados
- No educa sobre entrenamiento seguro
```

#### 6. **Información de Última Carrera Subutilizada**
```
PROBLEMA:
- Solo dice "ajusta el plan en consecuencia"
- No da criterios específicos de cómo usar esa info
- No compara ritmo objetivo vs ritmo real

IMPACTO:
- IA puede ignorar esta información valiosa
- No aprovecha datos reales del usuario
```

#### 7. **Prompt Demasiado Largo**
```
PROBLEMA:
- 133 líneas es extenso
- Algunos puntos son redundantes
- Ejemplo JSON muy detallado puede limitar creatividad

IMPACTO:
- Mayor costo por tokens
- Puede confundir al modelo con detalles
```

---

## 🚀 PROPUESTA DE OPTIMIZACIÓN

### Estrategia de Mejora

#### 1. **Añadir Chain-of-Thought Reasoning**
```
ANTES:
"Genera un plan de entrenamiento..."

DESPUÉS:
"Antes de generar el plan, analiza:
1. Nivel del corredor (principiante/intermedio/avanzado)
2. Volumen semanal recomendado
3. Duración óptima de cada fase
Luego genera el plan basándote en este análisis."
```

#### 2. **Inferencia Automática de Nivel**
```swift
// Calcular en el código antes del prompt
let estimatedLevel: String
if lastRacePace < currentPace * 0.85 {
    estimatedLevel = "AVANZADO"
} else if lastRacePace < currentPace * 0.95 {
    estimatedLevel = "INTERMEDIO"
} else {
    estimatedLevel = "PRINCIPIANTE"
}

// O usar solo en el prompt:
"Infiere el nivel del corredor comparando:
- Ritmo objetivo: 6:00/km
- Ritmo última carrera 10K: 5:30/km
→ Esto sugiere nivel INTERMEDIO-AVANZADO"
```

#### 3. **Especificaciones de Volumen**
```
AÑADIR:
- Volumen semanal inicial recomendado:
  · 3 sesiones/semana: 20-30km total
  · 4 sesiones/semana: 30-40km total
  · 5+ sesiones/semana: 40-50km total

- Long run inicial: 40-50% del volumen semanal
- Incremento máximo: 10% semanal (con semanas de descarga)
```

#### 4. **Periodización Específica**
```
AÑADIR:
Para X semanas de preparación:
- 8-10 semanas: 40% base, 40% build, 20% taper
- 11-14 semanas: 35% base, 45% build, 20% taper
- 15+ semanas: 30% base, 50% build, 20% taper
```

#### 5. **Safety Guidelines**
```
AÑADIR:
PREVENCIÓN DE LESIONES:
- Nunca incrementar distancia Y intensidad a la vez
- Incluir 10 min warm-up en workouts intensos
- Minimum 1 día completo de descanso/semana
- Señales de alerta: dolor persistente, fatiga extrema
```

#### 6. **Uso Inteligente de Última Carrera**
```
AÑADIR:
ANÁLISIS DE ÚLTIMA CARRERA:
Si ritmo última carrera < ritmo objetivo:
  → Corredor sub-estimando capacidad
  → Ajustar ritmos 5-10% más rápido
  → Incrementar volumen más agresivamente

Si ritmo última carrera > ritmo objetivo:
  → Corredor sobre-estimando capacidad
  → Ser conservador en progresión
  → Enfocarse en construcción aeróbica
```

---

## 📝 PROMPT OPTIMIZADO (Propuesta)

### Versión Mejorada - Más Concisa y Efectiva

```
Eres un entrenador profesional certificado en running, especializado en media maratones.

PERFIL DEL CORREDOR:
- Sesiones/semana: {sessionsPerWeek}
- Semanas hasta carrera: {weeksUntilRace}
- Ritmo objetivo: {currentPace}
- FC Máxima: {maxHeartRate} bpm
{lastRaceInfo}

PASO 1 - ANÁLISIS (reasoning interno):
Determina:
a) Nivel del corredor (principiante/intermedio/avanzado)
   - Comparar ritmo objetivo vs última carrera
   - Considerar volumen semanal y experiencia

b) Volumen semanal apropiado
   - {sessionsPerWeek} sesiones → {X-Y}km totales/semana
   - Long run inicial: {Z}km

c) Distribución de fases
   - Base: {X} semanas
   - Build: {Y} semanas
   - Taper: 2 semanas

PASO 2 - PLAN DE {weeksUntilRace} SEMANAS:

Principios:
✓ Incremento gradual (máx 10%/semana, con descarga cada 3-4 sem)
✓ Variedad: long_run, tempo_run, intervals, easy_run, recovery_run, rest
✓ Safety: warm-up en intensos, min 1 día descanso/semana
✓ Zonas FC: z1(50-60%), z2(60-70%), z3(70-80%), z4(80-90%), z5(90-100%)

Tipos de workout:
- long_run: Construir resistencia (zona 2-3)
- tempo_run: Umbral anaeróbico (zona 3-4)
- intervals: Velocidad/VO2max (zona 4-5)
- easy_run: Recuperación activa (zona 2)
- recovery_run: Muy suave (zona 1-2)
- rest: Descanso completo

JSON Output (únicamente JSON válido):
{
  "analysis": {
    "runnerLevel": "principiante|intermedio|avanzado",
    "weeklyVolumeKm": {número},
    "reasoning": "Breve explicación del enfoque del plan"
  },
  "weeks": [
    {
      "weekNumber": 1,
      "focus": "Base Building|Build Phase|Peak Week|Taper",
      "totalVolumeKm": {número},
      "workouts": [
        {
          "dayOfWeek": 1-7,
          "type": "long_run|tempo_run|intervals|easy_run|recovery_run|rest",
          "title": "Título descriptivo",
          "distanceKm": {número o null si rest},
          "targetPaceMinPerKm": {número o null si rest},
          "heartRateZone": "zone1|zone2|zone3|zone4|zone5" (null si rest),
          "description": "Descripción detallada con instrucciones",
          "goals": ["objetivo1", "objetivo2"]
        }
      ]
    }
  ]
}

REGLAS CRÍTICAS:
- dayOfWeek: 1=Lun, 7=Dom
- TOTAL workouts/semana = {sessionsPerWeek} (incluye rest si aplica)
- Última 2 semanas = taper (50% volumen)
- Minimum 1 long_run/semana
- NO incrementar distancia E intensidad simultáneamente
- Para "rest": omitir distanceKm, targetPaceMinPerKm, heartRateZone
- Para otros tipos: TODOS los campos requeridos

DEVUELVE ÚNICAMENTE JSON VÁLIDO, SIN MARKDOWN NI TEXTO ADICIONAL.
```

---

## 🎯 MEJORAS CLAVE

### 1. Chain-of-Thought (PASO 1)
- Fuerza al modelo a razonar antes de generar
- Mejora consistencia y calidad

### 2. Análisis en el Output
- Campo "analysis" explica la lógica
- Usuario puede ver el "por qué" del plan
- Debugging más fácil

### 3. Más Conciso
- De ~130 líneas → ~80 líneas
- Menos redundancia
- Más claro

### 4. Safety Integrado
- Prevención de lesiones explícita
- Warm-up mencionado
- Días de descanso garantizados

### 5. Uso Inteligente de Datos
- Compara ritmo objetivo vs real
- Ajusta automáticamente el nivel
- Volumen semanal calculado

### 6. Volumen Total Visible
- Campo "totalVolumeKm" por semana
- Permite validar progresión
- Detecta errores fácilmente

---

## 📊 COMPARACIÓN

| Aspecto | Prompt Actual | Prompt Optimizado |
|---------|---------------|-------------------|
| **Longitud** | ~133 líneas | ~80 líneas |
| **Reasoning** | ❌ No | ✅ Sí (PASO 1) |
| **Nivel inferido** | ❌ No | ✅ Sí |
| **Volumen especificado** | ❌ Implícito | ✅ Explícito |
| **Safety** | ⚠️ Mínimo | ✅ Integrado |
| **Última carrera** | ⚠️ Mencionada | ✅ Analizada |
| **Output validable** | ⚠️ Parcial | ✅ Con totales |
| **Costo tokens** | ~600 tokens | ~400 tokens |

---

## 🔬 TESTING RECOMENDADO

Para validar la mejora, probar con:

### Test Case 1: Principiante
- 3 sesiones/semana
- 12 semanas
- Ritmo objetivo: 7:00/km
- Sin última carrera
- **Esperado**: Plan conservador, volumen bajo (~25km/sem)

### Test Case 2: Intermedio
- 4 sesiones/semana
- 14 semanas
- Ritmo objetivo: 6:00/km
- Última carrera: 10K a 5:45/km
- **Esperado**: Plan moderado, ritmos ajustados (~35km/sem)

### Test Case 3: Avanzado
- 5 sesiones/semana
- 16 semanas
- Ritmo objetivo: 5:00/km
- Última carrera: 21K a 4:50/km
- **Esperado**: Plan agresivo, volumen alto (~50km/sem)

---

## ⚡ SIGUIENTE PASO

¿Quieres que implemente el prompt optimizado?

**Ventajas**:
- ✅ Planes más personalizados
- ✅ Mejor uso de datos del usuario
- ✅ Más seguro (prevención lesiones)
- ✅ 30% menos tokens (ahorro costos)
- ✅ Output más validable

**Consideraciones**:
- ⚠️ Requiere testing para verificar mejora
- ⚠️ Posible breaking change en parser (nuevo campo "analysis")
- ⚠️ GPT-4o puede tardar ~1-2s más (reasoning)

