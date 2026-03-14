import { TestBed } from '@angular/core/testing';
import { Router } from '@angular/router';
import { firstValueFrom, isObservable, of } from 'rxjs';

import { AccessService } from '@app/theme/access/access.service';
import { mastersGuard } from './masters.guard';

describe('mastersGuard', () => {
  const routerMock = {
    navigate: jasmine.createSpy('navigate'),
  };

  const accessServiceMock = {
    mastersAccess: jasmine.createSpy('mastersAccess').and.returnValue(true),
    hasPermission: jasmine.createSpy('hasPermission').and.callFake((check: () => boolean) => of(check())),
  };

  beforeEach(() => {
    routerMock.navigate.calls.reset();
    accessServiceMock.mastersAccess.calls.reset();
    accessServiceMock.hasPermission.calls.reset();

    TestBed.configureTestingModule({
      providers: [
        { provide: Router, useValue: routerMock },
        { provide: AccessService, useValue: accessServiceMock },
      ],
    });
  });

  async function resolveGuardResult(result: any): Promise<any> {
    if (isObservable(result)) {
      return firstValueFrom(result);
    }
    if (result && typeof result.then === 'function') {
      return result;
    }
    return result;
  }

  it('allows activation when user has masters access', async () => {
    accessServiceMock.mastersAccess.and.returnValue(true);

    const allowed = await TestBed.runInInjectionContext(async () => {
      const result$ = mastersGuard({} as any, {} as any);
      return resolveGuardResult(result$);
    });

    expect(allowed).toBeTrue();
    expect(routerMock.navigate).not.toHaveBeenCalled();
  });

  it('redirects to /unauthorized when user has no masters access', async () => {
    accessServiceMock.mastersAccess.and.returnValue(false);

    const allowed = await TestBed.runInInjectionContext(async () => {
      const result$ = mastersGuard({} as any, {} as any);
      return resolveGuardResult(result$);
    });

    expect(allowed).toBeFalse();
    expect(routerMock.navigate).toHaveBeenCalledWith(['/unauthorized']);
  });
});
