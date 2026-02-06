```markdown
#### INIT003 - Configuración Contenedores: Keycloak + Postgres

**ID:** INIT003_Configuración_Contenedores_Keycloak_Postgres
**EPIC:** Epic0 - Inicialización de proyectos Helix6

**RESUMEN:** Crear `docker-compose.dev.yml` con Keycloak (o Keycloak.X), PostgreSQL y opcionalmente Adminer/pgAdmin para desarrollo. Incluir volúmenes, realm import (realm-export.json) y script de seed de la BD para desarrollo.

## OBJETIVOS
- Proveer un `docker-compose` reproducible que permita levantar Keycloak y Postgres para el desarrollo local.
- Documentar cómo importar realm y cargar usuarios de prueba.
- Asegurar que los servicios exponen puertos y credenciales por defecto en `web.env` o `.env.development`.

## ACEPTACIÓN
- [ ] `docker-compose -f docker-compose.dev.yml up` levanta Keycloak y Postgres y permite conexión desde backend y frontend.
- [ ] Realm de ejemplo (`realm-export.json`) está disponible y documentado el proceso de import.

## EJEMPLO `docker-compose.dev.yml`
```yaml
version: '3.8'
services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_USER: dev
      POSTGRES_PASSWORD: dev
      POSTGRES_DB: sintraport_dev
    ports:
      - '5432:5432'
    volumes:
      - pgdata:/var/lib/postgresql/data

  keycloak:
    image: quay.io/keycloak/keycloak:21.1.0
    command: start-dev --http-enabled=true
    environment:
      KEYCLOAK_ADMIN: admin
      KEYCLOAK_ADMIN_PASSWORD: admin
    ports:
      - '8080:8080'
    volumes:
      - ./keycloak/realm-export.json:/opt/keycloak/data/import/realm-export.json:ro
    entrypoint: ["/bin/sh","-c","/opt/keycloak/bin/kc.sh start-dev --import-realm"]

volumes:
  pgdata:

```

## NOTAS TÉCNICAS
- Keycloak en modo `start-dev` permite import rápido de `realm-export.json`. Para entornos más maduros usar Keycloak with persistent config.
- Documentar `X-Correlation-Id` y configuración de `appsettings.Development.json` y `web.env` para que la API apunte a Keycloak y Postgres.

## CRITERIOS DE ACEPTACIÓN
- [ ] Compose y realm import funcionan en entorno local.
- [ ] README con pasos para levantar y limpiar el entorno.

```
