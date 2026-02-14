import { Directive, Input } from '@angular/core';
import { UntypedFormControl, NG_VALIDATORS } from '@angular/forms';

@Directive({
  selector: '[customMax][formControlName],[customMax][formControl],[customMax][ngModel]',
  providers: [{ provide: NG_VALIDATORS, useExisting: CustomMaxDirective, multi: true }],
  standalone: true
})
export class CustomMaxDirective {
  @Input()
  customMax: number;

  validate(c: UntypedFormControl): { [key: string]: any } {
    const v = c.value;
    return v > this.customMax ? { customMax: true } : null;
  }
}
