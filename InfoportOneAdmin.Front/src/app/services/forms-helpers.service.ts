import { Injectable, inject } from '@angular/core';
import { AbstractControl, FormGroup, ValidationErrors } from '@angular/forms';
import { EmpleadoClient } from '@restApi/api/apiClients';

@Injectable({
  providedIn: 'root'
})
export class FormsHelpersService {
  private empleadoClient = inject(EmpleadoClient);

  /**
   * Función para validar NIF
   * @param control
   * @returns Si no cumple al patrón devuelve la key nifInvalido
   */
  validarNIF(control: AbstractControl): ValidationErrors | null {
    if (control.value) {
      const nif = String(control.value);
      const letras = 'TRWAGMYFPDXBNJZSQVHLCKET';
      const numero = parseInt(nif.substr(0, nif.length - 1), 10);
      const letra = nif.charAt(nif.length - 1);
      const letraCalculada = letras.charAt(numero % 23);

      if (letra.toUpperCase() !== letraCalculada) {
        return { nifInvalido: 'El nif es inválido' };
      }
    }

    return null;
  }

  /**
   * Función para validar teléfonos en España
   * @param control
   * @returns Si no cumple al patrón devuelve la key telefonoInvalido
   */
  validarTelefono(control: AbstractControl): ValidationErrors | null {
    if (control.value) {
      const telefono = control.value;
      const patron = /^(\+34|0034|34)?[6|7|8|9][0-9]{8}$/; // Patrón para teléfonos en España

      if (!patron.test(telefono)) {
        return { telefonoInvalido: 'El teléfono es inválido' };
      }
    }

    return null;
  }

  /**
   *Funcion para valida los controles del formulario que son inválidos.
   * @param form - Indicar el formulario a comprobar.
   * @returns Devuelve un Array con los nombres de los controles inválidos.
   */

  getInvalidControls(form: FormGroup) {
    const invalid = [];
    const controls = form.controls;
    for (const name in controls) {
      if (controls[name].invalid) {
        invalid.push(name);
      }
    }
    return invalid;
  }
}
