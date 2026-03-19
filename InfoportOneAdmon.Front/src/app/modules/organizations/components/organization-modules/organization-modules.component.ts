import { Component, EventEmitter, Input, OnInit, Output, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { TranslateModule } from '@ngx-translate/core';
import { MatIconModule } from '@angular/material/icon';
import { take } from 'rxjs';
import {
  ApplicationClient,
  ApplicationModuleView,
  OrganizationClient,
  Organization_ApplicationModuleView,
  OrganizationView,
} from '../../../../../webServicesReferences/api/apiClients';
import { AccessService } from '@app/theme/access/access.service';
import { SharedMessageService } from '@app/theme/services/shared-message.service';
import { OrganizationModulesService } from './services/organization-modules.service';

interface OrganizationModulesAppItem {
  id: number;
  appName: string;
  description?: string;
  modulesAvailable: ApplicationModuleView[];
  assignedModuleIds: number[];
}

@Component({
  selector: 'app-organization-modules',
  standalone: true,
  imports: [CommonModule, FormsModule, TranslateModule, MatIconModule],
  providers: [OrganizationClient, ApplicationClient, OrganizationModulesService],
  templateUrl: './organization-modules.component.html',
  styleUrls: ['./organization-modules.component.scss'],
})
export class OrganizationModulesComponent implements OnInit {
  @Input() organizationId = 0;
  @Input() preloadedOrganization: OrganizationView | null = null;
  @Output() organizationModulesChanged = new EventEmitter<Organization_ApplicationModuleView[]>();

  private readonly organizationModulesService = inject(OrganizationModulesService);
  private readonly accessService = inject(AccessService);
  private readonly sharedMessageService = inject(SharedMessageService);

  organization: OrganizationView | null = null;
  apps: OrganizationModulesAppItem[] = [];
  loading = false;

  // panel state
  editingApp: OrganizationModulesAppItem | null = null;
  selectedModuleIds: number[] = [];
  loadingEditModules = false;

  canViewModules = false;
  canEditModules = false;

  constructor() {}

  async ngOnInit(): Promise<void> {
    this.refreshPermissions();
    this.accessService.permissionsReady$.pipe(take(1)).subscribe(() => this.refreshPermissions());
    if (!this.canViewModules) {
      return;
    }

    if (this.organizationId > 0) {
      await this.loadData(this.preloadedOrganization);
    }
  }

  private async loadData(preloadedOrganization?: OrganizationView | null): Promise<void> {
    this.loading = true;
    try {
      const org = preloadedOrganization ?? this.organization ?? await this.organizationModulesService.getOrganizationComplete(this.organizationId);
      this.organization = org;

      const appsCatalog = await this.organizationModulesService.getAllApplicationsWithModules();

      const assignedModuleIdsByApp = new Map<number, Set<number>>();
      (org.organization_ApplicationModule ?? []).forEach((assignment: Organization_ApplicationModuleView) => {
        const moduleId = assignment.applicationModuleId;
        const appId = assignment.applicationModule?.applicationId;
        if (!moduleId || !appId) {
          return;
        }

        if (!assignedModuleIdsByApp.has(appId)) {
          assignedModuleIdsByApp.set(appId, new Set<number>());
        }
        assignedModuleIdsByApp.get(appId)?.add(moduleId);
      });

      this.apps = appsCatalog.map((app) => ({
        id: app.id ?? 0,
        appName: app.appName ?? '',
        description: app.description,
        modulesAvailable: app.applicationModule ?? [],
        assignedModuleIds: Array.from(assignedModuleIdsByApp.get(app.id ?? 0) ?? []),
      }));

      // Keep compatibility for assignments whose app is not returned in catalog.
      const missingAppAssignments = (org.organization_ApplicationModule ?? []).filter(
        (assignment) =>
          !!assignment.applicationModule?.applicationId &&
          !this.apps.some((app) => app.id === assignment.applicationModule?.applicationId)
      );

      if (missingAppAssignments.length > 0) {
        const fallbackAppsMap = new Map<number, OrganizationModulesAppItem>();
        missingAppAssignments.forEach((assignment) => {
          const module = assignment.applicationModule;
          const app = module?.application;
          const appId = module?.applicationId;
          if (!module || !app || !appId || !module.id) {
            return;
          }

          let item = fallbackAppsMap.get(appId);
          if (!item) {
            item = {
              id: appId,
              appName: app.appName ?? '',
              description: app.description,
              modulesAvailable: [],
              assignedModuleIds: [],
            };
            fallbackAppsMap.set(appId, item);
          }

          if (!item.modulesAvailable.some((existing) => existing.id === module.id)) {
            item.modulesAvailable.push(module);
          }
          if (!item.assignedModuleIds.includes(module.id)) {
            item.assignedModuleIds.push(module.id);
          }
        });

        this.apps = [...this.apps, ...Array.from(fallbackAppsMap.values())];
      }
    } catch (err) {
      this.sharedMessageService.showError?.('Error cargando aplicaciones y módulos');
    } finally {
      this.loading = false;
    }
  }

  async openEdit(app: OrganizationModulesAppItem): Promise<void> {
    this.refreshPermissions();
    if (!app) return;
    this.editingApp = app;
    await this.loadModulesForEditingApp(app.id);
    // clone selection
    this.selectedModuleIds = [...(app.assignedModuleIds ?? [])];
  }

  private async loadModulesForEditingApp(appId: number): Promise<void> {
    if (!this.editingApp) {
      return;
    }

    this.loadingEditModules = true;
    try {
      this.editingApp.modulesAvailable = await this.organizationModulesService.getApplicationWithModules(appId);
    } catch (err) {
      this.sharedMessageService.showError?.('No se pudieron cargar los módulos de la aplicación');
    } finally {
      this.loadingEditModules = false;
    }
  }

  closeEdit() {
    this.editingApp = null;
    this.selectedModuleIds = [];
  }

  toggleModule(moduleId: number, checked?: boolean) {
    const idx = this.selectedModuleIds.indexOf(moduleId);

    if (checked === undefined) {
      if (idx >= 0) this.selectedModuleIds.splice(idx, 1);
      else this.selectedModuleIds.push(moduleId);
      return;
    }

    if (checked && idx < 0) {
      this.selectedModuleIds.push(moduleId);
      return;
    }

    if (!checked && idx >= 0) {
      this.selectedModuleIds.splice(idx, 1);
    }
  }

  async saveModules() {
    this.refreshPermissions();
    if (!this.editingApp || !this.organization) return;
    if (!this.canEditModules) return;
    if (this.loadingEditModules) return;

    const updatedAppModuleIds = this.selectedModuleIds;
    const editedAppId = this.editingApp.id;

    try {
      const editedApp = this.apps.find((app) => app.id === editedAppId);
      if (editedApp) {
        editedApp.assignedModuleIds = [...updatedAppModuleIds];
      }

      const rebuiltAssignments = this.buildAssignmentsFromApps();
      this.organization.organization_ApplicationModule = rebuiltAssignments;

      if (this.preloadedOrganization) {
        this.preloadedOrganization.organization_ApplicationModule = rebuiltAssignments;
      }

      this.organizationModulesChanged.emit([...rebuiltAssignments]);

      // No mostrar mensajes al usuario tras editar módulos — sólo preparamos los cambios
      this.closeEdit();
    } catch (err) {
      // No mostrar mensajes en caso de error aquí; dejar que el flujo superior gestione errores si procede
      this.closeEdit();
    }
  }

  getStagedAssignments(): Organization_ApplicationModuleView[] {
    return [...(this.organization?.organization_ApplicationModule ?? [])];
  }

  private refreshPermissions(): void {
    const canView = this.accessService.organizationModulesQuery();
    const canEdit = this.accessService.organizationModulesEdit();
    this.canViewModules = !!canView || !!canEdit; // write implies read
    this.canEditModules = !!canEdit;
  }

  private buildAssignmentsFromApps(): Organization_ApplicationModuleView[] {
    const organizationId = this.organization?.id ?? this.organizationId;
    const assignments: Organization_ApplicationModuleView[] = [];

    this.apps.forEach((app) => {
      (app.assignedModuleIds ?? []).forEach((moduleId) => {
        assignments.push(
          new Organization_ApplicationModuleView({
            applicationModuleId: moduleId,
            organizationId,
          })
        );
      });
    });

    return assignments;
  }
}
