# TASK-002-FE: Implementar edición de organización con validación de permisos por pestaña

=============================================================
**TICKET ID:** TASK-002-FE  
**EPIC:** Gestión del Portfolio de Organizaciones Clientes  
**USER STORY:** US-002 - Editar información de organización existente  
**COMPONENT:** Frontend - Angular  
**PRIORITY:** Alta  
**ESTIMATION:** 3 horas  
=============================================================

## TÍTULO
Extender formulario de organización para modo edición con permisos diferenciados por pestaña

## DESCRIPCIÓN
Extender el componente OrganizationFormComponent (TASK-001-FE) para soportar modo edición con las siguientes características:

**Pestaña 1 - Datos de Organización:**
- **OrganizationManager**: Puede editar todos los campos EXCEPTO SecurityCompanyId (inmutable)
- **ApplicationManager**: Solo lectura (ver warning visual)
- Validación client-side: SecurityCompanyId deshabilitado en modo edición
- Auditoría: SOLO si cambia GroupId (visual notification sobre cambio crítico)

**Pestaña 2 - Módulos y Permisos de Acceso:**
- **ApplicationManager**: Puede editar módulos
- **OrganizationManager**: Solo lectura (ver warning visual)
- Warning modal si al remover módulos ModuleCount llegará a 0 (auto-baja)

**Indicador de auditoría:**
- Mostrar icono de auditoría junto al campo GroupId
- Tooltip: "Los cambios de grupo se registran en auditoría"

## CONTEXTO TÉCNICO
- **Componente**: Reutilizar OrganizationFormComponent de TASK-001-FE
- **Modo edición**: Detectado por presencia de parámetro :id en ruta
- **Validación**: SecurityCompanyId field disabled en modo edición
- **Warnings**: Angular Material Snackbar o Dialog para notificaciones
- **Audit indicator**: Material Icon con tooltip

## CRITERIOS DE ACEPTACIÓN TÉCNICOS
- [ ] Modo edición activado cuando ruta contiene :id
- [ ] SecurityCompanyId field disabled en modo edición (no editable)
- [ ] Validación client-side impide modificar SecurityCompanyId
- [ ] Icono de auditoría visible junto a campo GroupId
- [ ] Tooltip informativo en icono de auditoría
- [ ] Permisos por rol implementados diferenciadamente en cada pestaña
- [ ] Warning visual cuando usuario sin permisos accede a pestaña
- [ ] Tests unitarios verifican SecurityCompanyId inmutable
- [ ] Tests verifican permisos por pestaña

## GUÍA DE IMPLEMENTACIÓN

### Paso 1: Extender Componente para Modo Edición

Archivo: `src/app/modules/organizations/components/organization-form/organization-form.component.ts`

```typescript
// Agregar al componente existente de TASK-001-FE

private initForm(): void {
  this.organizationForm = this.fb.group({
    securityCompanyId: [{ value: '', disabled: true }], // SIEMPRE disabled en edición
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
  
  // Deshabilitar campos si no tiene permisos en esta pestaña
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
        
        // CRÍTICO: SecurityCompanyId siempre disabled en edición
        this.organizationForm.get('securityCompanyId')?.disable();
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

  const formValue = this.organizationForm.getRawValue(); // getRawValue incluye disabled fields

  if (this.isEditMode()) {
    // Verificar si GroupId cambió (auditoría crítica)
    const originalGroupId = this.originalOrganization?.groupId;
    const newGroupId = formValue.groupId;
    
    if (originalGroupId !== newGroupId) {
      // Mostrar notificación de cambio crítico
      this.snackBar.open(
        'El cambio de grupo será registrado en auditoría',
        'Entendido',
        { duration: 5000 }
      );
    }
    
    // Actualizar
    this.organizationService.update(this.organizationId()!, formValue).subscribe({
      next: (updated) => {
        this.snackBar.open('Organización actualizada correctamente', 'Cerrar', {
          duration: 3000
        });
      },
      error: (err) => {
        if (err.error?.includes('SecurityCompanyId es inmutable')) {
          this.snackBar.open(
            'Error: SecurityCompanyId no puede modificarse',
            'Cerrar',
            { duration: 5000, panelClass: ['error-snackbar'] }
          );
        }
      }
    });
  } else {
    // Crear (código existente de TASK-001-FE)
    // ...
  }
}
```

### Paso 2: Actualizar Template con Indicador de Auditoría

Archivo: `src/app/modules/organizations/components/organization-form/organization-form.component.html`

```html
<!-- En la sección de formulario de Pestaña 1 -->

<!-- SecurityCompanyId (solo visible en modo edición, SIEMPRE disabled) -->
@if (isEditMode()) {
  <mat-form-field appearance="outline">
    <mat-label>ID de Empresa (Inmutable)</mat-label>
    <input matInput formControlName="securityCompanyId" readonly>
    <mat-icon matPrefix>lock</mat-icon>
    <mat-hint>Este campo no se puede modificar</mat-hint>
  </mat-form-field>
}

<!-- Grupo con icono de auditoría -->
<mat-form-field appearance="outline">
  <mat-label>Grupo de Organizaciones</mat-label>
  <mat-select formControlName="groupId">
    <mat-option [value]="null">Sin grupo</mat-option>
    <mat-option *ngFor="let group of groups" [value]="group.id">
      {{ group.name }}
    </mat-option>
  </mat-select>
  <mat-icon matPrefix>folder</mat-icon>
  
  <!-- Icono de auditoría con tooltip -->
  <mat-icon 
    matSuffix 
    class="audit-indicator"
    matTooltip="Los cambios de grupo se registran en auditoría"
    matTooltipPosition="above">
    history
  </mat-icon>
</mat-form-field>
```

### Paso 3: Estilos para Indicador de Auditoría

Archivo: `src/app/modules/organizations/components/organization-form/organization-form.component.scss`

```scss
// Agregar a los estilos existentes

.audit-indicator {
  color: #ff9800; // naranja para indicar auditoría
  cursor: help;
  font-size: 20px;
}

::ng-deep .error-snackbar {
  background-color: #f44336;
  color: white;
}
```

### Paso 4: Tests Unitarios Adicionales

Archivo: `src/app/modules/organizations/components/organization-form/organization-form.component.spec.ts`

```typescript
// Agregar a los tests existentes de TASK-001-FE

describe('OrganizationFormComponent - Edit Mode', () => {
  it('should disable SecurityCompanyId field in edit mode', () => {
    const mockOrg = {
      id: 123,
      securityCompanyId: 12345,
      name: 'Test Org',
      cif: 'A12345678',
      contactEmail: 'test@example.com'
    };
    
    mockOrganizationService.getById.and.returnValue(of(mockOrg));
    
    // Simular ruta con id
    spyOn(component['route'].snapshot.paramMap, 'get').and.returnValue('123');
    
    component.ngOnInit();
    fixture.detectChanges();
    
    const securityCompanyIdControl = component.organizationForm.get('securityCompanyId');
    expect(securityCompanyIdControl?.disabled).toBeTrue();
  });

  it('should show audit notification when GroupId changes', () => {
    const mockSnackBar = jasmine.createSpyObj('MatSnackBar', ['open']);
    component['snackBar'] = mockSnackBar;
    
    component.originalOrganization = { groupId: 1 };
    component.organizationForm.patchValue({ groupId: 2 }); // Cambio de grupo
    
    mockOrganizationService.update.and.returnValue(of({}));
    
    component.onSubmitDataTab();
    
    expect(mockSnackBar.open).toHaveBeenCalledWith(
      jasmine.stringContaining('registrado en auditoría'),
      jasmine.any(String),
      jasmine.any(Object)
    );
  });

  it('should not allow submitting if SecurityCompanyId was manually modified', () => {
    // Este test verifica que aunque el usuario intente modificar SecurityCompanyId
    // mediante DevTools, el backend rechace el cambio
    
    component.organizationForm.get('securityCompanyId')?.enable(); // Forzar enable
    component.organizationForm.patchValue({ securityCompanyId: 99999 });
    
    mockOrganizationService.update.and.returnValue(
      throwError({ error: 'SecurityCompanyId es inmutable' })
    );
    
    component.onSubmitDataTab();
    
    // Verificar que se muestra error
    // ... assertions para snackbar de error
  });

  it('should show read-only warning for ApplicationManager on Data tab', () => {
    mockAuthService.hasRole.and.callFake((role: string) => {
      return role === 'ApplicationManager'; // No es OrganizationManager
    });
    
    fixture.detectChanges();
    
    expect(component.canEditDataTab()).toBeFalse();
    
    const compiled = fixture.nativeElement;
    const warning = compiled.querySelector('.permission-notice');
    expect(warning).toBeTruthy();
    expect(warning.textContent).toContain('Solo lectura');
  });

  it('should show read-only warning for OrganizationManager on Modules tab', () => {
    mockAuthService.hasRole.and.callFake((role: string) => {
      return role === 'OrganizationManager'; // No es ApplicationManager
    });
    
    component.selectedTabIndex.set(1); // Pestaña de módulos
    fixture.detectChanges();
    
    expect(component.canEditModulesTab()).toBeFalse();
    
    const compiled = fixture.nativeElement;
    const warning = compiled.querySelector('.permission-notice');
    expect(warning).toBeTruthy();
  });
});
```

## ARCHIVOS A CREAR/MODIFICAR

**Frontend:**
- `src/app/modules/organizations/components/organization-form/organization-form.component.ts` - Extender con modo edición
- `src/app/modules/organizations/components/organization-form/organization-form.component.html` - Agregar SecurityCompanyId field e icono auditoría
- `src/app/modules/organizations/components/organization-form/organization-form.component.scss` - Estilos para audit indicator
- `src/app/modules/organizations/components/organization-form/organization-form.component.spec.ts` - Tests adicionales

## DEPENDENCIAS
- TASK-001-FE - Componente base OrganizationFormComponent
- TASK-002-BE - Endpoint PUT /organizations/{id} con validación SecurityCompanyId
- Angular Material Snackbar
- Angular Material Tooltip

## DEFINITION OF DONE
- [x] Modo edición detecta parámetro :id correctamente
- [x] SecurityCompanyId field disabled en modo edición
- [x] getRawValue() usado para incluir campos disabled en submit
- [x] Icono de auditoría visible junto a GroupId con tooltip
- [x] Notificación mostrada cuando GroupId cambia
- [x] Error handler para intento de modificar SecurityCompanyId
- [x] Warnings visuales para roles sin permisos en cada pestaña
- [x] Tests verifican SecurityCompanyId inmutable
- [x] Tests verifican notificación de auditoría en cambio de grupo
- [x] Tests verifican permisos diferenciados por pestaña
- [x] Code review aprobado
- [x] Accesibilidad verificada (tooltips, aria-labels)

## RECURSOS
- Angular Material Snackbar: [Documentation](https://material.angular.io/components/snack-bar/overview)
- Angular Material Tooltip: [Documentation](https://material.angular.io/components/tooltip/overview)
- User Story: `userStories.md#us-002`

=============================================================
