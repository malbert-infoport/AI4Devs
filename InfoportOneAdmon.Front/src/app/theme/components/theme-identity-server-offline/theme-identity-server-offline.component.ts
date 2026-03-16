import { Component, OnInit, inject } from '@angular/core';
import { ActivatedRoute, RouterLink } from '@angular/router';

import { MatButton } from '@angular/material/button';
import { MatDivider } from '@angular/material/divider';

import { TranslateModule } from '@ngx-translate/core';

import { ThemeSecondaryTopbarComponent } from '@app/theme/components/theme-secondary-topbar/theme-secondary-topbar.component';

/**
 * Componente error en el Identity Server (oidc-offline).
 */
@Component({
  selector: 'theme-identity-server-offline',
  template: `<theme-secondary-topbar
      label="{{ error ? error : ('IDENTITY_SERVER_CANNOT_CONNECT_MESSAGE' | translate) }}"
    ></theme-secondary-topbar>
    <mat-divider></mat-divider>
    <div class="vh-90 d-flex justify-content-center align-items-start">
      <img alt="logo" class="logo" src="assets/images/error_page.png" />
    </div>
    <div class="content error-button">
      <button type="button" mat-raised-button color="primary" [routerLink]="['/']">{{ 'GO_HOME' | translate }}</button>
    </div> `,
  imports: [ThemeSecondaryTopbarComponent, MatDivider, MatButton, RouterLink, TranslateModule]
})
export class ThemeIdentityServerOfflineComponent implements OnInit {
  private activateRoute = inject(ActivatedRoute);

  public error: string = '';

  /**
   * @ignore.
   */
  ngOnInit(): void {
    this.activateRoute.queryParams.subscribe((params) => {
      if (params) {
        this.error = params['error'];
      }
    });
  }
}
