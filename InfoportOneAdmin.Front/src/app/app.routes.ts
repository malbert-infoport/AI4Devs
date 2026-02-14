import { Routes } from '@angular/router';

import { OidcGuardService } from '@app/theme/services/oidc-guard.service';
import { ThemeLayoutComponent } from '@app/theme/components/theme-layout/theme-layout.component';
import { ThemeVersionComponent } from '@app/theme/components/theme-version/theme-version.component';
import { ThemeUnauthorizedComponent } from '@app/theme/components/theme-unauthorized/theme-unauthorized.component';
import { ThemeIdentityServerOfflineComponent } from '@app/theme/components/theme-identity-server-offline/theme-identity-server-offline.component';
import { ThemeInternalErrorComponent } from '@app/theme/components/theme-internal-error/theme-internal-error.component';
import { ThemeNotFoundComponent } from '@app/theme/components/theme-not-found/theme-not-found.component';
import { ThemeSigninComponent } from '@app/theme/components/theme-signin/theme-signin.component';
import { ThemeSignoutComponent } from '@app/theme/components/theme-signout/theme-signout.component';

import { systemOptionsGuard } from '@app/theme/guards/system-options.guard';
import { mastersGuard } from '@app/theme/guards/masters.guard';

import { ApvNotFoundComponent } from '@app/modules/apv/components/apv-not-found/apv-not-found.component';
import { ApvGatewayTimeoutComponent } from '@app/modules/apv/components/apv-gateway-timeout/apv-gateway-timeout.component';
import { ApvMaintenanceComponent } from '@app/modules/apv/components/apv-maintenance/apv-maintenance.component';
import { ApvInternalServerErrorComponent } from '@app/modules/apv/components/apv-internal-server-error/apv-internal-server-error.component';


export const APP_ROUTES: Routes = [
  { path: '', pathMatch: 'full', redirectTo: '/protected' },
  {
    path: 'protected',
    component: ThemeLayoutComponent,
    canActivate: [OidcGuardService],
    children: [
      { path: '', redirectTo: 'one', pathMatch: 'full' },
          {
        path: 'one',
        loadChildren: () => import('@app/modules/one/one.routes').then((m) => m.ONE_ROUTES),
        canActivate: [mastersGuard],
        title: 'ROUTES.ONE.TITLE'
      },
      {
        path: 'attachments',
        loadChildren: () => import('@app/modules/masters/masters.routes').then((m) => m.MASTERS_ROUTES),
        canActivate: [mastersGuard],
        title: 'ROUTES.MASTERS.TITLE'
      },
     
      {
        path: 'system-options',
        loadChildren: () => import('@app/modules/system-options/system-options.routes').then((m) => m.SYSTEM_OPTIONS_ROUTES),
        canActivate: [systemOptionsGuard],
        title: 'ROUTES.SYSTEM_OPTIONS'
      },
      {
        path: 'apv',
        loadChildren: () => import('@app/modules/apv/apv.routes').then((m) => m.APV_ROUTES),
        title: 'ROUTES.APV.TITLE'
      },
      { path: 'version', component: ThemeVersionComponent, title: 'ROUTES.VERSION' },
      { path: '404', component: ThemeNotFoundComponent, title: 'ROUTES.NOT_FOUND' },
      { path: '**', redirectTo: '404' }
    ]
  },
  { path: 'not-found', component: ApvNotFoundComponent, title: 'ROUTES.NOT_FOUND' },
  { path: 'gateway-timeout', component: ApvGatewayTimeoutComponent, title: 'ROUTES.GATEWAY_TIMEOUT' },
  { path: 'internal-server-error', component: ApvInternalServerErrorComponent, title: 'ROUTES.INTERNAL_SERVER_ERROR' },
  { path: 'maintenance', component: ApvMaintenanceComponent, title: 'ROUTES.MAINTENANCE' },
  { path: 'unauthorized', component: ThemeUnauthorizedComponent, title: 'ROUTES.UNAUTHORIZED' },
  { path: 'oidc-offline', component: ThemeIdentityServerOfflineComponent, title: 'ROUTES.OIDC_OFFLINE' },
  { path: 'internal-error', component: ThemeInternalErrorComponent, title: 'ROUTES.INTERNAL_ERROR' },
  { path: '404', component: ThemeNotFoundComponent, title: 'ROUTES.NOT_FOUND' },
  { path: 'signin-callback', component: ThemeSigninComponent, title: 'ROUTES.SIGNIN_CALLBACK' },
  { path: 'signout-callback', component: ThemeSignoutComponent, title: 'ROUTES.SIGNOUT_CALLBACK' },
  { path: '**', redirectTo: '404' }
];
