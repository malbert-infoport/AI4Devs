import { Injectable, inject } from '@angular/core';
import { firstValueFrom } from 'rxjs';
import {
  ApplicationClient,
  ApplicationModuleView,
  ApplicationView,
  Organization_ApplicationModuleView,
  OrganizationClient,
  OrganizationView,
} from '../../../../../../webServicesReferences/api/apiClients';

@Injectable()
export class OrganizationModulesService {
  private readonly organizationClient = inject(OrganizationClient);
  private readonly applicationClient = inject(ApplicationClient);

  private normalizeModules(modules: ApplicationModuleView[] | undefined): ApplicationModuleView[] {
    return (modules ?? [])
      .filter((module) => !module.auditDeletionDate)
      .sort((left, right) => (left.displayOrder ?? 0) - (right.displayOrder ?? 0));
  }

  async getOrganizationComplete(organizationId: number): Promise<OrganizationView> {
    return firstValueFrom(this.organizationClient.getById(organizationId, 'OrganizationComplete'));
  }

  async getApplicationWithModules(appId: number): Promise<ApplicationModuleView[]> {
    const appView = await firstValueFrom(this.applicationClient.getById(appId, 'ApplicationWithModules'));

    return this.normalizeModules(appView.applicationModule);
  }

  async getAllApplicationsWithModules(): Promise<ApplicationView[]> {
    const apps = await firstValueFrom(this.applicationClient.getAll('ApplicationWithModules', false));

    return (apps ?? [])
      .filter((app) => !app.auditDeletionDate)
      .sort((left, right) => (left.appName ?? '').localeCompare(right.appName ?? ''))
      .map(
        (app) =>
          new ApplicationView({
            ...app,
            applicationModule: this.normalizeModules(app.applicationModule),
          })
      );
  }

  buildOrganizationPayloadForAppSelection(
    organization: OrganizationView,
    appId: number,
    selectedModuleIds: number[],
    appModuleIds: number[]
  ): OrganizationView {
    const appModuleIdsSet = new Set(appModuleIds);
    const otherAssignments = (organization.organization_ApplicationModule ?? []).filter(
      (assignment) => {
        const assignmentAppId = assignment.applicationModule?.applicationId;
        const assignmentModuleId = assignment.applicationModuleId;
        const belongsToEditedApp = assignmentAppId === appId || (assignmentModuleId != null && appModuleIdsSet.has(assignmentModuleId));
        return !belongsToEditedApp;
      }
    );

    const newAssignments = selectedModuleIds.map(
      (moduleId) =>
        new Organization_ApplicationModuleView({
          applicationModuleId: moduleId,
          organizationId: organization.id,
        })
    );

    const payload = new OrganizationView(organization);
    payload.organization_ApplicationModule = [...otherAssignments, ...newAssignments];

    return payload;
  }

  async saveOrganizationModules(payload: OrganizationView): Promise<OrganizationView> {
    return firstValueFrom(this.organizationClient.update(payload, 'OrganizationComplete', true));
  }
}
