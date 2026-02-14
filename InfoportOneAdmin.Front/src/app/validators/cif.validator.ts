import { AbstractControl, ValidationErrors } from '@angular/forms';

export function validarCIF(control: AbstractControl): ValidationErrors | null {
  //TODO: No valida bien. Revisar
  const cif = String(control.value).toUpperCase();

  // Comprobamos el formato general (letra inicial, 7 dígitos y un carácter de control)
  const cifRegex = /^[ABCDEFGHJNPQRSUVW][0-9]{7}[0-9A-J]$/;

  if (!cifRegex.test(cif)) {
    return { cifInvalido: 'El formato del CIF es inválido' };
  }

  const letrasIniciales = 'ABCDEFGHJNPQRSUVW';
  const letraInicial = cif[0];
  const numeros = cif.slice(1, -1);
  const controlCaracter = cif[cif.length - 1];

  // Validación de la letra inicial
  if (!letrasIniciales.includes(letraInicial)) {
    return { cifInvalido: 'La letra inicial del CIF es inválida' };
  }

  // Cálculo del control
  let sumaPares = 0;
  let sumaImpares = 0;

  for (let i = 0; i < numeros.length; i++) {
    const digito = parseInt(numeros[i], 10);

    if (i % 2 === 0) {
      // Posiciones impares (0-indexed)
      const doble = digito * 2;
      sumaImpares += Math.floor(doble / 10) + (doble % 10);
    } else {
      // Posiciones pares
      sumaPares += digito;
    }
  }

  const sumaTotal = sumaPares + sumaImpares;
  const digitoControlCalculado = (10 - (sumaTotal % 10)) % 10;

  // Definir la letra de control correspondiente (A-J)
  const letrasControl = 'JABCDEFGHI';
  const letraControlCalculada = letrasControl[digitoControlCalculado];

  // Validar el carácter de control final
  let controlValido = false;

  // Si la letra inicial es A, B, E o H, el carácter de control debe ser una letra
  if (['A', 'B', 'E', 'H'].includes(letraInicial)) {
    controlValido = controlCaracter === letraControlCalculada;
  } else {
    // En otros casos, el carácter de control debe ser numérico
    controlValido = controlCaracter === digitoControlCalculado.toString();
  }

  return controlValido ? null : { cifInvalido: 'El CIF es inválido' };
}
