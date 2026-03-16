import { NgModule } from '@angular/core';

import { MessageService } from '@progress/kendo-angular-l10n';

import { Kendoi18nMessageService } from '@app/theme/modules/kendo-ui/services/kendo-i18n-message.service';

import '@progress/kendo-angular-intl/locales/en/all';
import '@progress/kendo-angular-intl/locales/es/all';
import { ICON_SETTINGS, IconSettingsService } from '@progress/kendo-angular-icons';

import { ClIconsService } from '@cl/common-library/cl-icons';

import 'hammerjs';

import { NotificationModule } from '@progress/kendo-angular-notification';

@NgModule({
  imports: [NotificationModule],
  providers: [
    {
      provide: MessageService,
      useClass: Kendoi18nMessageService
    },
    { provide: ICON_SETTINGS, useValue: { type: 'font' } },
    { provide: IconSettingsService, useClass: ClIconsService }
  ]
})
export class KendoUiModule {}
