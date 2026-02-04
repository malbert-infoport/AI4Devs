# TASK-002-FE: Implementar grid de organizaciones con Kendo UI y columnas calculadas

=============================================================
**TICKET ID:** TASK-002-FE  
**EPIC:** Gestión del Portfolio de Organizaciones Clientes  
**USER STORY:** US-004 - Listar organizaciones con filtros  
**COMPONENT:** Frontend - Angular  
**PRIORITY:** Alta  
**ESTIMATION:** 5 horas  
=============================================================

## TÍTULO
Implementar listado de organizaciones con Kendo Grid, columnas calculadas y acciones contextuales

## DESCRIPCIÓN
Crear componente de listado de organizaciones usando Kendo UI Grid con las siguientes características:

**Columnas del grid:**
1. **SecurityCompanyId** - ID de negocio (número)
2. **Nombre** - Nombre de la organización
3. **CIF** - Código fiscal
4. **Email** - Email de contacto
5. **Teléfono** - Teléfono de contacto
6. **Grupo** - Nombre del grupo (lookup desde FK)
7. **Nº Apps** - Count de aplicaciones distintas (AppCount desde vista)
8. **Nº Módulos** - Count de módulos asignados (ModuleCount desde vista)
9. **Acciones** - Botones contextual (editar, dar de baja/alta)

**Indicadores visuales:**
- **Fila naranja** (warning): ModuleCount = 0 y AuditDeletionDate = null (pendiente de configuración)
- **Fila gris** (disabled): AuditDeletionDate != null (dada de baja)
- **Fila normal** (white/default): ModuleCount > 0 y AuditDeletionDate = null (activa)

**Filtros:**
- **Estado**: Todas / Dadas de alta / Dadas de baja
- **Búsqueda**: Texto libre por nombre o CIF
- **Grupo**: Dropdown con grupos disponibles

**Acciones contextuales (botón "..."):**
- Se permite editar directamente haciendo doble clic sobre la fila. En ese caso el componente invoca el endpoint genérico `GetById` para cargar los datos de la entidad y posteriormente abre la vista/route de detalle (`/organizations/:id`).
- Dar de baja (solo si está dada de alta, requiere SecurityManager)
- Dar de alta (solo si está dada de baja, requiere SecurityManager, modal con validación ModuleCount > 0)

## CONTEXTO TÉCNICO
- **Grid**: Kendo UI Grid para Angular con paginación server-side
- **Datos**: Consulta a vista VW_ORGANIZATION (TASK-001-VIEW) para obtener ModuleCount y AppCount
- **Filtros**: El grid envía un objeto `KendoFilter` (Telerik) en el body de la petición al endpoint genérico Helix6 `GetAllKendoFilter` usando el verbo HTTP `PUT`. El backend se encarga de la paginación, ordenación y filtrado según el `KendoFilter` recibido.
- **Paginación**: 20 registros por página por defecto
- **Row styling**: Conditional class binding basado en estado

## CRITERIOS DE ACEPTACIÓN TÉCNICOS
- [ ] Kendo Grid implementado con 9 columnas especificadas
- [ ] Paginación server-side configurada (20 items por página)
- [ ] Columnas ModuleCount y AppCount vinculadas a vista backend
- [ ] Indicadores visuales por estado (naranja/gris/default)
- [ ] Filtro por estado (alta/baja) funcional
- [ ] Búsqueda por texto (nombre/CIF) funcional
- [ ] Filtro por grupo funcional
- [ ] Acciones contextuales implementadas con modal de confirmación
- [ ] Tests unitarios de lógica de filtros
- [ ] Tests de row styling condicional

## GUÍA DE IMPLEMENTACIÓN

### Paso 1: Crear Componente de Listado

Archivo: `src/app/modules/organizations/components/organization-list/organization-list.component.ts`

```typescript
import { Component, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, Router } from '@angular/router';
import { ReactiveFormsModule, FormBuilder, FormGroup } from '@angular/forms';
import { GridModule, PageChangeEvent } from '@progress/kendo-angular-grid';
import { DropDownsModule } from '@progress/kendo-angular-dropdowns';
import { InputsModule } from '@progress/kendo-angular-inputs';
import { ButtonsModule } from '@progress/kendo-angular-buttons';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatMenuModule } from '@angular/material/menu';
import { MatDialog } from '@angular/material/dialog';
import { MatSnackBar } from '@angular/material/snack-bar';
import { OrganizationService } from '../../services/organization.service';
import { AuthService } from '@app/services/auth.service';
import { ConfirmDialogComponent } from '@shared/components/confirm-dialog/confirm-dialog.component';
import { debounceTime, distinctUntilChanged } from 'rxjs/operators';

interface OrganizationListItem {
  id: number;
  securityCompanyId: number;
  name: string;
  cif: string;
  contactEmail: string;
  contactPhone: string;
  groupName?: string;
  appCount: number;
  moduleCount: number;
  auditDeletionDate?: Date;
}

@Component({
  selector: 'app-organization-list',
  standalone: true,
  imports: [
    CommonModule,
    RouterModule,
    ReactiveFormsModule,
    GridModule,
    DropDownsModule,
    InputsModule,
    ButtonsModule,
    MatIconModule,
    MatButtonModule,
    MatMenuModule
  ],
  templateUrl: './organization-list.component.html',
  styleUrls: ['./organization-list.component.scss']
})
export class OrganizationListComponent implements OnInit {
  organizations = signal<OrganizationListItem[]>([]);
  total = signal(0);
  loading = signal(false);
  
  filterForm!: FormGroup;
  
  // Configuración del grid
  pageSize = 20;
  skip = 0;
  
  // Opciones de filtros
  statusOptions = [
    { value: 'all', label: 'Todas' },
    { value: 'active', label: 'Dadas de alta' },
    { value: 'inactive', label: 'Dadas de baja' }
  ];
  
  groups = signal<any[]>([]);
  
  isSecurityManager = signal(false);

  constructor(
    private fb: FormBuilder,
    private organizationService: OrganizationService,
    private authService: AuthService,
    private router: Router,
    private dialog: MatDialog,
    private snackBar: MatSnackBar
  ) {}


  ngOnInit(): void {
    this.isSecurityManager.set(this.authService.hasRole('SecurityManager'));
    this.initFilterForm();
    this.loadOrganizations();
    this.loadGroups();
    this.setupFilterListeners();
  }

  private initFilterForm(): void {
    this.filterForm = this.fb.group({
      status: ['all'],
      search: [''],
      groupId: [null]
    });
  }

  private setupFilterListeners(): void {
    // Filtro de búsqueda con debounce
    this.filterForm.get('search')?.valueChanges
      .pipe(
        debounceTime(300),
        distinctUntilChanged()
      )
      .subscribe(() => {
        this.skip = 0; // Reset pagination
        this.loadOrganizations();
      });
    
    // Otros filtros sin debounce
    this.filterForm.get('status')?.valueChanges.subscribe(() => {
      this.skip = 0;
      this.loadOrganizations();
    });
    
    this.filterForm.get('groupId')?.valueChanges.subscribe(() => {
      this.skip = 0;
      this.loadOrganizations();
    });
  }

  private loadOrganizations(): void {
    this.loading.set(true);
    
    const filters = this.filterForm.value;
    
    this.organizationService.getAll({
      skip: this.skip,
      take: this.pageSize,
      status: filters.status,
      search: filters.search,
      groupId: filters.groupId
    }).subscribe({
      next: (response) => {
        this.organizations.set(response.data);
        this.total.set(response.total);
        this.loading.set(false);
      },
      error: (err) => {
        console.error('Error al cargar organizaciones', err);
        this.loading.set(false);
      }
    });
  }

  private loadGroups(): void {
    this.organizationService.getGroups().subscribe({
      next: (groups) => this.groups.set(groups),
      error: (err) => console.error('Error al cargar grupos', err)
    });
  }

  onPageChange(event: PageChangeEvent): void {
    this.skip = event.skip;
    this.loadOrganizations();
  }

  onRowDoubleClick(event: any): void {
    const org = event?.dataItem as OrganizationListItem;
    if (!org || !org.id) {
      return;
    }

    this.loading.set(true);

    this.organizationService.getById(org.id).subscribe({
      next: (view) => {
        this.loading.set(false);
        this.router.navigate(['/organizations', org.id], { state: { view } });
      },
      error: (err) => {
        this.loading.set(false);
        this.snackBar.open('Error al cargar la organización', 'Cerrar', {
          duration: 5000,
          panelClass: ['error-snackbar']
        });
      }
    });
  }

  onClearFilters(): void {
    this.filterForm.reset({
      status: 'all',
      search: '',
      groupId: null
    });
    this.skip = 0;
    this.loadOrganizations();
  }

  // Lógica de row styling condicional
  getRowClass = (context: any): string => {
    const org = context.dataItem as OrganizationListItem;
    
    if (org.auditDeletionDate) {
      return 'row-inactive'; // Gris
    }
    
    if (org.moduleCount === 0) {
      return 'row-pending'; // Naranja
    }
    
    return ''; // Default (blanco)
  };

  isDadaDeBaja(org: OrganizationListItem): boolean {
    return !!org.auditDeletionDate;
  }

  canDeactivate(org: OrganizationListItem): boolean {
    return this.isSecurityManager() && !this.isDadaDeBaja(org);
  }

  canReactivate(org: OrganizationListItem): boolean {
    return this.isSecurityManager() && this.isDadaDeBaja(org);
  }

  onDeactivate(org: OrganizationListItem): void {
    const dialogRef = this.dialog.open(ConfirmDialogComponent, {
      data: {
        title: 'Dar de baja organización',
        message: `¿Está seguro de dar de baja "${org.name}"? Los usuarios perderán acceso inmediatamente.`,
        confirmText: 'Dar de baja',
        type: 'danger'
      }
    });

    dialogRef.afterClosed().subscribe((confirmed) => {
      if (confirmed) {
        this.organizationService.deactivate(org.id).subscribe({
          next: () => {
            this.snackBar.open('Organización dada de baja correctamente', 'Cerrar', {
              duration: 3000
            });
            this.loadOrganizations(); // Recargar grid
          },
          error: (err) => {
            this.snackBar.open('Error al dar de baja', 'Cerrar', {
              duration: 5000,
              panelClass: ['error-snackbar']
            });
          }
        });
      }
    });
  }

  onReactivate(org: OrganizationListItem): void {
    // Validar ModuleCount > 0
    if (org.moduleCount === 0) {
      this.snackBar.open(
        'No se puede dar de alta una organización sin módulos asignados',
        'Cerrar',
        { duration: 7000, panelClass: ['error-snackbar'] }
      );
      return;
    }

    const dialogRef = this.dialog.open(ConfirmDialogComponent, {
      data: {
        title: 'Dar de alta organización',
        message: `¿Confirma reactivar "${org.name}"? Los usuarios recuperarán acceso.`,
        confirmText: 'Dar de alta',
        type: 'warning'
      }
    });

    dialogRef.afterClosed().subscribe((confirmed) => {
      if (confirmed) {
        this.organizationService.reactivate(org.id).subscribe({
          next: () => {
            this.snackBar.open('Organización dada de alta correctamente', 'Cerrar', {
              duration: 3000
            });
            this.loadOrganizations();
          },
          error: (err) => {
            this.snackBar.open('Error al dar de alta', 'Cerrar', {
              duration: 5000,
              panelClass: ['error-snackbar']
            });
          }
        });
      }
    });
  }
}
```

### Paso 2: Template HTML

Archivo: `src/app/modules/organizations/components/organization-list/organization-list.component.html`

```html
<div class="organization-list-container">
  <div class="list-header">
    <h1>Organizaciones Clientes</h1>
    <button mat-raised-button color="primary" routerLink="/organizations/new">
      <mat-icon>add</mat-icon>
      Nueva Organización
    </button>
  </div>

  <!-- Filtros -->
  <div class="filters-panel" [formGroup]="filterForm">
    <mat-form-field appearance="outline">
      <mat-label>Estado</mat-label>
      <mat-select formControlName="status">
        <mat-option *ngFor="let status of statusOptions" [value]="status.value">
          {{ status.label }}
        </mat-option>
      </mat-select>
    </mat-form-field>

    <mat-form-field appearance="outline" class="search-field">
      <mat-label>Buscar</mat-label>
      <input matInput formControlName="search" placeholder="Nombre o CIF...">
      <mat-icon matPrefix>search</mat-icon>
    </mat-form-field>

    <mat-form-field appearance="outline">
      <mat-label>Grupo</mat-label>
      <mat-select formControlName="groupId">
        <mat-option [value]="null">Todos</mat-option>
        <mat-option *ngFor="let group of groups()" [value]="group.id">
          {{ group.name }}
        </mat-option>
      </mat-select>
    </mat-form-field>

    <button mat-button (click)="onClearFilters()">
      <mat-icon>clear</mat-icon>
      Limpiar filtros
    </button>
  </div>

  <!-- Grid Kendo -->
  <kendo-grid
    [data]="organizations()"
    [pageSize]="pageSize"
    [skip]="skip"
    [pageable]="true"
    [loading]="loading()"
    [rowClass]="getRowClass"
    (pageChange)="onPageChange($event)"
    (rowDblClick)="onRowDoubleClick($event)">
    
    <kendo-grid-column field="securityCompanyId" title="ID Empresa" [width]="120">
    </kendo-grid-column>

    <kendo-grid-column field="name" title="Nombre" [width]="250">
    </kendo-grid-column>

    <kendo-grid-column field="cif" title="CIF" [width]="120">
    </kendo-grid-column>

    <kendo-grid-column field="contactEmail" title="Email" [width]="200">
    </kendo-grid-column>

    <kendo-grid-column field="contactPhone" title="Teléfono" [width]="140">
    </kendo-grid-column>

    <kendo-grid-column field="groupName" title="Grupo" [width]="150">
      <ng-template kendoGridCellTemplate let-dataItem>
        {{ dataItem.groupName || '-' }}
      </ng-template>
    </kendo-grid-column>

    <kendo-grid-column field="appCount" title="Nº Apps" [width]="100">
      <ng-template kendoGridCellTemplate let-dataItem>
        <span class="count-badge">{{ dataItem.appCount }}</span>
      </ng-template>
    </kendo-grid-column>

    <kendo-grid-column field="moduleCount" title="Nº Módulos" [width]="110">
      <ng-template kendoGridCellTemplate let-dataItem>
        <span 
          class="count-badge"
          [class.count-warning]="dataItem.moduleCount === 0">
          {{ dataItem.moduleCount }}
        </span>
      </ng-template>
    </kendo-grid-column>

    <kendo-grid-column title="Acciones" [width]="100">
      <ng-template kendoGridCellTemplate let-dataItem>
        <button 
          mat-icon-button 
          [matMenuTriggerFor]="menu"
          [matMenuTriggerData]="{org: dataItem}">
          <mat-icon>more_vert</mat-icon>
        </button>
      </ng-template>
    </kendo-grid-column>

    <!-- Paginador -->
    <ng-template kendoPagerTemplate let-totalPages="totalPages" let-currentPage="currentPage">
      <kendo-pager-info></kendo-pager-info>
      <kendo-pager-page-sizes [pageSizes]="[10, 20, 50, 100]"></kendo-pager-page-sizes>
      <kendo-pager-prev-buttons></kendo-pager-prev-buttons>
      <kendo-pager-numeric-buttons [buttonCount]="5"></kendo-pager-numeric-buttons>
      <kendo-pager-next-buttons></kendo-pager-next-buttons>
    </ng-template>
  </kendo-grid>
</div>

<!-- Menú contextual -->
<mat-menu #menu="matMenu">
  <ng-template matMenuContent let-org="org">
    <button mat-menu-item [routerLink]="['/organizations', org.id]">
      <mat-icon>edit</mat-icon>
      Editar
    </button>
    
    @if (canDeactivate(org)) {
      <button mat-menu-item (click)="onDeactivate(org)">
        <mat-icon>block</mat-icon>
        Dar de baja
      </button>
    }
    
    @if (canReactivate(org)) {
      <button mat-menu-item (click)="onReactivate(org)">
        <mat-icon>check_circle</mat-icon>
        Dar de alta
      </button>
    }
  </ng-template>
</mat-menu>
```

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
