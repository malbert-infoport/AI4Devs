# PROMPT PARA GENERACIÓN DE TESTS DE SERVICIOS

## Contexto del Proyecto

Necesito crear tests unitarios para un servicio Angular con las siguientes características del proyecto:

### Configuración del Proyecto

- Framework: Angular 20+
- Testing: Jasmine + Karma
- Servicios: Injectable con lógica de negocio
- HTTP: Comunicación con API usando HttpClient
- Formularios: ReactiveFormsModule con validadores personalizados
- Arquitectura: Separación de servicios de lógica UI

---

## Estructura de Tests Requerida

### Imports Estándar

```typescript
import { TestBed } from '@angular/core/testing';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { of, throwError } from 'rxjs';
import { TranslateService } from '@ngx-translate/core';

// MODIFICAR: Importar el servicio a testear
import { ServiceToTest } from './service-to-test.service';

// MODIFICAR: Importar dependencias y API Clients
import { AccessService } from '@app/theme/access/access.service';
import { ApiClient, OtherApiClient, ModelClassName } from '@restApi/api/apiClients';
```

---

### ⚠️ CRÍTICO: Verificación de Imports Correctos

Antes de generar cualquier test, **VERIFICA que los imports sean correctos**:

#### ❌ ERRORES COMUNES DE IMPORTS

```typescript
// ❌ ERROR: EventEmitter NO está en rxjs (es de @angular/core)
import { of, throwError, EventEmitter } from 'rxjs';

// ❌ ERROR: Importar FormArray desde lugar incorrecto
import { FormArray } from 'rxjs';
```

#### ✅ IMPORTS CORRECTOS PARA SERVICIOS

```typescript
// ✅ CORRECTO: RxJS solo exporta operadores y creadores de observables
import { of, throwError } from 'rxjs';

// ✅ CORRECTO: FormArray viene de @angular/forms
import { FormArray } from '@angular/forms';

// ✅ CORRECTO: EventEmitter es de @angular/core (raramente usado en servicios)
import { EventEmitter } from '@angular/core';
```

#### Reglas de Imports en Servicios

| Símbolo                                 | Origen Correcto       | Uso                        |
| --------------------------------------- | --------------------- | -------------------------- |
| `of`, `throwError`                      | `rxjs`                | Crear observables mock     |
| `FormBuilder`, `FormGroup`, `FormArray` | `@angular/forms`      | Formularios reactivos      |
| `Validators`                            | `@angular/forms`      | Validadores de formularios |
| `TranslateService`                      | `@ngx-translate/core` | Traducciones               |

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

#### Patrón Recomendado en Servicios

```typescript
it('should return entity data', (done) => {
  // 1. Crear mock usando constructor
  const mockEntity = new EntityView({
    id: 1,
    nombre: 'Test Entity',
    valor: 150.5,
    idExterno: 12345 // number, NO '12345' string
  });

  // 2. Configurar spy con el mock
  apiClientSpy.getById.and.returnValue(of(mockEntity));

  // 3. Ejecutar test
  service.loadEntity(1).subscribe((result) => {
    expect(result.id).toBe(1);
    expect(result.idExterno).toBe(12345);
    done();
  });
});
```

---

### Configuración Completa de TestBed

```typescript
describe('ServiceToTest', () => {
  let service: ServiceToTest;
  let fb: FormBuilder;

  // MODIFICAR: Crear spies para TODAS las dependencias del servicio
  let apiClientSpy: jasmine.SpyObj<ApiClient>;
  let translateSpy: jasmine.SpyObj<TranslateService>;
  let accessServiceSpy: jasmine.SpyObj<AccessService>;
  let otherApiSpy: jasmine.SpyObj<OtherApiClient>;

  beforeEach(() => {
    // 1. Crear spies de TODAS las dependencias
    // MODIFICAR: Añadir TODOS los métodos de los API Clients que usa el servicio
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

    // MODIFICAR: Añadir otros API Clients si es necesario
    otherApiSpy = jasmine.createSpyObj('OtherApiClient', ['getAll']);

    // 2. Configurar TestBed
    TestBed.configureTestingModule({
      providers: [
        ServiceToTest, // MODIFICAR: Nombre del servicio
        FormBuilder,
        // MODIFICAR: Proveer TODOS los servicios que inyecta
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

## Tests a Incluir (Cobertura de Riesgo Alto/Medio)

### 1. Creación del Servicio

```typescript
it('should be created', () => {
  expect(service).toBeTruthy();
});
```

### 2. Validadores Personalizados

```typescript
describe('Custom Validators', () => {
  it('should validate required field correctly', () => {
    // MODIFICAR: Nombre y lógica del validador
    const validator = ServiceValidators.customRequired();

    const validControl: any = { value: 'value' };
    const emptyControl: any = { value: '' };
    const nullControl: any = { value: null };

    expect(validator(validControl)).toBeNull();
    expect(validator(emptyControl)).toEqual({ customRequired: true });
    expect(validator(nullControl)).toEqual({ customRequired: true });
  });

  it('should validate maxLength correctly', () => {
    // MODIFICAR: Parámetros del validador
    const validator = ServiceValidators.maxLength(10);

    const validControl: any = { value: 'short' };
    const invalidControl: any = { value: 'this is too long' };

    expect(validator(validControl)).toBeNull();
    expect(validator(invalidControl)).toBeTruthy();
  });

  it('should validate at least one checkbox is required', () => {
    // MODIFICAR: Campos y lógica según el validador
    const validator = ServiceValidators.atLeastOneRequired(['field1', 'field2']);

    const form1 = fb.group({ field1: [true], field2: [false] });
    const form2 = fb.group({ field1: [false], field2: [false] });

    expect(validator(form1)).toBeNull();
    expect(validator(form2)).toEqual({ atLeastOneRequired: true });
  });

  // MODIFICAR: Añadir más validadores según el servicio
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

### 3. Construcción de Formularios

```typescript
describe('Form Building', () => {
  it('should build form with correct structure and validators', () => {
    // MODIFICAR: Estructura de la entidad según el servicio
    const entity = {
      id: 1,
      campo1: 'valor1',
      campo2: 10,
      grupoAnidado: {
        subcampo1: 'sub1',
        subcampo2: true
      }
    };

    // MODIFICAR: Nombre del método de construcción
    const form = service.buildForm(entity);

    expect(form).toBeDefined();
    expect(form.get('id')?.value).toBe(1);
    expect(form.get('campo1')?.value).toBe('valor1');
    expect(form.get('grupoAnidado.subcampo1')?.value).toBe('sub1');

    // Verificar validadores
    expect(form.get('campo1')?.hasError('required')).toBeTrue();
  });

  it('should build form with FormArray when entity has array', () => {
    // MODIFICAR: Entidad con array
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
    // MODIFICAR: Condición de enable/disable según el servicio
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

### 4. Manejo de Cambios de Campos (Handlers)

```typescript
describe('Field Change Handlers', () => {
  it('should update related fields when main field changes', () => {
    const form = service.buildForm({ id: 0 });

    // MODIFICAR: Lógica de cambio según el servicio
    service.handleFieldChange(form, { id: 1, nombre: 'Selected Item' });

    expect(form.get('fieldId')?.value).toBe(1);
    expect(form.get('displayField')?.value).toBe('Selected Item');
  });

  it('should disable dependent fields when condition is met', () => {
    const form = service.buildForm({ id: 0 });

    // MODIFICAR: Condición y campos afectados
    service.handleConditionChange(form, true);

    expect(form.get('dependentField1')?.disabled).toBeTrue();
    expect(form.get('dependentField2')?.disabled).toBeTrue();
  });

  it('should clear and disable fields when toggle is false', () => {
    const form = service.buildForm({ id: 0 });
    form.get('conditionalField')?.setValue('value');

    // MODIFICAR: Método y lógica de toggle
    service.toggleField(form, false);

    expect(form.get('conditionalField')?.value).toBeNull();
    expect(form.get('conditionalField')?.disabled).toBeTrue();
  });
});
```

### 5. Preparación de Datos para Submit

```typescript
describe('Submit Data Preparation', () => {
  it('should prepare submit data correctly', () => {
    const form = service.buildForm({ id: 0 });

    // MODIFICAR: Valores del formulario
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
    // MODIFICAR: Verificar campos que se deben eliminar
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

### 6. Operaciones CRUD

```typescript
describe('CRUD Operations', () => {
  it('should call insert for id 0', (done) => {
    // MODIFICAR: Datos de entidad
    const entity = { id: 0, name: 'New Entity' };
    apiClientSpy.insert.and.returnValue(of({ id: 100, name: 'New Entity' } as any));

    service.save(entity).subscribe((res) => {
      expect(apiClientSpy.insert).toHaveBeenCalled();
      expect(res.id).toBe(100);
      done();
    });
  });

  it('should call update for id > 0', (done) => {
    // MODIFICAR: Datos de entidad
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

### 7. Carga de Entidades

```typescript
describe('Entity Loading', () => {
  it('should use getById when id > 0', (done) => {
    // MODIFICAR: Datos de respuesta
    const entity = { id: 10, name: 'Entity 10' };
    apiClientSpy.getById.and.returnValue(of(entity as any));

    service.loadEntity(10).subscribe((res) => {
      expect(apiClientSpy.getById).toHaveBeenCalledWith(10, jasmine.any(String));
      expect(res.id).toBe(10);
      done();
    });
  });

  it('should use getNewEntity when id === 0', (done) => {
    // MODIFICAR: Datos de entidad nueva
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
    // MODIFICAR: Datos de catálogo
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

### 8. Propagación de Errores

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

### 9. Configuración de Grid (si aplica)

```typescript
describe('Grid Configuration', () => {
  it('should build grid config with correct filters and columns', () => {
    // MODIFICAR: Templates mock según el servicio
    // ⚠️ IMPORTANTE: Usar `any` para evitar errores de TemplateRef en tests unitarios
    const templates: any = {
      addButtonTemplate: {},
      noRecordsTemplate: {},
      refreshGridTemplate: {},
      titleGridTemplate: {}
    };

    // MODIFICAR: Parámetros según el servicio
    const config = service.buildGridConfig(entityId, templates, false);

    expect(config.idGrid).toBeTruthy();
    expect(config.state.filter.filters).toContain(jasmine.objectContaining({ field: 'entityId', value: entityId }));

    const columnFields = config.columns.map((c: any) => c.field);
    // MODIFICAR: Columnas esperadas
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
    // ⚠️ IMPORTANTE: Castear a `any` para acceder a propiedades opcionales
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
    // ⚠️ Castear para acceder a propiedades que pueden ser boolean | ClSortableSettings
    expect((config.sortable as any).mode).toBe('multiple');
    expect((config.sortable as any).allowUnsort).toBeTrue();
  });

  it('should configure filterable settings', () => {
    const templates: any = {
      /* templates mock */
    };
    const config = service.buildGridConfig(entityId, templates);

    // ⚠️ Castear para acceder a propiedades que pueden ser boolean | ClFilterableSettings
    expect((config.filterable as any).hideToolbarFilter).toBeTrue();
    expect((config.filterable as any).hideSearcherFilter).toBeTrue();
  });

  it('should load grid data with kendo filter', (done) => {
    // ⚠️ IMPORTANTE: Castear state a `any` para evitar errores de tipo con getAllKendoFilter
    const mockState: any = { skip: 0, take: 10, filter: { filters: [] } };

    // MODIFICAR: Resultado esperado usando constructor NSwag
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
    // MODIFICAR: Estructura del state según el servicio
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

### 10. Control de Acceso

```typescript
describe('Access Control', () => {
  it('should hide edition when no access', () => {
    accessServiceSpy.maestroViajesModificacion.and.returnValue(false);

    // MODIFICAR: Método de construcción de modal
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

### 11. Búsquedas y Filtros

```typescript
describe('Search and Filters', () => {
  it('should search items by filter', (done) => {
    // MODIFICAR: Datos de búsqueda
    const results = [{ id: 1, name: 'Match 1' }];
    apiClientSpy.getAllKendoFilter.and.returnValue(of({ list: results, count: 1 } as any));

    service.searchItems('query').subscribe((res) => {
      expect(res.length).toBe(1);
      expect(apiClientSpy.getAllKendoFilter).toHaveBeenCalled();
      done();
    });
  });

  it('should filter results by condition', () => {
    // MODIFICAR: Lógica de filtro
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

### 12. Concurrencia (Opcional pero Recomendado)

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

## Patrones Importantes

### Done Callback para Tests Async

```typescript
it('should test async operation', (done) => {
  serviceSpy.method.and.returnValue(of(data));

  service.operation().subscribe((result) => {
    expect(result).toBeDefined();
    done();
  });
});
```

### Encadenamiento de Tests con Done

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

### Error Handling con Subscribe

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

## Problemas Comunes y Soluciones

| Problema                                    | Solución                                                                                                         |
| ------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| **Done not called**                         | Asegurarse de llamar `done()` en TODOS los paths (success y error)                                               |
| **Spy not called**                          | Verificar que el spy está configurado con `and.returnValue()`                                                    |
| **FormBuilder undefined**                   | Incluir `FormBuilder` en providers de TestBed                                                                    |
| **Validator no funciona**                   | Asegurarse que el validator devuelve `null` cuando es válido                                                     |
| **Observable no completa**                  | Usar `of()` o `throwError()` que completan automáticamente                                                       |
| **Multiple calls fallan**                   | Usar `and.returnValues()` en lugar de `and.returnValue()`                                                        |
| **Error tipo mock NSwag**                   | Usar `new ModelClassName({...})` en lugar de `{...} as ModelClassName`                                           |
| **Error tipo de propiedad**                 | Verificar tipos en `apiClients.ts` - ej: `idExterno` puede ser `number` no `string`                              |
| **EventEmitter import error**               | `EventEmitter` está en `@angular/core`, NO en `rxjs`                                                             |
| **Import no usado**                         | Eliminar imports no utilizados - verificar warnings de TypeScript                                                |
| **Spy no funciona en tests de componentes** | Si el servicio está en `providers` del componente, usar `overrideComponent` (ver prompt de componentes)          |
| **TemplateRef error en mocks**              | Usar `const templates: any = {...}` para evitar errores de TemplateRef en tests de servicios                     |
| **Acceso a propiedades opcionales**         | Castear a `any` cuando la propiedad puede ser `boolean \| ClSettings` (ej: `(config.pageable as any).pageSizes`) |
| **Error tipo en getAllKendoFilter**         | Castear state a `any`: `const mockState: any = { skip: 0, take: 10 }`                                            |

---
