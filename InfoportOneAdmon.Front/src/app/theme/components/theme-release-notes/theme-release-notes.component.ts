import { OnInit, Component, Output, EventEmitter } from '@angular/core';
import { TranslateModule } from '@ngx-translate/core';

@Component({
  selector: 'theme-release-notes',
  template: ` <div class="container-fluid">
    @for (patch of patches; track patch.version) {
      <div class="patch">
        <span class="info">
          {{ 'UPDATE_OF' | translate }} {{ patch.dateString }} ({{ 'PATCH' | translate }} {{ patch.version }})
        </span>
        <div class="notes" [innerHTML]="patch.notes"></div>
      </div>
    }
  </div>`,
  imports: [TranslateModule]
})
export class ThemeReleaseNotesComponent implements OnInit {
  @Output() closeWindow: EventEmitter<any> = new EventEmitter<any>();

  patches: Array<Patch> = [];

  ngOnInit(): void {
    this.patches = [
      new Patch({
        date: new Date(),
        notes: this.getParagraphs('Change 5'),
        version: '0.0.8'
      }),
      new Patch({
        date: new Date(),
        notes: this.getParagraphs('Change 4'),
        version: '0.0.7'
      }),
      new Patch({
        date: new Date(),
        notes: this.getParagraphs('Change 1 \n Change 2 \n Change 3'),
        version: '0.0.6'
      })
    ];
  }

  getParagraphs(text: string): string {
    text = text.replace(new RegExp('\n', 'g'), '<br /><br />');
    return text;
  }
}

export class Patch {
  date: Date;
  dateString: string;
  version: string;
  notes: string;

  constructor(values: { date: Date; version: string; notes: string }) {
    this.date = values.date;
    this.dateString = values.date.toLocaleDateString();
    this.version = values.version;
    this.notes = values.notes;
  }
}
