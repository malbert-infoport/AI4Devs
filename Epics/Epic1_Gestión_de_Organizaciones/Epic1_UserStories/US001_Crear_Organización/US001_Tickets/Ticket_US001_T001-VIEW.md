# TASK-001-VIEW: Crear vista VW_ORGANIZATION con campos calculados

=============================================================
**TICKET ID:** TASK-001-VIEW  
**EPIC:** Gestión del Portfolio de Organizaciones Clientes  
**USER STORY:** US-001 - Crear nueva organización cliente  
**COMPONENT:** Database - View  
**PRIORITY:** Alta  
**ESTIMATION:** 1 hora  
=============================================================

## TÍTULO
Crear vista VW_ORGANIZATION con campos calculados ModuleCount y AppCount

## DESCRIPCIÓN
Crear una vista de base de datos PostgreSQL que exponga las organizaciones con campos calculados para mostrar el número de aplicaciones y módulos asignados a cada organización. Esta vista se utilizará en:

1. **Grid de organizaciones** (US-004): Mostrar columnas "Nº Apps" y "Nº Módulos"
2. **Lógica de auto-baja** (US-017v2): Detectar cuando ModuleCount llega a 0
3. **Validación de alta manual** (US-003v2): Verificar que ModuleCount > 0 antes de reactivar

**Campos calculados:**
- **ModuleCount**: COUNT DISTINCT de módulos asignados a través de ORGANIZATION_MODULE
- **AppCount**: COUNT DISTINCT de aplicaciones a través de ORGANIZATION_MODULE

**Rendimiento:** La vista debe incluir índices apropiados para consultas por SecurityCompanyId y filtros por AuditDeletionDate.

## CONTEXTO TÉCNICO
- **Base de datos**: PostgreSQL 15+
- **Tablas origen**: ORGANIZATION, ORGANIZATION_MODULE (tabla de relación muchos-a-muchos)
- **Acceso**: La vista se usará desde OrganizationService y OrganizationModuleService
- **Índices**: Aprovechar índices existentes en ORGANIZATION (SecurityCompanyId, CIF)

## CRITERIOS DE ACEPTACIÓN TÉCNICOS
- [ ] Vista VW_ORGANIZATION creada en PostgreSQL
- [ ] Campo ModuleCount calculado correctamente (0 si no tiene módulos)
- [ ] Campo AppCount calculado correctamente (0 si no tiene aplicaciones)
- [ ] Vista incluye TODOS los campos de ORGANIZATION (Id, SecurityCompanyId, Name, CIF, etc.)
- [ ] Vista incluye AuditDeletionDate para filtrar alta/baja
- [ ] Migración EF Core generada para crear la vista
- [ ] Tests de integración verifican cálculos correctos
- [ ] Documentación SQL de la vista creada

## GUÍA DE IMPLEMENTACIÓN

### Paso 1: Crear Script SQL de la Vista

Archivo: `InfoportOneAdmon.DataModel/Migrations/Scripts/CreateView_VW_ORGANIZATION.sql`

```sql
-- Vista que expone organizaciones con campos calculados de módulos y aplicaciones
CREATE OR REPLACE VIEW VW_ORGANIZATION AS
SELECT 
    o.id,
    o.security_company_id,
    o.name,
    o.cif,
    o.address,
    o.city,
    o.postal_code,
    o.country,
    o.contact_email,
    o.contact_phone,
    o.group_id,
    o.audit_creation_user,
    o.audit_creation_date,
    o.audit_modification_user,
    o.audit_modification_date,
    o.audit_deletion_date,
    
    -- Campos calculados
    COALESCE(COUNT(DISTINCT om.module_id), 0) AS module_count,
    COALESCE(COUNT(DISTINCT om.app_id), 0) AS app_count
    
FROM 
    organization o
    LEFT JOIN organization_module om ON o.id = om.organization_id
    
GROUP BY 
    o.id,
    o.security_company_id,
    o.name,
    o.cif,
    o.address,
    o.city,
    o.postal_code,
    o.country,
    o.contact_email,
    o.contact_phone,
    o.group_id,
    o.audit_creation_user,
    o.audit_creation_date,
    o.audit_modification_user,
    o.audit_modification_date,
    o.audit_deletion_date;

-- Comentarios para documentación
COMMENT ON VIEW VW_ORGANIZATION IS 'Vista de organizaciones con contadores de aplicaciones y módulos asignados';
COMMENT ON COLUMN VW_ORGANIZATION.module_count IS 'Número total de módulos asignados a la organización';
COMMENT ON COLUMN VW_ORGANIZATION.app_count IS 'Número total de aplicaciones distintas asignadas a la organización';
```

### Paso 2: Crear Migración EF Core para la Vista

Archivo: `InfoportOneAdmon.DataModel/Migrations/XXXXXX_CreateVwOrganization.cs`

```csharp
using Microsoft.EntityFrameworkCore.Migrations;
using System.IO;

namespace InfoportOneAdmon.DataModel.Migrations
{
    public partial class CreateVwOrganization : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Leer y ejecutar el script SQL de la vista
            var assembly = typeof(CreateVwOrganization).Assembly;
            var resourceName = "InfoportOneAdmon.DataModel.Migrations.Scripts.CreateView_VW_ORGANIZATION.sql";
            
            using (var stream = assembly.GetManifestResourceStream(resourceName))
            using (var reader = new StreamReader(stream))
            {
                var sql = reader.ReadToEnd();
                migrationBuilder.Sql(sql);
            }
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("DROP VIEW IF EXISTS VW_ORGANIZATION;");
        }
    }
}
```

**NOTA:** Marcar el archivo SQL como "Embedded Resource" en las propiedades del proyecto.

### Paso 3: Crear Entidad de Vista en EF Core (opcional, para queries)

Archivo: `InfoportOneAdmon.DataModel/Entities/VwOrganization.cs`

```csharp
using System.ComponentModel.DataAnnotations.Schema;

namespace InfoportOneAdmon.DataModel.Entities
{
    /// <summary>
    /// Vista de organizaciones con campos calculados de módulos y aplicaciones
    /// </summary>
    [Table("vw_organization")]
    public class VwOrganization
    {
        public int Id { get; set; }
        public int SecurityCompanyId { get; set; }
        public string Name { get; set; }
        public string Cif { get; set; }
        public string Address { get; set; }
        public string City { get; set; }
        public string PostalCode { get; set; }
        public string Country { get; set; }
        public string ContactEmail { get; set; }
        public string ContactPhone { get; set; }
        public int? GroupId { get; set; }
        
        public int? AuditCreationUser { get; set; }
        public DateTime? AuditCreationDate { get; set; }
        public int? AuditModificationUser { get; set; }
        public DateTime? AuditModificationDate { get; set; }
        public DateTime? AuditDeletionDate { get; set; }
        
        // Campos calculados
        public int ModuleCount { get; set; }
        public int AppCount { get; set; }
        
        // Propiedades derivadas para UI
        [NotMapped]
        public bool HasModules => ModuleCount > 0;
        
        [NotMapped]
        public bool IsDadaDeBaja => AuditDeletionDate.HasValue;
    }
}
```

### Paso 4: Registrar en DbContext

Archivo: `InfoportOneAdmon.DataModel/InfoportOneAdmonContext.cs`

```csharp
public DbSet<VwOrganization> VwOrganizations { get; set; }

protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    base.OnModelCreating(modelBuilder);
    
    // Configurar vista (sin clave primaria en EF Core para vistas)
    modelBuilder.Entity<VwOrganization>()
        .HasNoKey()
        .ToView("vw_organization");
}
```

### Paso 5: Implementar Tests de Integración

Archivo: `InfoportOneAdmon.DataModel.Tests/Views/VwOrganizationTests.cs`

```csharp
using Xunit;
using FluentAssertions;
using Microsoft.EntityFrameworkCore;

namespace InfoportOneAdmon.DataModel.Tests.Views
{
    public class VwOrganizationTests : IClassFixture<DatabaseFixture>
    {
        private readonly InfoportOneAdmonContext _context;

        public VwOrganizationTests(DatabaseFixture fixture)
        {
            _context = fixture.Context;
        }

        [Fact]
        public async Task VwOrganization_WithNoModules_ReturnsZeroCount()
        {
            // Arrange: Crear organización sin módulos
            var org = new Organization
            {
                SecurityCompanyId = 12345,
                Name = "Test Org",
                Cif = "A12345678",
                ContactEmail = "test@example.com"
            };
            _context.Organizations.Add(org);
            await _context.SaveChangesAsync();

            // Act: Consultar vista
            var view = await _context.VwOrganizations
                .FirstOrDefaultAsync(v => v.Id == org.Id);

            // Assert
            view.Should().NotBeNull();
            view.ModuleCount.Should().Be(0);
            view.AppCount.Should().Be(0);
            view.HasModules.Should().BeFalse();
        }

        [Fact]
        public async Task VwOrganization_WithMultipleModules_ReturnsCorrectCounts()
        {
            // Arrange: Crear organización con 3 módulos de 2 aplicaciones distintas
            var org = new Organization
            {
                SecurityCompanyId = 99999,
                Name = "Multi-App Org",
                Cif = "B99999999",
                ContactEmail = "multi@example.com"
            };
            _context.Organizations.Add(org);
            await _context.SaveChangesAsync();

            // Asignar módulos
            var modules = new[]
            {
                new OrganizationModule { OrganizationId = org.Id, AppId = 1, ModuleId = 101 },
                new OrganizationModule { OrganizationId = org.Id, AppId = 1, ModuleId = 102 },
                new OrganizationModule { OrganizationId = org.Id, AppId = 2, ModuleId = 201 }
            };
            _context.OrganizationModules.AddRange(modules);
            await _context.SaveChangesAsync();

            // Act: Consultar vista
            var view = await _context.VwOrganizations
                .FirstOrDefaultAsync(v => v.Id == org.Id);

            // Assert
            view.Should().NotBeNull();
            view.ModuleCount.Should().Be(3); // 3 módulos distintos
            view.AppCount.Should().Be(2); // 2 aplicaciones distintas
            view.HasModules.Should().BeTrue();
        }

        [Fact]
        public async Task VwOrganization_FilterByAuditDeletionDate_Works()
        {
            // Arrange: Crear organización dada de baja
            var org = new Organization
            {
                SecurityCompanyId = 88888,
                Name = "Deactivated Org",
                Cif = "C88888888",
                ContactEmail = "deactivated@example.com",
                AuditDeletionDate = DateTime.UtcNow
            };
            _context.Organizations.Add(org);
            await _context.SaveChangesAsync();

            // Act: Consultar vista filtrando por dadas de alta
            var activeOrgs = await _context.VwOrganizations
                .Where(v => v.AuditDeletionDate == null)
                .ToListAsync();

            var inactiveOrgs = await _context.VwOrganizations
                .Where(v => v.AuditDeletionDate != null)
                .ToListAsync();

            // Assert
            activeOrgs.Should().NotContain(v => v.Id == org.Id);
            inactiveOrgs.Should().Contain(v => v.Id == org.Id);
        }
    }
}
```

## ARCHIVOS A CREAR/MODIFICAR

**Database:**
- `InfoportOneAdmon.DataModel/Migrations/Scripts/CreateView_VW_ORGANIZATION.sql` - Script SQL de la vista
- `InfoportOneAdmon.DataModel/Migrations/XXXXXX_CreateVwOrganization.cs` - Migración EF Core
- `InfoportOneAdmon.DataModel/Entities/VwOrganization.cs` - Entidad de vista (opcional para queries)
- `InfoportOneAdmon.DataModel/InfoportOneAdmonContext.cs` - Registrar DbSet de la vista

**Tests:**
- `InfoportOneAdmon.DataModel.Tests/Views/VwOrganizationTests.cs` - Tests de integración

## DEPENDENCIAS
- TASK-001-BE - Tabla ORGANIZATION debe existir
- TASK-001-BE-EXT - Tabla ORGANIZATION_MODULE debe existir (relación muchos-a-muchos)

## DEFINITION OF DONE
- [x] Script SQL de la vista creado con ModuleCount y AppCount
- [x] Vista incluye TODOS los campos de ORGANIZATION
- [x] Migración EF Core generada y ejecutada sin errores
- [x] Entidad VwOrganization creada y registrada en DbContext
- [x] Test verifica ModuleCount=0 cuando no hay módulos
- [x] Test verifica cálculos correctos con múltiples módulos de varias aplicaciones
- [x] Test verifica filtrado por AuditDeletionDate
- [x] Comentarios SQL documentan la vista y sus columnas
- [x] Code review aprobado
- [x] Sin warnings de SQL ni EF Core

## RECURSOS
- PostgreSQL Documentation: [CREATE VIEW](https://www.postgresql.org/docs/current/sql-createview.html)
- EF Core Migrations: [SQL Scripts](https://docs.microsoft.com/ef/core/managing-schemas/migrations/managing)
- User Story: `userStories.md#us-004`
- User Story: `userStories.md#us-017v2`

=============================================================
