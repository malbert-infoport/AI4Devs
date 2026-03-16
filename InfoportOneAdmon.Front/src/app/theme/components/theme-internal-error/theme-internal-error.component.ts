import { Component } from '@angular/core';
import { TranslateModule } from '@ngx-translate/core';

/**
 * Componente error interno (internal-error).
 */
@Component({
  selector: 'theme-internal-error',
  template: `<div class="h-100 d-flex justify-content-center align-items-start">
    <img alt="logo" class="logo" src="assets/images/error_page.png" />
    <span class="mat-headline-4">{{ 'INTERNAL_ERROR_MESSAGE' | translate }}</span>
    <span class="mat-headline-5">{{ 'INTERNAL_ERROR_SUBMESSAGE' | translate }}</span>
  </div> `,
  imports: [TranslateModule]
})
export class ThemeInternalErrorComponent {}
