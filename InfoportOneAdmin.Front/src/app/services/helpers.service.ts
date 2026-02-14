import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root'
})
export class HelpersService {
  // función para comprobar si existe elemento en array
  checkAvailability(array, valor, posicionArray?) {
    return array.some((arrVal) => {
      if (posicionArray) {
        return valor === arrVal[posicionArray];
      } else {
        return valor === arrVal;
      }
    });
  }

  inserOrUpdateItemInArray(
    originalArray: any[],
    newItem: any,
    isNew: boolean,
    sortField?: string,
    sortOrder: 'asc' | 'desc' = 'asc'
  ): any[] {
    const result = isNew ? this.insertItemInArray(originalArray, newItem) : this.replaceItemInArray(originalArray, newItem);

    //  Si se especifica campo de ordenamiento, ordenar
    if (sortField) {
      return this.sortArray(result, sortField, sortOrder);
    }

    return result;
  }

  /** Actualizar un elemento del array de grid,client-side */
  replaceItemInArray(originalArray: any[], newItem: any): any[] {
    const index = originalArray.findIndex(
      (item) => item.id === newItem.id && item.auditCreationDate === newItem.auditCreationDate
    );

    if (index !== -1) {
      // Clonamos el array original para una nueva referencia
      const updatedArray = structuredClone(originalArray);

      // Reemplazamos el elemento
      updatedArray[index] = structuredClone(newItem); // o JSON.parse(JSON.stringify(newItem))

      return updatedArray;
    }

    // Si no lo encuentra, retornamos el original
    return originalArray;
  }

  /** Insertar un elemento en el array de grid,client-side */
  // insertItemInArray(originalArray: any[], newItem: any): any[] {
  //   return [...originalArray, structuredClone(newItem)];
  // }

  /** ✅ Insertar un elemento en el array de grid,client-side con deep copy */
  insertItemInArray(originalArray: any[], newItem: any): any[] {
    const clonedArray = structuredClone(originalArray);
    clonedArray.push(structuredClone(newItem));
    return clonedArray;
  }

  reorderArray<T>(
    array: T[],
    item: T,
    newIndex: number,
    orderField: keyof T = 'orden' as keyof T,
    matchFields: (keyof T)[] = ['id'] as (keyof T)[],
    customComparator?: (a: T, b: T) => boolean
  ): T[] {
    const clonedArray = structuredClone(array);

    // Detecta si un valor es una fecha válida (Date o string parseable)
    const isDateValue = (value: any): boolean => {
      return value instanceof Date || (typeof value === 'string' && !isNaN(Date.parse(value)));
    };

    // Comparador genérico según campos o función custom
    const isMatch = (a: T, b: T): boolean => {
      if (customComparator) return customComparator(a, b);

      return matchFields.every((field) => {
        const aVal = a[field];
        const bVal = b[field];

        // Comparación segura de fechas
        if (isDateValue(aVal) && isDateValue(bVal)) {
          return new Date(aVal as any).getTime() === new Date(bVal as any).getTime();
        }

        return aVal === bVal;
      });
    };

    // Buscar el elemento
    const currentIndex = clonedArray.findIndex((el) => isMatch(el, item));

    if (currentIndex === -1) {
      console.warn('Elemento no encontrado en el array');
      return array;
    }

    // Mover el elemento
    const [movedItem] = clonedArray.splice(currentIndex, 1);
    clonedArray.splice(newIndex, 0, movedItem);

    // Reasignar orden
    clonedArray.forEach((el, index) => {
      el[orderField] = (index + 1) as any;
    });

    return clonedArray;
  }

  /**
   * ✅ Método genérico para ordenar un array por cualquier campo
   * @param array - Array a ordenar
   * @param field - Campo por el cual ordenar
   * @param order - 'asc' | 'desc'
   */
  sortArray<T>(array: T[], field: string, order: 'asc' | 'desc' = 'asc'): T[] {
    return array.sort((a, b) => {
      const valueA = a[field as keyof T] ?? 0;
      const valueB = b[field as keyof T] ?? 0;

      if (order === 'asc') {
        return valueA > valueB ? 1 : valueA < valueB ? -1 : 0;
      } else {
        return valueA < valueB ? 1 : valueA > valueB ? -1 : 0;
      }
    });
  }
}
