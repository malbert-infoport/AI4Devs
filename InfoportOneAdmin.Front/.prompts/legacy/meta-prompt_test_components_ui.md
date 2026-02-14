## Instrucciones de Uso

### 1. Preparación

MODIFICAR: Pegar aquí el código del componente a testear

Dar contexto de archivos.

MODIFICAR: Pegar aquí el código de los servicios que inyecta

```typescript
// Código del/los servicios
```

### 2. Generación

Genera el archivo `[component-name].component.spec.ts` siguiendo esta estructura:

1. Incluir TODOS los imports necesarios
2. Crear mocks completos de formularios si el componente los usa
3. Configurar spies con valores de retorno por defecto
4. Inicializar @Inputs ANTES de `fixture.detectChanges()`
5. Implementar tests de:
   - Ciclo de vida
   - Formularios
   - Cambios en @Input
   - Eventos @Output
   - Grids (si aplica)
   - Permisos y Estados
   - Diálogos/Modales si aplica
6. Usar `fakeAsync`/`tick` para operaciones asíncronas
7. Verificar estados de loading en operaciones async
8. NO usar magic numbers, definir constantes descriptivas
9. Añadir comentarios en casos complejos

### 3. Validación

- Sin errores de compilación
- Todos los tests deben pasar
- Cobertura de riesgo alto y medio
- Código limpio y mantenible

---

## Notas Adicionales

MODIFICAR: Añadir información específica del componente

- Este componente tiene: [grid / dialog / búsqueda / etc.]
- Validaciones especiales: [describir si hay]
- Permisos críticos: [describir si hay]
- Otras consideraciones: [añadir si es necesario]

/\*
EJEMPLO REAL
\*/

/\*
Puedes obviar la inserción del código porque lo he incluido en el prompt padre. RECOMENDABLE añadirlo en componentes complejos.
\*/

## Instrucciones de Uso

### 1. Preparación

Contexto importante antes de realizar cualquier acción: #file:prompt_test_components_ui.md

Código del componente a testear

#file:equipamiento-dialog.component.ts
#file:equipamiento-dialog.component.html

Código de los servicios que inyecta

```typescript
  private readonly dialogRef = inject(DialogRef);
  private readonly cdRef = inject(ChangeDetectorRef);
  private readonly sharedMessageService = inject(SharedMessageService);
  private readonly translate = inject(TranslateService);
  private readonly accessService = inject(AccessService);
  private readonly dialogService = inject(DialogNavigationService);
  private readonly equipamientoDialogService = inject(EquipamientoDialogService);
```

```typescript
providers: [
  EquipamientoDialogService,
  DialogNavigationService,
  ViajeEquipamientoClient,
  TipoEquipamientoClient,
  ClasificacionContenedorClient,
  TipoCodigoISOClient
];
```

### 2. Generación

Genera el archivo `equipamiento-dialog.component.spec.ts` #file:equipamiento-dialog.component.spec.ts siguiendo esta estructura:

1. Incluir TODOS los imports necesarios
2. Crear mocks completos de formularios si el componente los usa
3. Configurar spies con valores de retorno por defecto
4. Inicializar @Inputs ANTES de `fixture.detectChanges()`
5. Implementar tests de:
   - Ciclo de vida
   - Formularios
   - Cambios en @Input
   - Eventos @Output
   - Grids (si aplica)
   - Permisos y Estados
   - Diálogos/Modales si aplica
6. Usar `fakeAsync`/`tick` para operaciones asíncronas
7. Verificar estados de loading en operaciones async
8. NO usar magic numbers, definir constantes descriptivas
9. Añadir comentarios en casos complejos

### 3. Validación

- Sin errores de compilación
- Todos los tests deben pasar
- Cobertura de riesgo alto y medio
- Código limpio y mantenible
