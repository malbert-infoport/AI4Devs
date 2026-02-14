import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';

import { MessageService } from '@progress/kendo-angular-l10n';
@Injectable({ providedIn: 'root' })
export class Kendoi18nMessageService extends MessageService {
  private http = inject(HttpClient);

  private static cultures = [];
  private static twoLetterLanguage: string;

  public setLanguage(culture: string) {
    Kendoi18nMessageService.twoLetterLanguage = this.getTwoLetterLanguage(culture);
    if (!Kendoi18nMessageService.cultures[Kendoi18nMessageService.twoLetterLanguage]) {
      this.http
        .get(`./assets/i18n/kendo/${Kendoi18nMessageService.twoLetterLanguage}.json`, { responseType: 'json' })
        .subscribe((i18nData: any) => {
          Kendoi18nMessageService.cultures[Kendoi18nMessageService.twoLetterLanguage] = i18nData;
          this.notify();
        });
    } else {
      this.notify();
    }
  }

  private getTwoLetterLanguage(culture: string): string {
    return culture.split('-')[0];
  }

  private get messages(): any {
    const lang = Kendoi18nMessageService.cultures[Kendoi18nMessageService.twoLetterLanguage];
    if (lang) {
      return lang.messages;
    }
  }

  public get(key: string): string {
    return !this.messages ? '' : this.messages[key];
  }
}
