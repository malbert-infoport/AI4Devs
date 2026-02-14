import { ApplicationConfig, importProvidersFrom, LOCALE_ID, inject, provideAppInitializer } from '@angular/core';
import { provideRouter, TitleStrategy, withComponentInputBinding } from '@angular/router';
import { HttpClient, provideHttpClient, withInterceptorsFromDi } from '@angular/common/http';
import { provideAnimationsAsync } from '@angular/platform-browser/animations/async';
import { BrowserModule } from '@angular/platform-browser';
import { LocationStrategy, PathLocationStrategy, registerLocaleData } from '@angular/common';

// import { TranslateLoader, TranslateModule, TranslateStore } from '@ngx-translate/core';
import { TranslateHttpLoader } from '@ngx-translate/http-loader';

import { APP_ROUTES } from '@app/app.routes';
import { KendoUiModule } from '@app/theme/modules/kendo-ui/kendo-ui.module';
import { MaterialForAngularModule } from '@app/theme/modules/material/material.module';
import { ThemeCoreModule } from '@app/theme/modules/core/theme-core.module';
import { EnvConfigurationService } from '@app/theme/services/env-configuration.service';
import { MastersModule } from '@app/modules/masters/masters.module';
import { DialogContainerService, DialogService } from '@progress/kendo-angular-dialog';

import { API_BASE_URL, EmpleadoClient, SecurityUserGridConfigurationClient } from '@restApi/api/apiClients';

import { BrowserAnimationsModule, provideAnimations } from '@angular/platform-browser/animations';

const getApiUrlFromConfigFn = (envConfigurationService: EnvConfigurationService): string => {
  return envConfigurationService.readConfig().apiUrl;
};

export function useFactory(http: HttpClient) {
  return new TranslateHttpLoader(http, './assets/i18n/', '.json');
}

// importar locales
import localeEs from '@angular/common/locales/es';
import localeEn from '@angular/common/locales/en';

// registrar  locales
registerLocaleData(localeEn, 'en');
registerLocaleData(localeEs, 'es');

import { ClMultiTranslateHttpLoader, ClTranslationsService, Resource } from '@cl/common-library/translate';
import { TranslateLoader, TranslateModule, TranslateService } from '@ngx-translate/core';
import { MessageService } from '@progress/kendo-angular-l10n';
import { GRID_CONFIG_CLIENT } from './services/grid-configurator-mapper-service.service';
import { TranslateTitleStrategy } from './router/translate-title.strategy';

// registerLocaleData(localeEs);

const resources: Resource[] = [{ prefix: '../assets/i18n/', suffix: '.json' }];
export function HttpLoaderFactory(_httpBackend: HttpClient) {
  return new ClMultiTranslateHttpLoader(_httpBackend, { resources: resources });
}

export function initializeApp(translateService: TranslateService) {
  return (): Promise<any> => {
    return new Promise((resolve, reject) => {
      const clLang = localStorage.getItem('cl-lang');
      const localLang = clLang?.substring(0, 2);
      translateService.setDefaultLang(clLang ?? 'es-cl');
      translateService.use(localLang ?? 'es');
      translateService.get('cl.common.accept').subscribe(() => {
        resolve(true);
      });
    });
  };
}
export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(APP_ROUTES, withComponentInputBinding()),
    provideAnimationsAsync(),
    importProvidersFrom(
      BrowserModule,
      BrowserAnimationsModule,
      TranslateModule.forRoot({
        loader: {
          provide: TranslateLoader,
          useFactory: HttpLoaderFactory,
          deps: [HttpClient]
        }
      }),
      ThemeCoreModule,
      KendoUiModule,
      MaterialForAngularModule,
      MastersModule
    ),
    EmpleadoClient,
    {
      provide: API_BASE_URL,
      useFactory: getApiUrlFromConfigFn,
      deps: [EnvConfigurationService]
    },
    {
      provide: GRID_CONFIG_CLIENT,
      useClass: SecurityUserGridConfigurationClient
    },
    {
      provide: TitleStrategy,
      useClass: TranslateTitleStrategy
    },
    provideAppInitializer(() => {
      const initializerFn = (
        (envConfigService: EnvConfigurationService) => () =>
          envConfigService.setConfig()
      )(inject(EnvConfigurationService));
      return initializerFn();
    }),
    provideAppInitializer(() => {
      const initializerFn = initializeApp(inject(TranslateService));
      return initializerFn();
    }),
    { provide: MessageService, useClass: ClTranslationsService, deps: [TranslateService] },

    { provide: LocationStrategy, useClass: PathLocationStrategy },
    provideAnimations(),
    provideHttpClient(withInterceptorsFromDi()),
    DialogService,
    DialogContainerService
  ]
};
