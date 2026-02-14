import { Component, ViewChild, AfterViewInit, ChangeDetectorRef, OnInit, inject } from '@angular/core';
import { RouterOutlet } from '@angular/router';

import { MatSidenav, MatSidenavContainer, MatSidenavContent } from '@angular/material/sidenav';

import { HighlightedElementService } from '@app/theme/services/highlighted-element.service';
import { AuthenticationService } from '@app/theme/services/authentication.service';
import { ThemeLeftSidebarService } from '@app/theme/services/theme-left-sidebar.service';
import { ThemeTopBarService } from '@app/theme/services/theme-topbar.service';
import { EnvConfigurationService } from '@app/theme/services/env-configuration.service';
import { ThemeLoadingComponent } from '@app/theme/components/theme-loading/theme-loading.component';
import { ThemeLeftSidebarComponent } from '@app/theme/components/theme-left-sidebar/theme-left-sidebar.component';
import { ThemeTopbarComponent } from '@app/theme/components/theme-topbar/theme-topbar.component';

import { IAuthUser } from '@restApi/api/apiClients';

/**
 * Componente en el que se realiza la disposición de los componentes de navegación de la aplicación.ThemeLeftSidebar & ThemeTopBar
 * Es el marco de nuestra aplicación, se cargará siempre dentro de la ruta /protected configurada dentro del app-routing.module.ts
 */
@Component({
  selector: 'theme-layout',
  templateUrl: './theme-layout.component.html',
  imports: [
    ThemeLoadingComponent,
    ThemeLeftSidebarComponent,
    MatSidenavContainer,
    MatSidenav,
    MatSidenavContent,
    ThemeTopbarComponent,
    RouterOutlet
  ]
})
export class ThemeLayoutComponent implements AfterViewInit, OnInit {
  private highlightService = inject(HighlightedElementService);
  themeLeftSidebarService = inject(ThemeLeftSidebarService);
  themeTopBarService = inject(ThemeTopBarService);
  private ref = inject(ChangeDetectorRef);
  authService = inject(AuthenticationService);
  envConfigurationService = inject(EnvConfigurationService);

  /**
   * @internal
   */
  @ViewChild('sidenav') sidenav!: MatSidenav;

  user!: IAuthUser;

  /**
   * @ignore
   */
  ngOnInit() {
    this.authService.userObs.subscribe((user: IAuthUser) => {
      this.user = user;
    });
  }

  /**
   * @ignore
   */
  ngAfterViewInit(): void {
    this.ref.markForCheck();
    this.ref.detectChanges();

    this.highlightService.toggleSidenav.subscribe(() => {
      this.sidenav.toggle();
    });

    this.highlightService.closeSidenav.subscribe(() => {
      if (this.sidenav.opened) {
        this.sidenav.close();
      }
    });
  }
}
