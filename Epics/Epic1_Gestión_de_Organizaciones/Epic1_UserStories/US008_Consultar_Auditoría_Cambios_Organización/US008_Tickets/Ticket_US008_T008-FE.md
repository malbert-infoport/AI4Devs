# TASK-008-FE: Implementar pestaña de auditoría con cambios críticos

=============================================================
**TICKET ID:** TASK-008-FE  
**EPIC:** Gestión del Portfolio de Organizaciones Clientes  
**USER STORY:** US-008 - Consultar histórico de cambios críticos  
**COMPONENT:** Frontend - Angular  
**PRIORITY:** Media  
**ESTIMATION:** 4 horas  
=============================================================

## TÍTULO
Implementar pestaña de auditoría mostrando solo cambios críticos con columna de usuario

## DESCRIPCIÓN
Crear componente para la tercera pestaña del formulario de organización que muestra el histórico de cambios críticos registrados en AUDIT_LOG.

**Pestaña 3 - Auditoría:**
- Visible para: OrganizationManager y ApplicationManager (solo lectura)
- Grid con columnas: Fecha/Hora, Acción (traducida), Usuario, Detalles
- Solo muestra 6 acciones críticas auditadas
- Columna Usuario muestra "Sistema" cuando UserId es NULL (auto-baja)
- Ordenado por fecha descendente (más reciente primero)

**Acciones críticas traducidas:**
1. `ModuleAssigned` → "Módulo asignado"
2. `ModuleRemoved` → "Módulo removido"
3. `OrganizationDeactivatedManual` → "Dada de baja (manual)"
4. `OrganizationAutoDeactivated` → "Dada de baja (automática)"
5. `OrganizationReactivatedManual` → "Dada de alta"
6. `GroupChanged` → "Cambio de grupo"

**Visual:**
- Filas con acciones automáticas (UserId=NULL) en gris claro
- Icon indicator: Diferentes iconos por tipo de acción
- Sin paginación (máximo 100 registros recientes)

## CONTEXTO TÉCNICO
- **Componente**: AuditHistoryComponent standalone
- **API**: GET /organizations/{id}/audit
- **Grid**: Kendo Grid simple sin edición
- **Traducciones**: Pipe personalizado para traducir Actions
- **Formato**: Pipes de Angular para fecha/hora localizados

## CRITERIOS DE ACEPTACIÓN TÉCNICOS
- [ ] AuditHistoryComponent creado
- [ ] Grid con 4 columnas (Fecha/Hora, Acción, Usuario, Detalles)
- [ ] Pipe ActionTranslationPipe para traducir acciones
- [ ] Columna Usuario muestra "Sistema" cuando UserId es NULL
- [ ] Indicadores visuales por tipo de acción (iconos)
- [ ] Ordenación por fecha descendente
- [ ] Filas de acciones automáticas con estilo diferenciado
- [ ] Tests unitarios del pipe de traducción
- [ ] Tests de renderizado condicional de usuario

## GUÍA DE IMPLEMENTACIÓN

### Paso 1: Crear Pipe de Traducción

Archivo: `src/app/shared/pipes/action-translation.pipe.ts`

```typescript
import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
  name: 'actionTranslation',
  standalone: true
})
export class ActionTranslationPipe implements PipeTransform {
  private translations: Record<string, { label: string; icon: string; color: string }> = {
    'ModuleAssigned': {
      label: 'Módulo asignado',
      icon: 'add_circle',
      color: '#4caf50'
    },
    'ModuleRemoved': {
      label: 'Módulo removido',
      icon: 'remove_circle',
      color: '#f44336'
    },
    'OrganizationDeactivatedManual': {
      label: 'Dada de baja (manual)',
      icon: 'block',
      color: '#ff9800'
    },
    'OrganizationAutoDeactivated': {
      label: 'Dada de baja (automática)',
      icon: 'sync_disabled',
      color: '#9e9e9e'
    },
    'OrganizationReactivatedManual': {
      label: 'Dada de alta',
      icon: 'check_circle',
      color: '#2196f3'
    },
    'GroupChanged': {
      label: 'Cambio de grupo',
      icon: 'swap_horiz',
      color: '#673ab7'
    }
  };

  transform(action: string, property: 'label' | 'icon' | 'color' = 'label'): string {
    return this.translations[action]?.[property] || action;
  }
}
```

### Paso 2: Crear Componente de Auditoría

Archivo: `src/app/modules/organizations/components/audit-history/audit-history.component.ts`

```typescript
import { Component, Input, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { GridModule } from '@progress/kendo-angular-grid';
import { MatIconModule } from '@angular/material/icon';
import { MatTooltipModule } from '@angular/material/tooltip';
import { AuditLogService } from '../../services/audit-log.service';
import { ActionTranslationPipe } from '@shared/pipes/action-translation.pipe';

interface AuditEntry {
  id: number;
  action: string;
  timestamp: Date;
  userId: number | null;
  userName?: string;
  correlationId: string;
}

@Component({
  selector: 'app-audit-history',
  standalone: true,
  imports: [
    CommonModule,
    GridModule,
    MatIconModule,
    MatTooltipModule,
    ActionTranslationPipe
  ],
  templateUrl: './audit-history.component.html',
  styleUrls: ['./audit-history.component.scss']
})
export class AuditHistoryComponent implements OnInit {
  @Input({ required: true }) organizationId!: number;

  auditEntries = signal<AuditEntry[]>([]);
  loading = signal(false);

  constructor(private auditLogService: AuditLogService) {}

  ngOnInit(): void {
    this.loadAuditHistory();
  }

  private loadAuditHistory(): void {
    this.loading.set(true);
    
    this.auditLogService.getOrganizationAudit(this.organizationId).subscribe({
      next: (entries) => {
        // Ordenar por fecha descendente (más reciente primero)
        const sorted = entries.sort((a, b) => 
          new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime()
        );
        
        this.auditEntries.set(sorted);
        this.loading.set(false);
      },
      error: (err) => {
        console.error('Error al cargar auditoría', err);
        this.loading.set(false);
      }
    });
  }

  getUserDisplay(entry: AuditEntry): string {
    if (entry.userId === null) {
      return 'Sistema';
    }
    return entry.userName || `Usuario ${entry.userId}`;
  }

  isSystemAction(entry: AuditEntry): boolean {
    return entry.userId === null;
  }

  getRowClass = (context: any): string => {
    const entry = context.dataItem as AuditEntry;
    return this.isSystemAction(entry) ? 'row-system-action' : '';
  };
}
```

### Paso 3: Template HTML

Archivo: `src/app/modules/organizations/components/audit-history/audit-history.component.html`

```html
<div class="audit-history-container">
  <div class="audit-header">
    <h3>Histórico de Cambios Críticos</h3>
    <p class="audit-description">
      Solo se muestran cambios en permisos, activación/desactivación y grupo
    </p>
  </div>

  @if (auditEntries().length === 0 && !loading()) {
    <div class="empty-state">
      <mat-icon>history</mat-icon>
      <p>No hay cambios críticos registrados</p>
    </div>
  } @else {
    <kendo-grid
      [data]="auditEntries()"
      [loading]="loading()"
      [rowClass]="getRowClass">
      
      <!-- Fecha y Hora -->
      <kendo-grid-column title="Fecha y Hora" [width]="180">
        <ng-template kendoGridCellTemplate let-dataItem>
          {{ dataItem.timestamp | date:'dd/MM/yyyy HH:mm:ss' }}
        </ng-template>
      </kendo-grid-column>

      <!-- Acción -->
      <kendo-grid-column title="Acción" [width]="250">
        <ng-template kendoGridCellTemplate let-dataItem>
          <div class="action-cell">
            <mat-icon 
              [style.color]="dataItem.action | actionTranslation:'color'"
              [matTooltip]="dataItem.action">
              {{ dataItem.action | actionTranslation:'icon' }}
            </mat-icon>
            <span>{{ dataItem.action | actionTranslation:'label' }}</span>
          </div>
        </ng-template>
      </kendo-grid-column>

      <!-- Usuario -->
      <kendo-grid-column title="Usuario" [width]="150">
        <ng-template kendoGridCellTemplate let-dataItem>
          <div class="user-cell" [class.system-user]="isSystemAction(dataItem)">
            @if (isSystemAction(dataItem)) {
              <mat-icon class="system-icon">settings</mat-icon>
            } @else {
              <mat-icon class="user-icon">person</mat-icon>
            }
            <span>{{ getUserDisplay(dataItem) }}</span>
          </div>
        </ng-template>
      </kendo-grid-column>

      <!-- Detalles (CorrelationId para agrupar) -->
      <kendo-grid-column title="Detalles" [width]="200">
        <ng-template kendoGridCellTemplate let-dataItem>
          <span class="correlation-id">
            {{ dataItem.correlationId ? 'ID: ' + dataItem.correlationId.substring(0, 8) : '-' }}
          </span>
        </ng-template>
      </kendo-grid-column>
    </kendo-grid>
  }
</div>
```

### Paso 4: Estilos

Archivo: `src/app/modules/organizations/components/audit-history/audit-history.component.scss`

```scss
.audit-history-container {
  padding: 24px;
}

.audit-header {
  margin-bottom: 24px;

  h3 {
    margin: 0 0 8px 0;
    font-size: 18px;
    font-weight: 500;
  }

  .audit-description {
    margin: 0;
    color: #757575;
    font-size: 14px;
  }
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 64px 32px;
  background-color: #f5f5f5;
  border-radius: 8px;

  mat-icon {
    font-size: 64px;
    width: 64px;
    height: 64px;
    color: #bdbdbd;
    margin-bottom: 16px;
  }

  p {
    margin: 0;
    color: #757575;
    font-size: 16px;
  }
}

// Row styling para acciones del sistema
::ng-deep {
  .row-system-action {
    background-color: #fafafa !important;
    font-style: italic;
    
    td {
      opacity: 0.8;
    }
  }
}

.action-cell {
  display: flex;
  align-items: center;
  gap: 12px;

  mat-icon {
    font-size: 20px;
    width: 20px;
    height: 20px;
  }

  span {
    font-weight: 500;
  }
}

.user-cell {
  display: flex;
  align-items: center;
  gap: 8px;

  .system-icon {
    color: #9e9e9e;
  }

  .user-icon {
    color: #2196f3;
  }

  &.system-user {
    color: #757575;
    font-style: italic;
  }
}

.correlation-id {
  font-family: monospace;
  font-size: 12px;
  color: #757575;
}
```

### Paso 5: Servicio

Archivo: `src/app/modules/organizations/services/audit-log.service.ts`

```typescript
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class AuditLogService {
  private apiUrl = '/api/organizations';

  constructor(private http: HttpClient) {}

  getOrganizationAudit(organizationId: number): Observable<AuditEntry[]> {
    return this.http.get<AuditEntry[]>(
      `${this.apiUrl}/${organizationId}/audit`
    );
  }
}
```

### Paso 6: Integrar en Formulario

Archivo: `src/app/modules/organizations/components/organization-form/organization-form.component.html`

```html
<!-- Agregar tercera pestaña -->
<mat-tab label="Auditoría">
  <div class="tab-content">
    @if (!isEditMode()) {
      <div class="info-message">
        <mat-icon>info</mat-icon>
        <p>La auditoría estará disponible después de crear la organización.</p>
      </div>
    } @else {
      <app-audit-history [organizationId]="organizationId()!">
      </app-audit-history>
    }
  </div>
</mat-tab>
```

### Paso 7: Tests

Archivo: `src/app/modules/organizations/components/audit-history/audit-history.component.spec.ts`

```typescript
describe('AuditHistoryComponent', () => {
  it('should display "Sistema" for null userId', () => {
    const entry: AuditEntry = {
      id: 1,
      action: 'OrganizationAutoDeactivated',
      userId: null,
      timestamp: new Date()
    } as any;
    
    const display = component.getUserDisplay(entry);
    
    expect(display).toBe('Sistema');
  });

  it('should display user name when userId is populated', () => {
    const entry: AuditEntry = {
      id: 1,
      action: 'ModuleAssigned',
      userId: 123,
      userName: 'John Doe',
      timestamp: new Date()
    } as any;
    
    const display = component.getUserDisplay(entry);
    
    expect(display).toBe('John Doe');
  });

  it('should apply system action row class', () => {
    const entry: AuditEntry = {
      userId: null
    } as any;
    
    const rowClass = component.getRowClass({ dataItem: entry });
    
    expect(rowClass).toBe('row-system-action');
  });
});

describe('ActionTranslationPipe', () => {
  let pipe: ActionTranslationPipe;

  beforeEach(() => {
    pipe = new ActionTranslationPipe();
  });

  it('should translate ModuleAssigned to Spanish', () => {
    expect(pipe.transform('ModuleAssigned')).toBe('Módulo asignado');
  });

  it('should translate OrganizationAutoDeactivated to Spanish', () => {
    expect(pipe.transform('OrganizationAutoDeactivated')).toBe('Dada de baja (automática)');
  });

  it('should return icon for action', () => {
    expect(pipe.transform('ModuleAssigned', 'icon')).toBe('add_circle');
  });

  it('should return color for action', () => {
    expect(pipe.transform('GroupChanged', 'color')).toBe('#673ab7');
  });
});
```

## ARCHIVOS A CREAR/MODIFICAR

**Frontend:**
- `src/app/shared/pipes/action-translation.pipe.ts` - Pipe traducción
- `src/app/modules/organizations/components/audit-history/audit-history.component.ts`
- `src/app/modules/organizations/components/audit-history/audit-history.component.html`
- `src/app/modules/organizations/components/audit-history/audit-history.component.scss`
- `src/app/modules/organizations/services/audit-log.service.ts`
- `src/app/modules/organizations/components/organization-form/organization-form.component.html` - Agregar pestaña
- Tests

## DEPENDENCIAS
- TASK-001-FE - Componente padre OrganizationFormComponent
- TASK-AUDIT-SIMPLE - Endpoint GET /organizations/{id}/audit
- TASK-008-BE - Servicio backend de auditoría

## DEFINITION OF DONE
- [x] AuditHistoryComponent creado
- [x] ActionTranslationPipe implementado con 6 traducciones
- [x] Grid con 4 columnas (Fecha, Acción, Usuario, Detalles)
- [x] Columna Usuario muestra "Sistema" cuando UserId=NULL
- [x] Iconos diferentes por tipo de acción
- [x] Row styling para acciones del sistema (gris claro)
- [x] Ordenación por fecha descendente
- [x] Empty state cuando no hay registros
- [x] Integrado como tercera pestaña en formulario
- [x] Tests del pipe de traducción
- [x] Tests de renderizado de usuario
- [x] Code review aprobado
- [x] Accesibilidad verificada (tooltips, aria-labels)

## RECURSOS
- User Story: `userStories.md#us-008`
- Arquitectura: Matriz de auditoría crítica (6 acciones)

=============================================================
