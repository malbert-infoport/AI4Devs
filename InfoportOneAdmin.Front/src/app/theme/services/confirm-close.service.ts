import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root'
})
export class ConfirmCloseService {
  unSaveChanges: boolean = false;
}
