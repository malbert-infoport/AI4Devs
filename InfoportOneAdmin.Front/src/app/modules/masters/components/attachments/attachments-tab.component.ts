import { Component } from '@angular/core';
import { UpperCasePipe } from '@angular/common';
import { TranslateModule } from '@ngx-translate/core';
import { TabStripModule } from '@progress/kendo-angular-layout';
import { ThemeSecondaryTopbarComponent } from '@app/theme/components/theme-secondary-topbar/theme-secondary-topbar.component';
import { AttachmentTypeGridComponent } from '@app/modules/masters/components/attachments/attachmentType/attachment-type-grid/attachment-type-grid.component';

@Component({
  selector: 'attachments',
  templateUrl: './attachments-tab.component.html',
  standalone: true,
  imports: [ThemeSecondaryTopbarComponent, TabStripModule, AttachmentTypeGridComponent, TranslateModule, UpperCasePipe]
})
export class AttachmentsTabComponent {}
