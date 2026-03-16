import { TestBed } from '@angular/core/testing';
import { of } from 'rxjs';
import {
  ApplicationClient,
  ApplicationModuleView,
  ApplicationView,
  Organization_ApplicationModuleView,
  OrganizationClient,
  OrganizationView,
} from '../../../../../../webServicesReferences/api/apiClients';
import { OrganizationModulesService } from './organization-modules.service';

describe('OrganizationModulesService', () => {
  let service: OrganizationModulesService;

  const organizationClientMock = {
    getById: jasmine.createSpy('getById').and.returnValue(of(new OrganizationView({ id: 10 }))),
    update: jasmine.createSpy('update').and.returnValue(of(new OrganizationView({ id: 10 }))),
  };

  const applicationClientMock = {
    getById: jasmine.createSpy('getById').and.callFake(() =>
      of(
        new ApplicationView({
          id: 1,
          applicationModule: [
            new ApplicationModuleView({ id: 3, moduleName: 'C', displayOrder: 3 }),
            new ApplicationModuleView({ id: 1, moduleName: 'A', displayOrder: 1 }),
            new ApplicationModuleView({ id: 2, moduleName: 'B', displayOrder: 2, auditDeletionDate: new Date() }),
          ],
        })
      )
    ),
    getAll: jasmine.createSpy('getAll').and.callFake(() =>
      of([
        new ApplicationView({
          id: 2,
          appName: 'Zeta',
          applicationModule: [new ApplicationModuleView({ id: 20, displayOrder: 2 })],
        }),
        new ApplicationView({
          id: 1,
          appName: 'Alpha',
          applicationModule: [
            new ApplicationModuleView({ id: 10, displayOrder: 2 }),
            new ApplicationModuleView({ id: 11, displayOrder: 1 }),
            new ApplicationModuleView({ id: 12, displayOrder: 3, auditDeletionDate: new Date() }),
          ],
        }),
        new ApplicationView({
          id: 3,
          appName: 'DeletedApp',
          auditDeletionDate: new Date(),
          applicationModule: [new ApplicationModuleView({ id: 30, displayOrder: 1 })],
        }),
      ])
    ),
  };

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [
        OrganizationModulesService,
        { provide: OrganizationClient, useValue: organizationClientMock },
        { provide: ApplicationClient, useValue: applicationClientMock },
      ],
    });

    service = TestBed.inject(OrganizationModulesService);
  });

  it('should call OrganizationClient.getById with OrganizationComplete', async () => {
    await service.getOrganizationComplete(77);

    expect(organizationClientMock.getById).toHaveBeenCalledWith(77, 'OrganizationComplete');
  });

  it('should load app modules sorted and excluding soft-deleted rows', async () => {
    const modules = await service.getApplicationWithModules(1);

    expect(applicationClientMock.getById).toHaveBeenCalledWith(1, 'ApplicationWithModules');
    expect(modules.length).toBe(2);
    expect(modules[0].id).toBe(1);
    expect(modules[1].id).toBe(3);
  });

  it('should load all active applications with normalized modules', async () => {
    const apps = await service.getAllApplicationsWithModules();

    expect(applicationClientMock.getAll).toHaveBeenCalledWith('ApplicationWithModules', false);
    expect(apps.length).toBe(2);
    expect(apps[0].appName).toBe('Alpha');
    expect(apps[1].appName).toBe('Zeta');
    expect(apps[0].applicationModule?.map((x) => x.id)).toEqual([11, 10]);
  });

  it('should build payload replacing only selected app assignments', () => {
    const organization = new OrganizationView({
      id: 10,
      organization_ApplicationModule: [
        new Organization_ApplicationModuleView({
          applicationModuleId: 111,
          applicationModule: new ApplicationModuleView({ applicationId: 1 }),
        }),
        new Organization_ApplicationModuleView({
          applicationModuleId: 222,
          applicationModule: new ApplicationModuleView({ applicationId: 2 }),
        }),
      ],
    });

    const payload = service.buildOrganizationPayloadForAppSelection(organization, 1, [333, 444], [111, 333, 444]);
    const assignmentIds = (payload.organization_ApplicationModule ?? []).map((x) => x.applicationModuleId);

    expect(assignmentIds).toEqual([222, 333, 444]);
  });

  it('should replace assignments by appModuleIds when navigation data is missing', () => {
    const organization = new OrganizationView({
      id: 10,
      organization_ApplicationModule: [
        new Organization_ApplicationModuleView({ applicationModuleId: 111 }),
        new Organization_ApplicationModuleView({ applicationModuleId: 222 }),
      ],
    });

    const payload = service.buildOrganizationPayloadForAppSelection(organization, 1, [333], [111, 333]);
    const assignmentIds = (payload.organization_ApplicationModule ?? []).map((x) => x.applicationModuleId);

    expect(assignmentIds).toEqual([222, 333]);
  });

  it('should call update with OrganizationComplete and reloadView=true', async () => {
    const payload = new OrganizationView({ id: 10 });

    await service.saveOrganizationModules(payload);

    expect(organizationClientMock.update).toHaveBeenCalledWith(payload, 'OrganizationComplete', true);
  });
});
