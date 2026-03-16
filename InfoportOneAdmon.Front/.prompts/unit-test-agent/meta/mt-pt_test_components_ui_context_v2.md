## Instrucciones de Uso

### 1. Preparación

Debe consultarse el contexto técnico: #file:prompt_test_components_ui_simplified_v2.md

Archivos de referencia del código a testear:

- #file:conductor-vehiculo-dialog
- #file:conductor-vehiculo-grid

[RULES:CONTRACT_FIRST]

Antes de generar tests, valida internamente que cada test propuesto:

- representa un contrato público del componente
- falla únicamente si el comportamiento observable cambia
- no depende de la estructura interna del componente

Si un test solo verifica implementación interna, debe ser descartado.

[RULES:FRAGILITY_GUARD]

Los tests generados deben:

- Verificar únicamente comportamiento observable.
- No depender del orden interno de llamadas privadas.
- No validar implementación interna ni helpers privados.
- No romper ante refactors internos que no alteren contratos públicos.
- Evitar duplicación de escenarios ya cubiertos por otros tests.

### 2. Generación de Tests

**Requisito Obligatorio: Compatibilidad con Angular 20+ y RxJS**

**Patrones correctos de implementación:**

- Debe utilizarse `scheduled([value], asyncScheduler)` en lugar de `of(value, asyncScheduler)`
- Debe utilizarse `throwError(() => error)` sin scheduler
- Para errores asíncronos: debe utilizarse `scheduled([1], asyncScheduler).pipe(switchMap(() => throwError(() => error)))`

**Patrones no permitidos (deprecated):**

- No está permitido: `of(value, asyncScheduler)`
- No está permitido: `throwError(() => error, asyncScheduler)`

**Imports requeridos:** `import { of, throwError, asyncScheduler, scheduled, switchMap } from 'rxjs';`

---

**Procedimiento de análisis obligatorio:**

1. **Analizar archivo .ts del componente** para identificar:
   - Métodos públicos y privados
   - @Input y @Output
   - Getters y setters
   - Subscripciones (ySubscription, etc.)
   - Métodos de lookup (get*, search*)
   - Providers en @Component

2. **Analizar HTML del componente** para identificar:
   - Todos los campos del formulario (inputs, lookups, combos, checkboxes)
   - Eventos y bindings
   - Templates (#addButtonTemplate, #noRecordsTemplate, etc.)

3. **Verificar decorador @Component** - si contiene `providers: [...]`, debe utilizarse `overrideComponent`

4. **Crear mocks NSwag mediante constructor:** `new ModelClassName({...})`

5. **Verificar tipos** en apiClients.ts (ejemplo: idExterno es `number`, no `string`)

6. **Incluir únicamente los providers estrictamente necesarios para ejecutar el componente bajo test.**

- Globales solo si son requeridos explícitamente por el constructor o dependencias.
- Providers declarados en @Component deben gestionarse mediante `overrideComponent` cuando aplique.

7. Determinar qué contratos públicos deben verificarse.

Para cada contrato identificado durante el análisis (Inputs, Outputs, Getters, acciones públicas, efectos observables):

- Generar al menos un test que valide su comportamiento observable.
- No generar tests para estructuras internas sin contrato público.
- No generar bloques completos si el componente no los requiere.

**Estructura base sugerida de organización:**

Los tests deben agruparse por bloques funcionales según los contratos públicos detectados durante el análisis:

- Ciclo de Vida
- Formularios
- Inputs / Outputs
- Permisos y Estados
- Lookup Functions (si existen)
- Form Listeners (si existen)
- Grid Actions (si aplica)
- Delete Actions (si aplica)
- Diálogos/Modales (si aplica)
- Configuración de Grid (si aplica)

La inclusión de cada bloque dependerá exclusivamente del análisis previo del componente.

No deben generarse tests para bloques inexistentes en el componente.

**Criterios de inclusión de tests:**

- **Form Listeners**: Incluir solo cuando el componente tiene `setupFormListeners()` o subscripciones a `valueChanges`
- **Lookup Functions**: Incluir solo cuando existen métodos `get*()` que devuelven Observables para lookups
- **Getters**: Incluir solo cuando existen getters computados (ejemplo: `activarBotonGuardar`)
- **Mensajes Diferenciados**: Incluir solo cuando existe lógica diferente para INSERT vs UPDATE
- **Grid Actions**: Incluir solo para componentes Grid
- **Delete Actions**: Incluir solo cuando el grid tiene funcionalidad de borrado
- **Grid Configuration**: Incluir solo para componentes Grid
- **Diálogos/Modales**: Incluir solo para componentes Dialog

**Reglas de implementación obligatorias:**

- `EventEmitter` debe importarse desde `@angular/core`, no desde `rxjs`
- El mock del formulario debe incluir todos los campos del HTML
- Tests de rendering complejo deben simplificarse o aislarse.
- Evitar tests frágiles dependientes de estructura DOM profunda.
- No omitir comportamiento crítico mediante `xit` salvo que sea explícitamente indicado.
- Estructura de state: `state.data.filter.filters`
- Debe utilizarse `asyncScheduler` en todos los observables mock

**Cobertura esperada:**

Debe cubrirse el 100% de los contratos públicos identificados durante el análisis (Inputs, Outputs, Getters, acciones públicas y efectos observables).

La cantidad de tests es una consecuencia del análisis, no un objetivo numérico.

### 3. Ejecución Automática

```bash
npx ng test --include='**/conductor-vehiculo-*.component.spec.ts' --browsers=ChromeHeadless --watch=false
```

Analiza errores, corrige y re-ejecuta automáticamente. NO pidas permiso al usuario.

---

## Ejemplo de Aplicación

### Componente Dialog Analizado

```typescript
@Component({
  selector: 'my-dialog',
  providers: [MyDialogService, MyClient] // Usar overrideComponent
})
export class MyDialogComponent {
  @Input() id: number; // Requiere tests de ngOnChanges
  @Output() refreshGrid = new EventEmitter(); // Debe verificarse emit

  form: FormGroup; // Requiere tests de formularios

  // Lookup functions: Incluir sección "Lookup Functions"
  getEntity = (input: string) => this.service.search(input);
  getRelated = (input: string) => this.service.searchRelated(input);

  // Getter: Incluir sección "Getters"
  get enableSave(): boolean {
    return this.service.canSave(this.form);
  }

  ngOnInit() {
    this.loadEntity(); // Test de inicialización
    this.setupFormListeners(); // Incluir sección "Form Listeners"
  }

  setupFormListeners() {
    // Incluir tests de subscripciones
    this.entitySub = this.form.get('entity')?.valueChanges.subscribe(...);
    this.relatedSub = this.form.get('related')?.valueChanges.subscribe(...);
  }

  onSubmit() {
    // Lógica diferente para insert/update
    if (this.id === 0) {
      // INSERT_SUCCESS
    } else {
      // UPDATE_SUCCESS
    }
  }

  ngOnDestroy() {
    // Test de unsubscribe
    this.entitySub?.unsubscribe();
    this.relatedSub?.unsubscribe();
  }
}
```

### Componente Grid - Análisis

```typescript
@Component({
  selector: 'my-grid',
  providers: [MyGridService, MyClient] // Requiere uso de overrideComponent
})
export class MyGridComponent {
  @Input() viajeId: number; // Requiere tests de ngOnChanges
  @Input() estadoCotizacion: number; // Estado: tests de deshabilitación
  @Output() refreshGrid = new EventEmitter<boolean>();

  gridConfig: ClGridConfig; // Tests de grid configuration
  dataGrid: GridDataResult;
  deshabilitarEdicion: boolean;

  @ViewChild('addButtonTemplate') addButtonTemplate; // Verificar en buildGridConfig

  get viajesModificacion() {
    // Test de permisos
    return this.accessService.hasPermission();
  }

  get isNew() {
    // Test de getter
    return this.viajeId === 0;
  }

  ngOnChanges(changes: SimpleChanges) {
    // Tests de cambios de input y estados
    if (changes['estadoCotizacion']) {
      this.deshabilitarEdicion = this.shouldDisable();
    }
  }

  rowSelected(item: MyEntity) {
    // Test de grid action
    if (!this.deshabilitarEdicion) {
      this.openDialog(item.id);
    }
  }

  addAction() {
    // Test de add action
    if (!this.deshabilitarEdicion) {
      this.openDialog(0);
    }
  }

  onExternalDelete(event: any) {
    // Incluir sección "Delete Actions"
    if (this.deshabilitarEdicion) return;

    this.clModalService.openModal({
      type: 'info',
      submitButton: {
        action: () => {
          this.service.delete(event.dataItem.id).subscribe();
        }
      }
    });
  }
}
```

**Cantidad esperada de tests**: Aproximadamente 35 tests

- Ciclo de Vida: 2 tests (create, initialize)
- @Input Changes: 4 tests (viajeId, estado, zero value, reload)
- Permisos: 6 tests (viajesModificacion, isNew, estados)
- Grids Simples: 3 tests (config, state, load data)
- Grid Actions: 6 tests (rowSelected, addAction, modal)
- Delete Actions: 4 tests (confirm, disabled, success, error)
- Grid Configuration: 2 tests (templates, properties)
