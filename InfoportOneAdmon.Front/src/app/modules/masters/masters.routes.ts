import { Routes } from '@angular/router';
import { AttachmentsTabComponent } from './components/attachments/attachments-tab.component';
import { ThemeAttachmentsManagementComponent } from '@app/theme/components/theme-attachments-management/theme-attachments-management.component';

export const MASTERS_ROUTES: Routes = [
  {
    path: 'attachments',
    component: AttachmentsTabComponent
  },
  {
    path:'attachments-management',
    component: ThemeAttachmentsManagementComponent
  }
];
