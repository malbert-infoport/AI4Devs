import { TestBed } from '@angular/core/testing';
import { BehaviorSubject } from 'rxjs';

import { AccessService } from './access.service';
import { AuthenticationService } from '@app/theme/services/authentication.service';
import { Access } from './access';
import { appName } from '@app/config/config';

describe('AccessService', () => {
  let service: AccessService;

  const allPermissionsSubject = new BehaviorSubject<any[]>([]);

  const authServiceMock = {
    allPermissionsObs: allPermissionsSubject.asObservable(),
    hasPermissions: jasmine.createSpy('hasPermissions').and.callFake((permissions: any[], access: Access) => {
      if (!permissions || permissions.length === 0) return false;
      const app = permissions.find((p) => p.application === appName) ?? permissions[0];
      const list: number[] = app?.permissions ?? [];
      return list.includes(access as unknown as number);
    }),
  };

  beforeEach(() => {
    allPermissionsSubject.next([]);

    TestBed.configureTestingModule({
      providers: [
        AccessService,
        { provide: AuthenticationService, useValue: authServiceMock },
      ],
    });

    service = TestBed.inject(AccessService);
  });

  it('organizationModulesQuery should be false for 200/201 only', () => {
    service.permissions = [{ application: appName, permissions: [200, 201] }];

    expect(service.organizationModulesQuery()).toBeFalse();
  });

  it('organizationModulesQuery should be true for 202', () => {
    service.permissions = [{ application: appName, permissions: [202] }];

    expect(service.organizationModulesQuery()).toBeTrue();
  });

  it('organizationModulesQuery should be true for 204 (write implies read)', () => {
    service.permissions = [{ application: appName, permissions: [204] }];

    expect(service.organizationModulesQuery()).toBeTrue();
  });

  it('organizationModulesEdit should be true only for 204', () => {
    service.permissions = [{ application: appName, permissions: [202] }];
    expect(service.organizationModulesEdit()).toBeFalse();

    service.permissions = [{ application: appName, permissions: [204] }];
    expect(service.organizationModulesEdit()).toBeTrue();
  });

  it('hasPermission should emit based on loaded permissions from init()', (done) => {
    service.init();

    allPermissionsSubject.next([
      { application: appName, permissions: [202] },
      { application: 'other-app', permissions: [1] },
    ] as any);

    service.hasPermission(() => service.organizationModulesQuery()).subscribe((allowed) => {
      expect(allowed).toBeTrue();
      done();
    });
  });

  it('applicationsConsulta should be true when any application permission exists (300..308)', () => {
    service.permissions = [{ application: appName, permissions: [304] }];

    expect(service.applicationsConsulta()).toBeTrue();
  });
});
