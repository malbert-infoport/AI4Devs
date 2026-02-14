import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root'
})
export class ThemeFilesService {
  archivoBase64: string | undefined;

  /** Devuelve el archivo en base64 */
  uploadFile(event: any): Promise<string> {
    if (event?.target.files) {
      const fichero: any = event.target.files[0];

      return new Promise<string>((resolve, reject) => {
        const reader = new FileReader();

        reader.onload = () => {
          const base64String = reader.result as string;
          resolve(base64String);
        };

        reader.onerror = () => {
          reject(new Error('Error al leer el archivo.'));
        };

        reader.readAsDataURL(fichero);
        event.target.value = ''; // Reinicia el campo de entrada de tipo file
      });
    }
  }

  downloadFile(base64: string, name: string, extension: string) {
    const byteCharacters = window.atob(base64);
    const byteNumbers = new Array(byteCharacters.length);
    for (let i = 0; i < byteCharacters.length; i++) {
      byteNumbers[i] = byteCharacters.charCodeAt(i);
    }
    const byteArray = new Uint8Array(byteNumbers);

    const blob = new Blob([byteArray], { type: 'application/octet-stream' });

    const url = URL.createObjectURL(blob);

    const link = document.createElement('a');
    link.href = url;
    link.download = `${name}.${extension}`;
    link.click();

    URL.revokeObjectURL(url);
  }

  convertBytesToKB(bytes: number) {
    const kb: number = bytes / 1024;
    return Math.round(kb);
  }
}
