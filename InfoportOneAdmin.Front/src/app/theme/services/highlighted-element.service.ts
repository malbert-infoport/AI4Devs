import { Injectable, EventEmitter, Output, Directive } from '@angular/core';
import { MatAnchor } from '@angular/material/button';

@Directive()
@Injectable({
  providedIn: 'root'
})
export class HighlightedElementService {
  constructor() {}

  private selectedElement!: MatAnchor | null;
  private parentSelectedElement: MatAnchor | null = null;
  private sidebarClosed = false;

  @Output() openSidenav: EventEmitter<boolean> = new EventEmitter<boolean>();
  @Output() toggleSidenav: EventEmitter<boolean> = new EventEmitter<boolean>();
  @Output() closeSidenav: EventEmitter<boolean> = new EventEmitter<boolean>();
  @Output() collpaseSidebarNodes: EventEmitter<boolean> = new EventEmitter<boolean>();
  @Output() highlightElement: EventEmitter<boolean> = new EventEmitter<boolean>();

  // Node selected
  getSelectedElement(): MatAnchor {
    return this.selectedElement;
  }

  setSelectedElement(element: MatAnchor): void {
    this.selectedElement = element;
  }

  removeSelectedElement() {
    this.selectedElement = null;
  }

  // Parent selected
  getParentSelectedElement(): MatAnchor {
    return this.parentSelectedElement;
  }

  setParentSelectedElement(element: MatAnchor): void {
    this.parentSelectedElement = element;
  }

  removeParentSelectedElement() {
    this.parentSelectedElement = null;
  }

  // Sidebar status
  getSidebarClosed(): boolean {
    return this.sidebarClosed;
  }

  setSidebarClosed(element: boolean): void {
    this.sidebarClosed = element;
  }
}
