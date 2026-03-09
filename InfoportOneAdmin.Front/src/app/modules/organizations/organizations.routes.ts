import { Routes } from '@angular/router';
import { VtaOrganizationListComponent } from './components/vta-organization-list/vta-organization-list.component';

export const ORGANIZATIONS_ROUTES: Routes = [
  {
    path: '',
    component: VtaOrganizationListComponent
  }
];
