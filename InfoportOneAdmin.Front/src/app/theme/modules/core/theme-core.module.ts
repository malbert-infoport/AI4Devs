import { NgModule } from '@angular/core';
import { HTTP_INTERCEPTORS, provideHttpClient, withInterceptorsFromDi } from '@angular/common/http';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';

import { StoreModule, ActionReducerMap } from '@ngrx/store';
import { EffectsModule } from '@ngrx/effects';
import { routerReducer, RouterReducerState } from '@ngrx/router-store';

import { TranslateModule } from '@ngx-translate/core';

import { ThemeFormService } from '@app/theme/services/theme-form.service';
import { HighlightedElementService } from '@app/theme/services/highlighted-element.service';
import { OidcInterceptorService } from '@app/theme/interceptors/oidc-interceptor.service';
import { OidcGuardService } from '@app/theme/services/oidc-guard.service';
import { SecurityClient, SecurityUserGridConfigurationClient } from '@restApi/api/apiClients';

export interface State {
  router: RouterReducerState;
}

export const rootStore: ActionReducerMap<State> = {
  router: routerReducer
};

@NgModule({
  exports: [],
  imports: [
    CommonModule,
    RouterModule,
    TranslateModule,
    StoreModule.forRoot(rootStore, {
      runtimeChecks: {
        strictStateImmutability: true,
        strictActionImmutability: true
      }
    }),
    EffectsModule.forRoot([])
  ],
  providers: [
    OidcGuardService,
    ThemeFormService,
    HighlightedElementService,
    {
      provide: HTTP_INTERCEPTORS,
      useClass: OidcInterceptorService,
      multi: true
    },
    SecurityUserGridConfigurationClient,
    SecurityClient,
    provideHttpClient(withInterceptorsFromDi())
  ]
})
export class ThemeCoreModule {}
