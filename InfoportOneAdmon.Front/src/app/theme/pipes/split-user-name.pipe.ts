import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
  name: 'splitUserName',
  standalone: true
})
export class SplitUserNamePipe implements PipeTransform {
  transform(fullName: string): string {
    if (!fullName) {
      return 'unknown name';
    }

    if (fullName.length > 20 && fullName.includes(' ')) {
      const splitName = fullName.split(' ', 2);
      return `${splitName[0]}  ${splitName[1][0].toUpperCase()}.`;
    } else if (fullName.length > 20 && !fullName.includes(' ')) {
      return `${fullName.substring(0, 20)}...`;
    } else {
      return fullName;
    }
  }
}
