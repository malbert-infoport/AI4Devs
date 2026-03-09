import { Component, OnInit, inject } from '@angular/core';
import { Router } from '@angular/router';

import { AuthenticationService } from '@app/theme/services/authentication.service';

@Component({
  selector: 'theme-signin',
  template: ``,
  standalone: true
})
export class ThemeSigninComponent implements OnInit {
  private authService = inject(AuthenticationService);
  private router = inject(Router);

  async ngOnInit(): Promise<void> {
    try {
      await this.authService.completeLogin();
      await this.router.navigate(['/protected'], { replaceUrl: true });
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : String(error ?? '');
      const isStateError = /state/i.test(errorMessage);
      const isLogged = await this.authService.isLoggedIn().catch(() => false);

      if (isLogged) {
        await this.router.navigate(['/protected'], { replaceUrl: true });
        return;
      }

      if (isStateError) {
        await this.authService.login();
        return;
      }

      await this.router.navigate(['/internal-error'], { replaceUrl: true });
    }
  }
}
