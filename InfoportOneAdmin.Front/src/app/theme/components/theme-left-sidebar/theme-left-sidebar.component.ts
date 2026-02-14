import { Component, OnInit, OnDestroy, Input, inject } from '@angular/core';
import { RouterLink, RouterLinkActive } from '@angular/router';
import { NgClass } from '@angular/common';

import { NestedTreeControl } from '@angular/cdk/tree';

import { MatAnchor } from '@angular/material/button';
import { MatDialog } from '@angular/material/dialog';
import { MatBadge } from '@angular/material/badge';
import { MatTooltip } from '@angular/material/tooltip';
import { MatIcon } from '@angular/material/icon';
import {
  MatTree,
  MatTreeNodeDef,
  MatTreeNode,
  MatNestedTreeNode,
  MatTreeNodeToggle,
  MatTreeNodeOutlet
} from '@angular/material/tree';

import { TranslateModule, TranslateService } from '@ngx-translate/core';

import { UserSettingsComponent } from '@app/modules/system-options/components/users/user-settings/user-settings.component';
import { TitleNode, TreeNode } from '@app/theme/models/theme-left-sidebar.model';
import { SplitUserNamePipe } from '@app/theme/pipes/split-user-name.pipe';
import { ThemeReleaseNotesComponent } from '@app/theme/components/theme-release-notes/theme-release-notes.component';
import { HighlightedElementService } from '@app/theme/services/highlighted-element.service';
import { AuthenticationService } from '@app/theme/services/authentication.service';

import { of, Observable, Subscription } from 'rxjs';
import { ClModalConfig, ClModalService } from '@cl/common-library/cl-modal';
import { AccessService } from '@app/theme/access/access.service';
import { DialogRef } from '@progress/kendo-angular-dialog';
/**
 * Componente que muestra las opciones de menú en la barra lateral, toda la información viene del ThemeLeftSidebarService, servicio que se inyecta en el ThemeLayoutComponent, en el que se incluirá este componente.
 */
@Component({
  selector: 'theme-left-sidebar',
  templateUrl: './theme-left-sidebar.component.html',
  imports: [
    NgClass,
    MatTree,
    MatTreeNodeDef,
    MatTreeNode,
    MatAnchor,
    MatTooltip,
    MatIcon,
    RouterLink,
    RouterLinkActive,
    MatBadge,
    MatNestedTreeNode,
    MatTreeNodeToggle,
    MatTreeNodeOutlet,
    TranslateModule,
    SplitUserNamePipe
  ]
})
export class ThemeLeftSidebarComponent implements OnInit, OnDestroy {
  highlightService = inject(HighlightedElementService);
  authService = inject(AuthenticationService);
  private dialog = inject(MatDialog);
  private readonly clModalService = inject(ClModalService);
  private readonly accessService = inject(AccessService);
  private readonly translate = inject(TranslateService);

  userSettingsDialogRef: DialogRef = null;
  userSettingsComponent: UserSettingsComponent = null;

  /**
   * Datos de la aplicación (nombre, logo, slogan...). Se muestran en la parte superior del sidebar
   */
  @Input() titleInput!: Array<TitleNode>;
  /**
   * Items de menú de la aplicación. Se muestran en la parte media del sidebar
   */
  @Input() menuInput!: Array<TreeNode>;
  /**
   * Items de menú relacionados con el usuario. Se muestran en la parte inferior del sidebar
   */
  @Input() usermenuInput!: Array<TreeNode>;
  /**
   * Items de menú contacto Infoport. Se muestran en la parte inferior del sidebar
   */
  @Input() contactinfoInput!: Array<TreeNode>;

  sidebarClosed!: boolean;
  menu!: Array<TreeNode>;
  usermenu!: Array<TreeNode>;
  contactinfo!: Array<TreeNode>;
  title!: Array<TitleNode>;
  selectedNode: TreeNode | null = null;
  highlightServiceSubscription!: Subscription;

  name: string = '';

  /**
   * @Internal Obtiene los items del menú anidado
   */
  getChildren = (node: TreeNode) => of(node.children || []);
  // tslint:disable-next-line: member-ordering
  nestedTreeControl = new NestedTreeControl<any>(this.getChildren);
  // tslint:disable-next-line: member-ordering
  titleTreeControl = new NestedTreeControl<any>(this.getChildren);

  /**
   * @Internal Comprueba que exista menú anidado en un item de menú
   */
  hasChild(_: number, node: TreeNode) {
    return node.children != null && node.children.length > 0;
  }

  /**
   * @ignore
   */
  ngOnInit() {
    this.sidebarClosed = true;

    this.highlightServiceSubscription = this.highlightService.collpaseSidebarNodes.subscribe(() => {
      this.nestedTreeControl.collapseAll();
    });
    this.getTitle();
    this.getMenu();
  }

  /**
   * @ignore
   */
  ngOnDestroy() {
    this.highlightServiceSubscription.unsubscribe();
  }

  /**
   * @internal Temas del funcionamiento visual del menú
   */
  toggleSideBar(hasParent?: any) {
    if (!this.sidebarClosed) {
      this.nestedTreeControl.collapseAll();
    }

    const parentSelectedElement = this.highlightService.getParentSelectedElement();
    if (parentSelectedElement && !hasParent && hasParent !== undefined) {
      parentSelectedElement._elementRef.nativeElement.classList.remove('highlight-parent-node');
      this.highlightService.removeParentSelectedElement();
    }

    if (hasParent === undefined || hasParent) {
      this.sidebarClosed = !this.sidebarClosed;
    } else if (!hasParent) {
      this.sidebarClosed = true;
    }

    this.highlightService.setSidebarClosed(this.sidebarClosed);
  }

  /**
   * @internal Temas del funcionamiento visual del menú
   */
  highlight(element: MatAnchor) {
    const selectedElement = this.highlightService.getSelectedElement();

    if (selectedElement && selectedElement._elementRef.nativeElement['href'] !== element._elementRef.nativeElement['href']) {
      selectedElement._elementRef.nativeElement.classList.remove('highlight-node');
    }

    this.highlightService.setSelectedElement(element);
  }

  /**
   * @internal Temas del funcionamiento visual del menú
   */
  expandMenu(element: MatAnchor) {
    this.getSelectedNode();

    const parentSelectedElement = this.highlightService.getParentSelectedElement();

    if (this.selectedNode?.children && this.nestedTreeControl.expansionModel.selected.length > 0) {
      this.nestedTreeControl.collapseAll();

      if (parentSelectedElement) {
        parentSelectedElement._elementRef.nativeElement.classList.remove('highlight-parent-node');
      }

      element._elementRef.nativeElement.classList.add('highlight-parent-node');

      this.highlightService.setParentSelectedElement(element);

      this.nestedTreeControl.toggle(this.selectedNode);
    }

    // Open the sidebar
    if (this.sidebarClosed) {
      this.sidebarClosed = !this.sidebarClosed;
    }
  }

  /**
   * @internal Temas del funcionamiento visual del menú
   */
  getSelectedNode(): void {
    if (this.nestedTreeControl.expansionModel.selected.length > 0) {
      const lastIndex = this.nestedTreeControl.expansionModel.selected.length - 1;
      this.selectedNode = this.nestedTreeControl.expansionModel.selected[lastIndex];
    }
  }

  /**
   * Se obtienen los datos de la aplicación (nombre, logo, slogan...)
   */
  getTitle() {
    this.title = this.titleInput;
  }

  /**
   * Se obtienen los items del menú lateral de la aplicación, menú de usuario y datos de contacto
   */
  getMenu() {
    // TODO: Pendiente defirinir si quieremos ocultar las opciones de menú o deshabilitarlas
    // De momento lo que hacemos es si la opcción de menú está deshabilitada, no la mostramos
    this.menu = this.menuInput.filter((item) => !item.disabled);
    this.usermenu = this.usermenuInput;
    this.contactinfo = this.contactinfoInput;
  }

  /**
   * @internal Función para abrir el modal con información sobre las versiones
   */
  openReleaseNotes(): void {
    // TODO REVIEW BUTTONS

    this.dialog.open(ThemeReleaseNotesComponent, {
      width: '600px',
      maxWidth: '90%',
      maxHeight: '100%',
      height: 'auto',
      disableClose: false,
      autoFocus: true,
      data: { title: 'PATCH_NOTES' }
    });
  }

  /**
   * Función para abrir el modal de edición de preferencias de usuario
   */
  openSettings() {
    const modal = new ClModalConfig({
      title: this.translate.instant('PREFERENCES'),
      content: UserSettingsComponent,
      size: 'S',
      closeButton: {
        text: this.translate.instant('CANCEL'),
        hidden: false,
        action: (): boolean => {
          return true; // cerrar modal
        }
      },
      submitButton: {
        text: this.translate.instant('ACCEPT'),
        hidden: false,
        disabled: !this.accessService.maestroVehiculosModificacion(),
        action: () => {
          this.userSettingsComponent.onSubmit();
          this.userSettingsComponent.closeDialog.subscribe(() => this.clModalService.closeDialog());
          return false;
        }
      }
    });

    this.clModalService.openModal<UserSettingsComponent>(modal).then((value) => {
      this.userSettingsComponent = value.component;
      this.userSettingsDialogRef = value.dialogRef;
    });
  }

  /**
   * @internal ¿?
   */
  fromEvent(target: EventTarget, eventName: string) {
    return new Observable((observer) => {
      const handler = (e: Event) => observer.next(e);

      target.addEventListener(eventName, handler, { passive: true });

      return () => {
        target.removeEventListener(eventName, handler);
      };
    });
  }
}
