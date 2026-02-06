# Épica 7: Arquitectura de Eventos y Sincronización

## Objetivo de Negocio
Garantizar desacoplamiento total entre InfoportOneAdmon y aplicaciones satélite mediante eventos de estado.

## Valor que aporta
- Aplicaciones satélite operan autónomamente sin depender de InfoportOneAdmon en tiempo real
- Escalabilidad horizontal sin modificar InfoportOneAdmon
- Resiliencia: aplicaciones procesan cambios cuando se reconectan
- Prevención de duplicados reduce tráfico y procesamiento innecesario

## Criterios de aceptación de la épica
- Publicación de eventos OrganizationEvent, ApplicationEvent, UserEvent funcional
- Sistema de hash SHA-256 para prevención de duplicados operativo
- Consumo idempotente en Background Workers validado
- Sincronización inicial completa mediante republicación de eventos funcionando

## Uso de IPVInterchangeShared (ActiveMQ Artemis)

Este bloque muestra un ejemplo práctico, minimal y reproducible, para integrar la librería `IPVInterchangeShared` y publicar/suscribirse a eventos usando ActiveMQ Artemis.

1) Registrar servicios (Program.cs)

```csharp
using System.Reflection;
// ...
builder.Services.AddIntegrationEventsPostgres(
	builder.Configuration,
	"IntegrationEventsDb"
);

// Escanea el assembly en busca de IEventProcessor<T> y registra publisher/consumer
builder.Services.AddArtemisBroker(
	Assembly.GetExecutingAssembly(),
	builder.Configuration
);
```

2) Definir el evento (hereda de `EventBase`)

```csharp
public class OrganizationEvent : EventBase
{
	public OrganizationEvent() : base() { }
	public string OrganizationId { get; set; } = string.Empty;
	public string Name { get; set; } = string.Empty;
}
```

3) Publicar un evento desde un controller/servicio

```csharp
public class OrganizationsController : ControllerBase
{
	private readonly IMessagePublisher _publisher;

	public OrganizationsController(IMessagePublisher publisher)
	{
		_publisher = publisher;
	}

	[HttpPost]
	public async Task<IActionResult> Create(CreateOrgRequest req, CancellationToken ct)
	{
		var ev = new OrganizationEvent("OrganizationEvent", "OrgService", traceId: null)
		{
			OrganizationId = Guid.NewGuid().ToString(),
			Name = req.Name
		};

		// 'destination' es el nombre lógico de la cola/topic (ej: "OrganizationsCreated")
		await _publisher.PublishAsync("OrganizationsCreated", ev, ct);

		return Created(...);
	}
}
```

4) Implementar un processor para consumir el evento

```csharp
public class OrganizationProcessor : IEventProcessor<OrganizationEvent>
{
	// Devuelve las colas a las que se suscribe este processor
	public List<string> GetQueues()
	{
		// En desarrollo, seguir la convención de nombres
		return new List<string>
		{
			QueueNameConvention.GetConsumerDestination(
				serviceName: "OrgService",
				eventName: nameof(OrganizationEvent),
				queueName: "OrganizationsCreated"
			)
		};
	}

	public async Task ProcessAsync(OrganizationEvent eventToProcess, string queueName, CancellationToken ct = default)
	{
		// Lógica idempotente: usar EventId / hash para evitar duplicados
		// TODO: aplicar reglas de negocio (crear/actualizar entidad, publicar compensaciones si procede)
		await Task.CompletedTask;
	}
}
```

Notas rápidas:
- `AddArtemisBroker` registra automáticamente los `IEventProcessor<T>` que se encuentran en el assembly.
- La librería persiste el evento en PostgreSQL antes de publicarlo y aplica reintentos (Polly) en caso de fallo.
- Para trazabilidad distribuida, propaga `TraceId` en el `EventBase` y mantenga `X-Correlation-Id` en las peticiones que afecten estado.

Con lo anterior, el equipo frontend/backend puede levantar Artemis + Postgres (ver `INIT003` docker-compose) y probar publicación/consumo localmente.

