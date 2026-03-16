import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ActivatedRoute, convertToParamMap, Router } from '@angular/router';
import { Location } from '@angular/common';
import { fakeAsync, tick } from '@angular/core/testing';
import { of, throwError } from 'rxjs';
import { TranslateService } from '@ngx-translate/core';

import { OrganizationFormPageComponent } from './organization-form-page.component';
import {
  OrganizationClient,
  OrganizationGroupClient,
  OrganizationView,
  OrganizationGroupView,
} from '../../../../../webServicesReferences/api/apiClients';
import { AccessService } from '@app/theme/access/access.service';
import { AuthenticationService } from '@app/theme/services/authentication.service';
import { SharedMessageService } from '@app/theme/services/shared-message.service';

describe('OrganizationFormPageComponent', () => {
  let fixture: ComponentFixture<OrganizationFormPageComponent>;
  let component: OrganizationFormPageComponent;

  const organizationClientMock = {
    getNewEntity: jasmine.createSpy('getNewEntity').and.returnValue(of(new OrganizationView({ id: 0 }))),
    getById: jasmine.createSpy('getById').and.returnValue(of(new OrganizationView({ id: 10, name: 'Org', taxId: 'A' }))),
    update: jasmine.createSpy('update').and.returnValue(of(new OrganizationView({ id: 10 }))),
    insert: jasmine.createSpy('insert').and.returnValue(of(new OrganizationView({ id: 99 }))),
  };

  const organizationGroupClientMock = {
    getAll: jasmine.createSpy('getAll').and.returnValue(of([new OrganizationGroupView({ id: 7, groupName: 'Group 7' })])),
  };

  const accessServiceMock = {
    hasPermission: jasmine.createSpy('hasPermission').and.returnValues(of(true), of(true), of(false)),
    organizationModification: jasmine.createSpy('organizationModification').and.returnValue(true),
    organizationModulesQuery: jasmine.createSpy('organizationModulesQuery').and.returnValue(true),
    organizationModulesEdit: jasmine.createSpy('organizationModulesEdit').and.returnValue(false),
  };

  const authServiceMock = {
    hasPermissions: jasmine.createSpy('hasPermissions').and.returnValue(false),
  };

  const sharedMessageServiceMock = {
    showError: jasmine.createSpy('showError'),
    showMessage: jasmine.createSpy('showMessage'),
  };

  const routerMock = {
    navigate: jasmine.createSpy('navigate'),
  };

  const locationMock = {
    back: jasmine.createSpy('back'),
  };

  const translateServiceMock = {
    instant: (key: string) => key,
  };

  const activatedRouteMock = {
    snapshot: {
      paramMap: convertToParamMap({ id: '0' }),
    },
  };

  beforeEach(async () => {
    organizationClientMock.getNewEntity.calls.reset();
    organizationClientMock.getById.calls.reset();
    organizationClientMock.update.calls.reset();
    organizationClientMock.insert.calls.reset();
    organizationGroupClientMock.getAll.calls.reset();
    routerMock.navigate.calls.reset();
    locationMock.back.calls.reset();
    sharedMessageServiceMock.showError.calls.reset();
    sharedMessageServiceMock.showMessage.calls.reset();
    authServiceMock.hasPermissions.calls.reset();

    activatedRouteMock.snapshot.paramMap = convertToParamMap({ id: '0' });

    accessServiceMock.hasPermission.calls.reset();
    accessServiceMock.hasPermission.and.returnValues(of(true), of(true), of(false));

    TestBed.overrideComponent(OrganizationFormPageComponent, {
      set: {
        template: '<div></div>',
        imports: [],
        providers: [
          { provide: OrganizationClient, useValue: organizationClientMock },
          { provide: OrganizationGroupClient, useValue: organizationGroupClientMock },
        ],
      },
    });

    await TestBed.configureTestingModule({
      imports: [OrganizationFormPageComponent],
      providers: [
        { provide: OrganizationClient, useValue: organizationClientMock },
        { provide: OrganizationGroupClient, useValue: organizationGroupClientMock },
        { provide: AccessService, useValue: accessServiceMock },
        { provide: AuthenticationService, useValue: authServiceMock },
        { provide: SharedMessageService, useValue: sharedMessageServiceMock },
        { provide: Router, useValue: routerMock },
        { provide: Location, useValue: locationMock },
        { provide: TranslateService, useValue: translateServiceMock },
        { provide: ActivatedRoute, useValue: activatedRouteMock },
      ],
    }).compileComponents();

    fixture = TestBed.createComponent(OrganizationFormPageComponent);
    component = fixture.componentInstance;
  });

  it('should create', () => {
    fixture.detectChanges();
    expect(component).toBeTruthy();
  });

  it('should disable organization data fields when missing organization modify permission (201)', () => {
    accessServiceMock.hasPermission.and.returnValues(of(false), of(true), of(false));

    fixture.detectChanges();

    expect(component.canModifyOrganization).toBeFalse();
    expect(component.organizationForm.get('name')?.disabled).toBeTrue();
    expect(component.organizationForm.get('taxId')?.disabled).toBeTrue();
    expect(component.organizationForm.get('groupId')?.disabled).toBeTrue();
  });

  it('should allow viewing modules when query is false but edit is true (write implies read)', () => {
    accessServiceMock.hasPermission.and.returnValues(of(true), of(false), of(true));

    fixture.detectChanges();

    expect(component.canEditModules).toBeTrue();
    expect(component.canViewModules).toBeTrue();
  });

  it('should normalize group object to groupId number when saving', () => {
    fixture.detectChanges();

    component.organizationId = 10;
    component.organizationForm.patchValue({
      id: 10,
      securityCompanyId: 1,
      name: 'Org',
      taxId: 'A123',
      groupId: { id: 7, groupName: 'Group 7' } as any,
    });

    component.onSave();

    expect(organizationClientMock.update).toHaveBeenCalled();
    const payload = organizationClientMock.update.calls.mostRecent().args[0] as OrganizationView;
    expect(payload.groupId).toBe(7);
  });

  it('should call getById on init when route id is greater than zero', () => {
    activatedRouteMock.snapshot.paramMap = convertToParamMap({ id: '10' });

    fixture = TestBed.createComponent(OrganizationFormPageComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();

    expect(organizationClientMock.getById).toHaveBeenCalledWith(10, 'OrganizationComplete');
  });

  it('should call getNewEntity on init when route id is zero', () => {
    activatedRouteMock.snapshot.paramMap = convertToParamMap({ id: '0' });

    fixture = TestBed.createComponent(OrganizationFormPageComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();

    expect(organizationClientMock.getNewEntity).toHaveBeenCalled();
  });

  it('should use localStorage fallback permissions when available', () => {
    accessServiceMock.hasPermission.and.returnValues(of(false), of(false), of(false));
    authServiceMock.hasPermissions.and.callFake((_: any[], permission: number) => permission === 204);
    spyOn(localStorage, 'getItem').and.callFake((key: string) => {
      if (key === 'permissions') {
        return JSON.stringify([{ application: 'infoportoneadmon', permissions: [204] }]);
      }
      return null;
    });

    fixture.detectChanges();

    expect(component.canEditModules).toBeTrue();
    expect(component.canViewModules).toBeTrue();
  });

  it('should call showError and reset saving flag when save fails', () => {
    organizationClientMock.update.and.returnValue(throwError(() => ({ title: 'boom' })));

    fixture.detectChanges();

    component.organizationId = 10;
    component.organizationForm.patchValue({
      id: 10,
      securityCompanyId: 1,
      name: 'Org',
      taxId: 'A123',
    });

    component.onSave();

    expect(component.saving).toBeFalse();
    expect(sharedMessageServiceMock.showError).toHaveBeenCalled();
  });

  it('should navigate to new organization route after successful insert', fakeAsync(() => {
    organizationClientMock.insert.and.returnValue(of(new OrganizationView({ id: 999 })));

    fixture.detectChanges();

    component.organizationId = 0;
    component.organizationForm.patchValue({
      id: 0,
      securityCompanyId: 1,
      name: 'New Org',
      taxId: 'A123',
    });

    component.onSave();
    tick();

    expect(organizationClientMock.insert).toHaveBeenCalled();
    expect(routerMock.navigate).toHaveBeenCalledWith(['/protected/organizations', 999]);
  }));
});
