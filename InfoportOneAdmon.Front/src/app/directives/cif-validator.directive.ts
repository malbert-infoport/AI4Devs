import { Directive } from '@angular/core';
import { AbstractControl, NG_VALIDATORS, ValidationErrors, Validator, ValidatorFn } from '@angular/forms';

@Directive({
  selector: '[cifValidator]',
  providers: [{ provide: NG_VALIDATORS, useExisting: CifValidatorDirective, multi: true }],
  standalone: true
})
export class CifValidatorDirective implements Validator {
  validate(control: AbstractControl): ValidationErrors | null {
    return this.cifValidator()(control);
  }

  cifValidator(): ValidatorFn {
    const cifRegex = /^[A-HJNPQRSUVW]{1}\d{7}[0-9,A-J]$/;

    return (control: AbstractControl): ValidationErrors | null => {
      const cif = control.value;

      if (!cif || cifRegex.test(cif)) {
        return null; // Retorna null si es válido
      } else {
        return { invalidCif: true }; // Retorna un objeto si es inválido
      }
    };
  }
}
