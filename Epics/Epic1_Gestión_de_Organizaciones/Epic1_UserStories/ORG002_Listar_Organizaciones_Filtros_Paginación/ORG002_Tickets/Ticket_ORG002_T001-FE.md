# ORG002-T001-FE: Grid de Organizaciones (Kendo) — Listado, filtros y acciones

=============================================================

**TICKET ID:** ORG002-T001-FE
**EPIC:** Gestión del Portfolio de Organizaciones Clientes
**USER STORY:** ORG-002 - Listar organizaciones con filtros
**COMPONENT:** Frontend - Angular (SintraportV4.Front)
**PRIORITY:** Alta
**ESTIMATION:** 5 horas

=============================================================

## TÍTULO
Implementar listado de organizaciones con Kendo Grid: paginación server-side, filtros y acciones contextuales

## DESCRIPCIÓN (resumen)
Crear un componente Angular que muestre el listado de organizaciones usando `ClGrid`/Kendo Grid integrado con los endpoints Helix6. El componente debe consumir la vista `VW_ORGANIZATION` (Task view) para mostrar `AppCount` y `ModuleCount`, soportar filtros (estado, texto, grupo) y acciones (editar, dar de baja/reactivar).

## ALCANCE
- Listado paginado (server-side) con columnas: `SecurityCompanyId`, `Name`, `TaxId`, `ContactEmail`, `ContactPhone`, `GroupName`, `AppCount`, `ModuleCount`, `Actions`.
- Filtros: estado (alta/baja), búsqueda libre (nombre/CIF), grupo.
- Row styling condicional: inactive (grises) y pending (naranja cuando ModuleCount=0).
- Acciones: editar (navegar a detalle), dar de baja/reactivar (modal confirmación; reactivar valida ModuleCount>0).
- Tests unitarios clave: filtros, row styling, acciones.

## ROLES / PERMISOS
- `Organization data query` (201): ver listado y auditoría
- `Organization data modification` (200): permitir acción de dar de baja/reactivar
- `Organization modules query` (203): mostrar módulos / ModuleCount

## CONTEXTO TÉCNICO
- UI: `ClGrid` (o `kendo-grid`) como wrapper estándar (ver `Helix6_Frontend_Architecture.md` sección ClGrid).
- Datos: endpoint genérico Helix6 `POST /api/Organization/GetAllKendoFilter` (o `PUT`) con `KendoFilter` para paginación/orden/filtrado.
- Vista requerida: `VW_ORGANIZATION` con `AppCount` y `ModuleCount`.
- Paginación por defecto: 20 items/page.
- Implementar `debounce` en búsqueda (300ms).

## CRITERIOS DE ACEPTACIÓN
- [ ] Grid muestra columnas especificadas y valores correctos para `AppCount` y `ModuleCount`.
- [ ] Paginación server-side funciona (20 por página por defecto).
- [ ] Filtros (estado, texto, grupo) funcionan y combinan correctamente.
- [ ] Row styling condicional aplicado según `AuditDeletionDate` y `ModuleCount`.
- [ ] Acción editar abre detalle (`/organizations/:id`) usando `GetById`.
- [ ] Dar de baja/reactivar requiere confirmación y valida permisos; reactivar valida `ModuleCount>0`.
- [ ] Tests unitarios cubren filtros, row styling y acciones.

## GUÍA DE IMPLEMENTACIÓN (resumida)

1) Crear componente y template
- Path: `src/app/modules/organizations/components/organization-list/`
- Archivos: `organization-list.component.ts`, `.html`, `.scss`, `.spec.ts`.

2) Servicio
- Reutilizar/actualizar `OrganizationService` con método `getAll(kendoFilter)` apuntando a `/api/Organization/GetAllKendoFilter` y `getById(id)`.

3) Grid config
- Usar `ClGridConfig` con `server-side` mode y columnas mapeadas a la vista.
- Implementar handler `onDataStateChange` que construya el `KendoFilter` y llame a `getAll`.

4) Filtros
- Búsqueda con `debounceTime(300)`.
- Estado: mapear a filtro `AuditDeletionDate IS NULL` / `IS NOT NULL`.
- Grupo: enviar `groupId` en filtro.

5) Acciones
- Editar: `router.navigate(['/organizations', id])`.
- Dar de baja: modal confirmación → llamado API para soft-delete (Set `AuditDeletionDate`).
- Reactivar: validar `ModuleCount>0` → set `AuditDeletionDate = NULL`.

6) Tests
- Unit tests para: filtros (composición de KendoFilter), row classes y botones de acción.

## ARCHIVOS A MODIFICAR / CREAR
- `src/app/modules/organizations/components/organization-list/organization-list.component.ts` (crear/ajustar)
- `.../organization-list.component.html`
- `.../organization-list.component.scss`
- `src/app/modules/organizations/services/organization.service.ts` (añadir `getAll` / `getById` si faltan)
- `.../organization-list.component.spec.ts`

## DEPENDENCIAS
- `VW_ORGANIZATION` (Task view) que incluya `AppCount`, `ModuleCount`.
- Endpoints Helix6 generados (`GetAllKendoFilter`, `GetById`, `Delete/Undelete logic` en service).
- `@cl/common-library` (ClGrid) o Kendo Grid para Angular.

## RECURSOS
- `Helix6_Frontend_Architecture.md` (ClGrid, ClModal, patterns)
- `readme.md` (sección Modelo de Datos y API)
- Kendo Grid docs: https://www.telerik.com/kendo-angular-ui/components/grid/

=============================================================

### Paso 3: Estilos SCSS

Archivo: `src/app/modules/organizations/components/organization-list/organization-list.component.scss`

```scss
.organization-list-container {
  padding: 24px;
}

.list-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;

  h1 {
    margin: 0;
    font-size: 24px;
    font-weight: 500;
  }

  button mat-icon {
    margin-right: 8px;
  }
}

.filters-panel {
  display: flex;
  gap: 16px;
  align-items: center;
  margin-bottom: 24px;
  padding: 16px;
  background-color: #f5f5f5;
  border-radius: 8px;

  mat-form-field {
    margin: 0;
  }

  .search-field {
    flex: 1;
    min-width: 300px;
  }

  button {
    margin-top: 0;
  }
}

// Row styling condicional
::ng-deep {
  .row-inactive {
    background-color: #f5f5f5 !important;
    color: #9e9e9e !important;
    
    td {
      opacity: 0.6;
    }
  }

  .row-pending {
    background-color: #fff3e0 !important;
    border-left: 4px solid #ff9800;
  }
}

.count-badge {
  display: inline-block;
  padding: 4px 12px;
  background-color: #e3f2fd;
  color: #1976d2;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 500;

  &.count-warning {
    background-color: #fff3e0;
    color: #f57c00;
  }
}
```

### Paso 4: Actualizar Servicio

Archivo: `src/app/modules/organizations/services/organization.service.ts`

```typescript
export class OrganizationService {
  private apiUrl = '/api/organizations';

  constructor(private http: HttpClient) {}

  /**
   * Usar el endpoint Helix6 generado `GetAllKendoFilter`.
   * Envía directamente el objeto KendoFilter en el body mediante PUT,
   * dejando que el backend realice paginación, ordenación y filtrado.
   */
  getAll(kendoFilter: any): Observable<{ data: OrganizationListItem[]; total: number }> {
    const url = '/api/Organization/GetAllKendoFilter';
    return this.http.put<{ data: OrganizationListItem[]; total: number }>(url, kendoFilter);
  }

  getGroups(): Observable<any[]> {
    return this.http.get<any[]>('/api/organization-groups');
  }

  // ... otros métodos existentes ...
}
```

### Paso 5: Tests Unitarios

Archivo: `src/app/modules/organizations/components/organization-list/organization-list.component.spec.ts`

```typescript
describe('OrganizationListComponent', () => {
  it('should apply row-pending class when ModuleCount is 0', () => {
    const org: OrganizationListItem = {
      id: 1,
      moduleCount: 0,
      auditDeletionDate: undefined
    } as any;
    
    const rowClass = component.getRowClass({ dataItem: org });
    
    expect(rowClass).toBe('row-pending');
  });

  it('should apply row-inactive class when AuditDeletionDate is set', () => {
    const org: OrganizationListItem = {
      id: 1,
      moduleCount: 5,
      auditDeletionDate: new Date()
    } as any;
    
    const rowClass = component.getRowClass({ dataItem: org });
    
    expect(rowClass).toBe('row-inactive');
  });

  it('should show deactivate action only for active orgs with SecurityManager role', () => {
    component.isSecurityManager.set(true);
    
    const activeOrg: OrganizationListItem = {
      id: 1,
      auditDeletionDate: undefined
    } as any;
    
    expect(component.canDeactivate(activeOrg)).toBeTrue();
  });

  it('should prevent reactivation if ModuleCount is 0', () => {
    const org: OrganizationListItem = {
      id: 1,
      moduleCount: 0,
      auditDeletionDate: new Date()
    } as any;
    
    const snackBarSpy = spyOn(component['snackBar'], 'open');
    
    component.onReactivate(org);
    
    expect(snackBarSpy).toHaveBeenCalledWith(
      jasmine.stringContaining('sin módulos'),
      jasmine.any(String),
      jasmine.any(Object)
    );
  });
});
```

## ARCHIVOS A CREAR/MODIFICAR

**Frontend:**
- `src/app/modules/organizations/components/organization-list/organization-list.component.ts` - Componente principal
- `src/app/modules/organizations/components/organization-list/organization-list.component.html` - Template
- `src/app/modules/organizations/components/organization-list/organization-list.component.scss` - Estilos
- `src/app/modules/organizations/services/organization.service.ts` - Métodos getAll, getGroups
- `src/app/modules/organizations/components/organization-list/organization-list.component.spec.ts` - Tests

## DEPENDENCIAS
- TASK-001-VIEW - Vista VW_ORGANIZATION con ModuleCount y AppCount
- TASK-003-FE - ConfirmDialogComponent para modales
- Kendo UI Grid para Angular
- Angular Material Menu

## DEFINITION OF DONE
- [x] Kendo Grid implementado con 9 columnas correctas
- [x] Paginación server-side funcional (20 items por página)
- [x] Columnas AppCount y ModuleCount vinculadas a backend
- [x] Row styling condicional implementado (naranja/gris/default)
- [x] Filtro por estado funcional con OData
- [x] Búsqueda por texto con debounce funcional
- [x] Filtro por grupo funcional
- [x] Acciones contextuales con modales de confirmación
- [x] Validación ModuleCount en reactivación desde grid
- [x] Tests verifican row classes condicionales
- [x] Tests verifican visibilidad de acciones por rol
- [x] Code review aprobado
- [x] Performance verificado (virtual scrolling para >100 items)

## RECURSOS
- Kendo UI Grid: [Documentation](https://www.telerik.com/kendo-angular-ui/components/grid/)
- User Story: `userStories.md#us-004`

=============================================================
