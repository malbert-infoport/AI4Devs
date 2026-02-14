import { Injectable, Output, EventEmitter, Directive } from '@angular/core';
import { NgForm } from '@angular/forms';

/**
 * @ignore
 */
@Directive()
/**
 * @ignore
 */
@Injectable({
  providedIn: 'root'
})
export class ThemeFormService {
  private formStack: Array<NgForm> = [];
  @Output() isWorking = new EventEmitter<boolean>();
  @Output() saveCompleted = new EventEmitter<any>();

  constructor() {}

  get currentModel(): any {
    return this.hasForms() ? this.getCurrentForm().value : null;
  }

  getStackLength(): number {
    return this.formStack.length;
  }

  stackForm(form: NgForm): void {
    this.formStack.push(form);
  }

  unstackForm(): void {
    this.formStack.pop();
  }

  hasForms(): boolean {
    return this.formStack.length > 0;
  }

  getCurrentForm(): NgForm {
    return this.formStack[this.formStack.length - 1];
  }

  setAsCurrentForm(form: NgForm): void {
    this.formStack.splice(this.formStack.indexOf(form), 1);
    this.formStack.push(form);
  }

  markAsPristine(): void {
    this.getCurrentForm().reset({ ...this.getCurrentForm().value });
  }

  clearStack(): void {
    this.formStack = [];
  }

  isValid(): boolean {
    const currentForm = this.getCurrentForm();
    if (!currentForm) {
      console.warn('There is no form stacked.');
    }

    return currentForm?.form?.valid || false;
  }

  resetCurrentStackForm(): void {
    this.getCurrentForm().reset();
  }

  hasChanges(): boolean {
    const currentForm = this.getCurrentForm();
    return currentForm?.form?.dirty || false;
  }
}
