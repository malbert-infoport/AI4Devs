import { Component, inject } from '@angular/core';
import { Router } from '@angular/router';

import { AuthenticationService } from '@app/theme/services/authentication.service';

@Component({
  selector: 'theme-signin',
  template: ``,
  standalone: true
})
export class ThemeSigninComponent {
  private authService = inject(AuthenticationService);
  private router = inject(Router);

  constructor() {
    this.authService.completeLogin().then(() => {
      this.router.navigate(['/protected'], { replaceUrl: true });
    });
  }
}
