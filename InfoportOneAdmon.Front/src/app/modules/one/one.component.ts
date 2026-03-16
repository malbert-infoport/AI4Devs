import { CommonModule } from '@angular/common';
import { Component, OnDestroy, OnInit } from '@angular/core';
import { RouterLink } from '@angular/router';
import { MatIconModule } from '@angular/material/icon';
import { MatTooltipModule } from '@angular/material/tooltip';
import { TranslateModule } from '@ngx-translate/core';
import { AccessService } from '@app/theme/access/access.service';
import { Subscription } from 'rxjs';

@Component({
  selector: 'one',
  imports: [CommonModule, RouterLink, MatIconModule, MatTooltipModule, TranslateModule],
  templateUrl: './one.component.html',
  styleUrl: './one.component.scss'
})
export class OneComponent implements OnInit, OnDestroy {
  showOrganizations = false;
  showApplications = false;

  private subs: Subscription[] = [];

  constructor(private accessService: AccessService) {}

  ngOnInit(): void {
    this.accessService.init();

    const s1 = this.accessService.hasPermission(() => this.accessService.organizationsConsulta()).subscribe((v) => (this.showOrganizations = v));
    const s2 = this.accessService.hasPermission(() => this.accessService.applicationsConsulta()).subscribe((v) => (this.showApplications = v));

    this.subs.push(s1, s2);
  }

  ngOnDestroy(): void {
    this.subs.forEach((s) => s.unsubscribe());
  }

  onCardClick(event: Event, enabled: boolean) {
    if (!enabled) {
      event.preventDefault();
      event.stopPropagation();
    }
  }

}
