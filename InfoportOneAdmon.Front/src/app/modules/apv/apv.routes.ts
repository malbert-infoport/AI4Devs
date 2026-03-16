import { Routes } from '@angular/router';
import { ApvGatewayTimeoutComponent } from '@app/modules/apv/components/apv-gateway-timeout/apv-gateway-timeout.component';
import { ApvNotFoundComponent } from '@app/modules/apv/components/apv-not-found/apv-not-found.component';
import { ApvInternalServerErrorComponent } from '@app/modules/apv/components/apv-internal-server-error/apv-internal-server-error.component';
import { ApvMaintenanceComponent } from '@app/modules/apv/components/apv-maintenance/apv-maintenance.component';

export const APV_ROUTES: Routes = [
  {
    path: '',
    component: ApvNotFoundComponent
  },
  {
    path: 'timeout',
    component: ApvGatewayTimeoutComponent,
    title: 'ROUTES.APV.GATEWAY_TIMEOUT'
  },
  {
    path: 'internal-server-error',
    component: ApvInternalServerErrorComponent,
    title: 'ROUTES.APV.INTERNAL_SERVER_ERROR'
  },
  {
    path: 'maintenance',
    component: ApvMaintenanceComponent,
    title: 'ROUTES.APV.MAINTENANCE'
  }
];
