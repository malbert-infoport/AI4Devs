import { APP_ROUTES } from './app.routes';
import { OidcGuardService } from '@app/theme/services/oidc-guard.service';
import { mastersGuard } from '@app/theme/guards/masters.guard';

describe('APP_ROUTES', () => {
  it('should protect /protected with OidcGuardService', () => {
    const protectedRoute = APP_ROUTES.find((r) => r.path === 'protected');

    expect(protectedRoute).toBeTruthy();
    expect(protectedRoute?.canActivate).toBeTruthy();
    expect(protectedRoute?.canActivate?.includes(OidcGuardService as any)).toBeTrue();
  });

  it('should protect /protected/home with mastersGuard', () => {
    const protectedRoute = APP_ROUTES.find((r) => r.path === 'protected');
    const homeRoute = protectedRoute?.children?.find((c) => c.path === 'home');

    expect(homeRoute).toBeTruthy();
    expect(homeRoute?.canActivate).toBeTruthy();
    expect(homeRoute?.canActivate?.includes(mastersGuard as any)).toBeTrue();
  });

  it('should protect /protected/organizations with mastersGuard', () => {
    const protectedRoute = APP_ROUTES.find((r) => r.path === 'protected');
    const organizationsRoute = protectedRoute?.children?.find((c) => c.path === 'organizations');

    expect(organizationsRoute).toBeTruthy();
    expect(organizationsRoute?.canActivate).toBeTruthy();
    expect(organizationsRoute?.canActivate?.includes(mastersGuard as any)).toBeTrue();
  });
});
