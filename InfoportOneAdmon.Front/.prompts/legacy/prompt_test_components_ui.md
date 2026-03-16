# PROMPT PARA GENERACIÓN DE TESTS DE COMPONENTES CON LÓGICA UI

## Contexto del Proyecto

Necesito crear tests unitarios para un componente Angular standalone con las siguientes características del proyecto:

### Configuración del Proyecto

- Framework: Angular 20+ con standalone components
- Testing: Jasmine + Karma
- Polyfills: zone.js, zone.js/testing, @angular/localize/init
- HTTP Client: provideHttpClient() / provideHttpClientTesting()
- Formularios: ReactiveFormsModule
- Traducción: @ngx-translate con TranslateFakeLoader
- Animaciones: provideAnimations()

---

## Configuración Necesaria en angular.json

```json
"test": {
  "builder": "@angular/build:karma",
  "options": {
    "polyfills": ["zone.js", "zone.js/testing", "@angular/localize/init"],
    "tsConfig": "tsconfig.spec.json",
    "inlineStyleLanguage": "scss",
    "assets": ["src/favicon.ico", "src/assets"],
    "styles": ["src/styles.scss"],
    "scripts": []
  }
}
```

---

## Estructura de Tests Requerida

### Imports Estándar

```typescript
import { ComponentFixture, TestBed, fakeAsync, tick } from '@angular/core/testing';
import { FormBuilder, FormGroup, ReactiveFormsModule } from '@angular/forms';
import { provideHttpClient } from '@angular/common/http';
import { provideHttpClientTesting } from '@angular/common/http/testing';
import { provideAnimations } from '@angular/platform-browser/animations';
import { of, throwError, asyncScheduler, EventEmitter } from 'rxjs';
import { TranslateModule, TranslateLoader } from '@ngx-translate/core';
import { TranslateFakeLoader } from '@ngx-translate/core';
import { ChangeDetectorRef, SimpleChange, EventEmitter } from '@angular/core';

// MODIFICAR: Importar el componente a testear y sus dependencias
// import { ComponentToTest } from './component-to-test.component';
// import { ServiceName } from './service-name.service';
// import { ModelClassName } from '@webServicesReferences/api/apiClients';
```

---

### ⚠️ CRÍTICO: Verificación de Imports Correctos

Antes de generar cualquier test, **VERIFICA que los imports sean correctos**:

#### ❌ ERRORES COMUNES DE IMPORTS

```typescript
// ❌ ERROR: EventEmitter NO está en rxjs
import { of, throwError, asyncScheduler, EventEmitter } from 'rxjs';

// ❌ ERROR: EventEmitter importado pero no usado
import { EventEmitter } from '@angular/core';
// ... código sin usar EventEmitter
```

#### ✅ IMPORTS CORRECTOS

```typescript
// ✅ CORRECTO: EventEmitter está en @angular/core
import { of, throwError, asyncScheduler } from 'rxjs';
import { EventEmitter } from '@angular/core'; // Solo si se usa @Output

// ✅ CORRECTO: Solo importar si se usa en el test
import { EventEmitter } from '@angular/core';
// ... y luego se usa: spyOn(component.outputEvent, 'emit')
```

#### Reglas de Imports

| Símbolo             | Origen Correcto         | Uso                            |
| ------------------- | ----------------------- | ------------------------------ |
| `EventEmitter`      | `@angular/core`         | Para @Output en componentes    |
| `of`, `throwError`  | `rxjs`                  | Crear observables mock         |
| `asyncScheduler`    | `rxjs`                  | Control de ejecución asíncrona |
| `fakeAsync`, `tick` | `@angular/core/testing` | Tests asíncronos               |
| `SimpleChange`      | `@angular/core`         | Para ngOnChanges tests         |

**IMPORTANTE**: Solo importa lo que realmente vas a usar. Remove imports no utilizados.

---

### ⚠️ IMPORTANTE: Creación Correcta de Mocks de Modelos NSwag

Los modelos generados por NSwag (en `apiClients.ts`) tienen métodos `init()` y `toJSON()`. **NUNCA uses objetos literales con `as Type`**, siempre usa el constructor:

#### ❌ INCORRECTO - Causa errores de tipo

```typescript
// ERROR: Type conversion mistake - missing init/toJSON methods
const mockData: ModelClassName = {
  id: 1,
  campo1: 'valor',
  campo2: 100
} as ModelClassName;
```

#### ✅ CORRECTO - Usar constructor del modelo

```typescript
// CORRECTO: Instanciar usando el constructor
const mockData = new ModelClassName({
  id: 1,
  campo1: 'valor',
  campo2: 100
});
```

#### Verificación de Tipos

**SIEMPRE verifica el tipo correcto de cada propiedad** en el archivo `apiClients.ts` antes de crear mocks:

```typescript
// Ejemplo: Verificar en apiClients.ts la interfaz IModelClassName
export interface IModelClassName {
  id?: number;
  campo1?: string;
  campo2?: number; // ⚠️ Es number, no string
  idExterno?: number; // ⚠️ Es number, no string
}

// Mock correcto con tipos verificados
const mockData = new ModelClassName({
  id: 1,
  campo1: 'valor',
  campo2: 100, // number ✅
  idExterno: 999 // number ✅, NO '999' como string
});
```

#### Patrón Recomendado para Mocks Complejos

```typescript
// 1. Definir constantes con tipos explícitos
const TEST_ID = 1;
const TEST_CANTIDAD = 5;
const TEST_IMPORTE: number = 150.5; // Especificar tipo si hay ambigüedad

// 2. Crear mock usando constructor
const mockRecargo = new ViajeTarificacionRecargoView({
  id: TEST_ID,
  viajeTarificacionId: 100,
  recargo: 'Recargo Combustible',
  importeTarifaRecargo: TEST_IMPORTE,
  cantidadRecargo: TEST_CANTIDAD,
  importeTotalRecargo: TEST_CANTIDAD * TEST_IMPORTE,
  idExtRecargo: 12345 // number, NO '12345' string
});

// 3. Usar el mock en spies
serviceNameSpy.loadRecargo.and.returnValue(of(mockRecargo, asyncScheduler));
```

---

### ⚠️ CRÍTICO: Servicios Inyectados en Providers del Componente

Cuando un componente inyecta servicios en su propio array de `providers`, **los servicios del TestBed NO se usan**. Debes usar `overrideComponent` para reemplazarlos:

#### ❌ ERROR - Servicio no se inyecta correctamente

```typescript
// En el componente:
@Component({
  selector: 'my-component',
  providers: [MyService] // ⚠️ Servicio inyectado aquí
})

// En el test - INCORRECTO:
await TestBed.configureTestingModule({
  imports: [MyComponent],
  providers: [
    { provide: MyService, useValue: myServiceSpy } // ❌ NO FUNCIONA
  ]
}).compileComponents();
```

#### ✅ CORRECTO - Usar overrideComponent

```typescript
// En el test - CORRECTO:
await TestBed.configureTestingModule({
  imports: [MyComponent],
  providers: [
    // Otros servicios globales
    { provide: SharedMessageService, useValue: sharedMessageSpy }
  ]
})
  .overrideComponent(MyComponent, {
    set: {
      providers: [
        { provide: MyService, useValue: myServiceSpy } // ✅ FUNCIONA
      ]
    }
  })
  .compileComponents();
```

#### Guía de Uso

**Cómo identificar si necesitas overrideComponent:**

1. Revisar el componente a testear
2. Buscar el decorador `@Component`
3. Si tiene `providers: [...]`, necesitas `overrideComponent`

**Patrón completo:**

```typescript
await TestBed.configureTestingModule({
  imports: [ComponentToTest],
  providers: [
    // Solo servicios NO inyectados en el componente
    provideHttpClient(),
    { provide: GlobalService, useValue: globalServiceSpy }
  ]
})
  .overrideComponent(ComponentToTest, {
    set: {
      providers: [
        // TODOS los servicios del array providers del componente
        { provide: ComponentService, useValue: componentServiceSpy }
      ]
    }
  })
  .compileComponents();
```

---

### Configuración Completa de TestBed

```typescript
describe('ComponentToTest', () => {
  let component: ComponentToTest;
  let fixture: ComponentFixture<ComponentToTest>;

  // MODIFICAR: Crear spies para TODOS los servicios que inyecta el componente
  let serviceNameSpy: jasmine.SpyObj<ServiceName>;
  let sharedMessageSpy: jasmine.SpyObj<SharedMessageService>;
  let accessServiceSpy: jasmine.SpyObj<AccessService>;
  let dialogRefSpy: jasmine.SpyObj<DialogRef>;
  let mockForm: FormGroup;
  let fb: FormBuilder;

  // ✅ BUENA PRÁCTICA: Definir constantes de test al inicio
  // Esto hace los tests más legibles y mantenibles
  const TEST_ENTITY_ID = 100;
  const TEST_ITEM_ID = 1;
  const TEST_ID_EXT = 12345;
  const TEST_DESCRIPCION = 'Test Description';
  const TEST_CANTIDAD = 5;
  const TEST_IMPORTE: number = 150.5;

  beforeEach(async () => {
    // 1. Crear spies de TODOS los servicios inyectados
    // MODIFICAR: Añadir TODOS los métodos del servicio que usa el componente
    serviceNameSpy = jasmine.createSpyObj('ServiceName', [
      'method1',
      'method2',
      'buildForm',
      'loadData',
      'saveData',
      'prepareSubmitData'
    ]);

    sharedMessageSpy = jasmine.createSpyObj('SharedMessageService', ['showMessage', 'showError']);
    accessServiceSpy = jasmine.createSpyObj('AccessService', ['maestroViajesModificacion']);
    dialogRefSpy = jasmine.createSpyObj('DialogRef', ['close']);

    // 2. Configurar valores de retorno por defecto para métodos
    serviceNameSpy.loadData.and.returnValue(of({ id: 0 } as any));
    serviceNameSpy.buildForm.and.returnValue(mockForm);
    accessServiceSpy.maestroViajesModificacion.and.returnValue(true);

    // 3. Si el componente usa formularios, crear mockForm completo
    // MODIFICAR: Replicar EXACTAMENTE la estructura del formulario del componente
    fb = new FormBuilder();
    mockForm = fb.group({
      id: [0],
      campo1: ['', Validators.required],
      campo2: [0],
      grupoAnidado: fb.group({
        subcampo1: [''],
        subcampo2: [false]
      }),
      arrayItems: fb.array([
        fb.group({
          itemField: ['']
        })
      ])
    });

    // 4. Configurar TestBed
    await TestBed.configureTestingModule({
      imports: [
        ComponentToTest, // MODIFICAR: Nombre del componente
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
        // MODIFICAR: Proveer TODOS los servicios que usa el componente
        { provide: ServiceName, useValue: serviceNameSpy },
        { provide: SharedMessageService, useValue: sharedMessageSpy },
        { provide: AccessService, useValue: accessServiceSpy },
        { provide: DialogRef, useValue: dialogRefSpy },
        ChangeDetectorRef
      ]
    })
      .overrideComponent(ComponentToTest, {
        set: {
          providers: [
            // MODIFICAR: Servicios inyectados directamente en el componente
            { provide: InjectedService, useValue: injectedServiceSpy }
          ]
        }
      })
      .compileComponents();

    fixture = TestBed.createComponent(ComponentToTest);
    component = fixture.componentInstance;

    // 5. Inicializar @Input properties ANTES de detectChanges
    // MODIFICAR: Setear TODOS los @Input del componente
    component.inputProp1 = value1;
    component.inputProp2 = value2;
  });

  // Tests aquí...
});
```

---

## Tests a Incluir (Cobertura de Riesgo Alto/Medio)

### 1. Ciclo de Vida del Componente

```typescript
it('should create', () => {
  expect(component).toBeTruthy();
});

it('should load catalog data on construction', () => {
  // MODIFICAR: Verificar que se llaman los métodos de carga de datos
  expect(serviceNameSpy.loadCatalogs).toHaveBeenCalled();
});

it('should initialize form on ngOnInit', fakeAsync(() => {
  fixture.detectChanges();
  tick();

  // MODIFICAR: Verificar que el formulario existe y tiene los campos esperados
  expect(component.form).toBeDefined();
  expect(component.form.get('campo1')).toBeTruthy();
}));

it('should have empty ngOnDestroy without errors', () => {
  fixture.detectChanges();

  expect(() => component.ngOnDestroy()).not.toThrow();
});

// Si hay subscripciones que limpiar
it('should unsubscribe on destroy', () => {
  const sub = { unsubscribe: jasmine.createSpy('unsubscribe') };
  // MODIFICAR: Nombre de la subscripción a testear
  (component as any).subscriptionName = sub;

  component.ngOnDestroy();

  expect(sub.unsubscribe).toHaveBeenCalled();
});
```

### 2. Formularios

```typescript
it('should initialize form with correct values', fakeAsync(() => {
  // MODIFICAR: Datos de entidad mock
  const entity = { campo1: 'valor1', campo2: 10 };
  serviceNameSpy.loadEntity.and.returnValue(of(entity, asyncScheduler));

  fixture.detectChanges();
  tick();

  expect(component.form.get('campo1')?.value).toBe('valor1');
  expect(component.form.get('campo2')?.value).toBe(10);
}));

it('should disable form when no permission', fakeAsync(() => {
  accessServiceSpy.hasPermission.and.returnValue(false);

  fixture.detectChanges();
  tick();

  expect(component.form.disabled).toBeTrue();
}));

it('should mark form as dirty after user input', fakeAsync(() => {
  fixture.detectChanges();
  tick();

  expect(component.form.pristine).toBeTrue();

  // MODIFICAR: Nombre del campo a testear
  const control = component.form.get('campo1');
  control?.setValue('nuevo valor');
  control?.markAsDirty();

  expect(control?.dirty).toBeTrue();
  expect(component.form.dirty).toBeTrue();
}));

it('should submit successfully with loading states', fakeAsync(() => {
  // MODIFICAR: Datos de submit esperados
  const submitData = { id: 0, campo1: 'test' };
  serviceNameSpy.prepareSubmitData.and.returnValue(submitData);
  serviceNameSpy.save.and.returnValue(of({ id: 100 } as any, asyncScheduler));

  // MODIFICAR: Si el componente emite eventos, configurar spy
  spyOn(component.refreshGrid, 'emit');

  fixture.detectChanges();
  tick();

  expect(component.loading).toBeFalse();

  component.onSubmit();

  expect(component.loading).toBeTrue();
  tick();

  expect(component.loading).toBeFalse();
  expect(serviceNameSpy.save).toHaveBeenCalledWith(submitData);
  expect(sharedMessageSpy.showMessage).toHaveBeenCalled();
  expect(component.refreshGrid.emit).toHaveBeenCalledWith(jasmine.any(Object));
}));

it('should handle submit error', fakeAsync(() => {
  serviceNameSpy.save.and.returnValue(throwError(() => new Error('error'), asyncScheduler));

  fixture.detectChanges();
  tick();

  component.onSubmit();
  tick();

  expect(component.loading).toBeFalse();
  expect(sharedMessageSpy.showError).toHaveBeenCalled();
}));

it('should prepare submit data correctly before saving', fakeAsync(() => {
  // MODIFICAR: Datos esperados del submit
  const expectedSubmitData = {
    id: 0,
    campo1: 'valor',
    campo2: 100
  };

  serviceNameSpy.prepareSubmitData.and.returnValue(expectedSubmitData);
  serviceNameSpy.save.and.returnValue(of({} as any, asyncScheduler));

  fixture.detectChanges();
  tick();

  component.onSubmit();
  tick();

  expect(serviceNameSpy.prepareSubmitData).toHaveBeenCalledWith(mockForm);
  expect(serviceNameSpy.save).toHaveBeenCalledWith(expectedSubmitData);
}));

it('should emit event with saved data after submit', fakeAsync(() => {
  // MODIFICAR: Datos guardados esperados
  const savedData = { id: 1, campo1: 'test' };

  serviceNameSpy.save.and.returnValue(of(savedData, asyncScheduler));
  spyOn(component.refreshGrid, 'emit');

  fixture.detectChanges();
  tick();

  component.onSubmit();
  tick();

  expect(component.refreshGrid.emit).toHaveBeenCalledWith(savedData);
}));
```

### 4. Grids (ClGridComponent)

```typescript
// ⚠️ CRÍTICO: ClGridConfig requiere propiedades mínimas obligatorias
// Propiedades requeridas: idGrid, mode, columns, selectBy, state
// ⚠️ CRÍTICO: NUNCA mockear TranslateService - solo TranslateModule.forRoot() en imports
// TranslateFakeLoader maneja automáticamente traducciones (devuelve las claves sin traducir)

beforeEach(async () => {
  // Configurar spy del servicio grid
  gridServiceSpy.buildGridConfig.and.returnValue({
    idGrid: 'myGridId',
    mode: 'server-side', // o 'client-side'
    columns: [],
    selectBy: 'id',
    filterable: false, // ⚠️ CRÍTICO: false para evitar error de Kendo FilterComponent
    state: {
      skip: 0,
      take: 10,
      sort: [],
      filter: {
        logic: 'and',
        filters: [
          { field: 'entityId', operator: 'eq', value: 1 },
          { field: 'auditDeletionDate', operator: 'isnull', value: null }
        ]
      }
    },
    pageable: { pageSize: 10, pageSizes: [10, 20, 50] },
    sortable: { allowUnsort: true, mode: 'multiple' },
    navigable: true,
    toolbarTemplates: {},
    noRecordsTemplate: null,
    footerTemplate: null
  } as any);

  await TestBed.configureTestingModule({
    imports: [
      MyGridComponent,
      TranslateModule.forRoot({
        loader: { provide: TranslateLoader, useClass: TranslateFakeLoader }
      })
    ],
    providers: [
      provideHttpClient(),
      provideHttpClientTesting(),
      provideAnimations()
      // ❌ NUNCA incluir TranslateService aquí - TranslateFakeLoader lo maneja
    ]
  })
    .overrideComponent(MyGridComponent, {
      set: {
        providers: [{ provide: MyGridService, useValue: gridServiceSpy }]
      }
    })
    .compileComponents();

  fixture = TestBed.createComponent(MyGridComponent);
  component = fixture.componentInstance;

  // ✅ CRÍTICO: Inicializar gridConfig ANTES de detectChanges
  component.gridConfigRemote = gridServiceSpy.buildGridConfig(1, {} as any);
});

it('should initialize grid config correctly', () => {
  expect(component.gridConfigRemote).toBeDefined();
  expect(component.gridConfigRemote.mode).toBe('server-side');
  expect(component.gridConfigRemote.selectBy).toBe('id');
});

it('should load grid data on init', fakeAsync(() => {
  const mockData = { data: [{ id: 1 }], total: 1 };
  gridServiceSpy.loadData.and.returnValue(of(mockData));

  fixture.detectChanges();
  tick();

  expect(component.gridData).toEqual(mockData);
}));

it('should initialize grid state from config', () => {
  fixture.detectChanges();

  // ⚠️ IMPORTANTE: ClGrid envuelve el state en { data: state } después de callApi()
  // Después de ngOnInit(), el state tiene esta estructura
  expect(component.state).toEqual(
    jasmine.objectContaining({
      data: jasmine.objectContaining({
        skip: 0,
        take: 10,
        sort: [],
        filter: jasmine.any(Object)
      })
    })
  );
});

it('should update state correctly on grid events', fakeAsync(() => {
  const newState = { skip: 10, take: 5, sort: [], filter: {} };

  fixture.detectChanges();
  tick();

  component.callApi({ data: newState });
  tick();

  // ✅ Verificar que state se envuelve en { data: newState }
  expect(component.state).toEqual(jasmine.objectContaining({ data: newState }));
}));

it('should verify translated messages use keys not translated text', () => {
  // TranslateFakeLoader devuelve las claves sin traducir
  component.deleteWithoutSelection();

  // ✅ Esperar la clave, NO el texto traducido
  expect(sharedMessageSpy.showMessage).toHaveBeenCalledWith('NO_ELEMENT_SELECTED', 'warning');
});
```

### 5. Cambios en @Input (ngOnChanges)

```typescript
it('should handle input changes', () => {
  // MODIFICAR: Valores old/new y nombre del @Input
  const oldValue = 1;
  const newValue = 2;

  component.inputProp = oldValue;
  fixture.detectChanges();

  component.inputProp = newValue;
  component.ngOnChanges({
    inputProp: new SimpleChange(oldValue, newValue, false)
  });

  // MODIFICAR: Verificar comportamiento esperado
  expect(component.someProperty).toBe(expectedValue);
  expect(serviceNameSpy.updateMethod).toHaveBeenCalled();
});

it('should not reload when only non-critical input changes', () => {
  // MODIFICAR: Ajustar según lógica del componente
  component.viajeId = 5;
  fixture.detectChanges();

  const reloadSpy = spyOn(component as any, 'loadData');

  component.ngOnChanges({
    otherProp: new SimpleChange('old', 'new', false)
  });

  expect(reloadSpy).not.toHaveBeenCalled();
});

it('should initialize grid config on first change', () => {
  // MODIFICAR: Para componentes con grids
  const callApiSpy = spyOn(component, 'callApi');

  component.ngOnChanges({
    viajeId: new SimpleChange(0, 100, true) // isFirstChange = true
  });

  expect(gridServiceSpy.buildGridConfig).toHaveBeenCalled();
  expect(component.gridConfig).toBeDefined();
  expect(callApiSpy).toHaveBeenCalled();
});

it('should update filter when critical input changes', () => {
  // MODIFICAR: Ajustar según lógica del componente
  const oldId = 50;
  const newId = 100;
  const mockState = { data: { filter: { filters: [] } } };
  component.state = mockState as any;

  component.entityId = newId;
  component.ngOnChanges({
    entityId: new SimpleChange(oldId, newId, false)
  });

  expect(gridServiceSpy.updateFilter).toHaveBeenCalledWith(mockState, newId);
});

it('should handle combined input changes correctly', () => {
  // MODIFICAR: Cuando múltiples inputs cambian simultáneamente
  spyOn(component as any, 'loadData');

  component.ngOnChanges({
    viajeId: new SimpleChange(null, 100, true),
    estado: new SimpleChange(null, 'Pendiente', true)
  });

  expect((component as any).loadData).toHaveBeenCalled();
  expect(component.deshabilitarEdicion).toBeDefined();
});

it('should handle change to zero value', () => {
  // MODIFICAR: Casos especiales con valor 0
  component.entityId = 5;
  fixture.detectChanges();

  component.state = {
    data: {
      filter: {
        logic: 'and',
        filters: [{ field: 'entityId', operator: 'eq', value: 5 }]
      }
    }
  } as any;

  component.entityId = 0;
  component.ngOnChanges({
    entityId: new SimpleChange(5, 0, false)
  });

  expect(component.isNew).toBeTrue();
  expect(gridServiceSpy.updateFilter).toHaveBeenCalledWith(component.state, 0);
});
```

### 6. Eventos de @Output

```typescript
it('should emit event after successful operation', fakeAsync(() => {
  // MODIFICAR: Valor esperado a emitir
  const emittedValue = { id: 1 };
  serviceNameSpy.save.and.returnValue(of(emittedValue, asyncScheduler));

  // MODIFICAR: Nombre del @Output
  spyOn(component.outputEvent, 'emit');

  fixture.detectChanges();
  component.onSubmit();
  tick();

  expect(component.outputEvent.emit).toHaveBeenCalledWith(emittedValue);
}));
```

### 7. Permisos y Estados

```typescript
it('should disable edition when estado is Valorado', () => {
  // MODIFICAR: Valores de enum según el proyecto
  component.estadoCotizacion = EstadoTarificacionEs['Valorado'];

  component.ngOnChanges({
    estadoCotizacion: new SimpleChange(null, EstadoTarificacionEs['Valorado'], false)
  });

  expect(component.deshabilitarEdicion).toBeTrue();
});

it('should enable edition when estado is Pendiente and has permission', () => {
  accessServiceSpy.hasPermission.and.returnValue(true);
  component.estadoCotizacion = EstadoTarificacionEs['Pendiente'];

  fixture.detectChanges();

  expect(component.deshabilitarEdicion).toBeFalse();
});

it('should disable actions when edition disabled', () => {
  component.deshabilitarEdicion = true;
  spyOn(component as any, 'insertOrUpdateAction');

  component.addAction();

  expect((component as any).insertOrUpdateAction).not.toHaveBeenCalled();
});

it('should verify permission getter', () => {
  // MODIFICAR: Nombre del getter de permisos
  accessServiceSpy.maestroViajesModificacion.and.returnValue(true);

  expect(component.viajesModificacion).toBeTrue();
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
  component.entityId = 100;

  expect(component.isNew).toBeFalse();
});
```

### 8. Diálogos/Modales

```typescript
it('should close dialog on cancel', () => {
  dialogRefSpy.close = jasmine.createSpy('close');

  component.cancel();

  expect(dialogRefSpy.close).toHaveBeenCalledWith({ accepted: false });
});
it('should open modal and build config correctly', fakeAsync(() => {
  // MODIFICAR: Configuración del modal según el servicio
  gridServiceSpy.buildModal.and.returnValue({
    config: { componentInputs: new Map() },
    inputs: new Map([['id', 0]])
  } as any);

  modalServiceSpy.openModal.and.returnValue(
    Promise.resolve({
      dialogRef: { content: { instance: { submitButton: {} } } } as any,
      component: {
        formReady: of(null),
        form: { invalid: false, valueChanges: of({}) },
        onSubmit: jasmine.createSpy('onSubmit')
      } as any
    })
  );

  fixture.detectChanges();

  component.addAction();
  tick();

  expect(modalServiceSpy.openModal).toHaveBeenCalled();
}));
```

### 9. Búsquedas y Filtros

```typescript
it('should search and update results', fakeAsync(() => {
  // MODIFICAR: Resultados esperados de la búsqueda
  const searchResults = [{ id: 1, name: 'Result 1' }];
  serviceNameSpy.search.and.returnValue(of(searchResults, asyncScheduler));

  component.onSearch('query');
  tick();

  expect(component.searchResults).toEqual(searchResults);
}));

it('should return empty array when search returns no results', fakeAsync(() => {
  // MODIFICAR: Método de búsqueda del servicio
  serviceNameSpy.search.and.returnValue(of([]));

  fixture.detectChanges();
  tick();

  component.onSearch('NonExistent').subscribe((results) => {
    expect(results).toEqual([]);
  });
}));

it('should call search service with correct parameters', fakeAsync(() => {
  const searchInput = 'test query';
  const expectedResults = [{ id: 1, descripcion: 'Result' }];

  serviceNameSpy.search.and.returnValue(of(expectedResults, asyncScheduler));

  fixture.detectChanges();
  tick();

  component.onSearch(searchInput).subscribe((results) => {
    expect(results).toEqual(expectedResults);
  });

  expect(serviceNameSpy.search).toHaveBeenCalledWith(searchInput);
}));
```

---

## 10. Tests CRUD de Grids

```typescript
// ==================== Tests de Selección ====================

it('should update selection on selectionChange', () => {
  // MODIFICAR: Método de selección del componente
  component.selectionChange([5]);
  expect(component.selectedItem).toBe(5);

  component.selectionChange([]);
  expect(component.selectedItem).toBeNull();
});

it('should handle multiple selection', () => {
  component.selectionChange([1, 2, 3]);

  expect(component.selectedItems).toEqual([1, 2, 3]);
  expect(component.selectedItems.length).toBe(3);
});

// ==================== Tests de Eliminación ====================

it('should show warning when no element selected for delete', () => {
  component.selectedItem = null;

  component.openRemoveConfirmation();

  expect(sharedMessageSpy.showMessage).toHaveBeenCalledWith('NO_ELEMENT_SELECTED', 'warning');
  expect(modalServiceSpy.openModal).not.toHaveBeenCalled();
});

it('should open delete confirmation modal when element selected', () => {
  // MODIFICAR: Id del elemento seleccionado
  component.selectedItem = 5;

  component.openRemoveConfirmation();

  expect(gridServiceSpy.buildDeleteConfirmationModal).toHaveBeenCalled();
  expect(modalServiceSpy.openModal).toHaveBeenCalled();
});

it('should delete item and refresh grid', fakeAsync(() => {
  // MODIFICAR: Id del item y método de eliminación
  component.selectedItem = 10;
  component.state = { data: { skip: 0, take: 10 } };

  gridServiceSpy.deleteItem.and.returnValue(of(null, asyncScheduler));
  gridServiceSpy.loadItems.and.returnValue(of({ data: [], total: 0 }));

  fixture.detectChanges();

  (component as any).deleteAction();
  tick();

  expect(gridServiceSpy.deleteItem).toHaveBeenCalledWith(10);
  expect(sharedMessageSpy.showMessage).toHaveBeenCalledWith('DELETE_SUCCESS');
  expect(component.selectedItem).toBeNull();
}));

it('should handle delete error', fakeAsync(() => {
  component.selectedItem = 10;
  const error = new Error('Delete error');

  gridServiceSpy.deleteItem.and.returnValue(throwError(() => error, asyncScheduler));

  (component as any).deleteAction();
  tick();

  expect(sharedMessageSpy.showError).toHaveBeenCalledWith(error);
  expect(component.selectedItem).toBe(10); // No limpiar selección en error
}));

// ==================== Tests de Edición/Creación ====================

it('should not perform action when edition disabled', () => {
  component.deshabilitarEdicion = true;
  spyOn(component as any, 'insertOrUpdateAction');

  component.addAction();

  expect((component as any).insertOrUpdateAction).not.toHaveBeenCalled();
});

it('should call service method when calling grid action', () => {
  // MODIFICAR: Método de acción del componente
  spyOn(component as any, 'insertOrUpdateAction');
  component.deshabilitarEdicion = false;

  component.addAction();

  expect((component as any).insertOrUpdateAction).toHaveBeenCalled();
});
```

---

## Patrones Importantes

### Uso de Constantes en Tests

```typescript
// ✅ BUENA PRÁCTICA: Definir constantes al inicio del describe
const TEST_VIAJE_ID = 100;
const TEST_RECARGO_ID = 1;
const TEST_DESCRIPCION = 'Recargo Combustible';

// ❌ EVITAR: Números mágicos directamente en los tests
it('should load data', () => {
  component.viajeId = 100; // ¿Qué significa 100?
  expect(component.selectedId).toBe(1); // ¿Por qué 1?
});

// ✅ CORRECTO: Usar constantes con nombres descriptivos
it('should load data', () => {
  component.viajeId = TEST_VIAJE_ID;
  expect(component.selectedId).toBe(TEST_RECARGO_ID);
});
```

### Organización de Tests con Comentarios de Sección

```typescript
describe('ComponentToTest', () => {
  // ... setup ...

  // ==================== Tests de Ciclo de Vida ====================

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  // ==================== Tests de @Input ====================

  it('should initialize inputs correctly', () => {
    // ...
  });

  // ==================== Tests de ngOnChanges ====================

  it('should handle input changes', () => {
    // ...
  });

  // ==================== Tests de Estados ====================

  it('should disable edition when estado is Valorado', () => {
    // ...
  });

  // ==================== Tests de Carga de Datos ====================

  it('should load grid data successfully', fakeAsync(() => {
    // ...
  }));

  // ==================== Tests CRUD ====================

  it('should delete item and refresh grid', fakeAsync(() => {
    // ...
  }));

  // ==================== Tests de Getters ====================

  it('should return true for isNew when id is 0', () => {
    // ...
  });
});
```

### fakeAsync para Operaciones Asíncronas

```typescript
it('should test async operation', fakeAsync(() => {
  serviceSpy.method.and.returnValue(of(data, asyncScheduler));

  fixture.detectChanges();
  tick(); // Esperar inicialización

  component.asyncMethod();

  expect(component.loading).toBeTrue();
  tick(); // Procesar el observable

  expect(component.loading).toBeFalse();
  expect(result).toBeDefined();
}));
```

### EventEmitter para Modales

```typescript
// Opción 1: EventEmitter real
const mockEmitter = new EventEmitter<any>();

// Opción 2: Capturar callback
const mockEmitter = {
  subscribe: jasmine.createSpy('subscribe').and.callFake((callback) => {
    // capturar callback para ejecutarlo después
  })
};
```

### Done Callback para Async sin fakeAsync

```typescript
it('should handle async operation', (done) => {
  serviceSpy.method.and.returnValue(of(data));

  component.asyncMethod();

  setTimeout(() => {
    expect(component.result).toBeDefined();
    done();
  }, 10);
});
```

### Tests sin fixture.detectChanges()

```typescript
// ✅ PATRÓN: Tests de lógica pura sin inicialización del componente
// Útil cuando no necesitas el template o quieres evitar efectos secundarios de ngOnInit

it('should load grid data successfully without fixture', fakeAsync(() => {
  // MODIFICAR: Datos mock del grid
  const mockData: GridDataResult = {
    data: [{ id: 1, descripcion: 'Item 1' }],
    total: 1
  };

  gridServiceSpy.loadItems.and.returnValue(of(mockData, asyncScheduler));
  spyOn(component.refreshGrid, 'emit');

  const testState = { skip: 0, take: 3 };
  component.callApi({ data: testState });

  expect(component.refreshGrid.emit).toHaveBeenCalledWith(true);
  tick();

  expect(gridServiceSpy.loadItems).toHaveBeenCalledWith({ data: testState });
  expect(component.dataGrid).toEqual(mockData);
  expect(component.refreshGrid.emit).toHaveBeenCalledWith(false);
}));

// ⚠️ IMPORTANTE: No llamar fixture.detectChanges() si:
// 1. Solo testeas métodos públicos del componente
// 2. El componente tiene dependencias complejas en ngOnInit
// 3. Quieres evitar la inicialización de ClGrid u otros componentes complejos
```

### Spy en Métodos Privados del Componente

```typescript
it('should call private method when condition met', () => {
  // MODIFICAR: Nombre del método privado a espiar
  spyOn(component as any, 'loadData');

  component.ngOnChanges({
    entityId: new SimpleChange(0, 100, true)
  });

  expect((component as any).loadData).toHaveBeenCalled();
});

it('should not call private method when condition not met', () => {
  component.entityId = 5;
  fixture.detectChanges();

  const loadDataSpy = spyOn(component as any, 'loadData');

  component.ngOnChanges({
    otherProp: new SimpleChange('old', 'new', false)
  });

  expect(loadDataSpy).not.toHaveBeenCalled();
});
```

---

## Problemas Comunes y Soluciones

| **Problema**                                  | **Solución**                                                                                                                  |
| --------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| **Error de polyfills**                        | Verificar angular.json: `"polyfills": ["zone.js", "zone.js/testing", "@angular/localize/init"]`                               |
| **HTTP error**                                | Usar `provideHttpClient()` y `provideHttpClientTesting()`                                                                     |
| **Form undefined**                            | Crear mockForm completo en beforeEach ANTES de TestBed                                                                        |
| **State undefined en grids**                  | ClGrid envuelve state en `{ data: state }` después de `callApi()` - usar `objectContaining`                                   |
| **Loading no cambia**                         | Usar `asyncScheduler` en el observable mock: `of(data, asyncScheduler)`                                                       |
| **Subscribe no se llama**                     | Capturar callback con `spy.and.callFake((callback) => {...})`                                                                 |
| **Inputs no inicializados**                   | Setear @Inputs ANTES de `fixture.detectChanges()`                                                                             |
| **Form.dirty siempre false**                  | Llamar `control.markAsDirty()` y luego verificar `control.dirty`                                                              |
| **Error tipo mock NSwag**                     | Usar `new ModelClassName({...})` en lugar de `{...} as ModelClassName`                                                        |
| **Error tipo de propiedad**                   | Verificar tipos en `apiClients.ts` - ej: `idExterno` puede ser `number` no `string`                                           |
| **EventEmitter import error**                 | `EventEmitter` está en `@angular/core`, NO en `rxjs`                                                                          |
| **Import no usado**                           | Eliminar imports no utilizados - verificar warnings de TypeScript                                                             |
| **Spy no llamado**                            | Si el componente tiene `providers: [Service]`, usar `overrideComponent` en TestBed                                            |
| **Servicio no mockeado**                      | Verificar que el servicio esté en `overrideComponent` si está en providers del componente                                     |
| **ClGridConfig incompleto**                   | ClGridConfig REQUIERE: `idGrid`, `mode`, `columns`, `selectBy`, `state` (propiedades mínimas)                                 |
| **TranslatePipe/Service error**               | **NUNCA** mockear `TranslateService` - solo `TranslateModule.forRoot()` con `TranslateFakeLoader`                             |
| **ClGrid undefined mode**                     | Inicializar `component.gridConfig...` ANTES de `fixture.detectChanges()` en `beforeEach`                                      |
| **translate.get is not a function**           | **NO** proveer `TranslateService` en providers - `TranslateFakeLoader` maneja todo automáticamente                            |
| **Kendo FilterComponent error**               | Configurar `filterable: false` en ClGridConfig o definir `filterable: { filters: [...] }`                                     |
| **Grid state structure mismatch**             | Usar `jasmine.objectContaining()` para verificar propiedades esperadas sin estructura exacta                                  |
| **TranslateFakeLoader no traduce**            | `TranslateFakeLoader` devuelve las claves sin traducir - esperar 'KEY' no 'Translated text'                                   |
| **Tests inconsistentes**                      | Usar constantes de test (`TEST_ID`, `TEST_DESCRIPCION`) en lugar de números/strings mágicos                                   |
| **Dificultad para leer tests**                | Organizar tests con comentarios de sección: `// ==================== Tests de CRUD ====================`                      |
| **Necesidad de testear lógica sin template**  | No llamar `fixture.detectChanges()` para tests de métodos públicos sin necesidad de inicialización del componente             |
| **Error al testear método privado**           | Usar `spyOn(component as any, 'privateMethod')` y llamar como `(component as any).privateMethod()`                            |
| **No se emite evento esperado**               | Verificar con `spyOn(component.outputEvent, 'emit')` ANTES de ejecutar la acción                                              |
| **Test falla intermitentemente**              | Asegurar uso correcto de `fakeAsync`/`tick()` y `asyncScheduler` para controlar ejecución asíncrona                           |
| **Múltiples expects del mismo emit**          | Usar `toHaveBeenCalledWith` específico, o `toHaveBeenCalledTimes(n)` para verificar cantidad de llamadas                      |
| **Error en delete sin elemento seleccionado** | Verificar llamadas a `showMessage` con mensaje de advertencia ANTES de verificar que no se llama al servicio de delete        |
| **Grid no se actualiza después de CRUD**      | Verificar que después de delete/create/update se llame a `callApi(component.state)` o se emita `refreshGrid.emit(true/false)` |

---
