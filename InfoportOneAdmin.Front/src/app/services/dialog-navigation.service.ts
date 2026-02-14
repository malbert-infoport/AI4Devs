import { Injectable, DestroyRef, inject } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { Router, NavigationStart } from '@angular/router';
import { DialogRef } from '@progress/kendo-angular-dialog';
import { filter, take } from 'rxjs/operators';

/**
 * Servicio que cierra automáticamente un diálogo cuando se detecta navegación.
 * Usar en ngOnInit() de componentes de diálogo inyectando el servicio.
 */
@Injectable()
export class DialogNavigationService {
  private readonly router = inject(Router);
  private readonly destroyRef = inject(DestroyRef);

  /**
   * Configura el cierre automático del diálogo al navegar.
   * @param dialogRef Referencia al diálogo a cerrar
   */
  setup(dialogRef: DialogRef): void {
    this.router.events
      .pipe(
        filter((e) => e instanceof NavigationStart),
        take(1),
        takeUntilDestroyed(this.destroyRef)
      )
      .subscribe(() => dialogRef.close());
  }
}
