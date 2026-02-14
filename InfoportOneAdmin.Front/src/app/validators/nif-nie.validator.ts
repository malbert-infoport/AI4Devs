import { AbstractControl, ValidationErrors } from '@angular/forms';

export function validarNIFoNIE(control: AbstractControl): ValidationErrors | null {
  const valor = control.value;

  if (valor) {
    // Primero intentamos validar como NIF
    const nifError = validarNIF(control);
    if (!nifError) {
      return null; // Es un NIF válido
    }

    // Intentamos validar como NIE
    const nieError = validarNIE(control);
    if (!nieError) {
      return null; // Es un NIE válido
    }

    // Si no es ni NIF ni NIE válido, retornamos un error genérico
    return { documentoInvalido: 'El documento no es un CIF o NIE válido' };
  }

  return null; // No hay valor, por lo que no hay error
}

// Reutilizamos las funciones de validarNIF y validarNIE
export function validarNIF(control: AbstractControl): ValidationErrors | null {
  const nif = String(control.value).toUpperCase();
  const letras = 'TRWAGMYFPDXBNJZSQVHLCKET';
  const numero = parseInt(nif.substr(0, nif.length - 1), 10);
  const letra = nif.charAt(nif.length - 1);
  const letraCalculada = letras.charAt(numero % 23);

  if (letra !== letraCalculada) {
    return { nifInvalido: 'El NIF es inválido' };
  }
  return null;
}

export function validarNIE(control: AbstractControl): ValidationErrors | null {
  const nie = String(control.value).toUpperCase();
  const letras = 'TRWAGMYFPDXBNJZSQVHLCKET';
  let numero;

  if (nie.startsWith('X')) {
    numero = parseInt('0' + nie.substr(1, nie.length - 2), 10);
  } else if (nie.startsWith('Y')) {
    numero = parseInt('1' + nie.substr(1, nie.length - 2), 10);
  } else if (nie.startsWith('Z')) {
    numero = parseInt('2' + nie.substr(1, nie.length - 2), 10);
  } else {
    return { nieInvalido: 'El NIE es inválido' };
  }

  const letra = nie.charAt(nie.length - 1);
  const letraCalculada = letras.charAt(numero % 23);

  if (letra !== letraCalculada) {
    return { nieInvalido: 'El NIE es inválido' };
  }

  return null;
}
