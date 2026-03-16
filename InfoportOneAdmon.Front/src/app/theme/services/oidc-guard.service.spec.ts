import { TestBed } from '@angular/core/testing';

import { AuthenticationService } from '@app/theme/services/authentication.service';
import { OidcGuardService } from './oidc-guard.service';

describe('OidcGuardService', () => {
  let service: OidcGuardService;

  const authServiceMock = {
    isLoggedIn: jasmine.createSpy('isLoggedIn'),
    login: jasmine.createSpy('login'),
  };

  beforeEach(() => {
    authServiceMock.isLoggedIn.calls.reset();
    authServiceMock.login.calls.reset();

    TestBed.configureTestingModule({
      providers: [
        OidcGuardService,
        { provide: AuthenticationService, useValue: authServiceMock },
      ],
    });

    service = TestBed.inject(OidcGuardService);
  });

  it('returns true when user is already logged in', async () => {
    authServiceMock.isLoggedIn.and.returnValue(Promise.resolve(true));

    const result = await service.canActivate();

    expect(result).toBeTrue();
    expect(authServiceMock.login).not.toHaveBeenCalled();
  });

  it('triggers login and returns false when user is not logged in', async () => {
    authServiceMock.isLoggedIn.and.returnValue(Promise.resolve(false));

    const result = await service.canActivate();

    expect(result).toBeFalse();
    expect(authServiceMock.login).toHaveBeenCalled();
  });

  it('triggers login and returns false when isLoggedIn throws', async () => {
    authServiceMock.isLoggedIn.and.returnValue(Promise.reject(new Error('boom')));

    const result = await service.canLoad();

    expect(result).toBeFalse();
    expect(authServiceMock.login).toHaveBeenCalled();
  });
});
