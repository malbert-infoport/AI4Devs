import { Component, inject } from '@angular/core';
import { Router } from '@angular/router';

import { AuthenticationService } from '@app/theme/services/authentication.service';

@Component({
  selector: 'theme-signout',
  template: ``,
  standalone: true
})
export class ThemeSignoutComponent {
  private authService = inject(AuthenticationService);
  private router = inject(Router);

  ngOnInit(): void {
    this.authService.completeLogout().then(() => {
      this.router.navigate(['/'], { replaceUrl: true });
    });
  }
}
