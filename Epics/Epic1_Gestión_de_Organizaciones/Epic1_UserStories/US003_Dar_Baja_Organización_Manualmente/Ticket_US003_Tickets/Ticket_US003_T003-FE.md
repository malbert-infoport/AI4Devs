# TASK-003-FE: Implementar botones de baja/alta con modales de confirmación

=============================================================
**TICKET ID:** TASK-003-FE  
**EPIC:** Gestión del Portfolio de Organizaciones Clientes  
**USER STORY:** US-003 - Dar de baja/alta organización  
**COMPONENT:** Frontend - Angular  
**PRIORITY:** Alta  
**ESTIMATION:** 4 horas  
=============================================================

## TÍTULO
Implementar botones de baja/alta manual con modales de confirmación y validaciones

## DESCRIPCIÓN
Crear componentes para dar de baja y alta organizaciones con modales de confirmación obligatorios. Los botones están disponibles desde:

1. **Ficha de organización** (en header del formulario)
2. **Grid de organizaciones** (acción contextual)

**Botón "Dar de baja":**
- Visible solo si: Organización está dada de alta (AuditDeletionDate == null)
- Disponible para: SecurityManager
- Modal de confirmación con warning visual
- Texto: "¿Está seguro de dar de baja esta organización? Los usuarios perderán acceso inmediatamente."
- Acción: POST /organizations/{id}/deactivate

**Botón "Dar de alta":**
- Visible solo si: Organización está dada de baja (AuditDeletionDate != null)
- Disponible para: SecurityManager
- Validación: ModuleCount > 0 (si no, mostrar error descriptivo)
- Modal de confirmación
- Texto: "¿Confirma reactivar esta organización? Los usuarios recuperarán acceso."
- Acción: POST /organizations/{id}/reactivate

**Estados visuales:**
- Dada de baja: Chip gris con icono block
- Dada de alta SIN módulos: Chip naranja con icono warning ("Pendiente de configuración")
- Dada de alta CON módulos: Chip verde con icono check_circle ("Activa")

## CONTEXTO TÉCNICO
- **Modales**: Angular Material Dialog
- **Confirmación**: Componente reutilizable ConfirmDialogComponent
- **Roles**: SecurityManager exclusivamente
- **Validación**: ModuleCount desde vista VW_ORGANIZATION
- **Feedback**: Snackbar para éxito/error

## CRITERIOS DE ACEPTACIÓN TÉCNICOS
- [ ] Botón "Dar de baja" visible solo si org está dada de alta
- [ ] Botón "Dar de alta" visible solo si org está dada de baja
- [ ] Ambos botones solo visibles para SecurityManager
- [ ] Modal de confirmación obligatorio para ambas acciones
- [ ] Validación ModuleCount > 0 en alta con mensaje de error descriptivo
- [ ] Estados visuales implementados (gris/naranja/verde)
- [ ] Componente ConfirmDialogComponent reutilizable creado
- [ ] Tests unitarios de visibilidad de botones por estado y rol
- [ ] Tests de validación ModuleCount en alta
- [ ] Tests de integración de modales

## GUÍA DE IMPLEMENTACIÓN

### Paso 1: Crear Componente de Confirmación Reutilizable

Archivo: `src/app/shared/components/confirm-dialog/confirm-dialog.component.ts`

```typescript
import { Component, Inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatDialogModule, MAT_DIALOG_DATA, MatDialogRef } from '@angular/material/dialog';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';

export interface ConfirmDialogData {
  title: string;
  message: string;
  confirmText?: string;
  cancelText?: string;
  type?: 'warning' | 'danger' | 'info';
}

@Component({
  selector: 'app-confirm-dialog',
  standalone: true,
  imports: [CommonModule, MatDialogModule, MatButtonModule, MatIconModule],
  template: `
    <h2 mat-dialog-title>
      <mat-icon [class]="'icon-' + data.type">
        {{ getIcon() }}
      </mat-icon>
      {{ data.title }}
    </h2>
    
    <mat-dialog-content>
      <p>{{ data.message }}</p>
    </mat-dialog-content>
    
    <mat-dialog-actions align="end">
      <button mat-button (click)="onCancel()">
        {{ data.cancelText || 'Cancelar' }}
      </button>
      <button 
        mat-raised-button 
        [color]="data.type === 'danger' ? 'warn' : 'primary'"
        (click)="onConfirm()">
        {{ data.confirmText || 'Confirmar' }}
      </button>
    </mat-dialog-actions>
  `,
  styles: [`
    h2 {
      display: flex;
      align-items: center;
      gap: 12px;
    }
    
    .icon-warning { color: #ff9800; }
    .icon-danger { color: #f44336; }
    .icon-info { color: #2196f3; }
    
    mat-dialog-content {
      padding: 20px 0;
    }
  `]
})
export class ConfirmDialogComponent {
  constructor(
    public dialogRef: MatDialogRef<ConfirmDialogComponent>,
    @Inject(MAT_DIALOG_DATA) public data: ConfirmDialogData
  ) {
    // Establecer valores por defecto
    this.data.type = this.data.type || 'info';
  }

  getIcon(): string {
    switch (this.data.type) {
      case 'warning': return 'warning';
      case 'danger': return 'error';
      default: return 'info';
    }
  }

  onConfirm(): void {
    this.dialogRef.close(true);
  }

  onCancel(): void {
    this.dialogRef.close(false);
  }
}
```

### Paso 2: Agregar Botones al Formulario

Archivo: `src/app/modules/organizations/components/organization-form/organization-form.component.ts`

```typescript
// Agregar al componente existente

import { MatDialog } from '@angular/material/dialog';
import { MatSnackBar } from '@angular/material/snack-bar';
import { ConfirmDialogComponent } from '@shared/components/confirm-dialog/confirm-dialog.component';

export class OrganizationFormComponent implements OnInit {
  // ... propiedades existentes ...
  
  isSecurityManager = computed(() => this.authService.hasRole('SecurityManager'));
  isDadaDeBaja = computed(() => !!this.currentOrganization()?.auditDeletionDate);
  
  canDeactivate = computed(() => 
    this.isSecurityManager() && 
    !this.isDadaDeBaja() && 
    this.isEditMode()
  );
  
  canReactivate = computed(() => 
    this.isSecurityManager() && 
    this.isDadaDeBaja() && 
    this.isEditMode()
  );

  constructor(
    // ... otros inyectables ...
    private dialog: MatDialog,
    private snackBar: MatSnackBar
  ) {}

  onDeactivateOrganization(): void {
    const dialogRef = this.dialog.open(ConfirmDialogComponent, {
      data: {
        title: 'Dar de baja organización',
        message: '¿Está seguro de dar de baja esta organización? Los usuarios perderán acceso a todas las aplicaciones inmediatamente.',
        confirmText: 'Dar de baja',
        cancelText: 'Cancelar',
        type: 'danger'
      }
    });

    dialogRef.afterClosed().subscribe((confirmed: boolean) => {
      if (confirmed) {
        this.organizationService.deactivate(this.organizationId()!).subscribe({
          next: () => {
            this.snackBar.open(
              'Organización dada de baja correctamente',
              'Cerrar',
              { duration: 3000 }
            );
            
            // Recargar datos para actualizar estado visual
            this.loadOrganization();
          },
          error: (err) => {
            this.snackBar.open(
              'Error al dar de baja la organización',
              'Cerrar',
              { duration: 5000, panelClass: ['error-snackbar'] }
            );
          }
        });
      }
    });
  }

  onReactivateOrganization(): void {
    // Primero validar ModuleCount > 0
    if (this.moduleCount() === 0) {
      this.snackBar.open(
        'No se puede dar de alta una organización sin módulos asignados. Asigne al menos un módulo antes de reactivarla.',
        'Cerrar',
        { duration: 7000, panelClass: ['error-snackbar'] }
      );
      return;
    }

    const dialogRef = this.dialog.open(ConfirmDialogComponent, {
      data: {
        title: 'Dar de alta organización',
        message: '¿Confirma reactivar esta organización? Los usuarios recuperarán acceso a las aplicaciones.',
        confirmText: 'Dar de alta',
        cancelText: 'Cancelar',
        type: 'warning'
      }
    });

    dialogRef.afterClosed().subscribe((confirmed: boolean) => {
      if (confirmed) {
        this.organizationService.reactivate(this.organizationId()!).subscribe({
          next: () => {
            this.snackBar.open(
              'Organización dada de alta correctamente',
              'Cerrar',
              { duration: 3000 }
            );
            
            // Recargar datos
            this.loadOrganization();
          },
          error: (err) => {
            if (err.error?.includes('sin módulos')) {
              this.snackBar.open(
                'Error: La organización no tiene módulos asignados',
                'Cerrar',
                { duration: 7000, panelClass: ['error-snackbar'] }
              );
            } else {
              this.snackBar.open(
                'Error al reactivar la organización',
                'Cerrar',
                { duration: 5000, panelClass: ['error-snackbar'] }
              );
            }
          }
        });
      }
    });
  }
}
```

### Paso 3: Actualizar Template con Botones

Archivo: `src/app/modules/organizations/components/organization-form/organization-form.component.html`

```html
<!-- En el header del formulario -->
<div class="form-header">
  <div class="header-left">
    <h1>{{ isEditMode() ? 'Editar Organización' : 'Nueva Organización' }}</h1>
    
    @if (isEditMode()) {
      <!-- Estado visual -->
      @if (isDadaDeBaja()) {
        <mat-chip color="accent" selected class="status-chip-inactive">
          <mat-icon>block</mat-icon>
          Dada de baja
        </mat-chip>
      } @else {
        <mat-chip [color]="organizationStatus().color" selected>
          <mat-icon>{{ organizationStatus().icon }}</mat-icon>
          {{ organizationStatus().label }}
        </mat-chip>
      }
    }
  </div>

  <div class="header-actions">
    <!-- Botón Dar de baja -->
    @if (canDeactivate()) {
      <button 
        mat-raised-button 
        color="warn"
        (click)="onDeactivateOrganization()">
        <mat-icon>block</mat-icon>
        Dar de baja
      </button>
    }
    
    <!-- Botón Dar de alta -->
    @if (canReactivate()) {
      <button 
        mat-raised-button 
        color="primary"
        (click)="onReactivateOrganization()">
        <mat-icon>check_circle</mat-icon>
        Dar de alta
      </button>
    }
  </div>
</div>
```

### Paso 4: Actualizar Estilos

Archivo: `src/app/modules/organizations/components/organization-form/organization-form.component.scss`

```scss
.form-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;

  .header-left {
    display: flex;
    align-items: center;
    gap: 16px;

    h1 {
      margin: 0;
      font-size: 24px;
      font-weight: 500;
    }
  }

  .header-actions {
    display: flex;
    gap: 12px;

    button mat-icon {
      margin-right: 8px;
    }
  }

  mat-chip {
    mat-icon {
      margin-right: 8px;
    }
  }

  .status-chip-inactive {
    background-color: #757575 !important;
    color: white !important;
  }
}
```

### Paso 5: Actualizar Servicio con Métodos

Archivo: `src/app/modules/organizations/services/organization.service.ts`

```typescript
export class OrganizationService {
  private apiUrl = '/api/organizations';

  constructor(private http: HttpClient) {}

  // ... métodos existentes (create, update, getById, etc.) ...

  deactivate(id: number): Observable<void> {
    return this.http.post<void>(`${this.apiUrl}/${id}/deactivate`, {});
  }

  reactivate(id: number): Observable<void> {
    return this.http.post<void>(`${this.apiUrl}/${id}/reactivate`, {});
  }
}
```

### Paso 6: Tests Unitarios

Archivo: `src/app/modules/organizations/components/organization-form/organization-form.component.spec.ts`

```typescript
describe('OrganizationFormComponent - Baja/Alta', () => {
  it('should show deactivate button only for SecurityManager on active org', () => {
    mockAuthService.hasRole.and.callFake((role: string) => role === 'SecurityManager');
    
    component.organizationId.set(123);
    component.currentOrganization.set({
      id: 123,
      auditDeletionDate: null // Activa
    });
    
    fixture.detectChanges();
    
    expect(component.canDeactivate()).toBeTrue();
    expect(component.canReactivate()).toBeFalse();
  });

  it('should show reactivate button only for SecurityManager on inactive org', () => {
    mockAuthService.hasRole.and.callFake((role: string) => role === 'SecurityManager');
    
    component.organizationId.set(123);
    component.currentOrganization.set({
      id: 123,
      auditDeletionDate: new Date() // Inactiva
    });
    
    fixture.detectChanges();
    
    expect(component.canDeactivate()).toBeFalse();
    expect(component.canReactivate()).toBeTrue();
  });

  it('should open confirm dialog when deactivating', () => {
    const mockDialogRef = jasmine.createSpyObj('MatDialogRef', ['afterClosed']);
    mockDialogRef.afterClosed.and.returnValue(of(true));
    
    spyOn(component['dialog'], 'open').and.returnValue(mockDialogRef);
    mockOrganizationService.deactivate.and.returnValue(of(void 0));
    
    component.onDeactivateOrganization();
    
    expect(component['dialog'].open).toHaveBeenCalledWith(
      ConfirmDialogComponent,
      jasmine.objectContaining({
        data: jasmine.objectContaining({
          title: jasmine.stringContaining('baja'),
          type: 'danger'
        })
      })
    );
  });

  it('should prevent reactivation if ModuleCount is 0', () => {
    component.moduleCount.set(0);
    
    const snackBarSpy = spyOn(component['snackBar'], 'open');
    
    component.onReactivateOrganization();
    
    expect(snackBarSpy).toHaveBeenCalledWith(
      jasmine.stringContaining('sin módulos'),
      jasmine.any(String),
      jasmine.any(Object)
    );
    
    // No debe abrir diálogo
    expect(component['dialog'].open).not.toHaveBeenCalled();
  });

  it('should allow reactivation if ModuleCount > 0', () => {
    component.moduleCount.set(3); // Tiene módulos
    
    const mockDialogRef = jasmine.createSpyObj('MatDialogRef', ['afterClosed']);
    mockDialogRef.afterClosed.and.returnValue(of(true));
    
    spyOn(component['dialog'], 'open').and.returnValue(mockDialogRef);
    mockOrganizationService.reactivate.and.returnValue(of(void 0));
    
    component.onReactivateOrganization();
    
    expect(component['dialog'].open).toHaveBeenCalled();
    expect(mockOrganizationService.reactivate).toHaveBeenCalledWith(123);
  });
});
```

## ARCHIVOS A CREAR/MODIFICAR

**Frontend:**
- `src/app/shared/components/confirm-dialog/confirm-dialog.component.ts` - Modal reutilizable
- `src/app/modules/organizations/components/organization-form/organization-form.component.ts` - Agregar botones
- `src/app/modules/organizations/components/organization-form/organization-form.component.html` - Template botones
- `src/app/modules/organizations/components/organization-form/organization-form.component.scss` - Estilos
- `src/app/modules/organizations/services/organization.service.ts` - Métodos deactivate/reactivate
- `src/app/modules/organizations/components/organization-form/organization-form.component.spec.ts` - Tests

## DEPENDENCIAS
- TASK-001-FE - Componente base OrganizationFormComponent
- TASK-003-BE - Endpoint POST /organizations/{id}/deactivate
- TASK-003-BE-REACTIVATE - Endpoint POST /organizations/{id}/reactivate
- Angular Material Dialog
- Angular Material Snackbar

## DEFINITION OF DONE
- [x] ConfirmDialogComponent reutilizable creado
- [x] Botón "Dar de baja" visible solo para SecurityManager en org activa
- [x] Botón "Dar de alta" visible solo para SecurityManager en org inactiva
- [x] Modal de confirmación obligatorio para ambas acciones
- [x] Validación ModuleCount > 0 en alta con mensaje descriptivo
- [x] Estados visuales implementados (gris/naranja/verde chips)
- [x] Métodos deactivate/reactivate en OrganizationService
- [x] Tests verifican visibilidad de botones por rol y estado
- [x] Tests verifican apertura de modales
- [x] Tests verifican validación ModuleCount en reactivación
- [x] Feedback visual con snackbar en éxito/error
- [x] Code review aprobado
- [x] Accesibilidad verificada (aria-labels en botones)

## RECURSOS
- Angular Material Dialog: [Documentation](https://material.angular.io/components/dialog/overview)
- User Story: `userStories.md#us-003`
- User Story: `userStories.md#us-003v2`

=============================================================
