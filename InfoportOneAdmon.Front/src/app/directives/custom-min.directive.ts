import { Directive, Input } from '@angular/core';
import { UntypedFormControl, NG_VALIDATORS } from '@angular/forms';

@Directive({
  selector: '[customMin][formControlName],[customMin][formControl],[customMin][ngModel]',
  providers: [{ provide: NG_VALIDATORS, useExisting: CustomMinDirective, multi: true }],
  standalone: true
})
export class CustomMinDirective {
  @Input()
  customMin: number;

  validate(c: UntypedFormControl): { [key: string]: any } {
    const v = c.value;
    return v < this.customMin ? { customMin: true } : null;
  }
}
