# Guía de Generación de Tests Unitarios para Componentes Angular con Lógica de Interfaz

## 1. Contexto del Proyecto

**[RULES:CONTEXT]**

Esta guía establece los estándares para la creación de tests unitarios de componentes Angular standalone. Los tests generados deben cumplir con las siguientes especificaciones técnicas del proyecto:

[RULES:CONTRACT_FIRST]

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

### 1.1. Stack Tecnológico

- Framework: Angular 20+ con standalone components
- Testing: Jasmine + Karma
- Polyfills: zone.js, zone.js/testing, @angular/localize/init
- HTTP Client: provideHttpClient() / provideHttpClientTesting()
- Formularios: ReactiveFormsModule
- Traducción: @ngx-translate con TranslateFakeLoader
- Animaciones: provideAnimations()

---

## 2. Configuración de Entorno

### 2.1. Configuración Requerida en angular.json

**[RULES:ANGULAR_JSON]**

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

**[RULES:ZONELESS_SUPPORT]**

- **Detección de Cambios:** En entornos Angular 20+ (especialmente si son Zoneless), es obligatorio llamar a `fixture.detectChanges()` después de cada actualización de estado o Signal.
- **Estabilización:** En lugar de depender exclusivamente de `tick()`, se recomienda usar `await fixture.whenStable()` para asegurar que todas las microtareas asíncronas se hayan completado antes de las aserciones.

---

## 3. Estructura de Tests

**[RULES:IMPORTS]**

### 3.1. Imports Estándar

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

// Adaptar según el componente: Importar el componente a testear y sus dependencias
// import { ComponentToTest } from './component-to-test.component';
// import { ServiceName } from './service-name.service';
// import { ModelClassName } from '@webServicesReferences/api/apiClients';
```

### 3.2. Requisito Obligatorio: Verificación de Imports Correctos

**Reglas obligatorias:**

1. `EventEmitter` debe utilizarse exclusivamente desde `@angular/core`, no está permitido importarlo desde `rxjs`
2. No está permitido dejar imports sin usar - deben eliminarse todos los imports no utilizados
3. `of`, `throwError`, `asyncScheduler` provienen de `rxjs`
4. `fakeAsync`, `tick` provienen de `@angular/core/testing`
5. `SimpleChange` proviene de `@angular/core`
6. Solo debe importarse lo que se va a utilizar en el test

#### 3.2.1. Antipatrones de Imports

```typescript
// Error: EventEmitter NO está en rxjs
import { of, throwError, asyncScheduler, EventEmitter } from 'rxjs';

// Error: EventEmitter importado pero no usado
import { EventEmitter } from '@angular/core';
// ... código sin usar EventEmitter
```

#### 3.2.2. Patrones Correctos de Imports

```typescript
// Patrón correcto: EventEmitter está en @angular/core
import { of, throwError, asyncScheduler } from 'rxjs';
import { EventEmitter } from '@angular/core'; // Solo si se usa @Output

// Patrón correcto: Solo importar si se usa en el test
import { EventEmitter } from '@angular/core';
// ... y luego se usa: spyOn(component.outputEvent, 'emit')
```

#### 3.2.3. Tabla de Referencia de Imports

| Símbolo             | Origen Correcto         | Uso                            |
| ------------------- | ----------------------- | ------------------------------ |
| `EventEmitter`      | `@angular/core`         | Para @Output en componentes    |
| `of`, `throwError`  | `rxjs`                  | Crear observables mock         |
| `asyncScheduler`    | `rxjs`                  | Control de ejecución asíncrona |
| `scheduled`         | `rxjs`                  | Crear observables asíncronos   |
| `switchMap`         | `rxjs`                  | Para errores asíncronos        |
| `fakeAsync`, `tick` | `@angular/core/testing` | Tests asíncronos               |
| `SimpleChange`      | `@angular/core`         | Para ngOnChanges tests         |

---

## 4. Compatibilidad con Angular 20+ y RxJS 7+

**[RULES:ANGULAR20_RXJS]**

### 4.1. Requisito Obligatorio: Funciones Deprecated

**Reglas obligatorias:**

1. No está permitido usar `of(value, asyncScheduler)` - está DEPRECATED
2. Debe utilizarse `scheduled([value], asyncScheduler)` para observables asíncronos
3. No está permitido usar `throwError(() => error, asyncScheduler)` - está DEPRECATED
4. Para errores síncronos: debe usarse `throwError(() => error)` sin scheduler
5. Para errores asíncronos en tests: debe usarse `scheduled([1], asyncScheduler).pipe(switchMap(() => throwError(() => error)))`
6. Deben importarse `scheduled` y `switchMap` desde `rxjs` cuando se necesiten observables asíncronos

#### 4.1.1. Antipatrones: Funciones Deprecated

```typescript
// Error: of con asyncScheduler está deprecated
import { of, asyncScheduler } from 'rxjs';
serviceSpy.method.and.returnValue(of(mockData, asyncScheduler));

// Error: throwError con asyncScheduler está deprecated
serviceSpy.method.and.returnValue(throwError(() => new Error('error'), asyncScheduler));
```

#### 4.1.2. Patrones Correctos para Angular 20+

```typescript
// Patrón correcto: Usar scheduled para observables asíncronos
import { of, asyncScheduler, scheduled } from 'rxjs';
serviceSpy.method.and.returnValue(scheduled([mockData], asyncScheduler));

// Patrón correcto: throwError sin scheduler para errores síncronos
serviceSpy.method.and.returnValue(throwError(() => new Error('error')));

// Patrón correcto: throwError asíncrono para tests de loading states
import { asyncScheduler, scheduled, switchMap, throwError } from 'rxjs';
serviceSpy.method.and.returnValue(scheduled([1], asyncScheduler).pipe(switchMap(() => throwError(() => new Error('error')))));
```

#### 4.1.3. Guía de Uso de Patrones

| Escenario                              | Patrón a Usar                                                                   |
| -------------------------------------- | ------------------------------------------------------------------------------- |
| Observable con datos exitosos (async)  | `scheduled([data], asyncScheduler)`                                             |
| Observable con datos exitosos (sync)   | `of(data)`                                                                      |
| Error síncrono en test                 | `throwError(() => error)`                                                       |
| Error asíncrono para verificar loading | `scheduled([1], asyncScheduler).pipe(switchMap(() => throwError(() => error)))` |
| Observable vacío                       | `of([])` o `scheduled([[]], asyncScheduler)`                                    |
| Error asíncrono ultra-estable          | `defer(() => throwError(() => error))`                                          |

#### 4.1.4. Ejemplo Completo de Test con Observables Asíncronos

```typescript
it('should handle async operation with loading state', fakeAsync(() => {
  const mockData = new ModelClassName({ id: 1, name: 'Test' });

  // Observable asíncrono exitoso
  serviceSpy.loadData.and.returnValue(scheduled([mockData], asyncScheduler));

  fixture.detectChanges();
  tick();

  component.loadData();
  expect(component.loading).toBeTrue();

  tick();
  expect(component.loading).toBeFalse();
  expect(component.data).toEqual(mockData);
}));

it('should handle async error with loading state', fakeAsync(() => {
  // Error asíncrono
  serviceSpy.loadData.and.returnValue(
    scheduled([1], asyncScheduler).pipe(switchMap(() => throwError(() => new Error('Error'))))
  );

  fixture.detectChanges();
  tick();

  component.loadData();
  expect(component.loading).toBeTrue();

  tick();
  expect(component.loading).toBeFalse();
  expect(component.error).toBeDefined();
}));

// Patrón alternativo para errores asíncronos cuando asyncScheduler sea inestable
import { defer, throwError } from 'rxjs';
serviceSpy.method.and.returnValue(defer(() => throwError(() => new Error('API Error'))));
```

#### 4.1.5. Imports Necesarios

```typescript
// Para observables asíncronos
import { of, throwError, asyncScheduler, scheduled, switchMap } from 'rxjs';
```

### 4.2. Requisito Obligatorio: Componentes con Signals

**[RULES:ANGULAR_SIGNALS]**

Angular 20+ prioriza el uso de Signals. Los tests deben adaptarse para disparar la detección de cambios y la reactividad correctamente:

1.  **Signal Inputs (`input()`):** No se pueden asignar mediante `component.prop = valor`. Es obligatorio usar `fixture.componentRef.setInput('nombreProp', valor)`.
2.  **Signal Models (`model()`):** Se testean verificando tanto el valor del signal como la emisión del evento `nombrePropChange`.
3.  **Signal Outputs (`output()`):** Se testean usando `spyOn(component.prop, 'emit')` (comportamiento idéntico a EventEmitter).
4.  **Computed Signals:** Requieren siempre `fixture.detectChanges()` para actualizar su valor tras un cambio en sus dependencias.

#### 4.2.1. Ejemplo de Test con Signals

```typescript
it('should update signal input and verify computed state', () => {
  // Patrón correcto para Signal Inputs
  fixture.componentRef.setInput('viajeId', 500);
  fixture.detectChanges();

  expect(component.viajeId()).toBe(500);
  // Verificar un computed que dependa de viajeId
  expect(component.isViajeEspecial()).toBeTrue();
});
```

---

## 5. Creación de Mocks

**[RULES:NSWAG_MOCKS]**

### 5.1. Requisito Obligatorio: Mocks de Modelos NSwag

**Reglas obligatorias:**

1. No está permitido usar objetos literales con `as Type` para modelos NSwag
2. Debe utilizarse el constructor del modelo: `new ModelClassName({...})`
3. Es obligatorio verificar los tipos en `apiClients.ts` antes de crear mocks
4. Propiedades numéricas son `number`, NO `string` (ej: `idExterno: 123` NO `idExterno: '123'`)
5. Deben usarse constantes de test con tipos explícitos para evitar ambigüedades

### 5.2. Nota Técnica: Implementación de Mocks NSwag

Los modelos generados por NSwag (en `apiClients.ts`) tienen métodos `init()` y `toJSON()`. No está permitido usar objetos literales con `as Type`; debe utilizarse el constructor en todos los casos.

#### 5.2.1. Antipatrón: Uso de Type Assertion

```typescript
// ERROR: Type conversion mistake - missing init/toJSON methods
const mockData: ModelClassName = {
  id: 1,
  campo1: 'valor',
  campo2: 100
} as ModelClassName;
```

#### 5.2.2. Patrón Correcto: Uso del Constructor

```typescript
// Patrón correcto: Instanciar usando el constructor
const mockData = new ModelClassName({
  id: 1,
  campo1: 'valor',
  campo2: 100
});
```

#### 5.2.3. Verificación de Tipos

Es obligatorio verificar el tipo correcto de cada propiedad en el archivo `apiClients.ts` antes de crear mocks:

```typescript
// Ejemplo: Verificar en apiClients.ts la interfaz IModelClassName
export interface IModelClassName {
  id?: number;
  campo1?: string;
  campo2?: number; // Nota: Es number, no string
  idExterno?: number; // Nota: Es number, no string
}

// Mock correcto con tipos verificados
const mockData = new ModelClassName({
  id: 1,
  campo1: 'valor',
  campo2: 100, // number - Correcto
  idExterno: 999 // number - Correcto, NO '999' como string
});
```

#### 5.2.4. Patrón Recomendado para Mocks Complejos

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
  idExtRecargo: 12345 // number, NO '12345' string
});

// 3. Usar el mock en spies
serviceNameSpy.loadRecargo.and.returnValue(of(mockRecargo, asyncScheduler));
```

---

## 6. Configuración de TestBed

**[RULES:TESTBED_CONFIG]**

### 6.1. Requisito Obligatorio: Servicios Inyectados en Providers del Componente

Cuando un componente inyecta servicios en su propio array de `providers`, los servicios del TestBed no se utilizan. Debe usarse `overrideComponent` para reemplazarlos.

**Reglas obligatorias para overrideComponent:**

1. Si el componente tiene `providers: [...]` en el decorador `@Component`, debe usarse `overrideComponent`
2. Los servicios en el array `providers` del componente NO son afectados por los providers del TestBed
3. TODOS los servicios del array `providers` del componente deben estar en `overrideComponent`
4. Servicios globales van en `TestBed.providers`, servicios del componente en `overrideComponent`

#### 6.1.1. Antipatrón: Configuración Incorrecta de Servicios

```typescript
// En el componente:
@Component({
  selector: 'my-component',
  providers: [MyService] // Nota: Servicio inyectado aquí
})

// En el test - INCORRECTO:
await TestBed.configureTestingModule({
  imports: [MyComponent],
  providers: [
    { provide: MyService, useValue: myServiceSpy } // Error: NO FUNCIONA
  ]
}).compileComponents();
```

#### 6.1.2. Patrón Correcto: Uso de overrideComponent

```typescript
// En el test - Patrón correcto:
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
        { provide: MyService, useValue: myServiceSpy } // Correcto: FUNCIONA
      ]
    }
  })
  .compileComponents();
```

#### 6.1.3. Guía de Implementación

**Identificación de necesidad de overrideComponent:**

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

### 6.2. Configuración Completa de TestBed

```typescript
describe('ComponentToTest', () => {
  let component: ComponentToTest;
  let fixture: ComponentFixture<ComponentToTest>;

  // Adaptar según el componente: Crear spies para todos los servicios inyectados
  let serviceNameSpy: jasmine.SpyObj<ServiceName>;
  let sharedMessageSpy: jasmine.SpyObj<SharedMessageService>;
  let accessServiceSpy: jasmine.SpyObj<AccessService>;
  let dialogRefSpy: jasmine.SpyObj<DialogRef>;
  let mockForm: FormGroup;
  let fb: FormBuilder;

  // Patrón recomendado: Definir constantes de test al inicio
  // Esto hace los tests más legibles y mantenibles
  const TEST_ENTITY_ID = 100;
  const TEST_ITEM_ID = 1;
  const TEST_ID_EXT = 12345;
  const TEST_DESCRIPCION = 'Test Description';
  const TEST_CANTIDAD = 5;
  const TEST_IMPORTE: number = 150.5;

  beforeEach(async () => {
    // 1. Crear spies de todos los servicios inyectados
    // Adaptar según el servicio: Añadir todos los métodos utilizados por el componente
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
    // Adaptar según el componente: Replicar exactamente la estructura del formulario
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
        ComponentToTest, // Adaptar según el componente: Nombre del componente a testear
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
        // Adaptar según el componente: Proveer todos los servicios utilizados
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
            // Adaptar según el componente: Servicios inyectados directamente en el componente
            { provide: InjectedService, useValue: injectedServiceSpy }
          ]
        }
      })
      .compileComponents();

    fixture = TestBed.createComponent(ComponentToTest);
    component = fixture.componentInstance;

    // 5. Inicializar @Input properties antes de detectChanges
    // Adaptar según el componente: Establecer todos los @Input requeridos
    component.inputProp1 = value1;
    component.inputProp2 = value2;
  });

  // Tests aquí...
});
```

---

## 7. Catálogo de Tests (Cobertura de Riesgo Alto/Medio)

### 7.1. Ciclo de Vida del Componente

**[RULES:LIFECYCLE_TESTS]**

Aplicar siempre [RULES:CONTRACT_FIRST].
No verificar secuencias internas de llamadas salvo que afecten al estado observable.

```typescript
it('should create', () => {
  expect(component).toBeTruthy();
});

it('should load catalog data on construction', () => {
  // Adaptar según el servicio: Verificar que se invocan los métodos de carga de datos
  expect(serviceNameSpy.loadCatalogs).toHaveBeenCalled();
});

it('should initialize form on ngOnInit', fakeAsync(() => {
  fixture.detectChanges();
  tick();

  // Adaptar según el componente: Verificar que el formulario existe y contiene los campos esperados
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
  // Adaptar según el componente: Nombre de la subscripción a testear
  (component as any).subscriptionName = sub;

  component.ngOnDestroy();

  expect(sub.unsubscribe).toHaveBeenCalled();
});
```

### 7.2. Formularios

**[RULES:FORM_TESTS]**

```typescript
it('should initialize form with correct values', fakeAsync(() => {
  // Adaptar según el modelo: Datos de entidad mock
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

  // Adaptar según el componente: Nombre del campo a testear
  const control = component.form.get('campo1');
  control?.setValue('nuevo valor');
  control?.markAsDirty();

  expect(control?.dirty).toBeTrue();
  expect(component.form.dirty).toBeTrue();
}));

it('should submit successfully with loading states', fakeAsync(() => {
  // Adaptar según el modelo: Datos de submit esperados
  const submitData = { id: 0, campo1: 'test' };
  serviceNameSpy.prepareSubmitData.and.returnValue(submitData);
  serviceNameSpy.save.and.returnValue(of({ id: 100 } as any, asyncScheduler));

  // Adaptar según el componente: Si el componente emite eventos, configurar spy
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
  // Adaptar según el modelo: Datos esperados del submit
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
  // Adaptar según el modelo: Datos guardados esperados
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

### 7.3. Grids (ClGridComponent)

**[RULES:GRID_TESTS]**

**Reglas obligatorias para ClGrid:**

1. ClGridConfig REQUIERE propiedades mínimas: `idGrid`, `mode`, `columns`, `selectBy`, `state`
2. No está permitido mockear `TranslateService` - solo debe usarse `TranslateModule.forRoot()` con `TranslateFakeLoader`
3. Debe configurarse `filterable: false` para evitar errores de Kendo FilterComponent
4. Debe inicializarse `component.gridConfig` ANTES de `fixture.detectChanges()` en `beforeEach`
5. ClGrid envuelve el state en `{ data: state }` después de `callApi()`
6. `TranslateFakeLoader` devuelve las claves sin traducir - debe esperarse 'KEY' no 'Translated text'

```typescript
// Requisito Obligatorio: ClGridConfig requiere propiedades mínimas obligatorias
// Propiedades requeridas: idGrid, mode, columns, selectBy, state
// Requisito Obligatorio: No está permitido mockear TranslateService - solo TranslateModule.forRoot() en imports
// TranslateFakeLoader maneja automáticamente traducciones (devuelve las claves sin traducir)

beforeEach(async () => {
  // Configurar spy del servicio grid
  gridServiceSpy.buildGridConfig.and.returnValue({
    idGrid: 'myGridId',
    mode: 'server-side', // o 'client-side'
    columns: [],
    selectBy: 'id',
    filterable: false, // Requisito Obligatorio: false para evitar error de Kendo FilterComponent
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
      // No está permitido incluir TranslateService aquí - TranslateFakeLoader lo maneja
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

  // Requisito Obligatorio: Inicializar gridConfig ANTES de detectChanges
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

  // Nota técnica: ClGrid envuelve el state en { data: state } después de callApi()
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

  // Verificación: state se envuelve en { data: newState }
  expect(component.state).toEqual(jasmine.objectContaining({ data: newState }));
}));

it('should verify translated messages use keys not translated text', () => {
  // TranslateFakeLoader devuelve las claves sin traducir
  component.deleteWithoutSelection();

  // Verificación: Esperar la clave, NO el texto traducido
  expect(sharedMessageSpy.showMessage).toHaveBeenCalledWith('NO_ELEMENT_SELECTED', 'warning');
});
```

### 7.4. Cambios en @Input (ngOnChanges)

**[RULES:INPUT_CHANGES_TESTS]**

```typescript
it('should handle input changes', () => {
  // Adaptar según el componente: Valores old/new y nombre del @Input
  const oldValue = 1;
  const newValue = 2;

  component.inputProp = oldValue;
  fixture.detectChanges();

  component.inputProp = newValue;
  component.ngOnChanges({
    inputProp: new SimpleChange(oldValue, newValue, false)
  });

  // Adaptar según el componente: Verificar comportamiento esperado
  expect(component.someProperty).toBe(expectedValue);
  expect(serviceNameSpy.updateMethod).toHaveBeenCalled();
});

it('should not reload when only non-critical input changes', () => {
  // Adaptar según la lógica: Ajustar según el comportamiento esperado
  component.viajeId = 5;
  fixture.detectChanges();

  const reloadSpy = spyOn(component as any, 'loadData');

  component.ngOnChanges({
    otherProp: new SimpleChange('old', 'new', false)
  });

  expect(reloadSpy).not.toHaveBeenCalled();
});

it('should initialize grid config on first change', () => {
  // Adaptar según el componente: Aplicable para componentes con grids
  const callApiSpy = spyOn(component, 'callApi');

  component.ngOnChanges({
    viajeId: new SimpleChange(0, 100, true) // isFirstChange = true
  });

  expect(gridServiceSpy.buildGridConfig).toHaveBeenCalled();
  expect(component.gridConfig).toBeDefined();
  expect(callApiSpy).toHaveBeenCalled();
});

it('should update filter when critical input changes', () => {
  // Adaptar según la lógica: Ajustar según el comportamiento esperado
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
  // Adaptar según el componente: Cuando múltiples inputs cambian simultáneamente
  spyOn(component as any, 'loadData');

  component.ngOnChanges({
    viajeId: new SimpleChange(null, 100, true),
    estado: new SimpleChange(null, 'Pendiente', true)
  });

  expect((component as any).loadData).toHaveBeenCalled();
  expect(component.deshabilitarEdicion).toBeDefined();
});

it('should handle change to zero value', () => {
  // Adaptar según el componente: Casos especiales con valor 0
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

### 7.5. Eventos de @Output

**[RULES:OUTPUT_TESTS]**

```typescript
it('should emit event after successful operation', fakeAsync(() => {
  // Adaptar según el modelo: Valor esperado a emitir
  const emittedValue = { id: 1 };
  serviceNameSpy.save.and.returnValue(of(emittedValue, asyncScheduler));

  // Adaptar según el componente: Nombre del @Output
  spyOn(component.outputEvent, 'emit');

  fixture.detectChanges();
  component.onSubmit();
  tick();

  expect(component.outputEvent.emit).toHaveBeenCalledWith(emittedValue);
}));
```

### 7.6. Permisos y Estados

**[RULES:PERMISSIONS_TESTS]**

```typescript
it('should disable edition when estado is Valorado', () => {
  // Adaptar según el proyecto: Valores de enum específicos del dominio
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
  // Adaptar según el componente: Nombre del getter de permisos
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

### 7.7. Diálogos y Modales

**[RULES:DIALOG_TESTS]**

```typescript
it('should close dialog on cancel', () => {
  dialogRefSpy.close = jasmine.createSpy('close');

  component.cancel();

  expect(dialogRefSpy.close).toHaveBeenCalledWith({ accepted: false });
});
it('should open modal and build config correctly', fakeAsync(() => {
  // Adaptar según el servicio: Configuración del modal específica
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

### 7.8. Búsquedas y Filtros

**[RULES:SEARCH_FILTER_TESTS]**

```typescript
it('should search and update results', fakeAsync(() => {
  // Adaptar según el modelo: Resultados esperados de la búsqueda
  const searchResults = [{ id: 1, name: 'Result 1' }];
  serviceNameSpy.search.and.returnValue(of(searchResults, asyncScheduler));

  component.onSearch('query');
  tick();

  expect(component.searchResults).toEqual(searchResults);
}));

it('should return empty array when search returns no results', fakeAsync(() => {
  // Adaptar según el servicio: Método de búsqueda específico
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

### 7.9. Tests CRUD de Grids

**[RULES:CRUD_TESTS]**

```typescript
// Tests de Selección

it('should update selection on selectionChange', () => {
  // Adaptar según el componente: Método de selección específico
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

// Tests de Eliminación

it('should show warning when no element selected for delete', () => {
  component.selectedItem = null;

  component.openRemoveConfirmation();

  expect(sharedMessageSpy.showMessage).toHaveBeenCalledWith('NO_ELEMENT_SELECTED', 'warning');
  expect(modalServiceSpy.openModal).not.toHaveBeenCalled();
});

it('should open delete confirmation modal when element selected', () => {
  // Adaptar según el modelo: ID del elemento seleccionado
  component.selectedItem = 5;

  component.openRemoveConfirmation();

  expect(gridServiceSpy.buildDeleteConfirmationModal).toHaveBeenCalled();
  expect(modalServiceSpy.openModal).toHaveBeenCalled();
});

it('should delete item and refresh grid', fakeAsync(() => {
  // Adaptar según el servicio: ID del item y método de eliminación
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

// Tests de Edición/Creación

it('should not perform action when edition disabled', () => {
  component.deshabilitarEdicion = true;
  spyOn(component as any, 'insertOrUpdateAction');

  component.addAction();

  expect((component as any).insertOrUpdateAction).not.toHaveBeenCalled();
});

it('should call service method when calling grid action', () => {
  // Adaptar según el componente: Método de acción específico
  spyOn(component as any, 'insertOrUpdateAction');
  component.deshabilitarEdicion = false;

  component.addAction();

  expect((component as any).insertOrUpdateAction).toHaveBeenCalled();
});
```

---

## 8. Patrones Recomendados

**[RULES:ASYNC_PATTERNS]**

### 8.1. Requisito Obligatorio: Manejo de Operaciones Asíncronas

**Reglas obligatorias para operaciones asíncronas:**

1. Es obligatorio utilizar `fakeAsync`/`tick()` para operaciones asíncronas
2. Debe usarse `asyncScheduler` en observables mock: `of(data, asyncScheduler)`
3. Deben verificarse estados de loading ANTES y DESPUÉS de `tick()`
4. Primer `tick()` después de `fixture.detectChanges()` para inicialización
5. Segundo `tick()` después de llamar método asíncrono para procesar observable

### 8.2. Uso de Constantes en Tests

```typescript
// Patrón recomendado: Definir constantes al inicio del describe
const TEST_VIAJE_ID = 100;
const TEST_RECARGO_ID = 1;
const TEST_DESCRIPCION = 'Recargo Combustible';

// Antipatrón: Números mágicos directamente en los tests
it('should load data', () => {
  component.viajeId = 100; // Pregunta: ¿Qué significa 100?
  expect(component.selectedId).toBe(1); // Pregunta: ¿Por qué 1?
});

// Patrón correcto: Usar constantes con nombres descriptivos
it('should load data', () => {
  component.viajeId = TEST_VIAJE_ID;
  expect(component.selectedId).toBe(TEST_RECARGO_ID);
});
```

### 8.3. Organización de Tests con Comentarios de Sección

```typescript
describe('ComponentToTest', () => {
  // ... setup ...

  // Tests de Ciclo de Vida

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  // Tests de @Input

  it('should initialize inputs correctly', () => {
    // ...
  });

  // Tests de ngOnChanges

  it('should handle input changes', () => {
    // ...
  });

  // Tests de Estados

  it('should disable edition when estado is Valorado', () => {
    // ...
  });

  // Tests de Carga de Datos

  it('should load grid data successfully', fakeAsync(() => {
    // ...
  }));

  // Tests CRUD

  it('should delete item and refresh grid', fakeAsync(() => {
    // ...
  }));

  // Tests de Getters

  it('should return true for isNew when id is 0', () => {
    // ...
  });
});
```

### 8.4. fakeAsync para Operaciones Asíncronas

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

### 8.5. EventEmitter para Modales

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

### 8.6. Done Callback para Async sin fakeAsync

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

### 8.7. Tests sin fixture.detectChanges()

```typescript
// Patrón recomendado: Tests de lógica pura sin inicialización del componente
// Útil cuando no se necesita el template o se desea evitar efectos secundarios de ngOnInit

it('should load grid data successfully without fixture', fakeAsync(() => {
  // Adaptar según el modelo: Datos mock del grid
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

// Nota técnica: No invocar fixture.detectChanges() si:
// 1. Solo se testean métodos públicos del componente
// 2. El componente tiene dependencias complejas en ngOnInit
// 3. Se desea evitar la inicialización de ClGrid u otros componentes complejos
```

### 8.8. Spy en Métodos Privados del Componente

```typescript
it('should call private method when condition met', () => {
  // Adaptar según el componente: Método privado a espiar
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

### 8.9. Requisito Obligatorio: TranslateService y Traducciones

**[RULES:TRANSLATE_SERVICE]**

**Reglas obligatorias para traducciones:**

1. No está permitido mockear `TranslateService` directamente
2. SOLO debe usarse `TranslateModule.forRoot({ loader: { provide: TranslateLoader, useClass: TranslateFakeLoader } })` en imports
3. `TranslateFakeLoader` devuelve las claves sin traducir (ej: devuelve 'NO_ELEMENT_SELECTED' no 'No element selected')
4. No está permitido proveer `TranslateService` en providers del TestBed
5. En tests, debe esperarse las claves de traducción, NO el texto traducido

---

## 9. Problemas Comunes y Soluciones

**[RULES:COMMON_PROBLEMS]**

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
| **TranslatePipe/Service error**               | No está permitido mockear `TranslateService` - solo `TranslateModule.forRoot()` con `TranslateFakeLoader`                     |
| **ClGrid undefined mode**                     | Debe inicializarse `component.gridConfig...` ANTES de `fixture.detectChanges()` en `beforeEach`                               |
| **translate.get is not a function**           | No está permitido proveer `TranslateService` en providers - `TranslateFakeLoader` maneja todo automáticamente                 |
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
