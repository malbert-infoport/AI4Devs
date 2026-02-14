import { Component, HostListener, inject } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { Meta, Title } from '@angular/platform-browser';

import { MatSlideToggleModule } from '@angular/material/slide-toggle';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatDividerModule } from '@angular/material/divider';

import { TranslateService } from '@ngx-translate/core';

import { Kendoi18nMessageService } from '@app/theme/modules/kendo-ui/services/kendo-i18n-message.service';
import { AccessService } from '@app/theme/access/access.service';
import { DateAdapter } from '@angular/material/core';
import { ConfirmCloseService } from '@app/theme/services/confirm-close.service';
import { AuthenticationService } from '@app/theme/services/authentication.service';
import { ClModalContainerComponent } from '@cl/common-library/cl-modal';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet, MatSlideToggleModule, MatButtonModule, MatIconModule, MatDividerModule, ClModalContainerComponent],
  templateUrl: './app.component.html',
  styleUrl: './app.component.scss'
})
export class AppComponent {
  private readonly translate = inject(TranslateService);
  private readonly kendoTranslate = inject(Kendoi18nMessageService);
  private readonly authenticationService = inject(AuthenticationService);
  private readonly accessService = inject(AccessService);
  private readonly meta = inject(Meta);
  private readonly dateAdapter = inject<DateAdapter<any>>(DateAdapter);
  private readonly confirmCloseService = inject(ConfirmCloseService);

  title = 'InfoportOneAdmin 1.0';
  titleService = inject(Title);

  @HostListener('window:beforeunload')
  closeWindow() {
    // Alert the user window is closing, show alert if false;
    return !this.confirmCloseService.unSaveChanges;
  }

  constructor() {
    this.initMetaTags();
    this.initApplication();
  }

  initMetaTags() {
    this.setTitle(this.title);
    this.meta.removeTag('name="viewport"');
    this.meta.addTags([
      { name: 'viewport', content: 'width=device-width, initial-scale=1, maximum-scale=1.0, user-scalable=no' },
      { name: 'description', content: 'InfoportOneAdmin 1.0' },
      { name: 'keywords', content: 'InfoportOneAdmin, Transporte terrestre, contenedores' }
    ]);
  }

  setTitle(title: string) {
    this.titleService.setTitle(title);
  }

  initApplication() {
    this.authenticationService.init().then(() => {
      const twoLetterISOLanguage = localStorage.getItem('language')
        ? localStorage.getItem('language').split('-', 1)[0]
        : this.translate.getBrowserLang();
      this.kendoTranslate.setLanguage(twoLetterISOLanguage);
      this.dateAdapter.setLocale(twoLetterISOLanguage);

      this.accessService.init();
    });
  }
}
