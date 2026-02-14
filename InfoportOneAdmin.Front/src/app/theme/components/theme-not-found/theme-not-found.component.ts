import { Component } from '@angular/core';
import { TranslateModule } from '@ngx-translate/core';

import { MatDivider } from '@angular/material/divider';

import { ThemeSecondaryTopbarComponent } from '@app/theme/components/theme-secondary-topbar/theme-secondary-topbar.component';

/**
 * Componente página no encontrada (error 404).
 */
@Component({
  selector: 'theme-not-found',
  template: `<theme-secondary-topbar label="{{ 'PAGE_NOT_FOUND_MESSAGE' | translate }}"></theme-secondary-topbar>
    <mat-divider></mat-divider>
    <div class="h-100 d-flex justify-content-center align-items-start">
      <img alt="logo" class="logo" src="assets/images/error_page.png" />
    </div> `,
  imports: [ThemeSecondaryTopbarComponent, MatDivider, TranslateModule]
})
export class ThemeNotFoundComponent {}
