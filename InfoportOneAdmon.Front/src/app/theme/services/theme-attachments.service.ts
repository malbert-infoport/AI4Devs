import { Injectable, inject } from '@angular/core';
import { SharedMessageService } from './shared-message.service';
import { ThemeFilesService } from './theme-files.service';
import { TranslateService } from '@ngx-translate/core';
import { Observable, take } from 'rxjs';
import { IAttachmentView } from '@restApi/api/apiClients';

@Injectable({
  providedIn: 'root'
})
export class ThemeAttachmentsService {
  private themeFilesService = inject(ThemeFilesService);
  private translate = inject(TranslateService);
  private sharedMessageService = inject(SharedMessageService);

  downloadFile(id: number, getAttachmentContent: (id: number) => Observable<any>) {
    getAttachmentContent(id)
      .pipe(take(1))
      .subscribe({
        next: (attachment: IAttachmentView) => {
          if (attachment.fileContent) {
            /** Spliteamos el fileContent y nos quedmaos con el contenido a partir de la coma */
            const base64StringSplit = attachment.fileContent.split(',')[1];
            this.themeFilesService.downloadFile(base64StringSplit, attachment.fileName, attachment.fileExtension);
          } else {
            this.sharedMessageService.showError(
              this.translate.instant('ATTACHMENTS.MESSAGES.NO_FILE', { fileName: attachment.fileName })
            );
          }
        },
        error: (e) => this.sharedMessageService.showError(e)
      });
  }
}
