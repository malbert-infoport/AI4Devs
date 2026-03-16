# PROMPT PARA AUDITORÍA DE TESTS DE COMPONENTES UI

## Contexto del Proyecto

Framework: Angular 20+ standalone  
Testing: Jasmine + Karma  
RxJS 7+  
Arquitectura basada en separación de responsabilidades  
Principio rector: Contract-First Testing

---

## Modo Auditoría (Obligatorio)

Este meta-prompt **NO debe generar tests desde cero**.

Su función es:

1. Analizar un archivo existente (`*.component.spec.ts`).
2. Evaluar cumplimiento técnico y contractual.
3. Detectar desviaciones respecto al contexto.
4. Emitir un informe estructurado.
5. Proponer correcciones concretas cuando aplique.

No reescribir completamente el archivo salvo solicitud explícita.

---

## 1. Preparación y Validación de Contexto

Debe consultarse obligatoriamente:

```
#file:prompt_test_components_ui_v1.md
```

Archivos de referencia del componente auditado (si aplica):

```
#file:conductor-vehiculo-dialog
#file:conductor-vehiculo-grid
```

Aplicar siempre:

- [RULES:CONTRACT_FIRST]
- [RULES:TESTBED_CONFIG]
- [RULES:NSWAG_MOCKS]
- [RULES:ANGULAR_SIGNALS]

En caso de conflicto, prevalece CONTRACT_FIRST.

---

## 2. Auditoría Contractual

Verificar que cada test:

- Representa un contrato público del componente.
- Falla únicamente si cambia el comportamiento observable.
- No depende de implementación interna.

Clasificar como incumplimiento si el test:

- Espía métodos privados.
- Verifica flags internos no contractuales.
- Depende de estructura interna del componente.
- Rompe ante refactors sin cambio funcional.

---

## 3. Validación Técnica Angular 20+ y RxJS 7+

### RxJS

Está prohibido encontrar:

```typescript
of(value, asyncScheduler);
throwError(() => error, asyncScheduler);
```

Debe utilizarse:

```typescript
scheduled([value], asyncScheduler);
defer(() => throwError(() => error));
```

Reportar cualquier uso incorrecto.

---

### Angular Signals

Si el componente usa:

- `input()`
- `model()`

Debe verificarse que los tests utilicen:

```typescript
fixture.componentRef.setInput('prop', valor);
```

Reportar incumplimientos de [RULES:ANGULAR_SIGNALS].

---

### Imports

Validar que:

- `EventEmitter` proviene de `@angular/core`.
- No existen imports duplicados.
- No existen imports sin uso.
- Los imports son específicos y no genéricos innecesarios.

---

## 4. Auditoría de Estructura del Archivo

Evaluar si el archivo cumple:

1. Imports limpios y específicos.
2. Uso correcto de `jasmine.SpyObj` para servicios inyectados.
3. Aplicación correcta de `overrideComponent` cuando el componente usa `providers: []`.
4. Inicialización de `@Inputs` y `gridConfig` antes del primer `fixture.detectChanges()`.
5. El `describe` principal coincide exactamente con el nombre de la clase del componente.
6. Uso sistemático de `fakeAsync` y `tick()` en asincronía.

---

## 5. Auditoría de Cobertura Funcional

Verificar cobertura de:

- Ciclo de vida (`ngOnInit`, `ngOnChanges`, etc.).
- Formularios (comportamiento funcional, no estructura interna).
- Grids (contrato funcional, no configuración interna).
- DOM relevante y permisos.
- Diálogos / modales.
- Eventos `@Output`.
- Estados observables y loading states.

Evaluar cobertura de riesgo funcional, no cantidad de tests.

---

## 6. Evaluación de Optimización y Mantenibilidad

Analizar:

- Existencia de duplicación innecesaria.
- Posibilidad de consolidar setup en función `setup()`.
- Uso de constantes compartidas.
- Tests redundantes.
- Complejidad innecesaria o sobre-ingeniería.

Proponer mejoras manteniendo intacto el contrato funcional.

---

## 7. Clasificación Final

### Estado de Cumplimiento

- ✅ Cumple completamente
- ⚠️ Cumple parcialmente
- ❌ No cumple

---

### Informe Estructurado

El resultado debe incluir:

#### 1️ Incumplimientos Críticos

- Regla vulnerada.
- Explicación.
- Ubicación aproximada en el archivo.
- Propuesta concreta de corrección.

#### 2️ Incumplimientos Técnicos

- RxJS incorrecto.
- Signals mal gestionadas.
- TestBed mal configurado.
- Problemas potenciales de compilación.

#### 3️ Mejoras Recomendadas

- Simplificación.
- Consolidación de mocks.
- Refactorización estructural.

---

## 8. Evaluación Cuantitativa (Opcional)

Asignar puntuación:

- Score Contractual: 0–10
- Score Técnico: 0–10
- Score Mantenibilidad: 0–10

Justificar cada puntuación brevemente.

---

## 9. Restricciones

- No generar un archivo nuevo completo.
- No modificar reglas del contexto.
- No justificar desviaciones que contradigan CONTRACT_FIRST.
- No simular ejecución de tests salvo que se solicite explícitamente.

---

## Objetivo del Meta-Prompt

Garantizar que todos los tests de componentes UI:

- Respeten el contrato público del componente.
- Cumplan Angular 20+, Signals y RxJS 7+.
- Sean robustos ante refactors.
- Mantengan coherencia estructural con la arquitectura del proyecto.
