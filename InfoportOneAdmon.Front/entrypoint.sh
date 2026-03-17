#!/bin/sh
set -e

echo "🟢 Variables de entorno cargadas:"
echo "  API_URL = $API_URL"
echo "  AUTHORITY = $AUTHORITY"
echo "  WEB_URL = $WEB_URL"
echo "  ENVIRONMENT = $ENVIRONMENT"

# Ruta del archivo de plantilla
TEMPLATE_FILE="/usr/share/nginx/html/assets/config/configCI.json"
OUTPUT_FILE="/usr/share/nginx/html/assets/config/config.json"

# Verifica que el archivo de plantilla exista antes de continuar
if [ ! -f "$TEMPLATE_FILE" ]; then
  echo "❌ Error: El archivo de plantilla $TEMPLATE_FILE no existe."
  echo "Asegúrate de que esté incluido en el build de Angular y copiado correctamente al contenedor."
  exit 1
fi

# Generar config.json reemplazando variables
echo "🔧 Generando config.json con variables de entorno..."
envsubst < "$TEMPLATE_FILE" > "$OUTPUT_FILE"

echo "✅ Archivo generado: $OUTPUT_FILE"

# Iniciar NGINX
echo "🚀 Iniciando NGINX..."
exec nginx -g 'daemon off;'