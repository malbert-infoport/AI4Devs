# ActiveMQ Artemis - Guía de Implementación
## Librería IPVInterchangeShared

### Versión del documento: 1.0.0
### Fecha: Enero 2026

---

## 📑 Tabla de Contenidos

1. [Introducción](#introducción)
2. [Arquitectura](#arquitectura)
3. [Prerequisites y Dependencias](#prerequisites-y-dependencias)
4. [Configuración Inicial](#configuración-inicial)
5. [Publicación de Eventos](#publicación-de-eventos)
6. [Suscripción a Eventos](#suscripción-a-eventos)
7. [Testing](#testing)
8. [Conceptos Avanzados](#conceptos-avanzados)
9. [Referencia Técnica](#referencia-técnica)

---

## Introducción

La librería **IPVInterchangeShared** proporciona una implementación completa de mensajería basada en eventos utilizando **ActiveMQ Artemis** como broker de mensajes. Esta solución está diseñada para garantizar la entrega confiable de eventos entre microservicios con persistencia, reintentos automáticos y trazabilidad distribuida.

### Proyectos NuGet

La librería se compone de tres paquetes NuGet principales:

| Paquete | Descripción | Responsabilidad |
|---------|-------------|-----------------|
| **IPVInterchangeShared.Broker** | Proyecto base con interfaces y clases abstractas | Define contratos (`IMessagePublisher`, `IEventProcessor<T>`, `EventBase`) y lógica común de publicación/consumo |
| **IPVInterchangeShared.Broker.Artemis** | Implementación específica para ActiveMQ Artemis | Implementa publisher/consumer usando ArtemisNetClient 3.0.0, gestión de conexiones y Jolokia API |
| **IPVInterchangeShared.Broker.Postgres** | Persistencia de eventos en PostgreSQL | Implementa repositorio con EF Core (Npgsql 9.0.4) para garantizar no pérdida de eventos |

### Características Principales

✅ **Patrón Publisher/Subscriber** con Virtual Topics  
✅ **Reintentos automáticos** con Polly (exponential backoff)  
✅ **Persistencia en PostgreSQL** antes y después de publicar/consumir  
✅ **Reconexión automática** al broker  
✅ **Registro automático** de processors por reflexión  
✅ **Compresión automática** de payloads grandes (Brotli)  
✅ **Multi-formato**: JSON, XML, EDI, Plain Text  
✅ **Trazabilidad distribuida** con TraceId  
✅ **Gestión administrativa** vía Jolokia API  
✅ **Environment-aware**: nombres diferentes en DEV vs Producción  

---

## Arquitectura

### Diagrama de Componentes

```mermaid
graph TB
    subgraph "Aplicación .NET"
        Controller[Controller/Service]
        Publisher[IMessagePublisher]
        Processor[IEventProcessor<T>]
        Consumer[MessageConsumer]
        Worker[ConsumerWorker<br/>BackgroundService]
    end
    
    subgraph "IPVInterchangeShared.Broker"
        BasePublisher[MessagePublisher<br/>Clase Base]
        BaseConsumer[MessageConsumer<br/>Clase Base]
        EventBase[EventBase<br/>Clase Base]
        IRepo[IIntegrationEventsRepository]
    end
    
    subgraph "IPVInterchangeShared.Broker.Artemis"
        ArtemisPublisher[ArtemisPublisher]
        ArtemisConsumer[ArtemisConsumer]
        ConnectionProvider[ArtemisConnectionProvider]
        JolokiaClient[ArtemisJolokiaClient]
    end
    
    subgraph "IPVInterchangeShared.Broker.Postgres"
        PostgresRepo[IntegrationEventsRepository]
        DbContext[EventsDbContext]
    end
    
    subgraph "Infraestructura"
        Artemis[(ActiveMQ Artemis<br/>Port 5672 AMQP)]
        Postgres[(PostgreSQL<br/>Integration Events DB)]
        JolokiaAPI[Jolokia API<br/>Port 8161]
    end
    
    Controller -->|Publica evento| Publisher
    Publisher --> BasePublisher
    BasePublisher --> ArtemisPublisher
    BasePublisher -->|Guarda antes| IRepo
    IRepo --> PostgresRepo
    PostgresRepo --> DbContext
    DbContext --> Postgres
    ArtemisPublisher --> ConnectionProvider
    ConnectionProvider --> Artemis
    
    Worker -->|Inicia| Consumer
    Consumer --> BaseConsumer
    BaseConsumer --> ArtemisConsumer
    ArtemisConsumer --> ConnectionProvider
    BaseConsumer -->|Guarda antes ACK| IRepo
    BaseConsumer -->|Procesa| Processor
    
    ArtemisConsumer -->|Crea colas/diverts| JolokiaClient
    JolokiaClient --> JolokiaAPI
    JolokiaAPI --> Artemis
    
    style Publisher fill:#e1f5ff
    style Processor fill:#e1f5ff
    style EventBase fill:#fff4e1
    style Artemis fill:#ffe1e1
    style Postgres fill:#ffe1e1
```

### Arquitectura de Virtual Topics en Artemis

Los **Virtual Topics** permiten que múltiples consumidores reciban una copia del mismo evento sin competir entre ellos.

```mermaid
graph LR
    Publisher[Publisher Service A]
    Publisher2[Publisher Service B]
    
    subgraph Artemis["ActiveMQ Artemis"]
        Topic[Address: VirtualTopic.DEV.OrderEvent.OrdersOk<br/>Routing: MULTICAST]
        Queue1[Queue: Consumer.ServiceX.VirtualTopic.DEV.OrderEvent.OrdersOk]
        Queue2[Queue: Consumer.ServiceY.VirtualTopic.DEV.OrderEvent.OrdersOk]
        Divert1[Divert 1]
        Divert2[Divert 2]
    end
    
    Consumer1[Consumer Service X<br/>OrderProcessor]
    Consumer2[Consumer Service Y<br/>NotificationProcessor]
    
    Publisher -->|Publish to Topic| Topic
    Publisher2 -->|Publish to Topic| Topic
    Topic -->|Divert| Divert1
    Topic -->|Divert| Divert2
    Divert1 --> Queue1
    Divert2 --> Queue2
    Queue1 --> Consumer1
    Queue2 --> Consumer2
    
    style Topic fill:#fff4e1
    style Queue1 fill:#e1f5ff
    style Queue2 fill:#e1f5ff
    style Divert1 fill:#f0f0f0
    style Divert2 fill:#f0f0f0
```

**Ventaja**: Cada servicio obtiene su propia copia del evento, sin afectar a otros consumidores.

---

## Prerequisites y Dependencias

### Framework y Runtime

- **.NET 8.0** o superior
- **C# 12** con nullable reference types habilitado

### Paquetes NuGet

#### IPVInterchangeShared.Broker
```xml
<PackageReference Include="Microsoft.Extensions.Hosting.Abstractions" Version="9.0.9" />
<PackageReference Include="Polly" Version="8.6.3" />
```

#### IPVInterchangeShared.Broker.Artemis
```xml
<PackageReference Include="ArtemisNetClient" Version="3.0.0" />
<PackageReference Include="Microsoft.Extensions.Configuration.Binder" Version="9.0.9" />
<PackageReference Include="Microsoft.Extensions.Http" Version="9.0.9" />
<PackageReference Include="Microsoft.Extensions.Options" Version="9.0.9" />
<PackageReference Include="Microsoft.Extensions.Options.ConfigurationExtensions" Version="9.0.9" />
```

#### IPVInterchangeShared.Broker.Postgres
```xml
<PackageReference Include="Microsoft.EntityFrameworkCore" Version="9.0.9" />
<PackageReference Include="Npgsql.EntityFrameworkCore.PostgreSQL" Version="9.0.4" />
<PackageReference Include="Microsoft.Extensions.Configuration.Binder" Version="9.0.9" />
```

### Infraestructura

| Componente | Versión Recomendada | Puerto | Propósito |
|------------|---------------------|--------|-----------|
| **ActiveMQ Artemis** | 2.30+ | 5672 (AMQP), 8161 (Console/Jolokia) | Broker de mensajes |
| **PostgreSQL** | 14+ | 5432 | Persistencia de eventos |

### Docker Compose para Entorno Local

```yaml
version: '3.8'

services:
  artemis:
    image: apache/activemq-artemis:2.30.0
    container_name: artemis-broker
    ports:
      - "5672:5672"   # AMQP
      - "8161:8161"   # Console Web / Jolokia API
      - "61616:61616" # OpenWire (opcional)
    environment:
      ARTEMIS_USER: artemis
      ARTEMIS_PASSWORD: artemis
    volumes:
      - artemis_data:/var/lib/artemis-instance

  postgres:
    image: postgres:16-alpine
    container_name: postgres-events
    ports:
      - "5432:5432"
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: integrationevents
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  artemis_data:
  postgres_data:
```

**Comandos**:
```bash
# Iniciar infraestructura
docker-compose up -d

# Ver logs
docker-compose logs -f artemis

# Acceder a consola Artemis
# URL: http://localhost:8161
# User: artemis / Password: artemis

# Detener
docker-compose down
```

---

## Configuración Inicial

### 1. Instalación de Paquetes NuGet

```bash
# Instalar los 3 paquetes en tu proyecto
dotnet add package IPVInterchangeShared.Broker
dotnet add package IPVInterchangeShared.Broker.Artemis
dotnet add package IPVInterchangeShared.Broker.Postgres
```

### 2. Configuración en Program.cs

```csharp
using System.Reflection;
using IPVInterchangeShared.Broker.Artemis;
using IPVInterchangeShared.Broker.Postgres.Extensions;

var builder = WebApplication.CreateBuilder(args);

// ... otros servicios ...

// 1. Registrar persistencia de eventos en Postgres
builder.Services.AddIntegrationEventsPostgres(
    builder.Configuration, 
    "IntegrationEventsDb"  // Nombre de la connection string
);

// 2. Registrar broker Artemis
// El segundo parámetro es el assembly donde buscar IEventProcessor<T>
builder.Services.AddArtemisBroker(
    Assembly.GetExecutingAssembly(), 
    builder.Configuration
);

var app = builder.Build();

// ... configuración del pipeline ...

app.Run();
```

**¿Qué hace `AddArtemisBroker`?**
1. Registra configuraciones (`ArtemisConfig`, `RetryConfig`, `JolokiaConfig`)
2. Registra `ArtemisConnectionProvider` como singleton
3. Registra `IMessagePublisher` → `ArtemisPublisher`
4. Registra `ArtemisJolokiaClient`
5. **Escanea el assembly buscando implementaciones de `IEventProcessor<T>`**
6. Registra cada processor y su consumer correspondiente (`ArtemisConsumer<T>`)
7. Registra `ConsumerWorker` como HostedService (inicia todos los consumers al arrancar)

### 3. Configuración en appsettings.json

**Estructura completa**:

```json
{
  "ActiveMq": {
    "ServiceName": "MyService",
    "Host": "amqp://artemis:artemis@localhost:5672",
    "ConnectionRetry": {
      "MaxRetries": 3,
      "InitialDelayMs": 500,
      "BackoffFactor": 2.0
    },
    "PublisherRetry": {
      "MaxRetries": 5,
      "InitialDelayMs": 1000,
      "BackoffFactor": 2.0
    },
    "ConsumerRetry": {
      "MaxRetries": 5,
      "InitialDelayMs": 1000,
      "BackoffFactor": 2.0
    },
    "Jolokia": {
      "Uri": "http://localhost:8161/console/jolokia/",
      "User": "artemis",
      "Password": "artemis"
    }
  },
  "ConnectionStrings": {
    "IntegrationEventsDb": "Host=localhost;Port=5432;Database=integrationevents;Username=postgres;Password=postgres"
  }
}
```

#### Descripción de Configuraciones

| Sección | Propiedad | Descripción |
|---------|-----------|-------------|
| **ActiveMq** | `ServiceName` | Nombre único del servicio (se usa en nombres de colas) |
| | `Host` | URI de conexión AMQP: `amqp://user:password@host:port` |
| **ConnectionRetry** | `MaxRetries` | Reintentos para conectar al broker |
| | `InitialDelayMs` | Delay inicial en ms |
| | `BackoffFactor` | Factor multiplicador (exponential backoff) |
| **PublisherRetry** | `MaxRetries` | Reintentos al publicar eventos |
| | `InitialDelayMs` | Delay inicial en ms |
| | `BackoffFactor` | Factor multiplicador |
| **ConsumerRetry** | `MaxRetries` | Reintentos al procesar eventos |
| | `InitialDelayMs` | Delay inicial en ms |
| | `BackoffFactor` | Factor multiplicador |
| **Jolokia** | `Uri` | URL de la API REST de Jolokia |
| | `User` | Usuario de Artemis |
| | `Password` | Password de Artemis |
| **ConnectionStrings** | `IntegrationEventsDb` | Connection string a PostgreSQL |

---

## Publicación de Eventos

### 1. Crear un Evento

Los eventos deben heredar de `EventBase`:

```csharp
using IPVInterchangeShared.Broker.Events;

namespace MyService.Events;

public class OrderEvent : EventBase
{
    // Constructor sin parámetros requerido para deserialización
    public OrderEvent() : base()
    {
    }
    
    // Constructor para crear el evento
    public OrderEvent(string topic, string originService, string? traceId = null) 
        : base(topic, originService, traceId)
    {
    }
    
    // Propiedades del negocio
    public Guid OrderId { get; set; } = Guid.NewGuid();
    public int NumOrder { get; set; }
    public string Customer { get; set; } = string.Empty;
    public decimal TotalAmount { get; set; }
    public List<OrderItem> Items { get; set; } = new();
}

public class OrderItem
{
    public string ProductId { get; set; } = string.Empty;
    public int Quantity { get; set; }
    public decimal Price { get; set; }
}
```

**Propiedades heredadas de `EventBase`**:
- `EventId`: GUID único del evento
- `EventName`: Nombre del evento (por defecto el nombre de la clase)
- `Topic`: Topic donde se publicará
- `CreatedDateUtc`: Fecha de creación en UTC
- `OriginService`: Servicio que originó el evento
- `TraceId`: ID de traza para seguimiento distribuido
- `EventVersion`: Versión del schema (por defecto "1.0.0")
- `Metadata`: Diccionario de metadatos adicionales
- `ContentData`: Contenido del evento (payload)

**Patrón de nomenclatura**: `{Nombre}Event` (ej: `OrderEvent`, `PaymentEvent`, `ShipmentEvent`)

### 2. Publicar un Evento

Inyectar `IMessagePublisher` y llamar a `PublishAsync`:

```csharp
using IPVInterchangeShared.Broker.Interfaces;
using IPVInterchangeShared.Broker.Artemis.Config;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;
using MyService.Events;

namespace MyService.Controllers;

[ApiController]
[Route("api/[controller]")]
public class OrdersController : ControllerBase
{
    private readonly IMessagePublisher _publisher;
    private readonly ArtemisConfig _config;

    public OrdersController(
        IMessagePublisher publisher, 
        IOptions<ArtemisConfig> options)
    {
        _publisher = publisher;
        _config = options.Value;
    }

    [HttpPost]
    public async Task<IActionResult> CreateOrder(
        CreateOrderRequest request, 
        CancellationToken ct)
    {
        // 1. Lógica de negocio: crear la orden
        var order = CreateOrderInDatabase(request);
        
        // 2. Generar el topic usando QueueNameConvention
        var topic = QueueNameConvention.GetPublishDestination(
            typeof(OrderEvent).Name, 
            "OrdersCreated"
        );
        // Resultado: VirtualTopic.DEV.OrderEvent.OrdersCreated (en desarrollo)
        
        // 3. Crear instancia del evento
        var orderEvent = new OrderEvent(topic, _config.ServiceName)
        { 
            OrderId = order.Id,
            NumOrder = order.Number,
            Customer = order.CustomerName,
            TotalAmount = order.TotalAmount
        };
        
        // 4. Publicar el evento
        await _publisher.PublishAsync("OrdersCreated", orderEvent, ct);
        
        return CreatedAtAction(nameof(GetOrder), new { id = order.Id }, order);
    }
}
```

**Parámetros de `PublishAsync`**:
- `destination`: Nombre de la cola (sin prefijos), ej: `"OrdersCreated"`
- `message`: Instancia del evento (debe heredar de `EventBase`)
- `ct`: CancellationToken (opcional)

### Flujo de Publicación

```mermaid
sequenceDiagram
    participant C as Controller
    participant MP as MessagePublisher
    participant DB as PostgreSQL
    participant AP as ArtemisPublisher
    participant A as Artemis Broker
    
    C->>MP: PublishAsync(destination, event)
    
    Note over MP: Genera nombre del topic<br/>VirtualTopic.DEV.OrderEvent.OrdersCreated
    
    MP->>MP: Asigna EventId, CreatedDateUtc
    MP->>MP: Serializa evento a JSON
    
    MP->>DB: SaveAsync(direction: "Published", payload)
    DB-->>MP: eventId
    
    Note over MP: Retry Policy (Polly)<br/>MaxRetries: 5, Backoff: Exponencial
    
    MP->>AP: EnsureDestinationCreatedAsync(topic)
    Note over AP: Solo la primera vez<br/>(usa caché interna)
    
    MP->>AP: PublishMessageAsync(topic, json)
    AP->>A: Send message (AMQP)
    A-->>AP: ACK
    AP-->>MP: Success
    
    MP->>DB: DeleteAsync(eventId)
    Note over DB: Evento publicado correctamente<br/>Se elimina de BD
    
    MP-->>C: Task completed
    
    Note over MP,A: Si falla la publicación:<br/>1. Se actualiza el evento en BD con error<br/>2. Se reintenta según RetryPolicy<br/>3. Si se agotan reintentos, evento permanece en BD
```

---

## Suscripción a Eventos

### 1. Crear un Event Processor

Los processors deben implementar `IEventProcessor<T>`:

```csharp
using IPVInterchangeShared.Broker.Interfaces;
using MyService.Events;
using Microsoft.Extensions.Logging;

namespace MyService.EventProcessors;

public class OrderProcessor : IEventProcessor<OrderEvent>
{
    private readonly ILogger<OrderProcessor> _logger;
    private readonly IOrderNotificationService _notificationService;

    public OrderProcessor(
        ILogger<OrderProcessor> logger,
        IOrderNotificationService notificationService)
    {
        _logger = logger;
        _notificationService = notificationService;
    }

    // Define las colas a las que se suscribe este processor
    public List<string> GetQueues()
    {
        return new List<string> 
        { 
            "OrdersCreated",    // Cola 1
            "OrdersUpdated"     // Cola 2
        };
    }

    // Lógica de procesamiento del evento
    public async Task ProcessAsync(
        OrderEvent eventToProcess, 
        string queueName, 
        CancellationToken ct = default)
    {
        _logger.LogInformation(
            "Processing order {NumOrder} from queue {Queue}", 
            eventToProcess.NumOrder, 
            queueName
        );
        
        try
        {
            // Lógica de negocio
            if (queueName == "OrdersCreated")
            {
                await _notificationService.SendOrderCreatedEmailAsync(
                    eventToProcess.Customer, 
                    eventToProcess.NumOrder,
                    ct
                );
            }
            else if (queueName == "OrdersUpdated")
            {
                await _notificationService.SendOrderUpdatedEmailAsync(
                    eventToProcess.Customer, 
                    eventToProcess.NumOrder,
                    ct
                );
            }
            
            _logger.LogInformation(
                "Successfully processed order {NumOrder}", 
                eventToProcess.NumOrder
            );
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, 
                "Error processing order {NumOrder}", 
                eventToProcess.NumOrder
            );
            
            // Lanzar excepción para que se active el retry
            throw;
        }
    }
}
```

**Características**:
- **Registro automático**: No necesita atributos decoradores. `AddArtemisBroker` lo registra automáticamente por reflexión.
- **Múltiples colas**: Un processor puede suscribirse a varias colas.
- **Parámetro `queueName`**: Permite diferenciar la lógica según la cola origen.
- **Manejo de errores**: Lanzar excepción activa el retry automático.

**Patrón de nomenclatura**: `{Nombre}Processor` (ej: `OrderProcessor`, `PaymentProcessor`)

### 2. Flujo de Consumo y Procesamiento

```mermaid
sequenceDiagram
    participant CW as ConsumerWorker<br/>(BackgroundService)
    participant MC as MessageConsumer
    participant AC as ArtemisConsumer
    participant A as Artemis Broker
    participant DB as PostgreSQL
    participant P as OrderProcessor
    
    Note over CW: Al iniciar la aplicación
    CW->>MC: StartAsync()
    
    loop Por cada cola en GetQueues()
        MC->>MC: Genera nombre completo<br/>Consumer.MyService.VirtualTopic.DEV.OrderEvent.OrdersCreated
        
        MC->>AC: EnsureQueueCreatedAsync(queueName)
        AC->>A: Jolokia API: CreateAddress, CreateQueue, CreateDivert
        Note over A: Address: VirtualTopic.DEV.OrderEvent.OrdersCreated<br/>Queue: Consumer.MyService.VirtualTopic.DEV.OrderEvent.OrdersCreated<br/>Divert: VirtualTopic → Queue
        A-->>AC: OK
        
        MC->>AC: InitiateConsumptionAsync(queueName)
        
        loop Bucle infinito
            AC->>A: ReceiveMessageAsync() [bloqueante]
            A-->>AC: Message body (JSON)
            
            AC->>MC: Deserializa a OrderEvent
            
            MC->>DB: SaveAsync(direction: "Received", payload)
            Note over DB: Guarda antes de hacer ACK
            DB-->>MC: eventId
            
            MC->>AC: AcknowledgeMessageAsync()
            AC->>A: ACK
            Note over A: Mensaje eliminado de la cola
            
            Note over MC: Retry Policy (Polly)<br/>MaxRetries: 5, Backoff: Exponencial
            
            MC->>P: ProcessAsync(event, queueName)
            
            alt Procesamiento exitoso
                P-->>MC: Task completed
                MC->>DB: DeleteAsync(eventId)
                Note over DB: Evento procesado correctamente<br/>Se elimina de BD
            else Procesamiento falla
                P-->>MC: Exception
                MC->>DB: UpdateAsync(eventId, retryCount, error)
                Note over MC: Reintenta según RetryPolicy
                Note over DB: Si se agotan reintentos,<br/>evento permanece en BD
            end
        end
    end
```

### 3. Ejemplo Completo con Manejo de Errores

```csharp
public class PaymentProcessor : IEventProcessor<PaymentEvent>
{
    private readonly ILogger<PaymentProcessor> _logger;
    private readonly IPaymentGateway _paymentGateway;
    private readonly IEmailService _emailService;

    public PaymentProcessor(
        ILogger<PaymentProcessor> logger,
        IPaymentGateway paymentGateway,
        IEmailService emailService)
    {
        _logger = logger;
        _paymentGateway = paymentGateway;
        _emailService = emailService;
    }

    public List<string> GetQueues()
    {
        return new List<string> { "PaymentsToProcess" };
    }

    public async Task ProcessAsync(
        PaymentEvent eventToProcess, 
        string queueName, 
        CancellationToken ct = default)
    {
        _logger.LogInformation(
            "Processing payment {PaymentId} for order {OrderId}. TraceId: {TraceId}", 
            eventToProcess.PaymentId,
            eventToProcess.OrderId,
            eventToProcess.TraceId
        );
        
        // Validación de negocio
        if (eventToProcess.Amount <= 0)
        {
            _logger.LogError("Invalid amount {Amount} for payment {PaymentId}", 
                eventToProcess.Amount, 
                eventToProcess.PaymentId
            );
            
            // No lanzar excepción si es un error de negocio no recuperable
            // El evento se procesará exitosamente pero sin ejecutar la acción
            return;
        }
        
        try
        {
            // Llamada a servicio externo
            var result = await _paymentGateway.ProcessPaymentAsync(
                eventToProcess.PaymentId,
                eventToProcess.Amount,
                eventToProcess.Currency,
                ct
            );
            
            if (result.IsSuccess)
            {
                _logger.LogInformation(
                    "Payment {PaymentId} processed successfully", 
                    eventToProcess.PaymentId
                );
                
                await _emailService.SendPaymentConfirmationAsync(
                    eventToProcess.CustomerEmail,
                    eventToProcess.OrderId,
                    ct
                );
            }
            else
            {
                _logger.LogWarning(
                    "Payment {PaymentId} declined: {Reason}", 
                    eventToProcess.PaymentId,
                    result.DeclineReason
                );
                
                // Lanzar excepción para que se reintente
                // (el pago podría estar temporalmente rechazado)
                throw new PaymentDeclinedException(result.DeclineReason);
            }
        }
        catch (HttpRequestException ex)
        {
            // Error de red: reintentar
            _logger.LogError(ex, 
                "Network error processing payment {PaymentId}. Will retry.", 
                eventToProcess.PaymentId
            );
            throw;
        }
        catch (PaymentGatewayException ex) when (ex.IsRetryable)
        {
            // Error temporal del gateway: reintentar
            _logger.LogError(ex, 
                "Temporary gateway error for payment {PaymentId}. Will retry.", 
                eventToProcess.PaymentId
            );
            throw;
        }
        catch (Exception ex)
        {
            // Error inesperado: registrar pero no reintentar indefinidamente
            _logger.LogCritical(ex, 
                "Unexpected error processing payment {PaymentId}", 
                eventToProcess.PaymentId
            );
            throw;
        }
    }
}
```

---

## Testing

### 1. Tests Unitarios de Processors

```csharp
using Xunit;
using Moq;
using Microsoft.Extensions.Logging;
using MyService.Events;
using MyService.EventProcessors;

public class OrderProcessorTests
{
    private readonly Mock<ILogger<OrderProcessor>> _loggerMock;
    private readonly Mock<IOrderNotificationService> _notificationServiceMock;
    private readonly OrderProcessor _processor;

    public OrderProcessorTests()
    {
        _loggerMock = new Mock<ILogger<OrderProcessor>>();
        _notificationServiceMock = new Mock<IOrderNotificationService>();
        _processor = new OrderProcessor(_loggerMock.Object, _notificationServiceMock.Object);
    }

    [Fact]
    public void GetQueues_ShouldReturnExpectedQueues()
    {
        // Act
        var queues = _processor.GetQueues();

        // Assert
        Assert.Equal(2, queues.Count);
        Assert.Contains("OrdersCreated", queues);
        Assert.Contains("OrdersUpdated", queues);
    }

    [Fact]
    public async Task ProcessAsync_OrdersCreated_ShouldSendCreatedEmail()
    {
        // Arrange
        var orderEvent = new OrderEvent("topic", "TestService")
        {
            NumOrder = 12345,
            Customer = "test@example.com"
        };

        // Act
        await _processor.ProcessAsync(orderEvent, "OrdersCreated", CancellationToken.None);

        // Assert
        _notificationServiceMock.Verify(
            x => x.SendOrderCreatedEmailAsync("test@example.com", 12345, It.IsAny<CancellationToken>()),
            Times.Once
        );
    }

    [Fact]
    public async Task ProcessAsync_OrdersUpdated_ShouldSendUpdatedEmail()
    {
        // Arrange
        var orderEvent = new OrderEvent("topic", "TestService")
        {
            NumOrder = 12345,
            Customer = "test@example.com"
        };

        // Act
        await _processor.ProcessAsync(orderEvent, "OrdersUpdated", CancellationToken.None);

        // Assert
        _notificationServiceMock.Verify(
            x => x.SendOrderUpdatedEmailAsync("test@example.com", 12345, It.IsAny<CancellationToken>()),
            Times.Once
        );
    }

    [Fact]
    public async Task ProcessAsync_ServiceThrowsException_ShouldRethrow()
    {
        // Arrange
        var orderEvent = new OrderEvent("topic", "TestService")
        {
            NumOrder = 12345,
            Customer = "test@example.com"
        };

        _notificationServiceMock
            .Setup(x => x.SendOrderCreatedEmailAsync(It.IsAny<string>(), It.IsAny<int>(), It.IsAny<CancellationToken>()))
            .ThrowsAsync(new InvalidOperationException("Email service unavailable"));

        // Act & Assert
        await Assert.ThrowsAsync<InvalidOperationException>(
            () => _processor.ProcessAsync(orderEvent, "OrdersCreated", CancellationToken.None)
        );
    }
}
```

### 2. Tests de Integración con Testcontainers

```csharp
using Testcontainers.ActiveMq;
using Testcontainers.PostgreSql;
using Xunit;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration;

public class IntegrationTests : IAsyncLifetime
{
    private readonly ActiveMqContainer _artemisContainer;
    private readonly PostgreSqlContainer _postgresContainer;
    private IServiceProvider _serviceProvider;

    public IntegrationTests()
    {
        // Configurar contenedor de Artemis
        _artemisContainer = new ActiveMqBuilder()
            .WithImage("apache/activemq-artemis:2.30.0")
            .WithUsername("artemis")
            .WithPassword("artemis")
            .Build();

        // Configurar contenedor de Postgres
        _postgresContainer = new PostgreSqlBuilder()
            .WithImage("postgres:16-alpine")
            .WithDatabase("integrationevents")
            .WithUsername("postgres")
            .WithPassword("postgres")
            .Build();
    }

    public async Task InitializeAsync()
    {
        // Iniciar contenedores
        await _artemisContainer.StartAsync();
        await _postgresContainer.StartAsync();

        // Configurar servicios
        var services = new ServiceCollection();

        var config = new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string>
            {
                ["ActiveMq:ServiceName"] = "IntegrationTest",
                ["ActiveMq:Host"] = $"amqp://artemis:artemis@{_artemisContainer.Hostname}:{_artemisContainer.GetMappedPublicPort(5672)}",
                ["ActiveMq:Jolokia:Uri"] = $"http://{_artemisContainer.Hostname}:{_artemisContainer.GetMappedPublicPort(8161)}/console/jolokia/",
                ["ActiveMq:Jolokia:User"] = "artemis",
                ["ActiveMq:Jolokia:Password"] = "artemis",
                ["ConnectionStrings:IntegrationEventsDb"] = _postgresContainer.GetConnectionString()
            })
            .Build();

        services.AddSingleton<IConfiguration>(config);
        services.AddLogging();
        services.AddIntegrationEventsPostgres(config, "IntegrationEventsDb");
        services.AddArtemisBroker(typeof(OrderProcessor).Assembly, config);

        _serviceProvider = services.BuildServiceProvider();
    }

    [Fact]
    public async Task PublishAndConsume_ShouldWorkEndToEnd()
    {
        // Arrange
        var publisher = _serviceProvider.GetRequiredService<IMessagePublisher>();
        var orderEvent = new OrderEvent("VirtualTopic.DEV.OrderEvent.OrdersOk", "IntegrationTest")
        {
            NumOrder = 999,
            Customer = "IntegrationTestCustomer"
        };

        // Act
        await publisher.PublishAsync("OrdersOk", orderEvent, CancellationToken.None);

        // Wait for processing
        await Task.Delay(2000);

        // Assert
        // Verificar en la base de datos que el evento fue procesado
        var repository = _serviceProvider.GetRequiredService<IIntegrationEventsRepository>();
        // ... verificaciones adicionales ...
    }

    public async Task DisposeAsync()
    {
        await _artemisContainer.StopAsync();
        await _postgresContainer.StopAsync();
    }
}
```

### 3. Setup de Test Fixtures

```csharp
public class EventProcessingTestFixture : IDisposable
{
    public IServiceProvider ServiceProvider { get; }
    public IMessagePublisher Publisher { get; }
    public Mock<IOrderNotificationService> NotificationServiceMock { get; }

    public EventProcessingTestFixture()
    {
        var services = new ServiceCollection();
        
        // Configuración mínima
        var config = new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string>
            {
                ["ActiveMq:ServiceName"] = "TestService"
            })
            .Build();

        services.AddSingleton<IConfiguration>(config);
        services.AddLogging();

        // Mock de dependencias
        NotificationServiceMock = new Mock<IOrderNotificationService>();
        services.AddSingleton(NotificationServiceMock.Object);

        // Registrar processor
        services.AddScoped<OrderProcessor>();

        ServiceProvider = services.BuildServiceProvider();
        Publisher = ServiceProvider.GetRequiredService<IMessagePublisher>();
    }

    public void Dispose()
    {
        (ServiceProvider as IDisposable)?.Dispose();
    }
}

public class OrderProcessorIntegrationTests : IClassFixture<EventProcessingTestFixture>
{
    private readonly EventProcessingTestFixture _fixture;

    public OrderProcessorIntegrationTests(EventProcessingTestFixture fixture)
    {
        _fixture = fixture;
    }

    [Fact]
    public async Task ProcessAsync_ShouldCallNotificationService()
    {
        // Arrange
        var processor = _fixture.ServiceProvider.GetRequiredService<OrderProcessor>();
        var orderEvent = new OrderEvent("topic", "TestService")
        {
            NumOrder = 123,
            Customer = "test@example.com"
        };

        // Act
        await processor.ProcessAsync(orderEvent, "OrdersCreated", CancellationToken.None);

        // Assert
        _fixture.NotificationServiceMock.Verify(
            x => x.SendOrderCreatedEmailAsync("test@example.com", 123, It.IsAny<CancellationToken>()),
            Times.Once
        );
    }
}
```

---

## Conceptos Avanzados

### 1. Compresión Automática con EventContentData

Los eventos pueden almacenar payloads grandes en la propiedad `ContentData` con compresión automática.

```csharp
using IPVInterchangeShared.Broker.Events;

public class LargeDocumentEvent : EventBase
{
    public LargeDocumentEvent() : base() { }
    
    public LargeDocumentEvent(string topic, string originService, string? traceId = null)
        : base(topic, originService, traceId) { }

    public string DocumentId { get; set; } = string.Empty;
    public string DocumentType { get; set; } = string.Empty;
}

// Crear evento con documento grande
var documentContent = File.ReadAllText("large-document.xml");

var eventContentData = await EventContentData.Create(
    documentContent,
    FormatTypeEnum.Xml,
    Encoding.UTF8,
    new EventCompressionOptions
    {
        MaxLengthToCompress = 10240,  // 10 KB
        Level = CompressionLevel.Optimal
    }
);

var documentEvent = new LargeDocumentEvent(topic, serviceName)
{
    DocumentId = "DOC-12345",
    DocumentType = "Invoice",
    ContentData = eventContentData
};

await _publisher.PublishAsync("LargeDocuments", documentEvent, ct);

// Al consumir, deserializar el contenido
public async Task ProcessAsync(LargeDocumentEvent eventToProcess, string queueName, CancellationToken ct)
{
    if (eventToProcess.ContentData != null)
    {
        // Obtener el contenido descomprimido
        string xmlContent = await eventToProcess.ContentData.GetContentString(Encoding.UTF8);
        
        // O deserializar directamente a un objeto
        var invoice = await eventToProcess.ContentData.DeserializeJsonAsync<Invoice>();
        
        // Procesar...
    }
}
```

**Formatos soportados**:
- `FormatTypeEnum.Json`
- `FormatTypeEnum.Xml`
- `FormatTypeEnum.Edi`
- `FormatTypeEnum.Plain`

**Encodings soportados**:
- `EventContentEncodingEnum.Plain`: Sin comprimir
- `EventContentEncodingEnum.Base64`: Base64 sin comprimir
- `EventContentEncodingEnum.Base64Brotli`: Base64 + compresión Brotli

### 2. Manejo de Errores y Reintentos con Polly

La librería usa **Polly** para implementar políticas de reintentos con **exponential backoff**.

#### Configuración de Reintentos

```json
{
  "ActiveMq": {
    "PublisherRetry": {
      "MaxRetries": 5,
      "InitialDelayMs": 1000,
      "BackoffFactor": 2.0
    },
    "ConsumerRetry": {
      "MaxRetries": 5,
      "InitialDelayMs": 1000,
      "BackoffFactor": 2.0
    }
  }
}
```

#### Cálculo de Delays

Con `InitialDelayMs = 1000` y `BackoffFactor = 2.0`:

| Reintento | Delay (ms) | Acumulado (s) |
|-----------|------------|---------------|
| 1 | 1000 | 1 |
| 2 | 2000 | 3 |
| 3 | 4000 | 7 |
| 4 | 8000 | 15 |
| 5 | 16000 | 31 |

#### Estrategias de Manejo de Errores en Processors

```csharp
public async Task ProcessAsync(OrderEvent eventToProcess, string queueName, CancellationToken ct)
{
    try
    {
        // Validación de negocio (NO reintentar)
        if (eventToProcess.TotalAmount <= 0)
        {
            _logger.LogWarning("Invalid order amount. Skipping event.");
            return; // No lanzar excepción
        }
        
        // Llamada a servicio externo (reintentar si falla)
        await _externalService.ProcessOrderAsync(eventToProcess, ct);
    }
    catch (ValidationException ex)
    {
        // Error de validación: NO reintentar
        _logger.LogError(ex, "Validation error. Event will not be retried.");
        return; // No lanzar excepción
    }
    catch (HttpRequestException ex)
    {
        // Error de red: REINTENTAR
        _logger.LogError(ex, "Network error. Event will be retried.");
        throw; // Lanzar para activar retry
    }
    catch (TimeoutException ex)
    {
        // Timeout: REINTENTAR
        _logger.LogError(ex, "Timeout. Event will be retried.");
        throw;
    }
    catch (Exception ex)
    {
        // Error inesperado: REINTENTAR (pero logear como crítico)
        _logger.LogCritical(ex, "Unexpected error processing event.");
        throw;
    }
}
```

### 3. Persistencia en PostgreSQL

#### Estructura de Tabla `IntegrationEvents`

```sql
CREATE TABLE "{SchemaName}"."IntegrationEvents" (
    "Id" SERIAL PRIMARY KEY,
    "EventDirection" VARCHAR(50) NOT NULL,  -- 'Published' o 'Received'
    "Destination" VARCHAR(500) NOT NULL,    -- Nombre de la cola/topic
    "Payload" TEXT NOT NULL,                -- JSON del evento
    "CreatedAt" TIMESTAMP NOT NULL,
    "RetryCount" INT NOT NULL DEFAULT 0,
    "LastError" TEXT NULL,
    "LastAttempt" TIMESTAMP NULL
);

CREATE INDEX "IX_IntegrationEvents_EventDirection" 
    ON "{SchemaName}"."IntegrationEvents" ("EventDirection");
    
CREATE INDEX "IX_IntegrationEvents_Destination" 
    ON "{SchemaName}"."IntegrationEvents" ("Destination");
    
CREATE INDEX "IX_IntegrationEvents_CreatedAt" 
    ON "{SchemaName}"."IntegrationEvents" ("CreatedAt");
```

**Nota**: El schema se crea automáticamente con el nombre del servicio (`ServiceName` en appsettings).

#### Consultas Útiles

**Ver eventos fallidos**:
```sql
SELECT * 
FROM "MyService"."IntegrationEvents"
WHERE "RetryCount" > 0
ORDER BY "LastAttempt" DESC;
```

**Ver eventos pendientes de publicar**:
```sql
SELECT * 
FROM "MyService"."IntegrationEvents"
WHERE "EventDirection" = 'Published'
ORDER BY "CreatedAt";
```

**Ver eventos recibidos pero no procesados**:
```sql
SELECT * 
FROM "MyService"."IntegrationEvents"
WHERE "EventDirection" = 'Received'
ORDER BY "CreatedAt";
```

**Eliminar eventos procesados exitosamente más antiguos de 30 días**:
```sql
-- Los eventos procesados exitosamente ya fueron eliminados automáticamente
-- Esta query es para eventos fallidos antiguos
DELETE FROM "MyService"."IntegrationEvents"
WHERE "RetryCount" >= 5  -- Agotó reintentos
  AND "CreatedAt" < NOW() - INTERVAL '30 days';
```

#### Estados de Eventos

| Estado | Descripción |
|--------|-------------|
| **Published, RetryCount=0** | Evento pendiente de publicar al broker |
| **Published, RetryCount>0** | Evento falló al publicar, reintentando |
| **Received, RetryCount=0** | Evento recibido, pendiente de procesar |
| **Received, RetryCount>0** | Evento falló al procesar, reintentando |
| **(Eliminado)** | Evento publicado/procesado exitosamente |

### 4. Gestión Administrativa con Jolokia API

`ArtemisJolokiaClient` permite gestionar Artemis mediante su API REST.

```csharp
using IPVInterchangeShared.Broker.Artemis.Jolokia;

public class AdminController : ControllerBase
{
    private readonly ArtemisJolokiaClient _jolokiaClient;

    public AdminController(ArtemisJolokiaClient jolokiaClient)
    {
        _jolokiaClient = jolokiaClient;
    }

    [HttpPost("admin/create-virtual-topic")]
    public async Task<IActionResult> CreateVirtualTopic(
        string topicName, 
        string queueName)
    {
        // Crea: Address (topic) + Queue + Divert
        await _jolokiaClient.CreateVirtualTopicAsync(
            topicName, 
            queueName, 
            CancellationToken.None
        );
        
        return Ok($"Virtual topic {topicName} created with queue {queueName}");
    }

    [HttpDelete("admin/reset-broker")]
    public async Task<IActionResult> ResetBroker()
    {
        // CUIDADO: Elimina TODOS los diverts, colas y addresses
        await _jolokiaClient.ResetBrokerAsync();
        
        return Ok("Broker reset completed");
    }

    [HttpPost("admin/create-address")]
    public async Task<IActionResult> CreateAddress(string addressName)
    {
        await _jolokiaClient.CreateAddressAsync(
            addressName, 
            CancellationToken.None
        );
        
        return Ok($"Address {addressName} created");
    }

    [HttpPost("admin/create-queue")]
    public async Task<IActionResult> CreateQueue(
        string addressName, 
        string queueName)
    {
        await _jolokiaClient.CreateQueueAsync(
            addressName, 
            queueName, 
            CancellationToken.None
        );
        
        return Ok($"Queue {queueName} created for address {addressName}");
    }
}
```

**⚠️ Advertencia**: `ResetBrokerAsync()` es destructivo. Úsalo solo en entornos de desarrollo/testing.

### 5. Trazabilidad Distribuida con TraceId

Cada evento tiene un `TraceId` para seguimiento distribuido.

```csharp
// Servicio A: Crear orden y publicar evento
public async Task<IActionResult> CreateOrder(CreateOrderRequest request)
{
    // Generar o usar TraceId del request entrante
    var traceId = HttpContext.TraceIdentifier; // O de un header
    
    var orderEvent = new OrderEvent(topic, _config.ServiceName, traceId)
    {
        NumOrder = 12345,
        Customer = "customer@example.com"
    };
    
    await _publisher.PublishAsync("OrdersCreated", orderEvent, CancellationToken.None);
    
    _logger.LogInformation("Order created with TraceId: {TraceId}", traceId);
    
    return Ok();
}

// Servicio B: Procesar evento y propagar TraceId
public async Task ProcessAsync(OrderEvent eventToProcess, string queueName, CancellationToken ct)
{
    using (_logger.BeginScope(new Dictionary<string, object>
    {
        ["TraceId"] = eventToProcess.TraceId,
        ["EventId"] = eventToProcess.EventId,
        ["OriginService"] = eventToProcess.OriginService
    }))
    {
        _logger.LogInformation("Processing order {NumOrder}", eventToProcess.NumOrder);
        
        // Si necesitas publicar otro evento, propaga el TraceId
        var paymentEvent = new PaymentEvent(paymentTopic, _config.ServiceName, eventToProcess.TraceId)
        {
            OrderId = eventToProcess.OrderId,
            Amount = eventToProcess.TotalAmount
        };
        
        await _publisher.PublishAsync("PaymentsToProcess", paymentEvent, ct);
    }
}
```

**Beneficio**: Puedes correlacionar todos los logs de múltiples servicios usando el mismo `TraceId`.

#### Integración con Application Insights / OpenTelemetry

```csharp
using System.Diagnostics;

public async Task ProcessAsync(OrderEvent eventToProcess, string queueName, CancellationToken ct)
{
    using var activity = Activity.Current?.Source.StartActivity("ProcessOrderEvent");
    activity?.SetTag("event.id", eventToProcess.EventId);
    activity?.SetTag("event.trace_id", eventToProcess.TraceId);
    activity?.SetTag("event.origin_service", eventToProcess.OriginService);
    activity?.SetTag("queue.name", queueName);
    
    try
    {
        // Procesar evento...
        activity?.SetStatus(ActivityStatusCode.Ok);
    }
    catch (Exception ex)
    {
        activity?.SetStatus(ActivityStatusCode.Error, ex.Message);
        throw;
    }
}
```

---

## Referencia Técnica

### Interfaces Principales

| Interfaz | Propósito | Métodos |
|----------|-----------|---------|
| `IMessagePublisher` | Publicar eventos al broker | `Task PublishAsync<T>(string destination, T message, CancellationToken ct)` |
| `IEventProcessor<T>` | Procesar eventos recibidos | `List<string> GetQueues()`<br/>`Task ProcessAsync(T eventToProcess, string queueName, CancellationToken ct)` |
| `IIntegrationEventsRepository` | Persistir eventos en BD | `Task<string> SaveAsync(...)`<br/>`Task UpdateAsync(...)`<br/>`Task DeleteAsync(...)` |
| `IEventBase` | Contrato base para eventos | Propiedades: `EventId`, `EventName`, `Topic`, etc. |

### Clases Base

| Clase | Tipo | Responsabilidad |
|-------|------|-----------------|
| `EventBase` | Abstracta | Clase base para todos los eventos. Define propiedades comunes. |
| `MessagePublisher` | Abstracta | Lógica común de publicación: persistencia, reintentos, serialización. |
| `MessageConsumer` | Abstracta | Lógica común de consumo: recepción, ACK, procesamiento, reintentos. |
| `ArtemisPublisher` | Concreta | Implementación específica para publicar en Artemis (AMQP). |
| `ArtemisConsumer` | Concreta | Implementación específica para consumir de Artemis (AMQP). |
| `IntegrationEventsRepository` | Concreta | Implementación de persistencia con EF Core + PostgreSQL. |
| `ArtemisConnectionProvider` | Singleton | Gestiona conexión AMQP con reconexión automática. |
| `ArtemisJolokiaClient` | Scoped | Cliente HTTP para Jolokia API (gestión administrativa). |

### Configuraciones Disponibles

```csharp
// ArtemisConfig
public class ArtemisConfig : BrokerConfig
{
    public string ServiceName { get; set; }              // Nombre del servicio
    public string Host { get; set; }                     // amqp://user:pass@host:port
    public RetryConfig ConnectionRetry { get; set; }     // Reintentos de conexión
    public RetryConfig PublisherRetry { get; set; }      // Reintentos de publicación
    public RetryConfig ConsumerRetry { get; set; }       // Reintentos de procesamiento
    public ArtemisJolokiaConfig Jolokia { get; set; }    // Config de Jolokia
}

// RetryConfig
public class RetryConfig
{
    public int MaxRetries { get; set; } = 3;             // Máximo de reintentos
    public int InitialDelayMs { get; set; } = 1000;      // Delay inicial en ms
    public double BackoffFactor { get; set; } = 2.0;     // Factor de backoff exponencial
}

// ArtemisJolokiaConfig
public class ArtemisJolokiaConfig
{
    public string Uri { get; set; }                      // http://host:8161/console/jolokia/
    public string User { get; set; }                     // Usuario de Artemis
    public string Password { get; set; }                 // Password de Artemis
}

// EventCompressionOptions
public class EventCompressionOptions
{
    public int MaxLengthToCompress { get; set; } = 10240;  // 10 KB por defecto
    public CompressionLevel Level { get; set; } = CompressionLevel.Optimal;
}
```

### Propiedades de EventBase

```csharp
public abstract class EventBase : IEventBase
{
    [Required] public string EventId { get; set; }           // GUID único
    [Required] public string EventName { get; set; }         // Nombre del evento
    [Required] public string Topic { get; set; }             // Topic destino
    [Required] public DateTime CreatedDateUtc { get; set; }  // Fecha creación UTC
    [Required] public string OriginService { get; set; }     // Servicio origen
    [Required] public string TraceId { get; set; }           // ID de traza
    public string EventVersion { get; set; } = "1.0.0";      // Versión del schema
    public Dictionary<string, object>? Metadata { get; set; } // Metadatos
    public virtual EventContentData? ContentData { get; set; } // Payload
}
```

### Métodos de EventContentData

```csharp
// Crear desde texto
public static Task<EventContentData> Create(
    string text, 
    FormatTypeEnum formatType, 
    Encoding? encoding = null, 
    EventCompressionOptions? compressionOptions = null
)

// Crear desde objeto (serializa a JSON)
public static Task<EventContentData> CreateFromObjectToJson<T>(
    T obj, 
    EventCompressionOptions? compressionOptions = null
)

// Obtener contenido como string
public Task<string> GetContentString(Encoding? encoding = null)

// Deserializar JSON
public Task<T> DeserializeJsonAsync<T>()

// Obtener como Stream
public Task<MemoryStream> GetContentStream()
```

### Convenciones de Nomenclatura

#### Topics (Publishers)

| Entorno | Patrón | Ejemplo |
|---------|--------|---------|
| **Desarrollo** | `VirtualTopic.DEV.{EventName}.{QueueName}` | `VirtualTopic.DEV.OrderEvent.OrdersCreated` |
| **Producción** | `VirtualTopic.{EventName}.{QueueName}` | `VirtualTopic.OrderEvent.OrdersCreated` |

#### Queues (Consumers)

| Entorno | Patrón | Ejemplo |
|---------|--------|---------|
| **Desarrollo** | `Consumer.{ServiceName}.VirtualTopic.DEV.{EventName}.{QueueName}` | `Consumer.OrderService.VirtualTopic.DEV.OrderEvent.OrdersCreated` |
| **Producción** | `Consumer.{ServiceName}.VirtualTopic.{EventName}.{QueueName}` | `Consumer.OrderService.VirtualTopic.OrderEvent.OrdersCreated` |

**Uso de `QueueNameConvention`**:

```csharp
// Para publicar
var topic = QueueNameConvention.GetPublishDestination(
    typeof(OrderEvent).Name,  // "OrderEvent"
    "OrdersCreated"           // Nombre de la cola
);
// Resultado: VirtualTopic.DEV.OrderEvent.OrdersCreated (en Development)

// Para consumir (usado internamente por MessageConsumer)
var queue = QueueNameConvention.GetConsumerDestination(
    "OrderService",           // ServiceName
    typeof(OrderEvent).Name,  // "OrderEvent"
    "OrdersCreated"           // Nombre de la cola
);
// Resultado: Consumer.OrderService.VirtualTopic.DEV.OrderEvent.OrdersCreated (en Development)
```

---

## Resumen

La librería **IPVInterchangeShared** proporciona una solución robusta y completa para mensajería basada en eventos con ActiveMQ Artemis:

1. **Fácil de usar**: Hereda de `EventBase`, implementa `IEventProcessor<T>`, inyecta `IMessagePublisher`.
2. **Confiable**: Persistencia en PostgreSQL antes de publicar/consumir + reintentos automáticos.
3. **Escalable**: Virtual Topics permiten múltiples consumidores independientes.
4. **Trazable**: `TraceId` para seguimiento distribuido end-to-end.
5. **Eficiente**: Compresión automática de payloads grandes.
6. **Testeable**: Interfaces inyectables, mocks sencillos, soporte para Testcontainers.

**Flujo completo**:
1. Crea un evento heredando de `EventBase`
2. Publica con `IMessagePublisher.PublishAsync()`
3. Crea un processor implementando `IEventProcessor<T>`
4. El processor se registra automáticamente al llamar a `AddArtemisBroker()`
5. La librería se encarga del resto: persistencia, reintentos, ACK, logging

---

**Versión del documento**: 1.0.0  
**Última actualización**: Enero 2026  
**Mantenedor**: IPV Development Team
