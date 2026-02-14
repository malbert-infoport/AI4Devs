import { Component, Input } from '@angular/core';

import { ClSpinnerComponent } from '@cl/common-library/cl-spinner';

@Component({
  selector: 'theme-loading',
  templateUrl: './theme-loading.component.html',
  imports: [ClSpinnerComponent]
})
export class ThemeLoadingComponent {
  @Input() showSpinner: boolean = true;
}
