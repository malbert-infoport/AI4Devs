# Meta-Prompt: Generación de Tests Unitarios de Alta Precisión

## 1. Preparación y Análisis de Dependencias

**[PASO OBLIGATORIO ANTES DE CODIFICAR]**
Antes de generar cualquier código, realiza un análisis interno (Chain of Thought) del `constructor` y los `providers` de los archivos de referencia:

- Identifica qué servicios están inyectados y deben ser mockeados como `jasmine.SpyObj`.
- Detecta si el componente usa `providers: []` en su decorador para aplicar la regla `[RULES:TESTBED_CONFIG]` (overrideComponent).
- Consulta el contexto técnico: #file:prompt_test_components_ui_v1.md

Archivos de referencia:

- #file:conductor-vehiculo-dialog
- #file:conductor-vehiculo-grid

[RULES:CONTRACT_FIRST]

Antes de generar tests, valida internamente que cada test propuesto:

- representa un contrato público del componente
- falla únicamente si el comportamiento observable cambia
- no depende de la estructura interna del componente

Si un test solo verifica implementación interna, debe ser descartado.

---

## 2. Generación de Tests (Angular 20+ & RxJS 7+)

**Requisito de Compatibilidad Estricta:**

- **RxJS:** Prohibido `of(val, scheduler)` y `throwError(() => err, scheduler)`. Usar `scheduled([val], asyncScheduler)` y `defer(() => throwError(() => err))`.
- **Signals:** Si el componente usa `input()` o `model()`, es obligatorio usar `fixture.componentRef.setInput('prop', valor)` para disparar la reactividad. Seguir `[RULES:ANGULAR_SIGNALS]`.
- **Imports:** Verificar que `EventEmitter` provenga de `@angular/core` y que no existan imports duplicados o sin uso.

**Estructura del archivo `.spec.ts`:**

1.  **Imports:** Limpios y específicos.
2.  **Mocks de Modelos:** Usar siempre constructores `new ModelClassName({...})` siguiendo `[RULES:NSWAG_MOCKS]`.
3.  **Configuración de TestBed:** Implementar spies con valores de retorno por defecto.
4.  **Inicialización:** Establecer `@Inputs` y `gridConfig` ANTES del primer `fixture.detectChanges()`.
5.  **Bloques `describe`:** El nombre del `describe` principal debe coincidir exactamente con el nombre de la clase del componente.
6.  **Cobertura de Tests:** Ciclo de vida, formularios, Grids, DOM/Permisos y Diálogos.
7.  **Asincronía:** Uso sistemático de `fakeAsync` y `tick()`.

---

## 3. Optimización Post-Generación (Regla 30%)

Antes de entregar el resultado, refactoriza el código para reducir redundancia:

- **Setup Helper:** Consolida la creación de mocks en una función `setup()` o similar.
- **Shared Constants:** Agrupa valores comunes al inicio del `describe`.
- **Objetivo:** Código un 30% más compacto manteniendo el 100% de la cobertura lógica.

---

## 4. Validación Mediante Ejecución de Tests

**Este paso es obligatorio para finalizar la tarea:**

El código generado debe validarse simulando la ejecución del siguiente comando:

```bash
npx ng test --include='**/{nombre-componente}.component.spec.ts' --browsers=ChromeHeadless --watch=false
```
