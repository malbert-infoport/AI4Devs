import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';

import { EnvConfigInterface } from '@app/theme/models/env-config.model';

import { lastValueFrom } from 'rxjs';

/**
 * Servicio que lee al archivo de configuración de la aplicación (/assets/config/config.json)
 */
@Injectable({
  providedIn: 'root'
})
export class EnvConfigurationService {
  private http = inject(HttpClient);

  private readonly CONFIG_URL = 'assets/config/config.json';
  private configuration: any;

  async setConfig(): Promise<EnvConfigInterface | undefined> {
    try {
      const config = await lastValueFrom(this.http.get<EnvConfigInterface>(`${this.CONFIG_URL}`));
      this.configuration = config;
      return config;
    } catch (error) {
      // Handle error here
      console.error(error);
    }
    return undefined; // Add return statement for undefined case
  }

  readConfig(): EnvConfigInterface {
    return this.configuration;
  }
}
