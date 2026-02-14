import { Component, Input } from '@angular/core';
import { TranslateModule } from '@ngx-translate/core';
import { MatCard, MatCardHeader, MatCardContent } from '@angular/material/card';
import { UpperCasePipe } from '@angular/common';

@Component({
  selector: 'theme-version-detail',
  template: `
    @for (d of data; track $index) {
      <mat-card appearance="outlined" class="m-3 px-0 pt-0 version">
        <mat-card-header class="p-2">{{ 'VERSION' | translate }}: {{ d.version }}</mat-card-header>
        @for (c of d.observations.changetype; track $index) {
          <mat-card-content id="fondo" class="m-0 p-2">
            <h5 class="card-title text-version mb-3 p-1">
              <span>{{ c.type | translate | uppercase }}</span>
            </h5>
            @for (m of c.module; track $index) {
              <h6 class="bg-version p-2 rounded">{{ m.name }}</h6>
              @for (d of m.description; track $index) {
                <ul class="pt-2">
                  <li>{{ d }}</li>
                </ul>
              }
            }
          </mat-card-content>
        }
      </mat-card>
    }
  `,
  imports: [MatCard, MatCardHeader, MatCardContent, TranslateModule, UpperCasePipe]
})
export class ThemeVersionDetailComponent {
  @Input() data: any;
}
