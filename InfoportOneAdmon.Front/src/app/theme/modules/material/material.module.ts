import { NgModule } from '@angular/core';

import { MatDialogRef } from '@angular/material/dialog';
import { MAT_FORM_FIELD_DEFAULT_OPTIONS } from '@angular/material/form-field';
import { MAT_DATE_LOCALE, DateAdapter, MAT_DATE_FORMATS } from '@angular/material/core';

import { MomentDateAdapter, MAT_MOMENT_DATE_ADAPTER_OPTIONS, MAT_MOMENT_DATE_FORMATS } from '@angular/material-moment-adapter';

import { TranslateConfigService } from '@app/theme/services/translate-config.service';

import 'moment/locale/en-gb';
import 'moment/locale/es';
@NgModule({
  providers: [
    {
      provide: MAT_DATE_LOCALE,
      deps: [TranslateConfigService],
      useFactory: (translateConfigService) => translateConfigService.getMatDateLocale()
    },
    {
      provide: DateAdapter,
      useClass: MomentDateAdapter,
      deps: [MAT_DATE_LOCALE, MAT_MOMENT_DATE_ADAPTER_OPTIONS]
    },
    { provide: MAT_DATE_FORMATS, useValue: MAT_MOMENT_DATE_FORMATS },
    { provide: MAT_FORM_FIELD_DEFAULT_OPTIONS, useValue: { appearance: 'outline' } },
    {
      provide: MatDialogRef,
      useValue: {}
    }
  ]
})
export class MaterialForAngularModule {}
