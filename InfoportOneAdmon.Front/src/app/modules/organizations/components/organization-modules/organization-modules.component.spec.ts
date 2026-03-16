import { ComponentFixture, TestBed } from '@angular/core/testing';
import { TranslateService } from '@ngx-translate/core';
import { of } from 'rxjs';
import {
  ApplicationClient,
  ApplicationModuleView,
  ApplicationView,
  OrganizationClient,
  Organization_ApplicationModuleView,
  OrganizationView,
} from '../../../../../webServicesReferences/api/apiClients';
import { AccessService } from '@app/theme/access/access.service';
import { SharedMessageService } from '@app/theme/services/shared-message.service';
import { OrganizationModulesComponent } from './organization-modules.component';
import { OrganizationModulesService } from './services/organization-modules.service';

describe('OrganizationModulesComponent', () => {
  let fixture: ComponentFixture<OrganizationModulesComponent>;
  let component: OrganizationModulesComponent;

  const organizationModulesServiceMock = {
    getOrganizationComplete: jasmine.createSpy('getOrganizationComplete'),
    getAllApplicationsWithModules: jasmine.createSpy('getAllApplicationsWithModules'),
    getApplicationWithModules: jasmine.createSpy('getApplicationWithModules'),
    buildOrganizationPayloadForAppSelection: jasmine.createSpy('buildOrganizationPayloadForAppSelection'),
    saveOrganizationModules: jasmine.createSpy('saveOrganizationModules'),
  };

  const accessServiceMock = {
    permissionsReady$: of(true),
    organizationModulesQuery: jasmine.createSpy('organizationModulesQuery').and.returnValue(true),
    organizationModulesEdit: jasmine.createSpy('organizationModulesEdit').and.returnValue(true),
  };

  const sharedMessageServiceMock = {
    showError: jasmine.createSpy('showError'),
    showMessage: jasmine.createSpy('showMessage'),
  };

  const translateServiceMock = {
    instant: (key: string) => key,
  };

  beforeEach(async () => {
    TestBed.overrideComponent(OrganizationModulesComponent, {
      set: {
        providers: [
          { provide: OrganizationModulesService, useValue: organizationModulesServiceMock },
          { provide: AccessService, useValue: accessServiceMock },
          { provide: SharedMessageService, useValue: sharedMessageServiceMock },
          { provide: OrganizationClient, useValue: {} },
          { provide: ApplicationClient, useValue: {} },
        ],
      },
    });

    await TestBed.configureTestingModule({
      imports: [OrganizationModulesComponent],
      providers: [
        { provide: TranslateService, useValue: translateServiceMock },
      ],
    }).compileComponents();
  });

  beforeEach(() => {
    organizationModulesServiceMock.getOrganizationComplete.calls.reset();
    organizationModulesServiceMock.getAllApplicationsWithModules.calls.reset();
    organizationModulesServiceMock.getApplicationWithModules.calls.reset();
    organizationModulesServiceMock.buildOrganizationPayloadForAppSelection.calls.reset();
    organizationModulesServiceMock.saveOrganizationModules.calls.reset();
    accessServiceMock.organizationModulesQuery.calls.reset();
    accessServiceMock.organizationModulesEdit.calls.reset();

    accessServiceMock.organizationModulesQuery.and.returnValue(true);
    accessServiceMock.organizationModulesEdit.and.returnValue(true);

    fixture = TestBed.createComponent(OrganizationModulesComponent);
    component = fixture.componentInstance;
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should not load data when user cannot view modules', async () => {
    accessServiceMock.organizationModulesQuery.and.returnValue(false);
    accessServiceMock.organizationModulesEdit.and.returnValue(false);
    component.organizationId = 10;

    await component.ngOnInit();

    expect(organizationModulesServiceMock.getOrganizationComplete).not.toHaveBeenCalled();
    expect(component.canViewModules).toBeFalse();
  });

  it('should allow viewing modules when query is false but edit is true (write implies read)', async () => {
    accessServiceMock.organizationModulesQuery.and.returnValue(false);
    accessServiceMock.organizationModulesEdit.and.returnValue(true);
    organizationModulesServiceMock.getAllApplicationsWithModules.and.returnValue(Promise.resolve([]));

    component.organizationId = 10;
    component.preloadedOrganization = new OrganizationView({ id: 10, organization_ApplicationModule: [] });

    await component.ngOnInit();

    expect(component.canViewModules).toBeTrue();
    expect(component.canEditModules).toBeTrue();
  });

  it('should load apps from full catalog and merge assigned modules', async () => {
    const organization = new OrganizationView({
      id: 99,
      organization_ApplicationModule: [
        new Organization_ApplicationModuleView({ applicationModuleId: 201, applicationModule: new ApplicationModuleView({ id: 201, applicationId: 2 }) }),
      ],
    });

    const allApps = [
      new ApplicationView({
        id: 1,
        appName: 'App 1',
        applicationModule: [new ApplicationModuleView({ id: 101, moduleName: 'M1', applicationId: 1 })],
      }),
      new ApplicationView({
        id: 2,
        appName: 'App 2',
        applicationModule: [new ApplicationModuleView({ id: 201, moduleName: 'M2', applicationId: 2 })],
      }),
    ];

    organizationModulesServiceMock.getAllApplicationsWithModules.and.returnValue(Promise.resolve(allApps));

    component.organizationId = 99;
    component.preloadedOrganization = organization;
    await component.ngOnInit();

    expect(component.apps.length).toBe(2);
    const app1 = component.apps.find((x) => x.id === 1);
    const app2 = component.apps.find((x) => x.id === 2);

    expect(app1?.assignedModuleIds).toEqual([]);
    expect(app2?.assignedModuleIds).toEqual([201]);
    expect(organizationModulesServiceMock.getOrganizationComplete).not.toHaveBeenCalled();
  });

  it('should stage module changes locally and not call saveOrganizationModules', async () => {
    const organization = new OrganizationView({
      id: 99,
      organization_ApplicationModule: [
        new Organization_ApplicationModuleView({ applicationModuleId: 101, organizationId: 99 }),
      ],
    });
    const app = {
      id: 1,
      appName: 'App 1',
      modulesAvailable: [new ApplicationModuleView({ id: 101 }), new ApplicationModuleView({ id: 102 })],
      assignedModuleIds: [101],
    } as any;

    component.organization = organization;
    component.preloadedOrganization = organization;
    component.apps = [app];
    component.editingApp = app;
    component.selectedModuleIds = [102];

    await component.saveModules();

    expect(organizationModulesServiceMock.saveOrganizationModules).not.toHaveBeenCalled();
    expect(component.organization?.organization_ApplicationModule?.[0]?.applicationModuleId).toBe(102);
    expect(component.preloadedOrganization?.organization_ApplicationModule?.[0]?.applicationModuleId).toBe(102);
    expect(component.apps[0].assignedModuleIds).toEqual([102]);
  });
});
