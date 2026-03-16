import { Routes } from '@angular/router';
import { SecurityTabComponent } from '@app/modules/system-options/components/security/security-tab/security-tab.component';

export const SYSTEM_OPTIONS_ROUTES: Routes = [
  {
    path: '',
    redirectTo: 'security',
    pathMatch: 'full'
  },
  {
    path: 'security',
    component: SecurityTabComponent,
    title: 'ROUTES.SYSTEM_OPTIONS.SECURITY'
  }
];
