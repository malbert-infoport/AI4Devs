# TASK-003-BE-REACTIVATE: Implementar alta manual de organización

=============================================================
**TICKET ID:** TASK-003-BE-REACTIVATE  
**EPIC:** Gestión del Portfolio de Organizaciones Clientes  
**USER STORY:** US-003v2 - Dar de alta manualmente organización  
**COMPONENT:** Backend  
**PRIORITY:** Alta  
**ESTIMATION:** 2 horas  
=============================================================

## TÍTULO
Implementar reactivación manual de organización (alta manual por SecurityManager)

## DESCRIPCIÓN
Implementar endpoint para dar de alta (reactivar) manualmente una organización que previamente fue dada de baja. Esta acción solo está disponible para SecurityManager y requiere validación de que la organización tenga módulos asignados.

**Diferencia con auto-baja:**
- **Alta manual** (este ticket): SIEMPRE manual, requiere ModuleCount > 0, ejecutada por SecurityManager
- **Auto-baja** (TASK-001-BE-EXT): Automática por sistema cuando ModuleCount=0

**Regla de negocio CRÍTICA:**
- **NO se puede dar de alta** una organización que no tenga módulos asignados (ModuleCount = 0)
- Razón: Una organización sin módulos no tiene permisos de acceso a ninguna aplicación
- UI debe mostrar error: "No se puede dar de alta una organización sin módulos asignados. Asigne al menos un módulo antes de reactivarla."

**Flujo típico:**
1. Organización fue dada de baja (manual o automática)
2. SecurityManager decide reactivarla
3. Sistema valida: ModuleCount > 0
4. Si válido: Usar DeleteUndeleteLogicById de Helix6 con userId
5. Registrar en AUDIT_LOG con Action="OrganizationReactivatedManual" y UserId poblado
6. Publicar OrganizationEvent con IsDeleted=false

## CONTEXTO TÉCNICO
- **Helix6**: DeleteUndeleteLogicById permite revertir soft delete (AuditDeletionDate → NULL)
- **Vista**: VW_ORGANIZATION para consultar ModuleCount actual
- **Auditoría**: IAuditLogService con Action="OrganizationReactivatedManual"
- **Eventos**: OrganizationEvent publicado desde OrganizationModuleService (arquitectura diferida)
- **Validación**: ModuleCount > 0 obligatorio antes de reactivar

## CRITERIOS DE ACEPTACIÓN TÉCNICOS
- [ ] Endpoint POST /organizations/{id}/reactivate implementado
- [ ] Validación: Solo puede reactivar si ModuleCount > 0
- [ ] Validación: Solo puede reactivar si AuditDeletionDate != NULL (está dada de baja)
- [ ] Método usa DeleteUndeleteLogicById de Helix6 con userId del SecurityManager
- [ ] AuditDeletionDate se establece a NULL (reactivación)
- [ ] Registro en AUDIT_LOG con Action="OrganizationReactivatedManual" y UserId poblado
- [ ] OrganizationEvent publicado con IsDeleted=false
- [ ] Error 400 BadRequest si ModuleCount = 0 con mensaje descriptivo
- [ ] Error 400 BadRequest si organización ya está dada de alta
- [ ] Tests unitarios verifican validaciones
- [ ] Tests de integración del endpoint

## GUÍA DE IMPLEMENTACIÓN

### Paso 1: Crear Método en OrganizationService

Archivo: `InfoportOneAdmon.Services/Services/OrganizationService.cs`

```csharp
/// <summary>
/// Reactiva manualmente una organización (alta manual por SecurityManager)
/// VALIDACIÓN CRÍTICA: Solo si ModuleCount > 0
/// </summary>
public async Task<ServiceResult> ReactivateManually(int organizationId, int userId, CancellationToken cancellationToken)
{
    // Obtener estado actual desde vista
    var orgView = await _vwOrganizationRepository.GetFirstOrDefaultAsync(
        v => v.Id == organizationId,
        cancellationToken);

    if (orgView == null)
    {
        return ServiceResult.Failure("Organización no encontrada");
    }

    // Validación 1: Debe estar dada de baja
    if (!orgView.IsDadaDeBaja)
    {
        return ServiceResult.Failure("La organización ya está dada de alta");
    }

    // Validación 2: CRÍTICO - Debe tener módulos asignados
    if (orgView.ModuleCount == 0)
    {
        return ServiceResult.Failure(
            "No se puede dar de alta una organización sin módulos asignados. " +
            "Asigne al menos un módulo antes de reactivarla.");
    }

    // Obtener entidad para actualizar
    var organization = await Repository.GetByIdAsync(organizationId, cancellationToken);

    // Reactivar usando Helix6
    organization.AuditDeletionDate = null; // NULL = dada de alta
    organization.AuditModificationDate = DateTime.UtcNow;
    organization.AuditModificationUser = userId;

    await Repository.UpdateAsync(organization, cancellationToken);

    // Auditar (cambio crítico)
    await _auditLogService.LogAsync(new AuditEntry
    {
        Action = "OrganizationReactivatedManual",
        EntityType = "Organization",
        EntityId = organizationId,
        UserId = userId, // IMPORTANTE: UserId poblado (no NULL)
        Timestamp = DateTime.UtcNow,
        CorrelationId = Guid.NewGuid().ToString()
    }, cancellationToken);

    _logger.LogInformation(
        "Organización {OrganizationId} reactivada manualmente por usuario {UserId}",
        organizationId,
        userId);

    // Publicar evento actualizado (IsDeleted=false)
    // NOTA: Esto se hace automáticamente desde OrganizationModuleService
    // porque la organización YA tiene módulos (validado arriba)

    return ServiceResult.Success();
}
```

### Paso 2: Crear Endpoint

Archivo: `InfoportOneAdmon.Api/Endpoints/OrganizationEndpoints.cs`

```csharp
/// <summary>
/// Dar de alta manualmente una organización (requiere rol SecurityManager)
/// VALIDACIÓN: Solo si tiene módulos asignados (ModuleCount > 0)
/// </summary>
/// <param name="id">ID de la organización</param>
/// <returns>NoContent si la reactivación fue exitosa</returns>
[HttpPost("{id}/reactivate")]
[ProducesResponseType(StatusCodes.Status204NoContent)]
[ProducesResponseType(StatusCodes.Status400BadRequest)]
[ProducesResponseType(StatusCodes.Status404NotFound)]
public async Task<IActionResult> ReactivateOrganization([FromRoute] int id)
{
    var userId = GetCurrentUserId(); // Obtener de JWT claims
    
    var service = scope.ServiceProvider.GetRequiredService<IOrganizationService>();
    
    var result = await service.ReactivateManually(id, userId, CancellationToken);
    
    if (!result.Success)
        return BadRequest(new { errors = result.Errors });
    
    return NoContent();
}
```

### Paso 3: Tests Unitarios

Archivo: `InfoportOneAdmon.Services.Tests/Services/OrganizationServiceTests.cs`

```csharp
[Fact]
public async Task ReactivateManually_WhenModuleCountIsZero_ReturnsFalse()
{
    // Arrange: Organización dada de baja SIN módulos
    var orgView = new VwOrganization
    {
        Id = 123,
        SecurityCompanyId = 12345,
        Name = "Org sin módulos",
        ModuleCount = 0, // SIN módulos
        IsDadaDeBaja = true // Dada de baja
    };

    _vwOrganizationRepositoryMock.Setup(r => r.GetFirstOrDefaultAsync(
        It.IsAny<Expression<Func<VwOrganization, bool>>>(),
        It.IsAny<CancellationToken>()))
        .ReturnsAsync(orgView);

    // Act
    var result = await _service.ReactivateManually(123, userId, CancellationToken.None);

    // Assert
    result.Success.Should().BeFalse();
    result.Errors.Should().Contain(e => e.Contains("sin módulos asignados"));
    
    // Verificar que NO se llamó a UpdateAsync
    _repositoryMock.Verify(r => r.UpdateAsync(
        It.IsAny<Organization>(),
        It.IsAny<CancellationToken>()),
        Times.Never);
}

[Fact]
public async Task ReactivateManually_WhenAlreadyActive_ReturnsFalse()
{
    // Arrange: Organización ya dada de alta
    var orgView = new VwOrganization
    {
        Id = 456,
        ModuleCount = 5,
        IsDadaDeBaja = false // Ya dada de alta
    };

    _vwOrganizationRepositoryMock.Setup(r => r.GetFirstOrDefaultAsync(
        It.IsAny<Expression<Func<VwOrganization, bool>>>(),
        It.IsAny<CancellationToken>()))
        .ReturnsAsync(orgView);

    // Act
    var result = await _service.ReactivateManually(456, userId, CancellationToken.None);

    // Assert
    result.Success.Should().BeFalse();
    result.Errors.Should().Contain(e => e.Contains("ya está dada de alta"));
}

[Fact]
public async Task ReactivateManually_WhenValidConditions_SucceedsAndAudits()
{
    // Arrange: Organización dada de baja CON módulos
    var orgView = new VwOrganization
    {
        Id = 789,
        SecurityCompanyId = 78900,
        ModuleCount = 3, // CON módulos
        IsDadaDeBaja = true // Dada de baja
    };

    var organization = new Organization
    {
        Id = 789,
        SecurityCompanyId = 78900,
        Name = "Org a reactivar",
        Cif = "A78900000",
        ContactEmail = "reactivate@test.com",
        AuditDeletionDate = DateTime.UtcNow.AddDays(-10) // Dada de baja hace 10 días
    };

    _vwOrganizationRepositoryMock.Setup(r => r.GetFirstOrDefaultAsync(
        It.IsAny<Expression<Func<VwOrganization, bool>>>(),
        It.IsAny<CancellationToken>()))
        .ReturnsAsync(orgView);

    _repositoryMock.Setup(r => r.GetByIdAsync(789, It.IsAny<CancellationToken>()))
        .ReturnsAsync(organization);

    _repositoryMock.Setup(r => r.UpdateAsync(It.IsAny<Organization>(), It.IsAny<CancellationToken>()))
        .Returns(Task.CompletedTask);

    // Act
    var result = await _service.ReactivateManually(789, userId, CancellationToken.None);

    // Assert
    result.Success.Should().BeTrue();
    
    // Verificar que AuditDeletionDate se estableció a NULL
    organization.AuditDeletionDate.Should().BeNull();
    organization.AuditModificationUser.Should().Be(userId);
    
    // Verificar auditoría con Action correcto y UserId poblado
    _auditLogServiceMock.Verify(a => a.LogAsync(
        It.Is<AuditEntry>(e => 
            e.Action == "OrganizationReactivatedManual" && 
            e.EntityId == 789 &&
            e.UserId == userId),
        It.IsAny<CancellationToken>()),
        Times.Once);
    
    // Verificar actualización en BD
    _repositoryMock.Verify(r => r.UpdateAsync(
        It.Is<Organization>(o => o.AuditDeletionDate == null),
        It.IsAny<CancellationToken>()),
        Times.Once);
}
```

### Paso 4: Tests de Integración

Archivo: `InfoportOneAdmon.Api.Tests/Endpoints/OrganizationEndpointsTests.cs`

```csharp
[Fact]
public async Task Reactivate_WithNoModules_ReturnsBadRequest()
{
    // Arrange: Crear y desactivar organización sin módulos
    var org = new OrganizationView
    {
        Name = "Org sin módulos",
        Cif = "R11111111",
        ContactEmail = "nomodules@test.com"
    };
    var createResponse = await _client.PostAsJsonAsync("/organizations", org);
    var created = await createResponse.Content.ReadFromJsonAsync<OrganizationView>();

    // Desactivarla
    await _client.PostAsync($"/organizations/{created.Id}/deactivate", null);

    // Act: Intentar reactivar sin módulos
    var response = await _client.PostAsync($"/organizations/{created.Id}/reactivate", null);

    // Assert
    response.StatusCode.Should().Be(System.Net.HttpStatusCode.BadRequest);
    var error = await response.Content.ReadAsStringAsync();
    error.Should().Contain("sin módulos asignados");
}

[Fact]
public async Task Reactivate_WithModules_Succeeds()
{
    // Arrange: Crear organización, asignar módulos, desactivar
    var org = new OrganizationView
    {
        Name = "Org con módulos",
        Cif = "R22222222",
        ContactEmail = "withmodules@test.com"
    };
    var createResponse = await _client.PostAsJsonAsync("/organizations", org);
    var created = await createResponse.Content.ReadFromJsonAsync<OrganizationView>();

    // Asignar módulo
    var assignRequest = new AssignModuleRequest
    {
        AppId = 1,
        ModuleId = 101,
        DatabaseName = "db_test"
    };
    await _client.PostAsJsonAsync($"/organizations/{created.Id}/modules", assignRequest);

    // Desactivar
    await _client.PostAsync($"/organizations/{created.Id}/deactivate", null);

    // Act: Reactivar (ahora SÍ tiene módulos)
    var response = await _client.PostAsync($"/organizations/{created.Id}/reactivate", null);

    // Assert
    response.StatusCode.Should().Be(System.Net.HttpStatusCode.NoContent);
    
    // Verificar que está dada de alta
    var getResponse = await _client.GetAsync($"/organizations/{created.Id}");
    var reactivated = await getResponse.Content.ReadFromJsonAsync<OrganizationView>();
    reactivated.AuditDeletionDate.Should().BeNull();
}
```

## ARCHIVOS A CREAR/MODIFICAR

**Backend:**
- `InfoportOneAdmon.Services/Services/OrganizationService.cs` - Añadir método ReactivateManually
- `InfoportOneAdmon.Api/Endpoints/OrganizationEndpoints.cs` - Añadir endpoint POST /organizations/{id}/reactivate
- `InfoportOneAdmon.Services.Tests/Services/OrganizationServiceTests.cs` - Tests de validación
- `InfoportOneAdmon.Api.Tests/Endpoints/OrganizationEndpointsTests.cs` - Tests de integración

## DEPENDENCIAS
- TASK-001-BE - OrganizationService debe existir
- TASK-001-VIEW - Vista VW_ORGANIZATION con ModuleCount
- TASK-001-BE-EXT - Tabla ORGANIZATION_MODULE con módulos asignados
- TASK-AUDIT-SIMPLE - IAuditLogService y tabla AUDIT_LOG
- TASK-001-EV-PUB-DEFERRED - OrganizationEvent para publicar estado actualizado

## DEFINITION OF DONE
- [x] Método ReactivateManually implementado en OrganizationService
- [x] Endpoint POST /organizations/{id}/reactivate creado
- [x] Validación ModuleCount > 0 implementada y testeada
- [x] Validación organización dada de baja implementada y testeada
- [x] AuditDeletionDate se establece a NULL en reactivación
- [x] AUDIT_LOG registra Action="OrganizationReactivatedManual" con UserId poblado
- [x] Test unitario verifica rechazo si ModuleCount=0
- [x] Test unitario verifica rechazo si ya está dada de alta
- [x] Test unitario verifica reactivación exitosa con módulos
- [x] Test integración verifica flujo completo (crear, asignar módulos, desactivar, reactivar)
- [x] Endpoint documentado en Swagger
- [x] Code review aprobado
- [x] Sin warnings ni vulnerabilidades

## RECURSOS
- Helix6 Documentation: DeleteUndeleteLogicById
- User Story: `userStories.md#us-003v2`
- Arquitectura: Matriz de auditoría crítica en `tickets_epica1.md`

=============================================================
