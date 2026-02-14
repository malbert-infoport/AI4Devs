// translate-title.strategy.ts
import { inject, Injectable, Injector } from '@angular/core';
import { Title } from '@angular/platform-browser';
import { RouterStateSnapshot, TitleStrategy } from '@angular/router';
import { TranslateService } from '@ngx-translate/core';

@Injectable()
export class TranslateTitleStrategy extends TitleStrategy {
  private readonly injector = inject(Injector);

  override updateTitle(routerState: RouterStateSnapshot): void {
    const title = this.injector.get(Title);
    const translate = this.injector.get(TranslateService);

    const titleKey = this.buildTitle(routerState);

    if (!titleKey) return;

    translate.get(titleKey).subscribe((translatedTitle) => {
      title.setTitle(translatedTitle);
    });
  }
}
