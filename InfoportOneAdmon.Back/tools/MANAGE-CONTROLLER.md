Manage-Controller — Uso rápido
=============================

Archivo: `tools\Manage-Controller.ps1`

Breve descripción
-----------------
- Edita `HelixEntities.xml` para añadir/eliminar endpoints generados por Helix6.
- Modo interactivo aplica los cambios inmediatamente y refresca el menú.
- Puede generar/actualizar los ficheros de endpoints C# y llamar `Create-Service.ps1` si hace falta.

Opciones comunes
----------------
- `-EntityName <name>` (obligatorio)
- `-DryRun` (no escribe, muestra lo que haría)
- `-Backup` (crea copias .bak al sobrescribir)
- `-Force` (forzar escritura)
- `-Methods "..."` (modo no interactivo; lista de comandos separados por comas o espacios)

Sintaxis de comandos (interactivo / -Methods)
-------------------------------------------
- `nC` : crear endpoint por índice (ej. `1C`)
- `nE` / `nD` : eliminar endpoint por índice (ej. `3D` o `2E`)
- `+MethodName` : añadir por nombre (ej. `+Insert`)
- `-MethodName` : eliminar por nombre (ej. `-GetById`)
- Método sin prefijo: toggle (en interactivo)

Ejemplos
--------
# Preview de cambios
```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File "tools\Manage-Controller.ps1" -EntityName "Organization" -DryRun
```

# Interactive: ejecutar y escribir comandos (ej: "1C" o "3D")
```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File "tools\Manage-Controller.ps1" -EntityName "Organization"
```

# Non-interactive: añadir Insert y GetById (preview)
```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File "tools\Manage-Controller.ps1" -EntityName "Organization" -Methods "Insert,GetById" -DryRun
```

# Eliminar por índice (preview)
```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File "tools\Manage-Controller.ps1" -EntityName "Organization" -Methods "3D" -DryRun
```

Notas
-----
- Usa `-DryRun` siempre en CI antes de aplicar cambios.
- `-Backup` es opt-in y crea .bak si se escribe un fichero existente.
- Si prefieres agrupar cambios y aplicarlos al final, usa `-Methods` (no interactivo).
