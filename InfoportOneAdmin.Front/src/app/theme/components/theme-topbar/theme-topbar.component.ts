import { Component, Input, OnInit, inject } from '@angular/core';
import { Router, RouterLink } from '@angular/router';
import { NgStyle, NgClass, TitleCasePipe } from '@angular/common';

import { TranslateModule } from '@ngx-translate/core';

import { MatMenuTrigger, MatMenu, MatMenuItem } from '@angular/material/menu';
import { MatTooltip } from '@angular/material/tooltip';
import { MatIcon } from '@angular/material/icon';
import { MatButton, MatIconButton } from '@angular/material/button';
import { MatToolbar } from '@angular/material/toolbar';

import { ThemeFormService } from '@app/theme/services/theme-form.service';
import { HighlightedElementService } from '@app/theme/services/highlighted-element.service';

/**
 * Componente que define el menú superior. Toda la información viene del ThemeTopBarService y el EnvConfigurationService.
 * Este servicio se inyecta en el componente ThemeLayoutComponent, en el que se incluirá este componente.
 */
@Component({
  selector: 'theme-topbar',
  templateUrl: './theme-topbar.component.html',
  imports: [
    MatToolbar,
    MatButton,
    MatIcon,
    NgStyle,
    MatIconButton,
    MatTooltip,
    RouterLink,
    NgClass,
    MatMenuTrigger,
    MatMenu,
    MatMenuItem,
    TranslateModule,
    TitleCasePipe
    
  ]
})
export class ThemeTopbarComponent implements OnInit {
  highlightedService = inject(HighlightedElementService);
  private readonly themeFormService = inject(ThemeFormService);
  //readonly delegacionService = inject(DelegacionService);
  private readonly router = inject(Router);

  /**
   * Muestra el nombre del usuario en el menú superior. Se utiliza la función getUser() del servicio ThemeTopBarService
   */

  @Input() userNameTopInput!: string;

  /**
   * Configuración de las opciones del menú superior. Se utiliza la función getTopMenu() del servicio ThemeTopBarService
   */
  @Input() topMenuInput!: Array<any>;

  /**
   * Indica en que entorno te encuentras.(Desarrollo,Producción,etc..). Lee del servicio EnvConfigurationService de la propiedad environment.
   */

  @Input() environment!: string;

  /**
   * Color, para identificar facilmente en que entorno de encuentras. Lee del servicio EnvConfigurationService de la propiedad colorEnvironment.
   */

  @Input() colorEnvironment!: string;

  name!: string;
  topMenu!: Array<any>;
  environmentTopbar!: string;
  colorEnvironmentTopbar!: string;

  /**
   * @ignore
   */
  ngOnInit() {
    this.getUserNameTop();
    this.getTopMenu();
    this.getEnvironment();
    //this.delegacionService.cargarDelegaciones();
  }

  // REVISAR (D A C)
  // setDelegacionActiva(id: number) {
  //   this.delegacionService
  //     .establecerDelegacionActiva(id)
  //     .pipe(take(1))
  //     .subscribe(() => {
  //       const currentUrl = this.router.url;
  //       /**
  //        * En caso de que cambiemos de delegación, probablemente el viaje no exista, así que lo mejor
  //        * es redirigir al listado de viajes
  //        */
  //       if (currentUrl.startsWith('/protected/viajes/')) {
  //         this.router.navigate(['/']).then(() => window.location.reload());
  //       } else {
  //         window.location.reload();
  //         // TODO: Como ahora lo tenemos con signals, podemos estar pendiente de cuando se cambie de delegación y hacer un reload de la grid.
  //         // Opcional: efecto que se ejecuta cada vez que cambia la delegación activa
  //         // effect(() => {
  //         //   const delegacion = this.delegacionActiva();
  //         //   if (delegacion) {
  //         //     console.log('Delegación activa:', delegacion);
  //         //     console.log('ID:', delegacion.id);
  //         //     console.log('Código:', delegacion.codigo);
  //         //     // console.log('Descripción:', delegacion.descripcion);
  //         //   }
  //         // });
  //       }
  //     });
  // }

  // REVISAR (D A C)
  // onDelegacionChange(event: IDelegacionView) {
  //   const idDelegacion = event.id;
  //   this.setDelegacionActiva(idDelegacion);
  // }

  /**
   * Se obtiene el nombre del usuario conectado
   */
  getUserNameTop() {
    this.name = this.userNameTopInput;
  }

  /**
   * Se obtienen los items del menú superior de la aplicación
   */
  getTopMenu() {
    this.topMenu = this.topMenuInput;
  }

  /**
   * Se obtiene el entorno de publicación
   */
  getEnvironment() {
    this.environmentTopbar = this.environment.trim();
    this.colorEnvironment = this.colorEnvironment.trim();
    this.colorEnvironmentTopbar = this.colorEnvironment ? this.colorEnvironment : '#b139c5';
  }

  /**
   * @internal Temas del funcionamiento visual del menú
   */
  highLightParent(element: any) {
    const selectedElement = this.highlightedService.getSelectedElement();

    if (selectedElement && this.highlightedService.getParentSelectedElement()) {
      this.highlightedService.getParentSelectedElement()._elementRef.nativeElement.classList.remove('highlight-parent-node');
      this.highlightedService.removeParentSelectedElement();
      this.highlightedService.collpaseSidebarNodes.emit();
    }

    if (!this.themeFormService.hasChanges()) {
      element._elementRef.nativeElement.classList.add('highlight-node');
    }

    this.highlightedService.setSelectedElement(element);

    this.highlightedService.highlightElement.subscribe(() => {
      element._elementRef.nativeElement.classList.add('highlight-node');
    });
  }
}
