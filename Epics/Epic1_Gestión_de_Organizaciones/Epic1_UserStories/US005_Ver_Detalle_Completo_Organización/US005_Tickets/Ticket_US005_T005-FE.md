# TASK-005-FE: Implementar componente de gestión de módulos con master-detail

=============================================================
**TICKET ID:** TASK-005-FE  
**EPIC:** Gestión del Portfolio de Organizaciones Clientes  
**USER STORY:** US-005 - Consultar detalle de organización  
**COMPONENT:** Frontend - Angular  
**PRIORITY:** Alta  
**ESTIMATION:** 6 horas  
=============================================================

## TÍTULO
Implementar componente OrganizationModulesComponent para gestión de módulos/aplicaciones asignados

## DESCRIPCIÓN
Crear componente hijo que se usa en la Pestaña 2 del formulario de organización (TASK-001-FE) para gestionar los módulos y aplicaciones asignados a una organización.

**Funcionalidades:**
1. **Grid master-detail** con aplicaciones agrupadas
2. **Asignar módulos**: Selector de aplicación → Selector de módulos disponibles → Botón "Asignar"
3. **Remover módulos**: Botón de eliminar en cada fila con modal de confirmación
4. **Warning de auto-baja**: Si al remover módulos ModuleCount llegará a 0, mostrar modal especial advirtiendo sobre auto-baja
5. **Eventos**: Emitir cambios al componente padre para actualizar ModuleCount

**Grid structure:**
```
📱 Aplicación: Sintraport (3 módulos)
  ├─ Módulo: Gestión de Contenedores
  ├─ Módulo: Tracking GPS
  └─ Módulo: Reportes Analíticos
  
📱 Aplicación: Helix6 (2 módulos)
  ├─ Módulo: Administración
  └─ Módulo: Seguridad
```

**Estados:**
- **Solo lectura** (readonly=true): Grid visible pero sin botones de asignar/remover (para OrganizationManager)
- **Editable** (readonly=false): Todos los controles habilitados (para ApplicationManager)

## CONTEXTO TÉCNICO
- **Componente hijo**: Recibe `@Input() organizationId` y `@Input() readonly`
- **Eventos**: `@Output() modulesChanged` emite nuevo ModuleCount
- **API calls**: POST/DELETE /organizations/{id}/modules
- **Grid**: Kendo Grid con grouping por aplicación
- **Warning modal**: Modal especial con texto destacado sobre auto-baja

## CRITERIOS DE ACEPTACIÓN TÉCNICOS
- [ ] Componente OrganizationModulesComponent creado
- [ ] Grid master-detail con agrupación por aplicación
- [ ] Selector de aplicación y módulos para asignar
- [ ] Botón "Asignar módulo" funcional con validación
- [ ] Botón "Remover" en cada fila con modal de confirmación
- [ ] Modal especial de warning si remoción causa auto-baja
- [ ] Modo readonly implementado (deshabilita asignar/remover)
- [ ] Evento modulesChanged emite ModuleCount actualizado
- [ ] Tests unitarios de lógica de asignación/remoción
- [ ] Tests de modal de auto-baja warning

## GUÍA DE IMPLEMENTACIÓN

### Paso 1: Crear Componente

Archivo: `src/app/modules/organizations/components/organization-modules/organization-modules.component.ts`

```typescript
import { Component, Input, Output, EventEmitter, OnInit, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { GridModule } from '@progress/kendo-angular-grid';
import { DropDownsModule } from '@progress/kendo-angular-dropdowns';
import { ButtonsModule } from '@progress/kendo-angular-buttons';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatDialog } from '@angular/material/dialog';
import { MatSnackBar } from '@angular/material/snack-bar';
import { OrganizationModuleService } from '../../services/organization-module.service';
import { ConfirmDialogComponent } from '@shared/components/confirm-dialog/confirm-dialog.component';
import { AutoBajaWarningDialogComponent } from './auto-baja-warning-dialog.component';

interface ModuleAssignment {
  id: number;
  appId: number;
  appName: string;
  moduleId: number;
  moduleName: string;
  databaseName: string;
}

interface Application {
  id: number;
  name: string;
}

interface Module {
  id: number;
  name: string;
  appId: number;
}

@Component({
  selector: 'app-organization-modules',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    GridModule,
    DropDownsModule,
    ButtonsModule,
    MatIconModule,
    MatButtonModule
  ],
  templateUrl: './organization-modules.component.html',
  styleUrls: ['./organization-modules.component.scss']
})
export class OrganizationModulesComponent implements OnInit {
  @Input({ required: true }) organizationId!: number;
  @Input() readonly = false;
  
  @Output() modulesChanged = new EventEmitter<number>();

  assignedModules = signal<ModuleAssignment[]>([]);
  availableApplications = signal<Application[]>([]);
  availableModules = signal<Module[]>([]);
  
  assignForm!: FormGroup;
  loading = signal(false);
  
  // Módulos disponibles filtrados por aplicación seleccionada
  filteredModules = computed(() => {
    const appId = this.assignForm?.get('appId')?.value;
    if (!appId) return [];
    
    return this.availableModules().filter(m => m.appId === appId);
  });
  
  moduleCount = computed(() => this.assignedModules().length);

  constructor(
    private fb: FormBuilder,
    private organizationModuleService: OrganizationModuleService,
    private dialog: MatDialog,
    private snackBar: MatSnackBar
  ) {}

  ngOnInit(): void {
    this.initForm();
    this.loadAssignedModules();
    this.loadAvailableApplications();
  }

  private initForm(): void {
    this.assignForm = this.fb.group({
      appId: [null, Validators.required],
      moduleId: [null, Validators.required],
      databaseName: ['', Validators.required]
    });
    
    // Resetear moduleId cuando cambia la aplicación
    this.assignForm.get('appId')?.valueChanges.subscribe(() => {
      this.assignForm.patchValue({ moduleId: null });
      this.loadAvailableModules();
    });
    
    // Deshabilitar en modo readonly
    if (this.readonly) {
      this.assignForm.disable();
    }
  }

  private loadAssignedModules(): void {
    this.loading.set(true);
    
    this.organizationModuleService.getModules(this.organizationId).subscribe({
      next: (modules) => {
        this.assignedModules.set(modules);
        this.loading.set(false);
        this.modulesChanged.emit(this.moduleCount());
      },
      error: (err) => {
        console.error('Error al cargar módulos', err);
        this.loading.set(false);
      }
    });
  }

  private loadAvailableApplications(): void {
    this.organizationModuleService.getApplications().subscribe({
      next: (apps) => this.availableApplications.set(apps),
      error: (err) => console.error('Error al cargar aplicaciones', err)
    });
  }

  private loadAvailableModules(): void {
    const appId = this.assignForm.get('appId')?.value;
    if (!appId) return;
    
    this.organizationModuleService.getModulesByApp(appId).subscribe({
      next: (modules) => this.availableModules.set(modules),
      error: (err) => console.error('Error al cargar módulos', err)
    });
  }

  onAssignModule(): void {
    if (this.assignForm.invalid) {
      this.assignForm.markAllAsTouched();
      return;
    }

    const formValue = this.assignForm.value;

    this.organizationModuleService.assignModule(
      this.organizationId,
      formValue.appId,
      formValue.moduleId,
      formValue.databaseName
    ).subscribe({
      next: () => {
        this.snackBar.open('Módulo asignado correctamente', 'Cerrar', {
          duration: 3000
        });
        
        this.assignForm.reset();
        this.loadAssignedModules(); // Recargar lista
      },
      error: (err) => {
        if (err.error?.includes('ya está asignado')) {
          this.snackBar.open('El módulo ya está asignado a esta organización', 'Cerrar', {
            duration: 5000,
            panelClass: ['error-snackbar']
          });
        } else {
          this.snackBar.open('Error al asignar módulo', 'Cerrar', {
            duration: 5000,
            panelClass: ['error-snackbar']
          });
        }
      }
    });
  }

  onRemoveModule(module: ModuleAssignment): void {
    // Verificar si la remoción causará auto-baja (ModuleCount = 1 → 0)
    const willTriggerAutoBaja = this.moduleCount() === 1;
    
    if (willTriggerAutoBaja) {
      // Mostrar modal especial de warning sobre auto-baja
      const dialogRef = this.dialog.open(AutoBajaWarningDialogComponent, {
        data: {
          organizationName: module.appName, // En producción sería el nombre de la org
          moduleName: module.moduleName
        }
      });
      
      dialogRef.afterClosed().subscribe((confirmed) => {
        if (confirmed) {
          this.executeRemoveModule(module);
        }
      });
    } else {
      // Modal de confirmación normal
      const dialogRef = this.dialog.open(ConfirmDialogComponent, {
        data: {
          title: 'Remover módulo',
          message: `¿Está seguro de remover el módulo "${module.moduleName}"?`,
          confirmText: 'Remover',
          type: 'warning'
        }
      });
      
      dialogRef.afterClosed().subscribe((confirmed) => {
        if (confirmed) {
          this.executeRemoveModule(module);
        }
      });
    }
  }

  private executeRemoveModule(module: ModuleAssignment): void {
    this.organizationModuleService.removeModule(
      this.organizationId,
      module.moduleId
    ).subscribe({
      next: () => {
        this.snackBar.open('Módulo removido correctamente', 'Cerrar', {
          duration: 3000
        });
        
        this.loadAssignedModules(); // Recargar lista
      },
      error: (err) => {
        this.snackBar.open('Error al remover módulo', 'Cerrar', {
          duration: 5000,
          panelClass: ['error-snackbar']
        });
      }
    });
  }
}
```

### Paso 2: Template HTML

Archivo: `src/app/modules/organizations/components/organization-modules/organization-modules.component.html`

```html
<div class="organization-modules-container">
  <!-- Panel de asignación de módulos -->
  @if (!readonly) {
    <div class="assign-panel">
      <h3>Asignar nuevo módulo</h3>
      
      <form [formGroup]="assignForm" (ngSubmit)="onAssignModule()">
        <div class="assign-form-grid">
          <mat-form-field appearance="outline">
            <mat-label>Aplicación</mat-label>
            <mat-select formControlName="appId">
              <mat-option *ngFor="let app of availableApplications()" [value]="app.id">
                {{ app.name }}
              </mat-option>
            </mat-select>
          </mat-form-field>

          <mat-form-field appearance="outline">
            <mat-label>Módulo</mat-label>
            <mat-select formControlName="moduleId" [disabled]="!assignForm.get('appId')?.value">
              <mat-option *ngFor="let module of filteredModules()" [value]="module.id">
                {{ module.name }}
              </mat-option>
            </mat-select>
          </mat-form-field>

          <mat-form-field appearance="outline">
            <mat-label>Nombre de BD</mat-label>
            <input matInput formControlName="databaseName" placeholder="sintraport_org_12345">
          </mat-form-field>

          <button 
            mat-raised-button 
            color="primary" 
            type="submit"
            [disabled]="assignForm.invalid">
            <mat-icon>add</mat-icon>
            Asignar
          </button>
        </div>
      </form>
    </div>
  }

  <!-- Grid de módulos asignados -->
  <div class="modules-grid">
    <h3>Módulos asignados ({{ moduleCount() }})</h3>
    
    @if (assignedModules().length === 0) {
      <div class="empty-state">
        <mat-icon>apps</mat-icon>
        <p>No hay módulos asignados a esta organización</p>
        @if (!readonly) {
          <p class="hint">Use el panel superior para asignar módulos</p>
        }
      </div>
    } @else {
      <kendo-grid
        [data]="assignedModules()"
        [loading]="loading()"
        [groupable]="true">
        
        <kendo-grid-column field="appName" title="Aplicación" [width]="200">
        </kendo-grid-column>

        <kendo-grid-column field="moduleName" title="Módulo" [width]="250">
        </kendo-grid-column>

        <kendo-grid-column field="databaseName" title="Base de Datos" [width]="200">
        </kendo-grid-column>

        @if (!readonly) {
          <kendo-grid-column title="Acciones" [width]="100">
            <ng-template kendoGridCellTemplate let-dataItem>
              <button 
                mat-icon-button 
                color="warn"
                (click)="onRemoveModule(dataItem)"
                matTooltip="Remover módulo">
                <mat-icon>delete</mat-icon>
              </button>
            </ng-template>
          </kendo-grid-column>
        }
      </kendo-grid>
    }
  </div>
</div>
```

### Paso 3: Modal de Warning Auto-Baja

Archivo: `src/app/modules/organizations/components/organization-modules/auto-baja-warning-dialog.component.ts`

```typescript
import { Component, Inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatDialogModule, MAT_DIALOG_DATA, MatDialogRef } from '@angular/material/dialog';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';

@Component({
  selector: 'app-auto-baja-warning-dialog',
  standalone: true,
  imports: [CommonModule, MatDialogModule, MatButtonModule, MatIconModule],
  template: `
    <h2 mat-dialog-title class="warning-title">
      <mat-icon class="warning-icon">warning</mat-icon>
      ⚠️ Advertencia: Auto-desactivación
    </h2>
    
    <mat-dialog-content>
      <div class="warning-content">
        <p class="main-message">
          Al remover el módulo <strong>{{ data.moduleName }}</strong>, 
          la organización quedará sin módulos asignados.
        </p>
        
        <div class="consequence-box">
          <mat-icon>info</mat-icon>
          <div>
            <p><strong>Consecuencia automática:</strong></p>
            <ul>
              <li>La organización será <strong>dada de baja automáticamente</strong> por el sistema</li>
              <li>Todos los usuarios perderán acceso inmediatamente</li>
              <li>Se registrará en auditoría como "Auto-desactivación por sistema"</li>
            </ul>
          </div>
        </div>
        
        <p class="action-message">
          ¿Está seguro de continuar?
        </p>
      </div>
    </mat-dialog-content>
    
    <mat-dialog-actions align="end">
      <button mat-button (click)="onCancel()">
        Cancelar
      </button>
      <button mat-raised-button color="warn" (click)="onConfirm()">
        Sí, remover módulo
      </button>
    </mat-dialog-actions>
  `,
  styles: [`
    .warning-title {
      display: flex;
      align-items: center;
      gap: 12px;
      color: #ff9800;
      
      .warning-icon {
        font-size: 32px;
        width: 32px;
        height: 32px;
      }
    }
    
    .warning-content {
      padding: 20px 0;
      
      .main-message {
        font-size: 16px;
        margin-bottom: 20px;
      }
      
      .consequence-box {
        display: flex;
        gap: 16px;
        padding: 16px;
        background-color: #fff3e0;
        border-left: 4px solid #ff9800;
        margin: 20px 0;
        
        mat-icon {
          color: #f57c00;
          flex-shrink: 0;
        }
        
        ul {
          margin: 8px 0 0 0;
          padding-left: 20px;
        }
        
        li {
          margin-bottom: 8px;
        }
      }
      
      .action-message {
        font-weight: 500;
        margin-top: 20px;
      }
    }
  `]
})
export class AutoBajaWarningDialogComponent {
  constructor(
    public dialogRef: MatDialogRef<AutoBajaWarningDialogComponent>,
    @Inject(MAT_DIALOG_DATA) public data: { organizationName: string; moduleName: string }
  ) {}

  onConfirm(): void {
    this.dialogRef.close(true);
  }

  onCancel(): void {
    this.dialogRef.close(false);
  }
}
```

### Paso 4: Servicio

Archivo: `src/app/modules/organizations/services/organization-module.service.ts`

```typescript
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class OrganizationModuleService {
  private apiUrl = '/api/organizations';

  constructor(private http: HttpClient) {}

  getModules(organizationId: number): Observable<ModuleAssignment[]> {
    return this.http.get<ModuleAssignment[]>(
      `${this.apiUrl}/${organizationId}/modules`
    );
  }

  assignModule(
    organizationId: number,
    appId: number,
    moduleId: number,
    databaseName: string
  ): Observable<void> {
    return this.http.post<void>(
      `${this.apiUrl}/${organizationId}/modules`,
      { appId, moduleId, databaseName }
    );
  }

  removeModule(organizationId: number, moduleId: number): Observable<void> {
    return this.http.delete<void>(
      `${this.apiUrl}/${organizationId}/modules/${moduleId}`
    );
  }

  getApplications(): Observable<Application[]> {
    return this.http.get<Application[]>('/api/applications');
  }

  getModulesByApp(appId: number): Observable<Module[]> {
    return this.http.get<Module[]>(`/api/applications/${appId}/modules`);
  }
}
```

### Paso 5: Tests

Archivo: `src/app/modules/organizations/components/organization-modules/organization-modules.component.spec.ts`

```typescript
describe('OrganizationModulesComponent', () => {
  it('should show auto-baja warning modal when removing last module', () => {
    component.assignedModules.set([
      { id: 1, moduleName: 'Last Module' } as any
    ]);
    
    const dialogSpy = spyOn(component['dialog'], 'open').and.returnValue({
      afterClosed: () => of(true)
    } as any);
    
    const module = component.assignedModules()[0];
    component.onRemoveModule(module);
    
    expect(dialogSpy).toHaveBeenCalledWith(
      AutoBajaWarningDialogComponent,
      jasmine.any(Object)
    );
  });

  it('should show normal confirm modal when removing non-last module', () => {
    component.assignedModules.set([
      { id: 1, moduleName: 'Module 1' } as any,
      { id: 2, moduleName: 'Module 2' } as any
    ]);
    
    const dialogSpy = spyOn(component['dialog'], 'open').and.returnValue({
      afterClosed: () => of(true)
    } as any);
    
    const module = component.assignedModules()[0];
    component.onRemoveModule(module);
    
    expect(dialogSpy).toHaveBeenCalledWith(
      ConfirmDialogComponent,
      jasmine.any(Object)
    );
  });

  it('should emit modulesChanged event after loading modules', () => {
    const emitSpy = spyOn(component.modulesChanged, 'emit');
    
    mockService.getModules.and.returnValue(of([
      { id: 1 } as any,
      { id: 2 } as any
    ]));
    
    component['loadAssignedModules']();
    
    expect(emitSpy).toHaveBeenCalledWith(2);
  });

  it('should disable form in readonly mode', () => {
    component.readonly = true;
    component.ngOnInit();
    
    expect(component.assignForm.disabled).toBeTrue();
  });
});
```

## ARCHIVOS A CREAR/MODIFICAR

**Frontend:**
- `src/app/modules/organizations/components/organization-modules/organization-modules.component.ts`
- `src/app/modules/organizations/components/organization-modules/organization-modules.component.html`
- `src/app/modules/organizations/components/organization-modules/organization-modules.component.scss`
- `src/app/modules/organizations/components/organization-modules/auto-baja-warning-dialog.component.ts`
- `src/app/modules/organizations/services/organization-module.service.ts`
- Tests

## DEPENDENCIAS
- TASK-001-FE - Componente padre OrganizationFormComponent
- TASK-001-BE-EXT - Endpoints de módulos
- TASK-003-FE - ConfirmDialogComponent

## DEFINITION OF DONE
- [x] OrganizationModulesComponent creado
- [x] Grid con agrupación por aplicación
- [x] Formulario de asignación con selectores dependientes
- [x] Botón remover con modal de confirmación
- [x] AutoBajaWarningDialogComponent para warning especial
- [x] Modo readonly funcional
- [x] Evento modulesChanged emite correctamente
- [x] Tests verifican warning modal cuando ModuleCount=1
- [x] Tests verifican modal normal cuando ModuleCount>1
- [x] Code review aprobado

## RECURSOS
- User Story: `userStories.md#us-005`
- User Story: `userStories.md#us-010`

=============================================================
