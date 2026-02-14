import { Injectable, inject } from '@angular/core';
import { AuthenticationService } from '@app/theme/services/authentication.service';

@Injectable({
  providedIn: 'root'
})
export class OidcGuardService {
  private authService = inject(AuthenticationService);

  isLogged(): Promise<boolean> {
    return this.authService
      .isLoggedIn()
      .then((isLogged: boolean) => {
        if (!isLogged) {
          this.authService.login();
        }
        return isLogged;
      })
      .catch(() => {
        this.authService.login();
        return false;
      });
  }

  canActivate(): Promise<boolean> {
    return this.isLogged();
  }

  canLoad(): Promise<boolean> {
    return this.isLogged();
  }
}
