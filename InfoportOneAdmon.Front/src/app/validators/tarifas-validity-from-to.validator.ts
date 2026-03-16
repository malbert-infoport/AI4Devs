import { AbstractControl, ValidationErrors, ValidatorFn } from '@angular/forms';

export const rangoFechasValidator: ValidatorFn = (group: AbstractControl): ValidationErrors | null => {
  const from = group.get('validityFrom')?.value;
  const to = group.get('validityTo')?.value;

  if (!from || !to) return null;

  return new Date(to) < new Date(from) ? { rangoFechasInvalido: true } : null;
};
