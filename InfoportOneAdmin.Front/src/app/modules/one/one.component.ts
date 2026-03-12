import { CommonModule } from '@angular/common';
import { Component } from '@angular/core';
import { RouterLink } from '@angular/router';
import { MatIconModule } from '@angular/material/icon';
import { TranslateModule } from '@ngx-translate/core';

@Component({
  selector: 'one',
  imports: [CommonModule, RouterLink, MatIconModule, TranslateModule],
  templateUrl: './one.component.html',
  styleUrl: './one.component.scss'
})
export class OneComponent {

}
