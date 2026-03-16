# PROMPT PARA AUDITORÍA DE TESTS DE SERVICIOS

## Contexto del Proyecto

Framework: Angular 20+ standalone\
Testing: Jasmine + Karma\
Arquitectura basada en separación de responsabilidades\
Principio rector: Contract-First Testing

---

## Modo Auditoría (Obligatorio)

Este meta-prompt **NO debe generar tests desde cero**.

Su función es:

1.  Analizar un archivo de tests existente (`*.service.spec.ts`).
2.  Evaluar si cumple las reglas técnicas y contractuales definidas en
    el contexto.
3.  Detectar desviaciones.
4.  Emitir un informe estructurado.
5.  Proponer correcciones concretas cuando aplique.

No modificar automáticamente el archivo salvo que se solicite
explícitamente.

---

## 1. Preparación

Debe consultarse obligatoriamente el contexto técnico:

    #file:prompt_test_services_logic.md

Archivos de referencia del servicio auditado (si aplica):

    #file:conductor-vehiculo-dialog
    #file:conductor-vehiculo-grid

Antes de analizar el archivo:

- Aplicar [RULES:CONTRACT_FIRST]
- Aplicar [RULES:SERVICE_CONTRACT_FIRST]
- Aplicar [RULES:IMPLEMENTATION_GUARD]

En caso de conflicto, prevalecen siempre:

- [RULES:CONTRACT_FIRST]
- [RULES:SERVICE_CONTRACT_FIRST]

---

## 2. Validación Técnica Angular 20+ y RxJS

### Verificar uso correcto de RxJS

Está prohibido encontrar en el archivo:

```typescript
of(value, asyncScheduler);
throwError(() => error, asyncScheduler);
```

Debe utilizarse:

```typescript
scheduled([value], asyncScheduler);
throwError(() => error);
```

Para errores asíncronos:

```typescript
scheduled([1], asyncScheduler).pipe(switchMap(() => throwError(() => error)));
```

### Verificar Imports

Confirmar que:

- `scheduled` y `switchMap` están importados cuando se utilizan.
- `EventEmitter` proviene de `@angular/core`, no de `rxjs`.
- No existen imports no utilizados.

Reportar cualquier incumplimiento.

---

## 3. Auditoría Contractual

### CONTRACT_FIRST

Un test solo debe fallar si cambia:

- Un input público
- Un output emitido
- Un estado observable
- Un efecto funcional expuesto

Reportar como incumplimiento si existen tests que:

- Verifican implementación interna
- Espían métodos privados
- Validan flags internos no contractuales
- Rompen ante refactors sin cambio funcional

---

### SERVICE_CONTRACT_FIRST

Verificar que los tests:

- Cubren comportamiento observable del servicio
- Verifican outputs y side-effects reales
- No dependen de estructura interna

---

### IMPLEMENTATION_GUARD

Detectar si existen tests que:

- Verifican orden interno de llamadas privadas
- Acceden a propiedades privadas sin necesidad contractual
- Validan detalles estructurales internos

Clasificar estos casos como **Incumplimiento Contractual**.

---

## 4. Evaluación de Calidad Técnica

Analizar el archivo y responder:

- ¿Incluye todos los imports necesarios?
- ¿Hay imports innecesarios?
- ¿Los spies tienen valores de retorno coherentes?
- ¿Se utilizan correctamente `fakeAsync` y `tick`?
- ¿Se verifican estados de loading cuando corresponde?
- ¿Se usan constantes descriptivas en lugar de valores literales?
- ¿Existe duplicación innecesaria?
- ¿Existen tests redundantes?

---

## 5. Evaluación de Cobertura de Riesgo

Determinar si el archivo cubre:

- Flujos principales (happy path)
- Casos de error relevantes
- Estados intermedios importantes
- Condiciones límite significativas

No evaluar cantidad de tests.\
Evaluar únicamente cobertura de riesgo funcional.

---

## 6. Clasificación Final

### Estado de Cumplimiento

- ✅ Cumple completamente
- ⚠️ Cumple parcialmente
- ❌ No cumple

---

### Informe Estructurado

El resultado debe incluir:

#### 1️ Incumplimientos Críticos

- Regla vulnerada
- Explicación
- Ubicación aproximada en el archivo
- Propuesta concreta de corrección

#### 2️ Incumplimientos Técnicos

- Uso incorrecto de RxJS
- Imports erróneos
- Async mal gestionado
- Problemas de compilación potencial

#### 3️ Mejoras Recomendadas

- Simplificaciones posibles
- Eliminación de duplicación
- Consolidación de mocks
- Refactorización de tests redundantes

---

## 7. Evaluación Cuantitativa (Opcional pero Recomendado)

Asignar puntuación:

- Score Contractual: 0--10
- Score Técnico: 0--10
- Score Mantenibilidad: 0--10

Justificar cada puntuación brevemente.

---

## 8. Restricciones

- No generar un archivo completo nuevo.
- No reescribir todo el test salvo solicitud explícita.
- No modificar reglas del contexto.
- No justificar desviaciones si contradicen CONTRACT_FIRST.

---

## Objetivo del Meta-Prompt

Garantizar que todos los archivos de tests de servicios:

- Respeten el contrato funcional del servicio.
- Cumplan con Angular 20+ y buenas prácticas RxJS.
- Sean mantenibles y robustos ante refactors.
- No contengan deuda técnica oculta.
