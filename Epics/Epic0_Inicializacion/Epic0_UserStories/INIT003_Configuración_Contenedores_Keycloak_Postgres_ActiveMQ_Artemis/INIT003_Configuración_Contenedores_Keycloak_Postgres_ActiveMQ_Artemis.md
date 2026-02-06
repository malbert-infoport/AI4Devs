```markdown
#### INIT003 - Configuración Contenedores: Keycloak + Postgres + ActiveMQ Artemis

**ID:** INIT003_Configuración_Contenedores_Keycloak_Postgres_ActiveMQ_Artemis
**EPIC:** Epic0 - Inicialización de proyectos Helix6

**RESUMEN:** Crear `docker-compose.dev.yml` con Keycloak (o Keycloak.X), PostgreSQL y ActiveMQ Artemis (broker), y opcionalmente Adminer/pgAdmin para desarrollo. Incluir volúmenes, realm import (realm-export.json) y script de seed de la BD para desarrollo.

## OBJETIVOS
- Proveer un `docker-compose` reproducible que permita levantar Keycloak, Postgres y ActiveMQ Artemis para el desarrollo local.
- Documentar cómo importar realm y cargar usuarios de prueba.
- Asegurar que los servicios exponen puertos y credenciales por defecto en `web.env` o `.env.development`.

## ACEPTACIÓN
- [ ] `docker-compose -f docker-compose.dev.yml up` levanta Keycloak, Postgres y Artemis y permite conexión desde backend y frontend.
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

  artemis:
    image: apache/activemq-artemis:2.30.0
    environment:
      ARTEMIS_USERNAME: artemis
      ARTEMIS_PASSWORD: artemis
    ports:
      - '5672:5672'   # AMQP
      - '8161:8161'   # Web console / Jolokia
    volumes:
      - artemis_data:/var/lib/artemis/data

  # Optional: admin UI for DB
  adminer:
    image: adminer
    restart: always
    ports:
      - '8081:8080'

volumes:
  pgdata:
  artemis_data:

```

## NOTAS TÉCNICAS
- ActiveMQ Artemis: expone AMQP en el puerto `5672` y la consola/Jolokia en `8161`. `ArtemisJolokiaClient` (ver documentación) puede usar la API HTTP para crear addresses/diverts si es necesario.
- Keycloak en modo `start-dev` permite import rápido de `realm-export.json`. Para entornos más maduros usar Keycloak con configuración persistente segura.
- Documentar en `web.env`/`.env.development` las variables: connection strings, Keycloak URL (`http://localhost:8080`), y broker AMQP (`amqp://artemis:artemis@localhost:5672`).
- En `appsettings.Development.json` del backend, asegurarse de que `ActiveMq:Host` apunte a `amqp://artemis:artemis@artemis:5672` (cuando se consume desde dentro de Docker-compose) o `amqp://artemis:artemis@localhost:5672` para llamadas desde host.

## PASOS SUGERIDOS PARA PRUEBAS LOCALES
1. Desde la raíz del proyecto donde se coloque el `docker-compose.dev.yml`:

```powershell
docker-compose -f docker-compose.dev.yml up -d

# Ver logs Artemis
docker-compose logs -f artemis

# Importar realm (si no se auto-importa)
# Acceder a: http://localhost:8080 (Keycloak admin/admin)
```

2. Configurar `appsettings.Development.json` para apuntar a Postgres y Artemis.
3. Levantar backend y comprobar que `AddArtemisBroker` puede conectar y que `AddIntegrationEventsPostgres` crea la tabla `IntegrationEvents`.

## CRITERIOS DE ACEPTACIÓN
- [ ] Compose y realm import funcionan en entorno local.
- [ ] README con pasos para levantar y limpiar el entorno está incluido.

## REFERENCIAS
- Ver guía de implementación de ActiveMQ Artemis y la librería `IPVInterchangeShared` en `ActiveMQ_Events.md` para patrones de topics/queues, `QueueNameConvention`, y recomendaciones de retry/persistencia.

```
