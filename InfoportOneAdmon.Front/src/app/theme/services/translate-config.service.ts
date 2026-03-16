import { Injectable, inject } from '@angular/core';
import { TranslateService } from '@ngx-translate/core';

/**
 * Servicio que traduce la aplicación al lenguaje seleccionado por el usuario o utiliza el lenguaje por defecto de la aplicación
 */
@Injectable({
  providedIn: 'root'
})
export class TranslateConfigService {
  private translate = inject(TranslateService);

  supportedLanguages = ['es', 'en'];
  defaultLanguage = ['es'];
  defaultMatdateLocale = 'es-ES';

  languagePreferences = [
    {
      culture: 'es-ES',
      description: 'Spanish (Spain, International Sort)'
    },
    {
      culture: 'en-EN',
      description: 'English(United Kingdom)'
    }
  ];

  userLanguage = localStorage.getItem('language')
    ? localStorage.getItem('language').split('-', 1)[0]
    : this.translate.getBrowserLang();

  constructor() {
    this.translate.use(this.userLanguage);
  }

  /**
   *
   * @param language
   * @param reload
   */
  changeLanguage(language: string, reload?: boolean) {
    this.translate.use(language);
  }

  /**
   * @returns
   * lenguaje del localstorage y si no se encuentra se devuelve la propiedad preinicializada defaultMatdateLocale
   */
  getMatDateLocale(): string {
    return localStorage.getItem('language') ? localStorage.getItem('language') : this.defaultMatdateLocale;
  }

  /**
   * @returns
   * userLanguage que se saca del localstorage, si está entre las opciones soportadas por la aplicación (supportedLanguages) se usa, sinó se usa el valor establecido por defecto
   */
  getLanguage(): string | string[] {
    return this.supportedLanguages.includes(this.userLanguage) ? this.userLanguage : this.defaultLanguage;
  }
}
