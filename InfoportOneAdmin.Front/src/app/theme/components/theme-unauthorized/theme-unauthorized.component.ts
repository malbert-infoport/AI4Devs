import { Component, inject } from '@angular/core';
import { MatDivider } from '@angular/material/divider';

import { AuthenticationService } from '@app/theme/services/authentication.service';

/**
 * Componente de acceso no autorizado (unauthorized).
 */
@Component({
  selector: 'theme-unauthorized',
  template: `<mat-divider></mat-divider>
    <div class="unauthorized-wrap">
      <div class="cloudWrapper">
        <div class="cloud cloud-1"><img alt="unauthorized-1" src="assets/images/unauthorized/cloud-1.png" /></div>
        <div class="cloud cloud-2"><img alt="unauthorized-2" src="assets/images/unauthorized/cloud-2.png" /></div>
        <div class="cloud cloud-3"><img alt="unauthorized-3" src="assets/images/unauthorized/cloud-3.png" /></div>
        <div class="cloud cloud-4"><img alt="unauthorized-4" src="assets/images/unauthorized/cloud-4.png" /></div>
      </div>
      <div class="scene-unauth"></div>
      <div class="row-flex">
        <div class="messge-unathorized">
          <h1>Unauthorized</h1>
          <p><a href="javascript:void(0)" (click)="logout()">Log out and log back in with another account.</a></p>
        </div>
      </div>
      <div class="charecter-6">
        <img alt="unauthorized" src="assets/images/unauthorized/charecter-6.png" />
        <span class="eye-6"><img alt="unauthorized-eye" src="assets/images/unauthorized/eye-6.gif" /></span>
        <span class="hand-6"> <img alt="unauthorized-hand" src="assets/images/unauthorized/hand-6.png" /> </span>
      </div>
    </div> `,
  imports: [MatDivider]
})
export class ThemeUnauthorizedComponent {
  private authService = inject(AuthenticationService);

  /**
   * @ignore.
   */
  logout() {
    this.authService.logout();
  }
}
