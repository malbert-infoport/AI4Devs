# Guía: Separación de Lógica UI y Lógica de Negocio mediante Servicios en Angular

## Índice

1. [Contexto y Objetivo](#contexto-y-objetivo)
2. [Arquitectura Recomendada](#arquitectura-recomendada)
3. [Buenas Prácticas](#buenas-prácticas)
4. [Proceso de Implementación](#proceso-de-implementación)
5. [Problemas Comunes y Soluciones](#problemas-comunes-y-soluciones)
6. [Checklist de Implementación](#checklist-de-implementación)
7. [Criterios de Decisión](#criterios-de-decisión)
8. [Patrones de Código](#patrones-de-código)

---

## 1. Contexto y Objetivo

### Justificación de la Separación UI y Lógica de Negocio

**Problema identificado:**

- Componentes con 400-530 líneas mezclando UI, lógica de negocio y llamadas API
- Dificultad para testear sin instanciar componentes completos
- Baja reutilización de lógica
- Alta complejidad cognitiva
- Dificultad en mantenimiento

**Objetivo de la arquitectura:**

Crear servicios que encapsulen:

- Configuración de grids y formularios
- Llamadas a API y transformaciones de datos
- Lógica de validación y negocio
- Preparación de datos para envío al backend

**Resultado esperado:**

- Componentes 50-60% más pequeños enfocados exclusivamente en UI
- Servicios testeables sin dependencias de Angular
- Lógica reutilizable entre componentes
- Código mantenible y comprensible

---

## 2. Arquitectura Recomendada

### Estructura de Carpetas (Co-Located Services)

```
[module]/
├── components/
│   └── [parent-component]/
│       ├── [feature]/
│       │   ├── components/          ← Componentes UI
│       │   │   ├── [feature]-dialog/
│       │   │   ├── [feature]-grid/
│       │   │   └── [sub-feature]/
│       │   ├── models/              ← Interfaces y tipos
│       │   │   ├── [feature].interface.ts
│       │   │   ├── [sub-feature].interface.ts
│       │   │   └── grid-templates.interface.ts
│       │   └── services/            ← Servicios del submódulo
│       │       ├── [feature]-grid.service.ts
│       │       ├── [feature]-dialog.service.ts
│       │       ├── [sub-feature]-grid.service.ts
│       │       └── [sub-feature]-dialog.service.ts
│       ├── [other-feature]/
│       │   ├── components/
│       │   ├── models/
│       │   └── services/
│       └── [another-feature]/
│           ├── components/
│           ├── models/
│           └── services/
└── services/                        ← Solo servicios compartidos
    ├── [module].service.ts
    ├── [module]-state.service.ts
    └── [module]-validators.service.ts
```

### Separación de Responsabilidades

#### **Grid Service** (Configuración + Datos)

```typescript
@Injectable()
export class [Feature]GridService {
  // Validaciones de negocio
  shouldDisableEdition(estado: number | null): boolean

  // Configuración de grid
  buildGridConfig(id: number, templates: IGridTemplates): ClGridConfig

  // Carga de datos
  loadEntities(state: any): Observable<GridDataResult>

  // Configuración de modales
  buildEntityModal(...): { config: ClModalConfig; inputs: Map }
}
```

#### **Dialog Service** (Formularios + Transformaciones)

```typescript
@Injectable()
export class [Feature]DialogService {
  // Carga de entidades
  loadEntity(id: number): Observable<IEntityView>

  // Carga de catálogos
  loadCatalog(): Observable<CatalogView[]>

  // Construcción de formularios
  buildEntityForm(entity, formData): FormGroup

  // Lógica de cambios
  handleFieldChange(form: FormGroup, item: any)

  // Preparación de datos
  prepareSubmitData(form: FormGroup): IEntitySubmit

  // Guardado
  saveEntity(data: ISubmit, ...): Observable<Entity>
}
```

#### **Componente** (Solo UI)

```typescript
@Component({
  providers: [[Feature]DialogService]  // Scope local
})
export class [Feature]DialogComponent implements OnInit {
  // Solo referencias al DOM
  @ViewChild templates
  @Input/@Output properties

  // Solo estado de UI
  loading: boolean
  showSection: boolean

  // Delegación al servicio
  ngOnInit() {
    this.service.loadEntity(this.id).subscribe(data => {
      this.form = this.service.buildEntityForm(data, ...);
    });
  }

  onSubmit() {
    const data = this.service.prepareSubmitData(this.form);
    this.service.saveEntity(data).subscribe(...);
  }
}
```

---

## Buenas Prácticas Aplicadas

### 1. **Principio SRP (Single Responsibility)**

- Cada servicio tiene UNA responsabilidad clara
- Grid Service: Configuración y datos de grid
- Dialog Service: Formularios y transformaciones
- Componente: Solo presentación e interacción

### 2. **Co-Located Services (Feature-First)**

- Servicios junto a los componentes que los usan
- Alta cohesión dentro del feature
- Bajo acoplamiento entre features
- Fácil encontrar código relacionado

### 3. **Inyección de Dependencias**

```typescript
// CORRECTO: Provisto a nivel componente
@Injectable()
export class [Feature]GridService {}

@Component({
  providers: [[Feature]GridService] // Nueva instancia por componente
})
// INCORRECTO: Singleton global innecesario
@Injectable({ providedIn: 'root' })
export class [Feature]GridService {}
```

### 4. **Interfaces: Verificar API Client Primero (Requisito Obligatorio)**

```typescript
// Paso 1: Debe verificarse primero si la interfaz existe en apiClients.ts
// Buscar: I[Entity]View

// Ejemplo: ITarifaRecargoDetalleView ya existe en API con todos los campos necesarios
import { ITarifaRecargoDetalleView } from '@restApi/api/apiClients';

// Patrón correcto: Usar interfaz del API directamente
prepareSubmitData(form: FormGroup): ITarifaRecargoDetalleView {
  return form.getRawValue() as ITarifaRecargoDetalleView;
}

// Antipatrón: Crear interfaz duplicada innecesaria
export interface ICondicionAplicadaRecargoSubmit {
  id: number;
  valorRecargo: number | null;
  // ... duplicando exactamente ITarifaRecargoDetalleView
}

// Paso 2: Si se necesitan campos adicionales, debe extenderse la interfaz del API
// models/[feature].interface.ts
import { ITarifaRecargoDetalleView } from '@restApi/api/apiClients';

export interface ICondicionAplicadaRecargoExtended extends ITarifaRecargoDetalleView {
  // Solo campos adicionales que no están en el API
  extraField?: string;
  computedValue?: number;
}

// Paso 3: Interfaces solo para casos específicos del frontend
// Formularios (datos temporales de UI)
export interface I[Feature]Form {
  tarifaRecargoId: number;
  orden: number;
}

// Templates (referencias del DOM)
export interface I[Feature]GridTemplates {
  noRecordsTemplate: any;
  conceptoTemplate: any;
}

// No está permitido duplicar interfaces del API
// Si I[Entity]View existe en apiClients.ts: debe utilizarse
// Si se necesitan campos extra: debe extenderse con extends
// Si es idéntica al API: debe eliminarse la custom y usar la del API
```

**Regla de implementación:**

> Antes de crear cualquier interfaz, debe buscarse en `apiClients.ts` si ya existe. En el 90% de los casos, la interfaz del API es suficiente.

### 5. **Tipado Fuerte**

```typescript
// Todos los métodos deben tener tipos explícitos
loadEntity(id: number): Observable<IEntityView>
prepareSubmitData(form: FormGroup): IEntitySubmit
buildGridConfig(parentId: number, templates: IGridTemplates): ClGridConfig
```

### 6. **RxJS Best Practices**

```typescript
// Devolver observables fríos (sin side-effects)
loadEquipamiento(id: number): Observable<IEntity> {
  return id > 0
    ? this.client.getById(id)
    : this.client.getNewEntity();
}

// Transformaciones con operadores
searchCodigosISO(input: string): Observable<any[]> {
  return this.client.getAllKendoFilter(...)
    .pipe(
      map(result => result.list.map(item => ({
        ...item,
        ...(item.refrigerado ? { identificarRefrigerado: '❄' } : {})
      })))
    );
}
```

### 7. **Documentación JSDoc**

```typescript
/**
 * Carga los datos de la entidad por ID o entidad nueva
 * @param id - ID de la entidad (0 para nuevo)
 * @returns Observable con los datos de la entidad
 */
loadEntity(id: number): Observable<IEntityView> { }
```

### 8. **Validadores Encapsulados**

```typescript
// Validadores en clase estática
export class [Feature]Validators {
  static fieldRequired(contextId: number): ValidatorFn {
    return (control: AbstractControl) => {
      if (contextId === SomeEnum['Value'] && !control.value) {
        return { required: true };
      }
      return null;
    };
  }
}

// Uso en servicio
buildForm(...): FormGroup {
  return this.fb.group({
    fieldName: [value, [
      [Feature]Validators.fieldRequired(contextId)
    ]]
  });
}
```

---

## Proceso de Implementación

### Paso 1: Analizar el Componente

```typescript
// ANTES: Componente de 400-530 líneas
export class [Feature]DialogComponent {
  // 150+ líneas de construcción de formulario
  buildForm() { ... }

  // 80+ líneas de transformación de datos
  prepareSubmitData() { ... }

  // 50+ líneas de lógica de cambios
  handleFieldChange() { ... }

  // Llamadas API directas
  this.entityClient.getById(...)
  this.entityClient.update(...)
}
```

### Paso 2: Identificar Responsabilidades

```
Lógica de Negocio/Datos (→ Servicio):
- Construcción de FormGroup
- Validaciones personalizadas
- Llamadas a API
- Transformación de datos (prepareSubmitData)
- Búsquedas y filtros
- Lógica de habilitación/deshabilitación de campos

Lógica UI (→ Componente):
- @ViewChild templates
- @Input/@Output
- Estado de UI (loading, showSection)
- Suscripciones a observables
- Actualización de vista (ChangeDetectorRef)
- Gestión de modales (DialogRef)
```

### Paso 3: Crear Interfaces en Models

```typescript
// models/[feature].interface.ts
export interface I[Feature]Form {
  id: number;
  parentId: number;
  contextTypeId: number;
  modeId: number;
}

export interface I[Feature]Submit {
  id: number;
  parentId: number;
  typeId: number | null;
  // ... todas las propiedades necesarias
}
```

### Paso 4: Crear el Servicio

```typescript
// services/[feature]-dialog.service.ts
import { I[Feature]Form, I[Feature]Submit } from '../models/[feature].interface';

@Injectable()
export class [Feature]DialogService {
  private readonly fb = inject(FormBuilder);
  private readonly client = inject([Entity]Client);

  loadEntity(id: number): Observable<I[Entity]View> {
    // Lógica movida del componente
  }

  buildEntityForm(entity, formData: I[Feature]Form): FormGroup {
    // Toda la construcción del formulario
  }

  prepareSubmitData(form: FormGroup): I[Feature]Submit {
    // Transformación de datos
  }

  saveEntity(data: I[Feature]Submit, ...): Observable<Entity> {
    // Llamada al API
  }
}
```

### Paso 5: Refactorizar el Componente

```typescript
// DESPUÉS: Componente de 150-200 líneas
@Component({
  providers: [[Feature]DialogService]  // Inyectar servicio
})
export class [Feature]DialogComponent implements OnInit {
  private readonly service = inject([Feature]DialogService);

  entityForm: FormGroup;
  loading: boolean = false;

  ngOnInit(): void {
    this.service.loadEntity(this.id)
      .pipe(take(1))
      .subscribe(entity => {
        // Delega al servicio
        this.entityForm = this.service.buildEntityForm(
          entity,
          { id: this.id, parentId: this.parentId, ... }
        );
      });
  }

  onSubmit(): void {
    // Delega al servicio
    const data = this.service.prepareSubmitData(this.entityForm);
    this.service.saveEntity(data, ...)
      .subscribe(...);
  }
}
```

---

## Problemas Comunes y Soluciones

### Problema 1: Interfaces Duplicadas

**Problema:**

```typescript
// INCORRECTO: Interface en servicio
export interface [Feature]SubmitData {}

// Podría duplicarse en otros lugares
```

**Solución:**

```typescript
// CORRECTO: Centralizar en models/
// models/[feature].interface.ts
export interface I[Feature]Submit {}

// Importar en servicio y componente
import { I[Feature]Submit } from '../models/[feature].interface';
```

### Problema 2: Nombres de Propiedades Inconsistentes

**Problema:**

```typescript
// ERROR: Template esperaba 'addButtonTemplate'
buildGridConfig(templates: IGridTemplates) {
  footerTemplate: templates.addButtonTemplate  // Espera esto
}

// Componente pasaba 'addEquipamientoTemplate'
this.service.buildGridConfig({
  addEquipamientoTemplate: this.addEquipamientoTemplate  // Error
});
```

**Solución:**

```typescript
// Usar nombres consistentes según la interface
this.service.buildGridConfig({
  addButtonTemplate: this.addEquipamientoTemplate // Correcto
});
```

### Problema 3: Decidir si Extraer Código Duplicado

**Problema:**

```typescript
// Duplicado en 3 servicios (2-4 líneas)
shouldDisableEdition(estado: number | null): boolean {
  return estado === StatusEnum['Completed'] ||
         estado === StatusEnum['Closed'];
}
```

**Análisis:**

- Solo 2 líneas de lógica
- Aparece en 3 lugares (no llega a 5)
- Lógica muy simple
- NO cambia frecuentemente

**Decisión:**

```
NO EXTRAER
Razón: La duplicación es más barata que crear dependencia común.
Crear un servicio común añadiría complejidad innecesaria.
```

### Problema 4: Código con Clientes Diferentes

**Problema:**

```typescript
// Feature A usa EntityAClient
buildGridEndpoints() {
  return { delete: (body) => this.entityAClient.deleteById(body.id) };
}

// Feature B usa EntityBClient
buildGridEndpoints() {
  return { delete: (body) => this.entityBClient.deleteById(body.id) };
}
```

**Decisión:**

```
NO EXTRAER
Razón: Cada servicio usa cliente diferente.
Extraer requeriría generics complejos o inyección dinámica.
La abstracción sería más compleja que el código original.
```

### Problema 5: FormGroup Complejo con Secciones Condicionales

**Problema:**

```typescript
// Feature tiene sección condicional compleja
toggleComplexSection() {
  if (show) {
    // Añadir FormGroup complejo
  } else {
    // Remover FormGroup
  }
}
```

**Solución:**

```typescript
// Encapsular en el servicio
export class [Feature]DialogService {
  toggleComplexSection(form: FormGroup, show: boolean): void {
    if (show) {
      const complexGroup = this.fb.group({
        // Construcción completa
      });
      form.setControl('complexSection', complexGroup);
    } else {
      form.removeControl('complexSection');
    }
  }
}

// Componente solo llama
toggleComplexSection() {
  this.showSection = !this.showSection;
  this.service.toggleComplexSection(this.form, this.showSection);
}
```

---

## Checklist de Implementación

### Antes de Crear el Servicio

- [ ] ¿El componente tiene **más de 200 líneas**?
- [ ] ¿Mezcla lógica de negocio con UI?
- [ ] ¿Tiene llamadas directas a API?
- [ ] ¿Construye FormGroups complejos?
- [ ] ¿Transforma datos antes de enviar al backend?
- [ ] ¿Es difícil de testear?

**Si 3+ respuestas son SÍ → Crear servicio**

### Durante la Creación

#### **1. Crear Interfaces en Models**

```typescript
// models/[feature].interface.ts
export interface I[Feature]Form { }
export interface I[Feature]Submit { }
```

#### **2. Crear el Servicio**

```typescript
@Injectable()
export class [Feature]Service {
  private readonly fb = inject(FormBuilder);
  private readonly client = inject([Feature]Client);

  // Métodos públicos documentados
  /**
   * Descripción del método
   */
  loadEntity(id: number): Observable<IEntity> { }
  buildForm(entity, formData: IForm): FormGroup { }
  prepareSubmitData(form: FormGroup): ISubmit { }
  saveEntity(data: ISubmit): Observable<Entity> { }

  // Métodos privados para encapsulación
  private buildSubForm(...): FormGroup { }
}
```

#### **3. Proveer el Servicio**

```typescript
@Component({
  providers: [[Feature]Service]  // ← A nivel componente
})
```

#### **4. Refactorizar el Componente**

```typescript
export class [Feature]Component {
  private readonly service = inject([Feature]Service);

  // Solo propiedades de UI
  form: FormGroup;
  loading: boolean;

  ngOnInit() {
    // Delegar al servicio
    this.service.loadEntity(this.id).subscribe(data => {
      this.form = this.service.buildForm(data, ...);
    });
  }

  onSubmit() {
    const data = this.service.prepareSubmitData(this.form);
    this.service.saveEntity(data).subscribe(...);
  }
}
```

### Después de la Refactorización

- [ ] ¿El componente tiene **50-60% menos líneas**?
- [ ] ¿El servicio es testeable sin Angular?
- [ ] ¿Las interfaces del API están siendo usadas directamente?
- [ ] ¿Solo se crearon interfaces para UI (Form/Templates)?
- [ ] ¿Se verificó que no hay interfaces duplicadas del API?
- [ ] ¿Los nombres son consistentes?
- [ ] ¿Hay documentación JSDoc?
- [ ] ¿Los tipos están correctos?

---

## Criterios de Decisión

### ¿Cuándo SÍ crear un Servicio Común?

```typescript
// Duplicación de 20+ líneas de lógica compleja
// Aparece en 5+ lugares con código idéntico
// Lógica que cambia frecuentemente y debe sincronizarse

// Ejemplo: Servicio de validación compleja compartida
@Injectable({ providedIn: 'root' })
export class ViajeValidatorsService {
  validateModoCreacion(modo: number): ValidationErrors | null {
    // 30+ líneas de lógica compleja
    // Usada en 8+ componentes
    // Cambia según reglas de negocio
  }
}
```

### ¿Cuándo NO crear un Servicio Común?

```typescript
// Duplicación de 1-10 líneas triviales
// Aparece en 2-3 lugares
// Cada caso usa clientes/contratos diferentes
// Lógica muy específica del contexto

// Ejemplo: Mantener duplicado
shouldDisableEdition(estado: number | null): boolean {
  return estado === EstadoTarificacionEs['Valorado'] ||
         estado === EstadoTarificacionEs['Facturado'];
}
```

### Principio Guía

> **"Duplication is far cheaper than the wrong abstraction"** - Sandi Metz
>
> La duplicación es mucho más barata que una abstracción incorrecta.

### Regla de Tres (Rule of Three)

1. **Primera vez:** Escribir el código inline
2. **Segunda vez:** Notar la duplicación, pero esperar
3. **Tercera vez:**
   - ¿Es **>20 líneas**? Considerar extraer
   - ¿Es **<10 líneas**? Mantener duplicado
   - ¿Usa **mismo cliente/contrato**? Extraer
   - ¿Usa **clientes diferentes**? NO extraer

---

## Métricas de Éxito

### Indicadores de Mejora Esperados

**Reducción de Código en Componentes:**

- Objetivo: 40-60% menos líneas en componentes
- Componentes Grid: Típicamente de 300-500 líneas a 150-250 líneas
- Componentes Dialog: Típicamente de 400-600 líneas a 150-250 líneas

**Mejora en Testabilidad:**

- Servicios testeables sin necesidad de TestBed o componentes Angular
- Tests unitarios más rápidos (sin necesidad de compilar templates)
- Mayor cobertura de código de lógica de negocio

**Mejora en Mantenibilidad:**

- Reducción de complejidad cognitiva por archivo
- Cambios de lógica de negocio sin tocar componentes
- Facilita identificación de responsabilidades

**Organización del Código:**

- Interfaces centralizadas en `models/`
- Servicios co-localizados con sus features
- Separación clara entre UI y lógica de negocio

### Cómo Medir el Impacto

**Antes de la Refactorización:**

1. Contar líneas de código del componente original
2. Identificar número de responsabilidades mezcladas (UI + API + validación + transformación)
3. Evaluar dificultad para testear (¿requiere TestBed completo?)

**Después de la Refactorización:**

1. Comparar líneas de código: componente refactorizado vs original
2. Verificar separación: ¿componente solo tiene UI? ¿servicio solo tiene lógica?
3. Evaluar testabilidad: ¿servicio testeable sin Angular?
4. Contar interfaces creadas/centralizadas en `models/`

**Criterios de evaluación:**

- Reducción de 50%+ en líneas de componente: Excelente
- Reducción de 30-50% en líneas de componente: Bueno
- Reducción de <30%: Revisar si había suficiente lógica para extraer
- 0 interfaces duplicadas del API: Excelente
- Más de 2 interfaces duplicadas: Debe revisarse apiClients.ts

---

## Lecciones Aprendidas

### 1. La Duplicación Controlada es Aceptable

- 2-3 líneas de lógica duplicadas en 3 servicios es preferible a crear abstracción compleja
- Cada servicio es independiente y puede evolucionar sin afectar a otros
- Es más comprensible tener todo en un lugar que navegar entre archivos

### 2. Interfaces Centralizadas son Clave

- Una sola fuente de verdad
- Facilita refactorizaciones
- Evita duplicaciones y desincronizaciones

### 3. Scope de Servicios es Relevante

- `providers: [Service]` a nivel componente para estado local
- `providedIn: 'root'` solo para servicios realmente globales
- Evita fugas de estado entre instancias

### 4. Nombrar Consistentemente

- Servicios: `[Feature][Purpose]Service` (ejemplo: `EquipamientoGridService`)
- Propiedades de templates: Usar nombres de la interface

### 5. Documentar es Esencial

- JSDoc en todos los métodos públicos
- Comentarios inline para lógica compleja
- Interfaces documentadas con propósito claro

---

## Conclusión

La separación de lógica UI y lógica de negocio mediante servicios es una práctica fundamental para:

1. **Mejorar mantenibilidad** - Código más comprensible y modificable
2. **Facilitar testing** - Servicios testeables sin Angular
3. **Aumentar reutilización** - Lógica compartible entre componentes
4. **Reducir complejidad** - Componentes más pequeños y enfocados
5. **Escalar mejor** - Arquitectura preparada para crecer
6. **Garantizar consistencia de tipos** - Usar interfaces del API asegura sincronización con el backend

**Principios de implementación:**

> "No extraigas código duplicado prematuramente. La duplicación controlada es preferible a una abstracción incorrecta."

> "Debe verificarse apiClients.ts antes de crear interfaces. En el 90% de los casos, la interfaz del API ya existe y es suficiente."

**Flujo de trabajo para interfaces:**

```
1. Determinar si se necesita una interfaz
   ↓
2. Buscar en apiClients.ts: I[Entity]View
   ↓
3a. Existe y contiene todos los campos necesarios:
    Debe utilizarse directamente
   ↓
3b. Existe pero faltan campos específicos:
    Debe extenderse con extends
   ↓
3c. No existe en el API:
    Debe crearse solo si es para UI (Form/Templates)
```

**Checklist de validación final:**

- [ ] Componente reducido 40-60%
- [ ] Servicios testeables sin Angular
- [ ] Interfaces del API usadas directamente
- [ ] 0 interfaces duplicadas del API
- [ ] Solo interfaces custom para UI
- [ ] Documentación JSDoc completa
- [ ] Tipos correctos en todos los métodos
