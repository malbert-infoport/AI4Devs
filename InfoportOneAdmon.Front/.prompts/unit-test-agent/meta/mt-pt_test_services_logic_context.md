## Instrucciones de Uso

### 1. Preparación

Debe consultarse el contexto técnico antes de proceder: #file:prompt_test_services_logic.md

Archivos de referencia del servicio a testear:

#file:conductor-vehiculo-dialog
#file:conductor-vehiculo-grid

Antes de generar cualquier test:

- aplicar obligatoriamente [RULES:CONTRACT_FIRST]
- aplicar [RULES:SERVICE_CONTRACT_FIRST]
- descartar tests prohibidos por [RULES:IMPLEMENTATION_GUARD]

### 2. Generación de Tests

**Requisito Obligatorio: Compatibilidad Angular 20+ y RxJS**

Reglas de implementación obligatorias previas a la escritura de código:

1. No está permitido: `of(value, asyncScheduler)` - Debe utilizarse: `scheduled([value], asyncScheduler)`
2. No está permitido: `throwError(() => error, asyncScheduler)` - Debe utilizarse: `throwError(() => error)`
3. Importar obligatoriamente: `scheduled`, `switchMap` desde `rxjs`
4. Para errores asíncronos: debe utilizarse `scheduled([1], asyncScheduler).pipe(switchMap(() => throwError(() => error)))`

**Patrón correcto de implementación:**

```typescript
// Implementación correcta
import { of, throwError, asyncScheduler, scheduled, switchMap } from 'rxjs';

serviceSpy.method.and.returnValue(scheduled([data], asyncScheduler));
serviceSpy.error.and.returnValue(throwError(() => new Error('error')));
```

---

El archivo de tests generado (ejemplo: `conductor-vehiculo-dialog.service.spec.ts` y `conductor-vehiculo-grid.service.spec.ts`) debe seguir esta estructura:

1. Incluir todos los imports necesarios
2. Crear mocks completos de formularios cuando el servicio los utilice
3. Configurar spies con valores de retorno por defecto
4. Inicializar @Inputs antes de invocar `fixture.detectChanges()`
5. Implementar tests de alto valor contractual, tales como:
   - Ciclo de vida observable
   - Formularios (solo comportamiento funcional)
   - Cambios en @Input que afecten al output o side effects
   - Eventos @Output o flujos equivalentes
   - Grids (solo contrato funcional, no configuración interna)
   - Permisos y Estados públicos
   - Diálogos/Modales (cuando formen parte del flujo funcional)
6. Utilizar `fakeAsync` y `tick` para operaciones asíncronas
7. Verificar estados de loading en operaciones async
8. Definir constantes descriptivas en lugar de valores literales
9. Añadir comentarios en casos de complejidad técnica

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
- Objetivo: reducir al menos 30% del código manteniendo intactos todos los contratos funcionales testeados

En caso de conflicto entre reglas técnicas y reglas de contrato,
prevalecen siempre:
[RULES:CONTRACT_FIRST] y [RULES:SERVICE_CONTRACT_FIRST].

**Validación Mediante Ejecución de Tests:**

El código generado debe validarse ejecutando el siguiente comando (adaptar [component] según el nombre del servicio):

```bash
npx ng test --include='**/[component].services.spec.ts' --browsers=ChromeHeadless --watch=false
```

Debe analizarse la salida, corregir errores detectados y re-ejecutar hasta lograr ejecución exitosa de todos los tests.
