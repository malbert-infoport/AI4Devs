## Instrucciones de Uso

### 1. Preparación

Debe consultarse el contexto técnico antes de proceder: #file:prompt_test_components_ui_v1.md

Archivos de referencia del componente a testear:

#file:conductor-vehiculo-dialog
#file:conductor-vehiculo-grid

### 2. Generación de Tests

**Requisito Obligatorio: Compatibilidad con Angular 20+ y RxJS**

Requisitos de implementación previos a la generación de código:

- No está permitido usar `of(value, asyncScheduler)` - debe utilizarse `scheduled([value], asyncScheduler)`
- No está permitido usar `throwError(() => error, asyncScheduler)` - debe utilizarse `throwError(() => error)`
- Importar obligatoriamente `scheduled` y `switchMap` desde `rxjs`
- Para errores asíncronos en tests: debe utilizarse `scheduled([1], asyncScheduler).pipe(switchMap(() => throwError(() => error)))`

El archivo de tests generado (ejemplo: `conductor-vehiculo-dialog.component.spec.ts` y `conductor-vehiculo-grid.component.spec.ts`) debe seguir esta estructura:

1. Incluir todos los imports necesarios
2. Crear mocks completos de formularios cuando el componente los utilice
3. Si el componente usa Signals, utiliza exclusivamente fixture.componentRef.setInput para simular cambios de entrada, siguiendo la regla [RULES:ANGULAR_SIGNALS].
4. Configurar spies con valores de retorno por defecto
5. Inicializar @Inputs antes de invocar `fixture.detectChanges()`
6. Implementar tests de:
   - Ciclo de vida
   - Formularios
   - Cambios en @Input
   - Eventos @Output
   - Grids (cuando aplique)
   - Permisos y Estados
   - Diálogos/Modales (cuando aplique)
7. Utilizar `fakeAsync` y `tick` para operaciones asíncronas
8. Verificar estados de loading en operaciones async
9. Definir constantes descriptivas en lugar de valores literales
10. Añadir comentarios en casos de complejidad técnica

### 3. Criterios de Validación

El código generado debe cumplir con los siguientes criterios:

- Compilación exitosa sin errores
- Ejecución exitosa de todos los tests
- Cobertura de riesgo alto y medio
- Código limpio y mantenible

### 4. Optimización Post-Generación

**Regla de Optimización Obligatoria:**

El archivo de tests debe optimizarse antes de finalizar:

- Eliminar duplicación de mocks y spies
- Consolidar tests similares cuando sea técnicamente viable
- Utilizar constantes compartidas y funciones auxiliares
- Objetivo: reducir al menos 30% del código manteniendo cobertura completa

**Validación Mediante Ejecución de Tests:**

El código generado debe validarse ejecutando el siguiente comando (adaptar [component] según el nombre del componente):

```bash
npx ng test --include='**/[component].component.spec.ts' --browsers=ChromeHeadless --watch=false
```

Debe analizarse la salida, corregir errores detectados y re-ejecutar hasta lograr ejecución exitosa de todos los tests.
