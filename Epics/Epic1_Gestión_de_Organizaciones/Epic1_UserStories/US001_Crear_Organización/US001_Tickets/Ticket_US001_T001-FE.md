# TASK-001-FE: Implementar formulario de creación de organización con dos pestañas

=============================================================
**TICKET ID:** TASK-001-FE  
**EPIC:** Gestión del Portfolio de Organizaciones Clientes  
**USER STORY:** US-001 - Crear nueva organización cliente  
**COMPONENT:** Frontend - Angular  
**PRIORITY:** Alta  
**ESTIMATION:** 6 horas  
=============================================================

## TÍTULO
Implementar formulario de creación de organización con Angular Material Tabs y validación por pestaña

## DESCRIPCIÓN
Crear componente Angular para el formulario de creación/edición de organizaciones con estructura de dos pestañas según arquitectura definida en US-002:

**Pestaña 1 - Datos de Organización:**
- Editable por: OrganizationManager
- Solo lectura para: ApplicationManager
- Campos: Name, CIF, Address, City, PostalCode, Country, ContactEmail, ContactPhone, GroupId
- Validaciones: Name, CIF, ContactEmail obligatorios
- Al guardar: NO se publica evento, solo se guarda en BD
- Navegación automática a Pestaña 2 después de guardar (si es creación nueva)

**Pestaña 2 - Módulos y Permisos de Acceso:**
- Editable por: ApplicationManager  
- Solo lectura para: OrganizationManager
- Gestión de módulos/aplicaciones asignados
- **PRIMER evento se publica aquí** al asignar el primer módulo
- Componente master-detail con grid de módulos asignados

**Flujo de creación:**
1. OrganizationManager crea organización en Pestaña 1 → Guarda → Automáticamente navega a Pestaña 2
2. ApplicationManager asigna módulos en Pestaña 2 → Guarda → Publica PRIMER OrganizationEvent
3. Estado visual: "Pendiente de configuración" si ModuleCount = 0 (naranja), "Activa" si ModuleCount > 0 (verde)

## CONTEXTO TÉCNICO
- **Framework**: Angular 20.1.6 con Standalone Components
- **UI**: Angular Material Tabs, Forms, Kendo UI Grid para listado de módulos
- **Validación**: Reactive Forms con validadores custom
- **Estado**: Señales de Angular para gestionar estado de pestañas
- **Roles**: Verificar claims JWT para habilitar/deshabilitar campos por rol
- **Routing**: Navegación entre pestañas mediante parámetros de ruta

## CRITERIOS DE ACEPTACIÓN TÉCNICOS
- [ ] Componente OrganizationFormComponent creado con dos pestañas Angular Material
- [ ] Pestaña 1 implementada con todos los campos de datos de organización
- [ ] Validaciones reactivas implementadas (Name, CIF, Email obligatorios)
- [ ] CIF validado con regex pattern español (ej: A12345678)
- [ ] Pestaña 2 implementada con grid Kendo de módulos asignados
- [ ] Permisos por rol implementados (OrganizationManager vs ApplicationManager)
- [ ] Navegación automática a Pestaña 2 después de crear organización
- [ ] Indicador visual de estado: "Pendiente de configuración" (naranja) si ModuleCount=0
- [ ] Tests unitarios de validaciones y navegación
- [ ] Tests E2E del flujo completo de creación

## GUÍA DE IMPLEMENTACIÓN

### Paso 1: Crear Estructura de Componente

Archivo: `src/app/modules/organizations/components/organization-form/organization-form.component.ts`

```typescript
import { Component, OnInit, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { MatTabsModule } from '@angular/material/tabs';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatSelectModule } from '@angular/material/select';
import { MatIconModule } from '@angular/material/icon';
import { MatChipModule } from '@angular/material/chip';
import { ActivatedRoute, Router } from '@angular/router';
import { OrganizationService } from '../../services/organization.service';
import { AuthService } from '@app/services/auth.service';

@Component({
  selector: 'app-organization-form',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    MatTabsModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    MatSelectModule,
    MatIconModule,
    MatChipModule
  ],
  templateUrl: './organization-form.component.html',
  styleUrls: ['./organization-form.component.scss']
})
export class OrganizationFormComponent implements OnInit {
  organizationForm!: FormGroup;
  organizationId = signal<number | null>(null);
  selectedTabIndex = signal(0);
  moduleCount = signal(0);
  
  // Señales computadas
  isEditMode = computed(() => this.organizationId() !== null);
  isOrganizationManager = computed(() => this.authService.hasRole('OrganizationManager'));
  isApplicationManager = computed(() => this.authService.hasRole('ApplicationManager'));
  
  // Estado visual basado en ModuleCount
  organizationStatus = computed(() => {
    const count = this.moduleCount();
    if (count === 0) {
      return {
        label: 'Pendiente de configuración',
        color: 'warn', // naranja
        icon: 'warning'
      };
    }
    return {
      label: 'Activa',
      color: 'primary', // verde
      icon: 'check_circle'
    };
  });
  
  // Control de permisos por pestaña
  canEditDataTab = computed(() => this.isOrganizationManager());
  canEditModulesTab = computed(() => this.isApplicationManager());

  constructor(
    private fb: FormBuilder,
    private route: ActivatedRoute,
    private router: Router,
    private organizationService: OrganizationService,
    private authService: AuthService
  ) {}

  ngOnInit(): void {
    this.initForm();
    this.loadOrganization();
    
    // Leer parámetro de pestaña de la URL
    this.route.queryParams.subscribe(params => {
      if (params['tab']) {
        this.selectedTabIndex.set(params['tab'] === 'modules' ? 1 : 0);
      }
    });
  }

  private initForm(): void {
    this.organizationForm = this.fb.group({
      name: ['', [Validators.required, Validators.maxLength(200)]],
      cif: ['', [Validators.required, Validators.pattern(/^[A-Z][0-9]{8}$/)]],
      address: ['', Validators.maxLength(500)],
      city: ['', Validators.maxLength(100)],
      postalCode: ['', Validators.maxLength(20)],
      country: ['', Validators.maxLength(100)],
      contactEmail: ['', [Validators.required, Validators.email, Validators.maxLength(200)]],
      contactPhone: ['', Validators.maxLength(50)],
      groupId: [null]
    });
    
    // Deshabilitar campos si no tiene permisos
    if (!this.canEditDataTab()) {
      this.organizationForm.disable();
    }
  }

  private loadOrganization(): void {
    const id = this.route.snapshot.paramMap.get('id');
    
    if (id) {
      this.organizationId.set(+id);
      
      this.organizationService.getById(+id).subscribe({
        next: (org) => {
          this.organizationForm.patchValue(org);
          this.moduleCount.set(org.moduleCount || 0);
        },
        error: (err) => console.error('Error al cargar organización', err)
      });
    }
  }

  onSubmitDataTab(): void {
    if (this.organizationForm.invalid) {
      this.organizationForm.markAllAsTouched();
      return;
    }

    const formValue = this.organizationForm.value;

    if (this.isEditMode()) {
      // Modo edición: actualizar
      this.organizationService.update(this.organizationId()!, formValue).subscribe({
        next: (updated) => {
          console.log('Organización actualizada', updated);
          // Mostrar toast de éxito
        },
        error: (err) => console.error('Error al actualizar', err)
      });
    } else {
      // Modo creación: crear y navegar a pestaña de módulos
      this.organizationService.create(formValue).subscribe({
        next: (created) => {
          console.log('Organización creada (sin evento)', created);
          this.organizationId.set(created.id);
          
          // IMPORTANTE: Navegar automáticamente a Pestaña 2 (Módulos)
          this.selectedTabIndex.set(1);
          
          // Actualizar URL con parámetro tab=modules
          this.router.navigate([], {
            relativeTo: this.route,
            queryParams: { tab: 'modules' },
            queryParamsHandling: 'merge'
          });
          
          // Mostrar toast: "Organización creada. Ahora asigne módulos para activarla."
        },
        error: (err) => console.error('Error al crear', err)
      });
    }
  }

  onTabChange(index: number): void {
    this.selectedTabIndex.set(index);
    
    // Actualizar URL
    const tab = index === 1 ? 'modules' : 'data';
    this.router.navigate([], {
      relativeTo: this.route,
      queryParams: { tab },
      queryParamsHandling: 'merge'
    });
  }
  
  onModulesUpdated(newModuleCount: number): void {
    // Callback desde componente hijo de módulos
    this.moduleCount.set(newModuleCount);
  }
}
```

### Paso 2: Crear Template HTML

Archivo: `src/app/modules/organizations/components/organization-form/organization-form.component.html`

```html
<div class="organization-form-container">
  <!-- Header con estado visual -->
  <div class="form-header">
    <h1>{{ isEditMode() ? 'Editar Organización' : 'Nueva Organización' }}</h1>
    
    @if (isEditMode()) {
      <mat-chip [color]="organizationStatus().color" selected>
        <mat-icon>{{ organizationStatus().icon }}</mat-icon>
        {{ organizationStatus().label }}
      </mat-chip>
    }
  </div>

  <!-- Pestañas -->
  <mat-tab-group 
    [selectedIndex]="selectedTabIndex()"
    (selectedIndexChange)="onTabChange($event)"
    class="organization-tabs">
    
    <!-- Pestaña 1: Datos de Organización -->
    <mat-tab label="Datos de Organización">
      <div class="tab-content">
        <!-- Indicador de permisos -->
        @if (!canEditDataTab()) {
          <div class="permission-notice">
            <mat-icon>info</mat-icon>
            <span>Solo lectura. Contacte con un OrganizationManager para editar estos datos.</span>
          </div>
        }
        
        <form [formGroup]="organizationForm" (ngSubmit)="onSubmitDataTab()">
          <div class="form-grid">
            <!-- Nombre -->
            <mat-form-field appearance="outline" class="full-width">
              <mat-label>Nombre de la Organización *</mat-label>
              <input matInput formControlName="name" maxlength="200">
              <mat-icon matPrefix>business</mat-icon>
              @if (organizationForm.get('name')?.hasError('required')) {
                <mat-error>El nombre es obligatorio</mat-error>
              }
            </mat-form-field>

            <!-- CIF -->
            <mat-form-field appearance="outline">
              <mat-label>CIF *</mat-label>
              <input matInput formControlName="cif" placeholder="A12345678" maxlength="9">
              <mat-icon matPrefix>badge</mat-icon>
              @if (organizationForm.get('cif')?.hasError('required')) {
                <mat-error>El CIF es obligatorio</mat-error>
              }
              @if (organizationForm.get('cif')?.hasError('pattern')) {
                <mat-error>Formato inválido (ej: A12345678)</mat-error>
              }
            </mat-form-field>

            <!-- Email de Contacto -->
            <mat-form-field appearance="outline">
              <mat-label>Email de Contacto *</mat-label>
              <input matInput type="email" formControlName="contactEmail">
              <mat-icon matPrefix>email</mat-icon>
              @if (organizationForm.get('contactEmail')?.hasError('required')) {
                <mat-error>El email es obligatorio</mat-error>
              }
              @if (organizationForm.get('contactEmail')?.hasError('email')) {
                <mat-error>Email inválido</mat-error>
              }
            </mat-form-field>

            <!-- Teléfono -->
            <mat-form-field appearance="outline">
              <mat-label>Teléfono de Contacto</mat-label>
              <input matInput formControlName="contactPhone">
              <mat-icon matPrefix>phone</mat-icon>
            </mat-form-field>

            <!-- Dirección -->
            <mat-form-field appearance="outline" class="full-width">
              <mat-label>Dirección</mat-label>
              <input matInput formControlName="address">
              <mat-icon matPrefix>location_on</mat-icon>
            </mat-form-field>

            <!-- Ciudad -->
            <mat-form-field appearance="outline">
              <mat-label>Ciudad</mat-label>
              <input matInput formControlName="city">
            </mat-form-field>

            <!-- Código Postal -->
            <mat-form-field appearance="outline">
              <mat-label>Código Postal</mat-label>
              <input matInput formControlName="postalCode">
            </mat-form-field>

            <!-- País -->
            <mat-form-field appearance="outline">
              <mat-label>País</mat-label>
              <input matInput formControlName="country">
            </mat-form-field>

            <!-- Grupo -->
            <mat-form-field appearance="outline">
              <mat-label>Grupo de Organizaciones</mat-label>
              <mat-select formControlName="groupId">
                <mat-option [value]="null">Sin grupo</mat-option>
                <!-- Opciones cargadas desde servicio -->
              </mat-select>
              <mat-icon matPrefix>folder</mat-icon>
            </mat-form-field>
          </div>

          <!-- Botones -->
          <div class="form-actions">
            <button mat-button type="button" routerLink="/organizations">
              Cancelar
            </button>
            <button 
              mat-raised-button 
              color="primary" 
              type="submit"
              [disabled]="!canEditDataTab()">
              {{ isEditMode() ? 'Guardar Cambios' : 'Crear y Configurar Módulos' }}
            </button>
          </div>
        </form>
      </div>
    </mat-tab>

    <!-- Pestaña 2: Módulos y Permisos -->
    <mat-tab label="Módulos y Permisos de Acceso">
      <div class="tab-content">
        <!-- Indicador de permisos -->
        @if (!canEditModulesTab()) {
          <div class="permission-notice">
            <mat-icon>info</mat-icon>
            <span>Solo lectura. Contacte con un ApplicationManager para gestionar módulos.</span>
          </div>
        }
        
        <!-- Mensaje si no hay organización creada aún -->
        @if (!isEditMode()) {
          <div class="info-message">
            <mat-icon>info</mat-icon>
            <p>Primero complete los datos de la organización en la pestaña anterior.</p>
          </div>
        } @else {
          <!-- Componente hijo para gestión de módulos -->
          <app-organization-modules
            [organizationId]="organizationId()!"
            [readonly]="!canEditModulesTab()"
            (modulesChanged)="onModulesUpdated($event)">
          </app-organization-modules>
        }
      </div>
    </mat-tab>
  </mat-tab-group>
</div>
```

### Paso 3: Estilos SCSS

Archivo: `src/app/modules/organizations/components/organization-form/organization-form.component.scss`

```scss
.organization-form-container {
  padding: 24px;
  max-width: 1200px;
  margin: 0 auto;
}

.form-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;

  h1 {
    margin: 0;
    font-size: 24px;
    font-weight: 500;
  }

  mat-chip {
    mat-icon {
      margin-right: 8px;
    }
  }
}

.organization-tabs {
  .tab-content {
    padding: 24px 0;
  }
}

.permission-notice {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 16px;
  background-color: #fff3cd;
  border-left: 4px solid #ffc107;
  margin-bottom: 24px;
  border-radius: 4px;

  mat-icon {
    color: #856404;
  }

  span {
    color: #856404;
    font-size: 14px;
  }
}

.form-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 16px;

  .full-width {
    grid-column: 1 / -1;
  }
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  margin-top: 24px;
  padding-top: 24px;
  border-top: 1px solid #e0e0e0;
}

.info-message {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 32px;
  background-color: #f5f5f5;
  border-radius: 8px;
  text-align: center;
  justify-content: center;

  mat-icon {
    font-size: 48px;
    width: 48px;
    height: 48px;
    color: #757575;
  }

  p {
    margin: 0;
    color: #616161;
    font-size: 16px;
  }
}
```

### Paso 4: Tests Unitarios

Archivo: `src/app/modules/organizations/components/organization-form/organization-form.component.spec.ts`

```typescript
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ReactiveFormsModule } from '@angular/forms';
import { NoopAnimationsModule } from '@angular/platform-browser/animations';
import { RouterTestingModule } from '@angular/router/testing';
import { of } from 'rxjs';
import { OrganizationFormComponent } from './organization-form.component';
import { OrganizationService } from '../../services/organization.service';
import { AuthService } from '@app/services/auth.service';

describe('OrganizationFormComponent', () => {
  let component: OrganizationFormComponent;
  let fixture: ComponentFixture<OrganizationFormComponent>;
  let mockOrganizationService: jasmine.SpyObj<OrganizationService>;
  let mockAuthService: jasmine.SpyObj<AuthService>;

  beforeEach(async () => {
    mockOrganizationService = jasmine.createSpyObj('OrganizationService', 
      ['create', 'update', 'getById']);
    mockAuthService = jasmine.createSpyObj('AuthService', ['hasRole']);

    await TestBed.configureTestingModule({
      imports: [
        OrganizationFormComponent,
        ReactiveFormsModule,
        NoopAnimationsModule,
        RouterTestingModule
      ],
      providers: [
        { provide: OrganizationService, useValue: mockOrganizationService },
        { provide: AuthService, useValue: mockAuthService }
      ]
    }).compileComponents();

    fixture = TestBed.createComponent(OrganizationFormComponent);
    component = fixture.componentInstance;
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should initialize form with validators', () => {
    fixture.detectChanges();
    
    expect(component.organizationForm.get('name')?.hasError('required')).toBeTrue();
    expect(component.organizationForm.get('cif')?.hasError('required')).toBeTrue();
    expect(component.organizationForm.get('contactEmail')?.hasError('required')).toBeTrue();
  });

  it('should validate CIF pattern', () => {
    fixture.detectChanges();
    
    const cifControl = component.organizationForm.get('cif');
    
    cifControl?.setValue('invalid');
    expect(cifControl?.hasError('pattern')).toBeTrue();
    
    cifControl?.setValue('A12345678');
    expect(cifControl?.hasError('pattern')).toBeFalse();
  });

  it('should navigate to modules tab after creating organization', () => {
    mockAuthService.hasRole.and.returnValue(true);
    mockOrganizationService.create.and.returnValue(of({ id: 123 }));
    
    fixture.detectChanges();
    
    component.organizationForm.patchValue({
      name: 'Test Org',
      cif: 'A12345678',
      contactEmail: 'test@example.com'
    });
    
    component.onSubmitDataTab();
    
    expect(component.selectedTabIndex()).toBe(1); // Pestaña de módulos
  });

  it('should show pending status when ModuleCount is 0', () => {
    component.moduleCount.set(0);
    fixture.detectChanges();
    
    const status = component.organizationStatus();
    expect(status.label).toBe('Pendiente de configuración');
    expect(status.color).toBe('warn');
  });

  it('should show active status when ModuleCount > 0', () => {
    component.moduleCount.set(3);
    fixture.detectChanges();
    
    const status = component.organizationStatus();
    expect(status.label).toBe('Activa');
    expect(status.color).toBe('primary');
  });

  it('should disable form when user is not OrganizationManager', () => {
    mockAuthService.hasRole.and.returnValue(false);
    fixture.detectChanges();
    
    expect(component.organizationForm.disabled).toBeTrue();
  });
});
```

## ARCHIVOS A CREAR/MODIFICAR

**Frontend:**
- `src/app/modules/organizations/components/organization-form/organization-form.component.ts` - Componente principal
- `src/app/modules/organizations/components/organization-form/organization-form.component.html` - Template
- `src/app/modules/organizations/components/organization-form/organization-form.component.scss` - Estilos
- `src/app/modules/organizations/components/organization-form/organization-form.component.spec.ts` - Tests
- `src/app/modules/organizations/services/organization.service.ts` - Servicio HTTP
- `src/app/modules/organizations/organizations.routes.ts` - Configuración de rutas

## DEPENDENCIAS
- TASK-001-BE - Endpoints backend de Organization
- Angular Material instalado y configurado
- Kendo UI Angular instalado
- AuthService con verificación de roles JWT

## DEFINITION OF DONE
- [x] Componente OrganizationFormComponent creado con dos pestañas
- [x] Pestaña 1 implementada con todos los campos y validaciones
- [x] Validación CIF con regex pattern español
- [x] Pestaña 2 preparada para componente hijo de módulos
- [x] Navegación automática a Pestaña 2 después de crear
- [x] Permisos por rol implementados (habilitar/deshabilitar campos)
- [x] Estado visual "Pendiente/Activa" basado en ModuleCount
- [x] Estilos responsive con grid CSS
- [x] Tests unitarios con cobertura > 80%
- [x] Tests verifican navegación automática a módulos
- [x] Tests verifican permisos por rol
- [x] Code review aprobado
- [x] Accesibilidad verificada (aria labels, navegación por teclado)

## RECURSOS
- Angular Material Tabs: [Documentation](https://material.angular.io/components/tabs/overview)
- Angular Reactive Forms: [Documentation](https://angular.io/guide/reactive-forms)
- User Story: `userStories.md#us-001`
- User Story: `userStories.md#us-002`

=============================================================
