using System;
using System.Collections.Generic;
using InfoportOneAdmon.Back.DataModel;
using Microsoft.EntityFrameworkCore;

namespace InfoportOneAdmon.Back.Data.DataModel;

public partial class EntityModel : DbContext
{
    public EntityModel(DbContextOptions<EntityModel> options)
        : base(options)
    {
    }

    public virtual DbSet<Application> Application { get; set; }

    public virtual DbSet<ApplicationModule> ApplicationModule { get; set; }

    public virtual DbSet<ApplicationRole> ApplicationRole { get; set; }

    public virtual DbSet<ApplicationSecurity> ApplicationSecurity { get; set; }

    public virtual DbSet<AuditLog> AuditLog { get; set; }

    public virtual DbSet<EventHash> EventHash { get; set; }

    public virtual DbSet<Organization> Organization { get; set; }

    public virtual DbSet<OrganizationApplicationModule> OrganizationApplicationModule { get; set; }

    public virtual DbSet<OrganizationGroup> OrganizationGroup { get; set; }

    public virtual DbSet<UserCache> UserCache { get; set; }

    public virtual DbSet<VTA_ActiveApplicationModules> VTA_ActiveApplicationModules { get; set; }

    public virtual DbSet<VTA_ActiveApplications> VTA_ActiveApplications { get; set; }

    public virtual DbSet<VTA_ActiveOrganizations> VTA_ActiveOrganizations { get; set; }

    public virtual DbSet<VTA_ApplicationSecurityCredentials> VTA_ApplicationSecurityCredentials { get; set; }

    public virtual DbSet<VTA_OrganizationModuleAccess> VTA_OrganizationModuleAccess { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasPostgresExtension("citext");

        modelBuilder.Entity<Application>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("Application_pkey");

            entity.ToTable("Application", "Admon", tb => tb.HasComment("Aplicaciones satélite del portfolio empresarial. Define el catálogo de aplicaciones disponibles"));

            entity.Property(e => e.Id).HasComment("Clave primaria técnica requerida por Helix6 (IEntityBase)");
            entity.Property(e => e.Acronym).HasComment("Acrónimo único para nomenclatura de roles y módulos (ej: STP, CRM, ERP)");
            entity.Property(e => e.ApplicationId)
                .ValueGeneratedOnAdd()
                .HasComment("Identificador único de negocio auto-generado inmutable")
                .UseIdentityAlwaysColumn();
            entity.Property(e => e.AuditCreationDate).HasDefaultValueSql("CURRENT_TIMESTAMP");
            entity.Property(e => e.AuditDeletionDate).HasComment("Fecha de baja lógica. Al establecerse, revoca automáticamente todas sus credenciales en Keycloak");
            entity.Property(e => e.AuditModificationDate).HasDefaultValueSql("CURRENT_TIMESTAMP");
        });

        modelBuilder.Entity<ApplicationModule>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("ApplicationModule_pkey");

            entity.ToTable("ApplicationModule", "Admon", tb => tb.HasComment("Módulos funcionales de aplicaciones. Permiten ventas granulares por funcionalidad"));

            entity.Property(e => e.AuditCreationDate).HasDefaultValueSql("CURRENT_TIMESTAMP");
            entity.Property(e => e.AuditDeletionDate).HasComment("Fecha de baja lógica del módulo");
            entity.Property(e => e.AuditModificationDate).HasDefaultValueSql("CURRENT_TIMESTAMP");
            entity.Property(e => e.Name).HasComment("Nombre del módulo siguiendo nomenclatura: M + Acronym + _ + nombre funcional");

            entity.HasOne(d => d.Application).WithMany(p => p.ApplicationModule).HasConstraintName("fk_applicationmodule_application");
        });

        modelBuilder.Entity<ApplicationRole>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("ApplicationRole_pkey");

            entity.ToTable("ApplicationRole", "Admon", tb => tb.HasComment("Catálogo maestro de roles de cada aplicación. Garantiza coherencia en nomenclatura"));

            entity.Property(e => e.AuditCreationDate).HasDefaultValueSql("CURRENT_TIMESTAMP");
            entity.Property(e => e.AuditDeletionDate).HasComment("Fecha de baja lógica. Roles dados de baja no se asignan a nuevos usuarios");
            entity.Property(e => e.AuditModificationDate).HasDefaultValueSql("CURRENT_TIMESTAMP");
            entity.Property(e => e.Name).HasComment("Nombre del rol siguiendo nomenclatura: Acronym + _ + nombre funcional (ej: STP_Supervisor)");

            entity.HasOne(d => d.Application).WithMany(p => p.ApplicationRole).HasConstraintName("fk_applicationrole_application");
        });

        modelBuilder.Entity<ApplicationSecurity>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("ApplicationSecurity_pkey");

            entity.ToTable("ApplicationSecurity", "Admon", tb => tb.HasComment("Credenciales OAuth2 para autenticación de aplicaciones en Keycloak. Soporta múltiples credenciales por aplicación"));

            entity.Property(e => e.ApplicationId).HasComment("ID de la aplicación (FK a Application.Id)");
            entity.Property(e => e.AuditCreationDate).HasDefaultValueSql("CURRENT_TIMESTAMP");
            entity.Property(e => e.AuditDeletionDate).HasComment("Fecha de baja lógica. Al establecerse, revoca la credencial en Keycloak");
            entity.Property(e => e.AuditModificationDate).HasDefaultValueSql("CURRENT_TIMESTAMP");
            entity.Property(e => e.ClientId).HasComment("OAuth2 client_id único para autenticación en Keycloak");
            entity.Property(e => e.ClientSecret).HasComment("OAuth2 client_secret. NULL para public clients (SPAs con PKCE), requerido para confidential clients");
            entity.Property(e => e.ClientType).HasComment("Tipo de cliente OAuth2: Public (Angular SPAs) o Confidential (APIs backend)");
            entity.Property(e => e.CredentialType).HasComment("Tipo de credencial: CODE_PKCE (acceso web) o CLIENT_CREDENTIALS (APIs externas)");

            entity.HasOne(d => d.Application).WithMany(p => p.ApplicationSecurity).HasConstraintName("fk_appsecurity_application");
        });

        modelBuilder.Entity<AuditLog>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("AuditLog_pkey");

            entity.ToTable("AuditLog", "Admon", tb => tb.HasComment("Auditoría selectiva de acciones críticas en seguridad y permisos (complementa auditoría automática Helix6)"));

            entity.Property(e => e.Action).HasComment("Acción auditada: ModuleAssigned, ModuleRemoved, OrganizationDeactivatedManual, OrganizationAutoDeactivated, OrganizationReactivatedManual, GroupChanged");
            entity.Property(e => e.AuditCreationDate).HasDefaultValueSql("CURRENT_TIMESTAMP");
            entity.Property(e => e.AuditModificationDate).HasDefaultValueSql("CURRENT_TIMESTAMP");
            entity.Property(e => e.EntityId).HasComment("ID de la entidad afectada");
            entity.Property(e => e.EntityType).HasComment("Tipo de entidad afectada: Organization, ApplicationModule, OrganizationApplicationModule");
            entity.Property(e => e.Timestamp).HasDefaultValueSql("CURRENT_TIMESTAMP");
            entity.Property(e => e.UserId).HasComment("ID del usuario que ejecutó la acción (NULL si fue acción automática del sistema)");
        });

        modelBuilder.Entity<EventHash>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("EventHash_pkey");

            entity.ToTable("EventHash", "Admon", tb => tb.HasComment("Control de eventos duplicados mediante hash SHA-256. Previene publicar eventos idénticos consecutivos"));

            entity.Property(e => e.AuditCreationDate).HasDefaultValueSql("CURRENT_TIMESTAMP");
            entity.Property(e => e.AuditModificationDate).HasDefaultValueSql("CURRENT_TIMESTAMP");
            entity.Property(e => e.EntityId).HasComment("ID de la entidad");
            entity.Property(e => e.EntityType).HasComment("Tipo de entidad: ORGANIZATION, APPLICATION, USER");
            entity.Property(e => e.LastEventHash)
                .IsFixedLength()
                .HasComment("Hash SHA-256 (64 caracteres) del Payload del último evento publicado");
            entity.Property(e => e.LastPublishedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasComment("Timestamp de la última publicación exitosa");
        });

        modelBuilder.Entity<Organization>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("Organization_pkey");

            entity.ToTable("Organization", "Admon", tb => tb.HasComment("Organizaciones clientes del ecosistema. Fuente de verdad para multi-tenancy"));

            entity.Property(e => e.Id).HasComment("Clave primaria técnica requerida por Helix6 (IEntityBase)");
            entity.Property(e => e.Acronym).HasComment("Acrónimo único de la organización (máx. 10 caracteres) para identificación rápida");
            entity.Property(e => e.AuditCreationDate).HasDefaultValueSql("CURRENT_TIMESTAMP");
            entity.Property(e => e.AuditDeletionDate).HasComment("Fecha de baja lógica. Al establecerse, bloquea acceso inmediato y propaga baja de usuarios a Keycloak");
            entity.Property(e => e.AuditModificationDate).HasDefaultValueSql("CURRENT_TIMESTAMP");
            entity.Property(e => e.GroupId).HasComment("ID del grupo al que pertenece (holding, consorcio). NULL si no pertenece a ningún grupo");
            entity.Property(e => e.SecurityCompanyId)
                .ValueGeneratedOnAdd()
                .HasComment("Identificador único inmutable de la organización. Se propaga en claim c_ids de tokens JWT")
                .UseIdentityAlwaysColumn();
            entity.Property(e => e.TaxId).HasComment("Identificador fiscal de la organización (CIF/NIF)");

            entity.HasOne(d => d.Group).WithMany(p => p.Organization)
                .OnDelete(DeleteBehavior.SetNull)
                .HasConstraintName("fk_organization_group");
        });

        modelBuilder.Entity<OrganizationApplicationModule>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("OrganizationApplicationModule_pkey");

            entity.ToTable("OrganizationApplicationModule", "Admon", tb => tb.HasComment("Permisos de acceso a módulos por organización. Habilita ventas granulares por funcionalidad"));

            entity.Property(e => e.ApplicationModuleId).HasComment("ID del módulo al que tiene acceso la organización");
            entity.Property(e => e.AuditCreationDate).HasDefaultValueSql("CURRENT_TIMESTAMP");
            entity.Property(e => e.AuditDeletionDate).HasComment("Fecha de revocación de acceso al módulo");
            entity.Property(e => e.AuditModificationDate).HasDefaultValueSql("CURRENT_TIMESTAMP");
            entity.Property(e => e.OrganizationId).HasComment("ID de la organización cliente (Organization.Id)");

            entity.HasOne(d => d.ApplicationModule).WithMany(p => p.OrganizationApplicationModule).HasConstraintName("fk_orgappmodule_module");

            entity.HasOne(d => d.Organization).WithMany(p => p.OrganizationApplicationModule).HasConstraintName("fk_orgappmodule_organization");
        });

        modelBuilder.Entity<OrganizationGroup>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("OrganizationGroup_pkey");

            entity.ToTable("OrganizationGroup", "Admon", tb => tb.HasComment("Agrupaciones lógicas de organizaciones para facilitar gestión colectiva (holdings, consorcios)"));

            entity.Property(e => e.AuditCreationDate).HasDefaultValueSql("CURRENT_TIMESTAMP");
            entity.Property(e => e.AuditDeletionDate).HasComment("Fecha de baja lógica (soft delete). NULL = activo");
            entity.Property(e => e.AuditModificationDate).HasDefaultValueSql("CURRENT_TIMESTAMP");
            entity.Property(e => e.Name).HasComment("Nombre del grupo de organizaciones");
        });

        modelBuilder.Entity<UserCache>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("UserCache_pkey");

            entity.ToTable("UserCache", "Admon", tb => tb.HasComment("Caché de usuarios consolidados multi-organización. Optimiza procesamiento del Background Worker"));

            entity.Property(e => e.Id).HasComment("Clave primaria técnica requerida por Helix6 (IEntityBase)");
            entity.Property(e => e.AuditCreationDate).HasDefaultValueSql("CURRENT_TIMESTAMP");
            entity.Property(e => e.AuditModificationDate).HasDefaultValueSql("CURRENT_TIMESTAMP");
            entity.Property(e => e.ConsolidatedCompanyIds).HasComment("Array JSON con todos los SecurityCompanyId del usuario: [12345, 67890, 11111]");
            entity.Property(e => e.ConsolidatedRoles).HasComment("Array JSON con todos los roles consolidados del usuario de todas las apps: [\"CRM_Vendedor\", \"ERP_Contable\"]");
            entity.Property(e => e.Email).HasComment("Email del usuario (único, case-insensitive)");
            entity.Property(e => e.LastEventHash)
                .IsFixedLength()
                .HasComment("Hash SHA-256 del último evento procesado para este usuario");
            entity.Property(e => e.LastUpdated)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasComment("Timestamp de la última consolidación");
        });

        modelBuilder.Entity<VTA_ActiveApplicationModules>(entity =>
        {
            entity.ToView("VTA_ActiveApplicationModules", "Admon");
        });

        modelBuilder.Entity<VTA_ActiveApplications>(entity =>
        {
            entity.ToView("VTA_ActiveApplications", "Admon");
        });

        modelBuilder.Entity<VTA_ActiveOrganizations>(entity =>
        {
            entity.ToView("VTA_ActiveOrganizations", "Admon");
        });

        modelBuilder.Entity<VTA_ApplicationSecurityCredentials>(entity =>
        {
            entity.ToView("VTA_ApplicationSecurityCredentials", "Admon");
        });

        modelBuilder.Entity<VTA_OrganizationModuleAccess>(entity =>
        {
            entity.ToView("VTA_OrganizationModuleAccess", "Admon");
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
