# PROMPT PARA GENERACIÓN DE TESTS DE COMPONENTES UI

## Contexto del Proyecto

Framework: Angular 20+ standalone | Testing: Jasmine + Karma | Forms: Reactive | i18n: @ngx-translate

---

## [RULES:CONTRACT_FIRST]

Los tests deben priorizar el comportamiento observable y los contratos públicos del componente.
Un test solo debe fallar si cambia:

- el input público
- el output emitido
- el estado visible (DOM, flags públicos, signals públicos)
- el flujo funcional esperado por el usuario u otros componentes

Está prohibido generar tests que fallen únicamente por:

- refactors internos
- cambios de implementación sin cambio de comportamiento
- reorganización de métodos privados

## [RULES:ANGULAR20_RXJS]

### Requisito Obligatorio: Angular 20+ y RxJS - Funciones Deprecated

**No está permitido usar funciones deprecated de RxJS:**

```typescript
// Error: DEPRECATED - NO USAR
of(value, asyncScheduler);
throwError(() => error, asyncScheduler);

// Correcto: Angular 20+ compatible
scheduled([value], asyncScheduler);
throwError(() => error); // Sin scheduler

// Correcto: Para errores asíncronos en tests
scheduled([1], asyncScheduler).pipe(switchMap(() => throwError(() => error)));
```

**Imports necesarios:**

```typescript
import { of, throwError, asyncScheduler, scheduled, switchMap } from 'rxjs';
```

---

## [RULES:IMPORTS]

### Imports Estándar

```typescript
import { ComponentFixture, TestBed, fakeAsync, tick } from '@angular/core/testing';
import { ReactiveFormsModule, FormBuilder } from '@angular/forms';
import { provideHttpClient } from '@angular/common/http';
import { provideHttpClientTesting } from '@angular/common/http/testing';
import { provideAnimations } from '@angular/platform-browser/animations';
import { of, throwError, asyncScheduler } from 'rxjs';
import { TranslateModule, TranslateLoader } from '@ngx-translate/core';
import { TranslateFakeLoader } from '@ngx-translate/core';
import { SimpleChange, EventEmitter } from '@angular/core';

// MODIFICAR: Importar componente y dependencias
import { ComponentToTest } from './component-to-test.component';
import { ServiceName } from './service-name.service';
import { ModelClassName } from '@webServicesReferences/api/apiClients';
```

**REGLAS OBLIGATORIAS:**

1. `EventEmitter` proviene de `@angular/core`, NO de `rxjs`
2. Deben eliminarse todos los imports no utilizados
3. Deben incluirse únicamente los providers estrictamente necesarios para ejecutar el componente bajo test.

---

## [RULES:NSWAG_MODELS]

### Mocks de Modelos NSwag

**Debe utilizarse siempre el constructor, no está permitido usar objeto literal:**

```typescript
// Error
const mock = { id: 1, nombre: 'test' } as ModelClassName;

// Correcto
const mock = new ModelClassName({ id: 1, nombre: 'test' });
```

**Debe verificarse los tipos en `apiClients.ts`:** propiedades numéricas son `number`, no `string`

---

## [RULES:OVERRIDE_COMPONENT]

### Servicios en Providers del Componente

Si el componente tiene `providers: [...]`, debe usarse `overrideComponent`:

```typescript
// Componente tiene: providers: [MyService]
await TestBed.configureTestingModule({
  imports: [MyComponent],
  providers: [provideHttpClient(), FormBuilder]
})
  .overrideComponent(MyComponent, {
    set: {
      providers: [
        { provide: MyService, useValue: myServiceSpy },
        { provide: OtherClient, useValue: {} }
      ]
    }
  })
  .compileComponents();
```

---

## [RULES:TESTBED_CONFIG]

### Configuración TestBed

```typescript
describe('ComponentToTest', () => {
  let component: ComponentToTest;
  let fixture: ComponentFixture<ComponentToTest>;
  let serviceNameSpy: jasmine.SpyObj<ServiceName>;

  // Constantes de test
  const TEST_ID = 1;
  const TEST_VIAJE_ID = 100;

  beforeEach(async () => {
    serviceNameSpy = jasmine.createSpyObj('ServiceName', ['method1', 'method2']);
    serviceNameSpy.method1.and.returnValue(of(data, asyncScheduler));

    await TestBed.configureTestingModule({
      imports: [
        ComponentToTest,
        ReactiveFormsModule,
        TranslateModule.forRoot({
          loader: { provide: TranslateLoader, useClass: TranslateFakeLoader }
        })
      ],
      providers: [
        provideHttpClient(),
        provideHttpClientTesting(),
        provideAnimations(),
        FormBuilder,
        { provide: EmpleadoClient, useValue: {} }
      ]
    })
      .overrideComponent(ComponentToTest, {
        set: {
          providers: [
            { provide: ServiceName, useValue: serviceNameSpy },
            { provide: ApiClient, useValue: {} }
          ]
        }
      })
      .compileComponents();

    fixture = TestBed.createComponent(ComponentToTest);
    component = fixture.componentInstance;

    // Mock completo del formulario con TODOS los campos del HTML
    component.form = new FormBuilder().group({
      id: [TEST_ID],
      campo1: ['valor'],
      codigoPostal: ['28001'], // No olvidar campos como estos
      referencia: ['REF001'],
      numeroAutorizacion: ['AUTH001']
    });

    // Setear @Inputs ANTES de detectChanges
    component.inputProp = value;
  });
});
```

---

## Ejemplos de Patrones de Test (Aplicar solo si el contrato existe)

Estos ejemplos ilustran patrones de implementación.
No implican obligatoriedad.
Solo deben aplicarse cuando el componente tenga el contrato público correspondiente.

### 1. Ciclo de Vida

Aplicar siempre [RULES:CONTRACT_FIRST].
No verificar secuencias internas de llamadas salvo que afecten al estado observable.

```typescript
it('should create', () => {
  expect(component).toBeTruthy();
});

it('should initialize form on ngOnInit', fakeAsync(() => {
  fixture.detectChanges();
  tick();
  expect(component.form).toBeDefined();
}));

// Solo válido cuando la suscripción forma parte del ciclo de vida observable
it('should unsubscribe on destroy', () => {
  const unsubscribeSpy = jasmine.createSpy('unsubscribe');
  component['subscription'] = { unsubscribe: unsubscribeSpy } as any;
  component.ngOnDestroy();
  expect(unsubscribeSpy).toHaveBeenCalled();
});
```

### 2. Formularios

```typescript
it('should initialize form with correct values', fakeAsync(() => {
  fixture.detectChanges();
  tick();
  expect(component.form.get('campo1')?.value).toBe('valor1');
}));

it('should submit successfully', fakeAsync(() => {
  spyOn(component.refreshGrid, 'emit');
  serviceNameSpy.save.and.returnValue(of(mockEntity, asyncScheduler));

  fixture.detectChanges();
  component.onSubmit();
  tick();

  expect(serviceNameSpy.save).toHaveBeenCalled();
  expect(component.refreshGrid.emit).toHaveBeenCalled();
}));

it('should handle submit error', fakeAsync(() => {
  serviceNameSpy.save.and.returnValue(throwError(() => new Error('error'), asyncScheduler));

  fixture.detectChanges();
  component.onSubmit();
  tick();

  expect(component.loading).toBeFalse();
}));
```

### 3. Form Listeners (Value Changes)

```typescript
it('should call handleFieldChange when field lookup changes', fakeAsync(() => {
  fixture.detectChanges();
  tick();

  const newValue = { id: 99, nombre: 'Nuevo Valor' };
  component.form.get('fieldLookup')?.setValue(newValue);
  tick();

  expect(serviceNameSpy.handleFieldChange).toHaveBeenCalledWith(component.form, newValue);
}));

it('should subscribe to field changes in setupFormListeners', fakeAsync(() => {
  fixture.detectChanges();
  tick();

  expect(component.fieldSubscription).toBeDefined();
}));
```

### 4. Lookup Functions

```typescript
it('should call search method from service', fakeAsync(() => {
  const testInput = 'search term';
  serviceNameSpy.searchEntities.and.returnValue(of([{ id: 1, nombre: 'Result' }], asyncScheduler));

  fixture.detectChanges();
  tick();

  component.getEntity(testInput).subscribe((result) => {
    expect(result).toEqual([{ id: 1, nombre: 'Result' }]);
  });

  tick();

  expect(serviceNameSpy.searchEntities).toHaveBeenCalledWith(testInput);
}));

it('should return results for each lookup function', fakeAsync(() => {
  const testInput = 'test';
  serviceNameSpy.searchMethod.and.returnValue(of([{ id: 1 }], asyncScheduler));

  fixture.detectChanges();
  tick();

  component.getLookupData(testInput).subscribe((result) => {
    expect(result.length).toBeGreaterThan(0);
  });

  tick();
}));
```

### 5. Getters

```typescript
it('should return correct value from getter', fakeAsync(() => {
  serviceNameSpy.shouldEnable.and.returnValue(true);

  fixture.detectChanges();
  tick();

  expect(component.myGetter).toBeTrue();
  expect(serviceNameSpy.shouldEnable).toHaveBeenCalled();
}));

it('should return false from getter when condition not met', fakeAsync(() => {
  serviceNameSpy.shouldEnable.and.returnValue(false);

  fixture.detectChanges();
  tick();

  expect(component.myGetter).toBeFalse();
}));
```

### 6. Mensajes Diferenciados

```typescript
it('should show insert success message when id is 0', fakeAsync(() => {
  const mockSavedData = new ModelClassName({ id: 0 });
  serviceNameSpy.prepareSubmitData.and.returnValue({ id: 0 });
  serviceNameSpy.saveEntity.and.returnValue(of(mockSavedData, asyncScheduler));

  fixture.detectChanges();
  tick();

  component.onSubmit();
  tick();

  expect(sharedMessageSpy.showMessage).toHaveBeenCalledWith('INSERT_SUCCESS');
}));

it('should show update success message when id is greater than 0', fakeAsync(() => {
  const mockSavedData = new ModelClassName({ id: TEST_ID });
  serviceNameSpy.prepareSubmitData.and.returnValue({ id: TEST_ID });
  serviceNameSpy.saveEntity.and.returnValue(of(mockSavedData, asyncScheduler));

  fixture.detectChanges();
  tick();

  component.onSubmit();
  tick();

  expect(sharedMessageSpy.showMessage).toHaveBeenCalledWith('UPDATE_SUCCESS');
}));
```

### 7. Cambios en @Input

```typescript
it('should handle input changes', () => {
  component.state = { data: { filter: { filters: [{ field: 'viajeId', value: 50 }] } } } as any;
  component.viajeId = 50;

  const changes = { viajeId: new SimpleChange(50, 100, false) };
  component.ngOnChanges(changes);

  const filter = component.state.data.filter.filters.find((f: any) => f.field === 'viajeId');
  expect(filter.value).toBe(100);
});

it('should handle change to zero value', () => {
  component.state = { data: { filter: { filters: [{ field: 'viajeId', value: 5 }] } } } as any;
  component.viajeId = 5;

  const changes = { viajeId: new SimpleChange(5, 0, false) };
  component.ngOnChanges(changes);

  const filter = component.state.data.filter.filters.find((f: any) => f.field === 'viajeId');
  expect(filter.value).toBe(0);
});
```

### 8. Grids - Tests Simples

```typescript
// Tests simples que deben ejecutarse
it('should initialize grid config correctly', () => {
  expect(component.gridConfig).toBeDefined();
  expect(component.gridConfig.idGrid).toBe('testGrid');
});

it('should update state on grid events', () => {
  const newState = { skip: 10, take: 5 };
  component.callApi({ data: newState });
  expect(component.state.data).toEqual(jasmine.objectContaining(newState));
});
```

### 9. Permisos y Estados

```typescript
it('should disable edition when estado is Valorado', () => {
  component.estadoCotizacion = EstadoTarificacionEs['Valorado'];
  const changes = { estadoCotizacion: new SimpleChange(null, 2, true) };
  component.ngOnChanges(changes);
  expect(component.deshabilitarEdicion).toBeTrue();
});

it('should enable edition when estado is Pendiente and has permission', () => {
  component.estadoCotizacion = EstadoTarificacionEs['Pendiente'];
  const changes = { estadoCotizacion: new SimpleChange(null, 0, true) };
  component.ngOnChanges(changes);
  expect(component.deshabilitarEdicion).toBeFalse();
});

it('should verify permission getter', () => {
  expect(component.viajesModificacion).toBeDefined();
  expect(accessServiceSpy.maestroViajesModificacion).toHaveBeenCalled();
});

it('should verify permission getter returns false when no permission', () => {
  accessServiceSpy.maestroViajesModificacion.and.returnValue(false);
  expect(component.viajesModificacion).toBeFalse();
});

it('should verify isNew getter when id is 0', () => {
  component.entityId = 0;
  expect(component.isNew).toBeTrue();
});

it('should verify isNew getter returns false when id is not 0', () => {
  component.entityId = TEST_ID;
  expect(component.isNew).toBeFalse();
});
```

### 10. Eventos @Output

```typescript
it('should emit event after successful operation', fakeAsync(() => {
  spyOn(component.outputEvent, 'emit');
  serviceNameSpy.save.and.returnValue(of(mockEntity, asyncScheduler));

  fixture.detectChanges();
  component.onSubmit();
  tick();

  expect(component.outputEvent.emit).toHaveBeenCalledWith(jasmine.any(Object));
}));
```

### 11. Delete Actions (para Grids)

```typescript
it('should open confirmation modal on delete', fakeAsync(() => {
  const removeEvent = { dataItem: new ModelClassName({ id: TEST_ID }) };

  component.onExternalDelete(removeEvent);
  tick();

  expect(clModalServiceSpy.openModal).toHaveBeenCalled();
  const modalConfig = clModalServiceSpy.openModal.calls.mostRecent().args[0];
  expect(modalConfig.type).toBe('info');
}));

it('should not open modal on delete when edition disabled', () => {
  component.deshabilitarEdicion = true;
  const removeEvent = { dataItem: new ModelClassName({ id: TEST_ID }) };

  component.onExternalDelete(removeEvent);

  expect(clModalServiceSpy.openModal).not.toHaveBeenCalled();
});

it('should call delete service and refresh grid on confirm', fakeAsync(() => {
  const removeEvent = { dataItem: new ModelClassName({ id: TEST_ID }) };
  gridServiceSpy.deleteEntity.and.returnValue(of({}, asyncScheduler));

  component.onExternalDelete(removeEvent);
  tick();

  const modalConfig = clModalServiceSpy.openModal.calls.mostRecent().args[0];
  modalConfig.submitButton.action();
  tick();

  expect(gridServiceSpy.deleteEntity).toHaveBeenCalledWith(TEST_ID);
  expect(gridServiceSpy.loadEntities).toHaveBeenCalled();
}));

it('should handle delete error', fakeAsync(() => {
  const removeEvent = { dataItem: new ModelClassName({ id: TEST_ID }) };
  gridServiceSpy.deleteEntity.and.returnValue(throwError(() => new Error('error'), asyncScheduler));

  component.onExternalDelete(removeEvent);
  tick();

  const modalConfig = clModalServiceSpy.openModal.calls.mostRecent().args[0];
  modalConfig.submitButton.action();
  tick();

  expect(sharedMessageSpy.showError).toHaveBeenCalled();
}));
```

### 12. Grid Configuration (para Grids)

```typescript
it('should pass correct templates to grid config', fakeAsync(() => {
  const changes = { viajeId: new SimpleChange(null, TEST_VIAJE_ID, true) };
  component.ngOnChanges(changes);
  tick();

  const buildConfigCall = gridServiceSpy.buildGridConfig.calls.mostRecent();
  const templates = buildConfigCall.args[1];

  expect(templates.addButtonTemplate).toBe(component.addButtonTemplate);
  expect(templates.noRecordsTemplate).toBe(component.noRecordsTemplate);
  expect(templates.refreshGridTemplate).toBe(component.refreshGridTemplate);
  expect(templates.titleGridTemplate).toBe(component.titleGridTemplate);
}));

it('should initialize grid config with correct properties', () => {
  expect(component.gridConfig.idGrid).toBeDefined();
  expect(component.gridConfig.selectBy).toBe('id');
});
```

### 13. Diálogos/Modales

```typescript
it('should close dialog on cancel', () => {
  component.cancel();
  expect(dialogRefSpy.close).toHaveBeenCalledWith({ accepted: false });
});
```

---

## [RULES:ASYNC]

### Operaciones Asíncronas

```typescript
it('should handle async operation', fakeAsync(() => {
  serviceSpy.method.and.returnValue(of(data, asyncScheduler));

  fixture.detectChanges();
  component.asyncMethod();
  tick();

  expect(component.result).toBeDefined();
}));
```

---

## [PATTERNS:TEST_CONSTANTS]

### Uso de Constantes

```typescript
// Buena Práctica
const TEST_VIAJE_ID = 100;
const TEST_AGENTE_ID = 1;

it('should load data', () => {
  component.viajeId = TEST_VIAJE_ID;
  expect(component.selectedId).toBe(TEST_AGENTE_ID);
});
```

---

## Problemas Comunes

Las siguientes soluciones son orientativas y deben aplicarse respetando [RULES:CONTRACT_FIRST].

| Problema                     | Solución                                                 |
| ---------------------------- | -------------------------------------------------------- |
| `EventEmitter` import error  | Viene de `@angular/core`, NO de `rxjs`                   |
| Missing provider for service | Añadir a `providers` del TestBed y a `overrideComponent` |
| Cannot find control 'campo'  | Incluir TODOS los campos del HTML en el FormGroup mock   |
| State not updating           | Verificar estructura: `state.data.filter.filters`        |

---

### Checklist Final

- [ ] Todos los imports son correctos (EventEmitter de @angular/core)
- [ ] Mock del formulario incluye TODOS los campos del HTML
- [ ] Usé `overrideComponent` si el componente tiene providers
- [ ] Usé constructores NSwag para los mocks
- [ ] Incluí asyncScheduler en todos los observables mock
- [ ] Tests de form listeners (si aplica)
- [ ] Tests de lookup functions (si aplica)
- [ ] Tests de getters (si aplica)
- [ ] Tests de delete actions (si aplica para grids)
- [ ] Todos los tests pasan sin errores
