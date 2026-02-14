import { Component } from '@angular/core';
import { TranslateModule } from '@ngx-translate/core';
import { RouterLink } from '@angular/router';
import { MatButton } from '@angular/material/button';

@Component({
  selector: 'apv-itnernal-server-error',
  template: `<div class="container-fluid m-0 p-0">
    <section id="layout">
      <div class="content logo"><img alt="logo" class="logoImage" src="assets/images/apv/logoApv.svg" /></div>
      <div class="content image"><img alt="error" class="errorImage" src="assets/images/apv/500_error.svg" /></div>
      <div class="content error-title">{{ 'ERRORS.500_TITLE' | translate }}</div>
      <div class="content error-text">
        <p class="text">{{ 'ERRORS.500_DESCRIPTION' | translate }}</p>
      </div>
      <div class="content error-button">
        <button type="button" mat-raised-button color="primary" [routerLink]="['/']">{{ 'GO_HOME' | translate }}</button>
      </div>
    </section>
  </div> `,
  styles: `
    #layout {
      display: flex;
      height: 100vh;
      flex-flow: column wrap;
      background-color: var(--white);
    }

    .content {
      display: flex;
      flex-direction: row;
      justify-content: center;
      align-items: center;
    }
    .logo {
      flex-grow: 0.17;
    }
    .image {
      flex-grow: 0.3;
    }
    .error-title {
      flex-grow: 0;
      font-weight: 400;
      font-size: 24px;
      line-height: 32px;
      color: var(--error-text);
    }
    .error-text {
      flex-grow: 0.1;
      font-weight: 500;
      font-style: normal;
      font-size: 14px;
      line-height: 22px;
      color: var(--error-text);
    }

    p.text {
      width: 432px;
      text-align: center;
    }

    .error-button {
      flex-grow: 0;
    }

    .logoImage {
      width: 136px;
      height: 65px;
    }

    .errorImage {
      width: 420px;
      height: 367px;
    }
  `,
  imports: [MatButton, RouterLink, TranslateModule]
})
export class ApvInternalServerErrorComponent {}
