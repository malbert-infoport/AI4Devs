# GUÍA TÉCNICA: GENERACIÓN DE TESTS UNITARIOS PARA SERVICIOS ANGULAR

## 1. Contexto del Proyecto

Esta guía establece los estándares y patrones para la creación de tests unitarios de servicios Angular en el proyecto.

## [RULES:PROJECT_CONTEXT]

### 1.1 Requisito Obligatorio: Compatibilidad con Angular 20+ y RxJS

**Importante:** A partir de RxJS 7+ y Angular 20+, ciertas funciones han sido marcadas como deprecated y no deben utilizarse.

**Reglas de implementación:**

1. No está permitido usar `of(value, asyncScheduler)` - función deprecated
2. Debe utilizarse `scheduled([value], asyncScheduler)` para operaciones asíncronas
3. No está permitido usar `throwError(() => error, asyncScheduler)` - función deprecated
4. Para manejo de errores síncronos: usar `throwError(() => error)` sin scheduler
5. Importar obligatoriamente `scheduled` y `switchMap` desde `rxjs` cuando se requieran operaciones asíncronas

**Ejemplo de implementación correcta:**

```typescript
// Patrón incorrecto (deprecated)
of(data, asyncScheduler);
throwError(() => error, asyncScheduler);

// Patrón correcto
scheduled([data], asyncScheduler);
throwError(() => error);
```

[RULES:CONTRACT_FIRST]

Los tests de servicios deben validar exclusivamente:

- el contrato público del servicio
- la transformación de datos de entrada a salida
- los side effects esperados (llamadas a APIs, estados públicos, flags, errores propagados)

Un test solo debe fallar si cambia:

- la firma pública del método
- la estructura o semántica del dato devuelto
- el flujo funcional observable (insert vs update, error vs success)
- la interacción esperada con dependencias externas (API Clients, AccessService, etc.)

Está prohibido generar tests que fallen únicamente por:

- refactors internos del método
- cambios de implementación sin cambio en output
- reorganización de helpers privados
- cambios internos en cómo se construye el formulario si el resultado funcional es equivalente

[RULES:SERVICE_CONTRACT_FIRST]

Un servicio se considera correctamente testado si:

- dos implementaciones distintas producen outputs, errores y side effects equivalentes
- un consumidor externo no puede distinguir entre ambas
- los tests siguen pasando tras un refactor sin cambio funcional

[RULES:IMPLEMENTATION_GUARD]

Está prohibido generar tests que validen directamente:

- estructura interna de formularios (nombres de controles, orden de creación)
- configuración interna de grids o tablas (sortable, pageable, layout interno)
- llamadas internas a helpers privados
- el orden exacto de llamadas internas si no afecta al resultado final

Estas verificaciones solo están permitidas si:

- el elemento forma parte del contrato público documentado del servicio
- o su cambio supondría un bug funcional observable para un consumidor externo

---

### 1.2 Configuración del Proyecto

Los tests unitarios deben ser compatibles con las siguientes especificaciones técnicas:

- **Framework:** Angular 20+
- **Testing:** Jasmine + Karma
- **Servicios:** Injectable con lógica de negocio
- **HTTP:** Comunicación con API usando HttpClient
- **Formularios:** ReactiveFormsModule con validadores personalizados
- **Arquitectura:** Separación de servicios de lógica UI

---

## 2. Estructura de Tests Requerida

## [RULES:IMPORTS_SERVICES]

### 2.1 Imports Estándar

Todo archivo de tests de servicio debe incluir los siguientes imports base:

```typescript
import { TestBed } from '@angular/core/testing';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { of, throwError } from 'rxjs';
import { TranslateService } from '@ngx-translate/core';

// Adaptar según el servicio: Importar el servicio a testear
import { ServiceToTest } from './service-to-test.service';

// Adaptar según el servicio: Importar dependencias y API Clients
import { AccessService } from '@app/theme/access/access.service';
import { ApiClient, OtherApiClient, ModelClassName } from '@restApi/api/apiClients';
```

---

## [ANTI_PATTERNS]

### 2.2 Antipatrón: Imports Incorrectos

Este antipatrón es una de las causas más comunes de errores en tests de servicios. Debe verificarse que todos los imports provengan de los módulos correctos.

#### Errores Comunes de Imports

```typescript
// Patrón incorrecto: EventEmitter no se encuentra en rxjs (pertenece a @angular/core)
import { of, throwError, EventEmitter } from 'rxjs';

// Patrón incorrecto: FormArray no se encuentra en rxjs (pertenece a @angular/forms)
import { FormArray } from 'rxjs';
```

#### Patrones Correctos de Imports

```typescript
// Patrón correcto: RxJS solo exporta operadores y creadores de observables
import { of, throwError } from 'rxjs';

// Patrón correcto: FormArray pertenece a @angular/forms
import { FormArray } from '@angular/forms';

// Patrón correcto: EventEmitter pertenece a @angular/core (uso infrecuente en servicios)
import { EventEmitter } from '@angular/core';
```

#### Referencia de Imports para Servicios

| Símbolo                                 | Módulo de Origen      | Propósito                  |
| --------------------------------------- | --------------------- | -------------------------- |
| `of`, `throwError`                      | `rxjs`                | Crear observables mock     |
| `FormBuilder`, `FormGroup`, `FormArray` | `@angular/forms`      | Formularios reactivos      |
| `Validators`                            | `@angular/forms`      | Validadores de formularios |
| `TranslateService`                      | `@ngx-translate/core` | Traducciones               |

**Nota técnica:** Solo debe importarse lo que efectivamente se utiliza en el archivo. Eliminar imports no utilizados.

---

## [RULES:NSWAG_MODELS]

### 2.3 Nota Técnica: Creación Correcta de Mocks de Modelos NSwag

Los modelos generados por NSwag (ubicados en `apiClients.ts`) incluyen los métodos `init()` y `toJSON()`. Por esta razón, no está permitido el uso de objetos literales con conversión de tipo `as Type`. Debe utilizarse el constructor del modelo.

#### Antipatrón: Objeto Literal con Conversión de Tipo

```typescript
// Patrón incorrecto: Conversión de tipo omite métodos init/toJSON
const mockData: ModelClassName = {
  id: 1,
  campo1: 'valor',
  campo2: 100
} as ModelClassName;
```

#### Patrón Recomendado: Uso del Constructor

```typescript
// Patrón correcto: Instanciar mediante el constructor
const mockData = new ModelClassName({
  id: 1,
  campo1: 'valor',
  campo2: 100
});
```

#### Verificación de Tipos

Debe verificarse el tipo correcto de cada propiedad en el archivo `apiClients.ts` antes de crear mocks:

```typescript
// Ejemplo: Consultar la interfaz IModelClassName en apiClients.ts
export interface IModelClassName {
  id?: number;
  campo1?: string;
  campo2?: number; // Tipo: number (no string)
  idExterno?: number; // Tipo: number (no string)
}

// Mock con tipos correctamente verificados
const mockData = new ModelClassName({
  id: 1,
  campo1: 'valor',
  campo2: 100, // Tipo correcto: number
  idExterno: 999 // Tipo correcto: number (no usar '999' como string)
});
```

#### Patrón Recomendado en Servicios

```typescript
it('should return entity data', (done) => {
  // Paso 1: Crear mock mediante constructor
  const mockEntity = new EntityView({
    id: 1,
    nombre: 'Test Entity',
    valor: 150.5,
    idExterno: 12345 // Tipo: number (no usar '12345' como string)
  });

  // Paso 2: Configurar spy con el mock
  apiClientSpy.getById.and.returnValue(of(mockEntity));

  // Paso 3: Ejecutar test
  service.loadEntity(1).subscribe((result) => {
    expect(result.id).toBe(1);
    expect(result.idExterno).toBe(12345);
    done();
  });
});
```

---

## [RULES:TESTBED_SERVICES]

## [RULES:SPIES]

### 2.4 Configuración Completa de TestBed

La configuración del TestBed para servicios debe incluir todos los providers necesarios y la creación de spies para las dependencias.

```typescript
describe('ServiceToTest', () => {
  let service: ServiceToTest;
  let fb: FormBuilder;

  // Adaptar según el servicio: Crear spies para todas las dependencias
  let apiClientSpy: jasmine.SpyObj<ApiClient>;
  let translateSpy: jasmine.SpyObj<TranslateService>;
  let accessServiceSpy: jasmine.SpyObj<AccessService>;
  let otherApiSpy: jasmine.SpyObj<OtherApiClient>;

  beforeEach(() => {
    // Paso 1: Crear spies de todas las dependencias
    // Adaptar según el servicio: Incluir todos los métodos de los API Clients utilizados
    apiClientSpy = jasmine.createSpyObj('ApiClient', [
      'getAll',
      'getAllKendoFilter',
      'getById',
      'getNewEntity',
      'insert',
      'update',
      'deleteById'
    ]);

    translateSpy = jasmine.createSpyObj('TranslateService', ['instant']);
    translateSpy.instant.and.callFake((key: string) => key);

    accessServiceSpy = jasmine.createSpyObj('AccessService', ['maestroViajesModificacion']);
    accessServiceSpy.maestroViajesModificacion.and.returnValue(true);

    // Adaptar según el servicio: Añadir otros API Clients según necesidad
    otherApiSpy = jasmine.createSpyObj('OtherApiClient', ['getAll']);

    // Paso 2: Configurar TestBed
    TestBed.configureTestingModule({
      providers: [
        ServiceToTest, // Adaptar según el servicio: Nombre del servicio a testear
        FormBuilder,
        // Adaptar según el servicio: Proveer todos los servicios que inyecta
        { provide: ApiClient, useValue: apiClientSpy },
        { provide: TranslateService, useValue: translateSpy },
        { provide: AccessService, useValue: accessServiceSpy },
        { provide: OtherApiClient, useValue: otherApiSpy }
      ]
    });

    service = TestBed.inject(ServiceToTest);
    fb = TestBed.inject(FormBuilder);
  });

  // Tests aquí...
});
```

---

## 3. Cobertura de Tests (Riesgo Alto/Medio)

La siguiente sección describe los tests obligatorios que deben implementarse para garantizar una cobertura adecuada del servicio.

## [PATTERNS:SERVICE_CREATION]

### 3.1 Creación del Servicio

```typescript
it('should be created', () => {
  expect(service).toBeTruthy();
});
```

## [PATTERNS:CUSTOM_VALIDATORS]

### 3.2 Validadores Personalizados

Tests para validación de formularios mediante validadores personalizados.

```typescript
describe('Custom Validators', () => {
  it('should validate required field correctly', () => {
    // Adaptar según el servicio: Nombre y lógica del validador
    const validator = ServiceValidators.customRequired();

    const validControl: any = { value: 'value' };
    const emptyControl: any = { value: '' };
    const nullControl: any = { value: null };

    expect(validator(validControl)).toBeNull();
    expect(validator(emptyControl)).toEqual({ customRequired: true });
    expect(validator(nullControl)).toEqual({ customRequired: true });
  });

  it('should validate maxLength correctly', () => {
    // Adaptar según el servicio: Parámetros del validador
    const validator = ServiceValidators.maxLength(10);

    const validControl: any = { value: 'short' };
    const invalidControl: any = { value: 'this is too long' };

    expect(validator(validControl)).toBeNull();
    expect(validator(invalidControl)).toBeTruthy();
  });

  it('should validate at least one checkbox is required', () => {
    // Adaptar según el servicio: Campos y lógica según el validador
    const validator = ServiceValidators.atLeastOneRequired(['field1', 'field2']);

    const form1 = fb.group({ field1: [true], field2: [false] });
    const form2 = fb.group({ field1: [false], field2: [false] });

    expect(validator(form1)).toBeNull();
    expect(validator(form2)).toEqual({ atLeastOneRequired: true });
  });

  // Adaptar según el servicio: Añadir más validadores según corresponda
  it('should validate matricula or booking required', () => {
    const validator = ServiceValidators.matriculaOrBookingRequired();

    const form1 = fb.group({ matricula: ['ABC123'], numeroBooking: [''] });
    const form2 = fb.group({ matricula: [''], numeroBooking: ['BOOK123'] });
    const form3 = fb.group({ matricula: [''], numeroBooking: [''] });

    expect(validator(form1)).toBeNull();
    expect(validator(form2)).toBeNull();
    expect(validator(form3)).toEqual({ matriculaOrBookingRequired: true });
  });
});
```

## [PATTERNS:FORM_BUILDING]

## [PATTERNS:FORM_ARRAY]

### 3.3 Construcción de Formularios

Tests para la construcción de formularios reactivos y manejo de FormArray.

[RULES:FORM_CONTRACT]

Los formularios solo deben testearse a nivel de contrato funcional:

- validez general (válido / inválido)
- impacto de campos en el flujo (submit permitido o bloqueado)
- datos finales emitidos o enviados

No está permitido:

- testear validadores individuales salvo que formen parte del contrato funcional
- verificar nombres internos de controles si no son consumidos externamente

```typescript
describe('Form Building', () => {
  it('should build form with correct structure and validators', () => {
    // Adaptar según el servicio: Estructura de la entidad
    const entity = {
      id: 1,
      campo1: 'valor1',
      campo2: 10,
      grupoAnidado: {
        subcampo1: 'sub1',
        subcampo2: true
      }
    };

    // Adaptar según el servicio: Nombre del método de construcción
    const form = service.buildForm(entity);

    expect(form).toBeDefined();
    expect(form.get('id')?.value).toBe(1);
    expect(form.get('campo1')?.value).toBe('valor1');
    expect(form.get('grupoAnidado.subcampo1')?.value).toBe('sub1');

    // Verificar validadores
    expect(form.get('campo1')?.hasError('required')).toBeTrue();
  });

  it('should build form with FormArray when entity has array', () => {
    // Adaptar según el servicio: Entidad con array
    const entity = {
      id: 1,
      items: [
        { id: 1, name: 'item1' },
        { id: 2, name: 'item2' }
      ]
    };

    const form = service.buildForm(entity);
    const itemsArray = form.get('items') as FormArray;

    expect(itemsArray).toBeTruthy();
    expect(itemsArray.length).toBe(2);
    expect(itemsArray.at(0).get('name')?.value).toBe('item1');
  });

  it('should disable fields based on condition', () => {
    // Adaptar según el servicio: Condición de enable/disable
    const entity = { id: 1, campo1: 'test' };

    const form1 = service.buildForm(entity, { condicion: true });
    expect(form1.get('campo1')?.disabled).toBeTrue();

    const form2 = service.buildForm(entity, { condicion: false });
    expect(form2.get('campo1')?.enabled).toBeTrue();
  });

  it('should apply custom validators to specific fields', () => {
    const entity = { id: 0 };
    const form = service.buildForm(entity);

    // MODIFICAR: Campo con validador personalizado
    const customField = form.get('customField');
    customField?.setValue('invalid_value');

    expect(customField?.hasError('customError')).toBeTrue();
  });
});
```

## [PATTERNS:FIELD_HANDLERS]

### 3.4 Manejo de Cambios de Campos (Handlers)

Tests para la lógica de manejo de cambios en campos del formulario.

[RULES:FIELD_HANDLERS]

Los métodos de manejo de campos solo deben testearse si:

- son públicos
- o afectan directamente al output del servicio

Está prohibido:

- testear el uso interno de patchValue / setValue
- testear el orden de actualización de campos

```typescript
describe('Field Change Handlers', () => {
  it('should update related fields when main field changes', () => {
    const form = service.buildForm({ id: 0 });

    // Adaptar según el servicio: Lógica de cambio
    service.handleFieldChange(form, { id: 1, nombre: 'Selected Item' });

    expect(form.get('fieldId')?.value).toBe(1);
    expect(form.get('displayField')?.value).toBe('Selected Item');
  });

  it('should disable dependent fields when condition is met', () => {
    const form = service.buildForm({ id: 0 });

    // Adaptar según el servicio: Condición y campos afectados
    service.handleConditionChange(form, true);

    expect(form.get('dependentField1')?.disabled).toBeTrue();
    expect(form.get('dependentField2')?.disabled).toBeTrue();
  });

  it('should clear and disable fields when toggle is false', () => {
    const form = service.buildForm({ id: 0 });
    form.get('conditionalField')?.setValue('value');

    // Adaptar según el servicio: Método y lógica de toggle
    service.toggleField(form, false);

    expect(form.get('conditionalField')?.value).toBeNull();
    expect(form.get('conditionalField')?.disabled).toBeTrue();
  });
});
```

## [PATTERNS:SUBMIT_PREPARATION]

### 3.5 Preparación de Datos para Submit

Tests para la preparación y transformación de datos antes del envío al servidor.

```typescript
describe('Submit Data Preparation', () => {
  it('should prepare submit data correctly', () => {
    const form = service.buildForm({ id: 0 });

    // Adaptar según el servicio: Valores del formulario
    form.patchValue({
      campo1: 'test',
      campo2: 10,
      tipoObjeto: { id: 5, nombre: 'Tipo 5' }
    });

    const submitData = service.prepareSubmitData(form);

    expect(submitData.campo1).toBe('test');
    expect(submitData.campo2).toBe(10);
    // Verificar que objetos se convierten a IDs
    expect(submitData.tipoObjetoId).toBe(5);
    // Verificar que objetos originales se eliminan
    expect((submitData as any).tipoObjeto).toBeUndefined();
  });

  it('should remove null or empty fields from submit data', () => {
    const form = service.buildForm({ id: 0 });
    form.patchValue({
      campo1: 'value',
      campo2: null,
      campo3: '',
      campo4: undefined
    });

    const submitData = service.prepareSubmitData(form);

    expect(submitData.campo1).toBe('value');
    // Adaptar según el servicio: Verificar campos que deben eliminarse
    expect((submitData as any).campo2).toBeUndefined();
    expect((submitData as any).campo3).toBeUndefined();
    expect((submitData as any).campo4).toBeUndefined();
  });

  it('should handle nested groups in submit data', () => {
    const form = service.buildForm({ id: 0 });
    form.patchValue({
      grupoAnidado: {
        subField1: 'sub1',
        subField2: 'sub2'
      }
    });

    const submitData = service.prepareSubmitData(form);

    expect(submitData.grupoAnidado.subField1).toBe('sub1');
  });
});
```

## [PATTERNS:CRUD_OPERATIONS]

### 3.6 Operaciones CRUD

Tests para operaciones básicas de Create, Read, Update y Delete.

```typescript
describe('CRUD Operations', () => {
  it('should call insert for id 0', (done) => {
    // Adaptar según el servicio: Datos de entidad
    const entity = { id: 0, name: 'New Entity' };
    apiClientSpy.insert.and.returnValue(of({ id: 100, name: 'New Entity' } as any));

    service.save(entity).subscribe((res) => {
      expect(apiClientSpy.insert).toHaveBeenCalled();
      expect(res.id).toBe(100);
      done();
    });
  });

  it('should call update for id > 0', (done) => {
    // Adaptar según el servicio: Datos de entidad
    const entity = { id: 5, name: 'Updated Entity' };
    apiClientSpy.update.and.returnValue(of({ id: 5, name: 'Updated Entity' } as any));

    service.save(entity).subscribe((res) => {
      expect(apiClientSpy.update).toHaveBeenCalledWith(5, entity);
      expect(apiClientSpy.insert).not.toHaveBeenCalled();
      expect(res.id).toBe(5);
      done();
    });
  });

  it('should delete entity by id', (done) => {
    apiClientSpy.deleteById.and.returnValue(of({} as any));

    service.delete(10).subscribe(() => {
      expect(apiClientSpy.deleteById).toHaveBeenCalledWith(10);
      done();
    });
  });
});
```

## [PATTERNS:ENTITY_LOADING]

### 3.7 Carga de Entidades

Tests para la carga de entidades desde el servidor.

```typescript
describe('Entity Loading', () => {
  it('should use getById when id > 0', (done) => {
    // Adaptar según el servicio: Datos de respuesta
    const entity = { id: 10, name: 'Entity 10' };
    apiClientSpy.getById.and.returnValue(of(entity as any));

    service.loadEntity(10).subscribe((res) => {
      expect(apiClientSpy.getById).toHaveBeenCalledWith(10, jasmine.any(String));
      expect(res.id).toBe(10);
      done();
    });
  });

  it('should use getNewEntity when id === 0', (done) => {
    // Adaptar según el servicio: Datos de entidad nueva
    const newEntity = { id: 0, name: '' };
    apiClientSpy.getNewEntity.and.returnValue(of(newEntity as any));

    service.loadEntity(0).subscribe((res) => {
      expect(apiClientSpy.getNewEntity).toHaveBeenCalled();
      expect(apiClientSpy.getById).not.toHaveBeenCalled();
      expect(res.id).toBe(0);
      done();
    });
  });

  it('should load catalog data', (done) => {
    // Adaptar según el servicio: Datos de catálogo
    const catalogData = [
      { id: 1, descripcion: 'Item 1' },
      { id: 2, descripcion: 'Item 2' }
    ];
    otherApiSpy.getAll.and.returnValue(of(catalogData as any));

    service.loadCatalog().subscribe((res) => {
      expect(res.length).toBe(2);
      expect(otherApiSpy.getAll).toHaveBeenCalled();
      done();
    });
  });
});
```

## [PATTERNS:ERROR_HANDLING]

### 3.8 Manejo de Errores

Tests para verificar la propagación correcta de errores.

```typescript
describe('Error Handling', () => {
  it('should propagate API error on save', (done) => {
    const error = new Error('API Error');
    apiClientSpy.insert.and.returnValue(throwError(() => error));

    service.save({ id: 0 } as any).subscribe({
      next: () => fail('expected error'),
      error: (err) => {
        expect(err).toBe(error);
        done();
      }
    });
  });

  it('should propagate error on load', (done) => {
    apiClientSpy.getById.and.returnValue(throwError(() => new Error('Load Error')));

    service.loadEntity(5).subscribe({
      next: () => fail('expected error'),
      error: (err) => {
        expect(err).toBeTruthy();
        done();
      }
    });
  });

  it('should propagate delete error', (done) => {
    apiClientSpy.deleteById.and.returnValue(throwError(() => new Error('Delete Error')));

    service.delete(10).subscribe({
      next: () => fail('expected error'),
      error: (err) => {
        expect(err).toBeTruthy();
        done();
      }
    });
  });
});
```

## [PATTERNS:GRID_CONFIG]

### 3.9 Configuración de Grid (Opcional)

Tests para la configuración de grillas Kendo UI. Esta sección aplica solo si el servicio incluye funcionalidad de grid.

[RULES:GRID_CONTRACT]

La configuración de grids solo debe validarse en términos de:

- columnas expuestas
- existencia de filtros funcionales
- resultado de carga de datos
- permisos aplicados

No está permitido:

- testear propiedades internas del grid (sortable.mode, pageable.size, etc.)
- acoplar tests a implementaciones específicas de librerías de UI

```typescript
describe('Grid Configuration', () => {
  it('should build grid config with correct filters and columns', () => {
    // Adaptar según el servicio: Templates mock
    // Nota técnica: Usar tipo `any` para evitar errores de TemplateRef en tests unitarios
    const templates: any = {
      addButtonTemplate: {},
      noRecordsTemplate: {},
      refreshGridTemplate: {},
      titleGridTemplate: {}
    };

    // Adaptar según el servicio: Parámetros de configuración
    const config = service.buildGridConfig(entityId, templates, false);

    expect(config.idGrid).toBeTruthy();
    expect(config.state.filter.filters).toContain(jasmine.objectContaining({ field: 'entityId', value: entityId }));

    const columnFields = config.columns.map((c: any) => c.field);
    // Adaptar según el servicio: Columnas esperadas
    expect(columnFields).toContain('campo1');
    expect(columnFields).toContain('campo2');
    expect(columnFields).toContain('actions');
  });

  it('should configure pagination correctly', () => {
    const templates: any = {
      /* templates mock */
    };
    const config = service.buildGridConfig(entityId, templates);

    expect(config.pageable).toBeDefined();
    // Nota técnica: Castear a `any` para acceder a propiedades opcionales
    expect((config.pageable as any).pageSizes).toEqual([5, 10, 25, 50, 100]);
    expect(config.state.take).toBe(10);
    expect(config.state.skip).toBe(0);
  });

  it('should configure sortable settings', () => {
    const templates: any = {
      /* templates mock */
    };
    const config = service.buildGridConfig(entityId, templates);

    expect(config.sortable).toBeDefined();
    // Nota técnica: Castear para acceder a propiedades que pueden ser boolean o ClSortableSettings
    expect((config.sortable as any).mode).toBe('multiple');
    expect((config.sortable as any).allowUnsort).toBeTrue();
  });

  it('should configure filterable settings', () => {
    const templates: any = {
      /* templates mock */
    };
    const config = service.buildGridConfig(entityId, templates);

    // Nota técnica: Castear para acceder a propiedades que pueden ser boolean o ClFilterableSettings
    expect((config.filterable as any).hideToolbarFilter).toBeTrue();
    expect((config.filterable as any).hideSearcherFilter).toBeTrue();
  });

  it('should load grid data with kendo filter', (done) => {
    // Nota técnica: Castear state a `any` para evitar errores de tipo con getAllKendoFilter
    const mockState: any = { skip: 0, take: 10, filter: { filters: [] } };

    // Adaptar según el servicio: Resultado esperado usando constructor NSwag
    const mockResult = {
      list: [new EntityView({ id: 1 }), new EntityView({ id: 2 })],
      count: 2
    };

    apiClientSpy.getAllKendoFilter.and.returnValue(of(mockResult as any));

    service.loadGridData(mockState).subscribe((res) => {
      expect(apiClientSpy.getAllKendoFilter).toHaveBeenCalled();
      expect(res.data.length).toBe(2);
      expect(res.total).toBe(2);
      done();
    });
  });

  it('should update viajeId filter in grid state', () => {
    // Adaptar según el servicio: Estructura del state
    const state: any = {
      data: {
        filter: {
          filters: [{ field: 'viajeId', operator: 'eq', value: 1 }]
        }
      }
    };

    service.updateViajeIdFilter(state, 10);

    const viajeFilter = state.data.filter.filters.find((f: any) => f.field === 'viajeId');
    expect(viajeFilter.value).toBe(10);
  });
});
```

## [PATTERNS:ACCESS_CONTROL]

### 3.10 Control de Acceso

Tests para verificar el control de permisos y acceso a funcionalidades.

```typescript
describe('Access Control', () => {
  it('should hide edition when no access', () => {
    accessServiceSpy.maestroViajesModificacion.and.returnValue(false);

    // Adaptar según el servicio: Método de construcción de modal
    const { config } = service.buildModal(id, onSubmit);

    expect(config.submitButton.hidden).toBeTrue();
  });

  it('should show edition when has access', () => {
    accessServiceSpy.maestroViajesModificacion.and.returnValue(true);

    const { config } = service.buildModal(0, jasmine.createSpy());

    expect(config.submitButton.hidden).toBeFalse();
  });

  it('should disable form when deshabilitarEdicion is true', () => {
    const form = service.buildForm({ id: 0 }, { deshabilitarEdicion: true });

    expect(form.disabled).toBeTrue();
  });
});
```

## [PATTERNS:SEARCH_FILTERS]

### 3.11 Búsquedas y Filtros

Tests para funcionalidades de búsqueda y filtrado de datos.

```typescript
describe('Search and Filters', () => {
  it('should search items by filter', (done) => {
    // Adaptar según el servicio: Datos de búsqueda
    const results = [{ id: 1, name: 'Match 1' }];
    apiClientSpy.getAllKendoFilter.and.returnValue(of({ list: results, count: 1 } as any));

    service.searchItems('query').subscribe((res) => {
      expect(res.length).toBe(1);
      expect(apiClientSpy.getAllKendoFilter).toHaveBeenCalled();
      done();
    });
  });

  it('should filter results by condition', () => {
    // Adaptar según el servicio: Lógica de filtro
    const items = [
      { id: 1, active: true },
      { id: 2, active: false }
    ];

    const filtered = service.filterByCondition(items, { active: true });

    expect(filtered.length).toBe(1);
    expect(filtered[0].id).toBe(1);
  });
});
```

## [PATTERNS:CONCURRENCY]

### 3.12 Concurrencia (Opcional pero Recomendado)

Tests para verificar el comportamiento del servicio ante operaciones concurrentes.

```typescript
describe('Concurrent Operations', () => {
  it('should handle concurrent load calls', (done) => {
    const mockResult1 = { list: [{ id: 1 }], count: 1 };
    const mockResult2 = { list: [{ id: 2 }], count: 1 };

    apiClientSpy.getAllKendoFilter.and.returnValues(of(mockResult1 as any), of(mockResult2 as any));

    const results: any[] = [];

    service.loadGridData({}).subscribe((res) => results.push(res));
    service.loadGridData({}).subscribe((res) => {
      results.push(res);

      expect(results.length).toBe(2);
      expect(results[0].data[0].id).toBe(1);
      expect(results[1].data[0].id).toBe(2);
      done();
    });
  });

  it('should handle concurrent save operations', (done) => {
    apiClientSpy.insert.and.returnValues(of({ id: 100 } as any), of({ id: 101 } as any));

    const results: any[] = [];

    service.save({ id: 0 } as any).subscribe((res) => results.push(res));
    service.save({ id: 0 } as any).subscribe((res) => {
      results.push(res);

      expect(results.length).toBe(2);
      expect(apiClientSpy.insert).toHaveBeenCalledTimes(2);
      done();
    });
  });

  it('should handle concurrent delete calls', (done) => {
    apiClientSpy.deleteById.and.returnValue(of({} as any));

    let deleteCount = 0;

    service.delete(1).subscribe(() => deleteCount++);
    service.delete(2).subscribe(() => {
      deleteCount++;

      expect(deleteCount).toBe(2);
      expect(apiClientSpy.deleteById).toHaveBeenCalledTimes(2);
      expect(apiClientSpy.deleteById).toHaveBeenCalledWith(1);
      expect(apiClientSpy.deleteById).toHaveBeenCalledWith(2);
      done();
    });
  });
});
```

---

## [RULES:DONE_ASYNC]

## [RULES:RXJS_ASYNC]

## 4. Patrones de Implementación

Esta sección describe patrones comunes para el manejo de operaciones asíncronas en tests.

### 4.1 Callback Done para Tests Asíncronos

El callback `done` es obligatorio en tests que involucran observables para garantizar que el test espere la finalización de la operación.

```typescript
it('should test async operation', (done) => {
  serviceSpy.method.and.returnValue(of(data));

  service.operation().subscribe((result) => {
    expect(result).toBeDefined();
    done();
  });
});
```

### 4.2 Encadenamiento de Operaciones

Para tests que requieren múltiples operaciones secuenciales:

```typescript
it('should test multiple operations', (done) => {
  serviceSpy.op1.and.returnValue(of(data1));
  serviceSpy.op2.and.returnValue(of(data2));

  service.operation1().subscribe((res1) => {
    expect(res1).toBe(data1);

    service.operation2().subscribe((res2) => {
      expect(res2).toBe(data2);
      done();
    });
  });
});
```

### 4.3 Manejo de Errores con Subscribe

Para tests de manejo de errores, debe utilizarse el bloque `error` del subscribe:

```typescript
it('should handle error', (done) => {
  serviceSpy.method.and.returnValue(throwError(() => new Error('error')));

  service.operation().subscribe({
    next: () => fail('expected error'),
    error: (err) => {
      expect(err).toBeTruthy();
      done();
    }
  });
});
```

---

## 5. Guía de Resolución de Problemas

Tabla de referencia para problemas frecuentes en tests de servicios y sus soluciones.

| Problema                                    | Solución                                                                                                                   |
| ------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| **Done not called**                         | Verificar que `done()` se invoca en todos los caminos de ejecución (tanto en success como en error)                        |
| **Spy not called**                          | Verificar que el spy está configurado con `and.returnValue()`                                                              |
| **FormBuilder undefined**                   | Incluir `FormBuilder` en el array de providers del TestBed                                                                 |
| **Validator no funciona**                   | Asegurar que el validator retorna `null` cuando la validación es exitosa                                                   |
| **Observable no completa**                  | Utilizar `of()` o `throwError()` que completan automáticamente                                                             |
| **Multiple calls fallan**                   | Utilizar `and.returnValues()` en lugar de `and.returnValue()` para múltiples llamadas                                      |
| **Error tipo mock NSwag**                   | Usar `new ModelClassName({...})` en lugar de `{...} as ModelClassName`                                                     |
| **Error tipo de propiedad**                 | Verificar tipos en `apiClients.ts` - ejemplo: `idExterno` puede ser `number` no `string`                                   |
| **EventEmitter import error**               | `EventEmitter` pertenece a `@angular/core`, no a `rxjs`                                                                    |
| **Import no usado**                         | Eliminar imports no utilizados - verificar advertencias de TypeScript                                                      |
| **Spy no funciona en tests de componentes** | Si el servicio está en `providers` del componente, usar `overrideComponent` (ver guía de componentes)                      |
| **TemplateRef error en mocks**              | Usar `const templates: any = {...}` para evitar errores de TemplateRef en tests de servicios                               |
| **Acceso a propiedades opcionales**         | Castear a `any` cuando la propiedad puede ser `boolean` o `ClSettings` (ejemplo: `(config.pageable as any).pageSizes`)     |
| **Error tipo en getAllKendoFilter**         | Castear state a `any`: `const mockState: any = { skip: 0, take: 10 }`                                                      |
| **Funciones deprecated de RxJS**            | No usar `of(value, asyncScheduler)` ni `throwError(error, asyncScheduler)` - ver sección 1.1 de compatibilidad Angular 20+ |

---

```

```
