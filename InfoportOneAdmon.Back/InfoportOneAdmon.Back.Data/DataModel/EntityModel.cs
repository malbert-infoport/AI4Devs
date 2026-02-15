using System;
using System.Collections.Generic;
using System.Linq;
using InfoportOneAdmon.Back.DataModel;
using Microsoft.EntityFrameworkCore;

namespace InfoportOneAdmon.Back.Data.DataModel;

public partial class EntityModel : DbContext
{
    public EntityModel(DbContextOptions<EntityModel> options)
        : base(options)
    {
    }

    // DbSets para InfoportOneAdmon
    public virtual DbSet<OrganizationGroup> OrganizationGroup { get; set; }

    public virtual DbSet<Organization> Organization { get; set; }

    public virtual DbSet<Application> Application { get; set; }

    public virtual DbSet<ApplicationSecurity> ApplicationSecurity { get; set; }

    public virtual DbSet<ApplicationModule> ApplicationModule { get; set; }

    public virtual DbSet<ApplicationRole> ApplicationRole { get; set; }

    public virtual DbSet<OrganizationApplicationModule> OrganizationApplicationModule { get; set; }

    public virtual DbSet<AuditLog> AuditLog { get; set; }

    public virtual DbSet<EventHash> EventHash { get; set; }

    public virtual DbSet<UserCache> UserCache { get; set; }

    // DbSets para vistas
    public virtual DbSet<VTA_ActiveOrganizations> VTA_ActiveOrganizations { get; set; }

    public virtual DbSet<VTA_ActiveApplications> VTA_ActiveApplications { get; set; }

    public virtual DbSet<VTA_ApplicationSecurityCredentials> VTA_ApplicationSecurityCredentials { get; set; }

    public virtual DbSet<VTA_ActiveApplicationModules> VTA_ActiveApplicationModules { get; set; }

    public virtual DbSet<VTA_OrganizationModuleAccess> VTA_OrganizationModuleAccess { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // ====================================================================
        // Configuración de entidades InfoportOneAdmon
        // ====================================================================

        modelBuilder.HasDefaultSchema("Admon");

        ConfigureOrganizationGroup(modelBuilder);
        ConfigureOrganization(modelBuilder);
        ConfigureApplication(modelBuilder);
        ConfigureApplicationSecurity(modelBuilder);
        ConfigureApplicationModule(modelBuilder);
        ConfigureApplicationRole(modelBuilder);
        ConfigureOrganizationApplicationModule(modelBuilder);
        ConfigureAuditLog(modelBuilder);
        ConfigureEventHash(modelBuilder);
        ConfigureUserCache(modelBuilder);

        // Configuración de vistas
        ConfigureViews(modelBuilder);

        // ----------------------------------------------------------------
        // Forzar tipo SQL para propiedades DateTime/DateTime?
        // Motivo: algunas entidades o herramientas de scaffolding (p. ej. cuando
        // se migra desde SQL Server) pueden dejar anotaciones con
        // `.HasColumnType("datetime")` o generar migraciones con
        // `type: "datetime"`. PostgreSQL no conoce ese tipo y falla al aplicar
        // migraciones. Para evitar tener que editar manualmente cada migración,
        // forzamos aquí que todas las propiedades `DateTime`/`DateTime?` se
        // mapearán al tipo PostgreSQL `timestamp` al generar futuras
        // migraciones.
        // Si prefieres incluir zona horaria, cambia a "timestamp with time zone".
        foreach (var entityType in modelBuilder.Model.GetEntityTypes())
        {
            var clrType = entityType.ClrType;
            if (clrType == null) continue;
            var dateProps = entityType.GetProperties()
                .Where(p => p.ClrType == typeof(DateTime) || p.ClrType == typeof(DateTime?));
            foreach (var p in dateProps)
            {
                modelBuilder.Entity(clrType).Property(p.Name).HasColumnType("timestamp");
            }
        }
    }

    // ====================================================================
    // Métodos de configuración para entidades InfoportOneAdmon
    // ====================================================================

    private void ConfigureOrganizationGroup(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<OrganizationGroup>(entity =>
        {
            entity.Property(e => e.Id).HasComment("Clave primaria técnica");
            entity.Property(e => e.Name).HasComment("Nombre del grupo de organizaciones");
            entity.Property(e => e.AuditCreationDate).HasComment("Audit - Creation Date#Registry creation date");
            entity.Property(e => e.AuditCreationUser).HasComment("Audit - Creation User#Registry creation user");
            entity.Property(e => e.AuditDeletionDate).HasComment("Audit - Deletion Date#Logic registry deletion date");
            entity.Property(e => e.AuditModificationDate).HasComment("Audit - Modification Date#Last registry modification date");
            entity.Property(e => e.AuditModificationUser).HasComment("Audit - Modification User#Registry modification User");
        });
    }

    private void ConfigureOrganization(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Organization>(entity =>
        {
            entity.Property(e => e.Id).HasComment("Clave primaria técnica requerida por Helix6 (IEntityBase)");
            entity.Property(e => e.SecurityCompanyId).HasComment("Identificador único inmutable de la organización. Se propaga en claim c_ids de tokens JWT");
            entity.Property(e => e.AuditCreationDate).HasComment("Audit - Creation Date#Registry creation date");
            entity.Property(e => e.AuditCreationUser).HasComment("Audit - Creation User#Registry creation user");
            entity.Property(e => e.AuditDeletionDate).HasComment("Audit - Deletion Date#Logic registry deletion date");
            entity.Property(e => e.AuditModificationDate).HasComment("Audit - Modification Date#Last registry modification date");
            entity.Property(e => e.AuditModificationUser).HasComment("Audit - Modification User#Registry modification User");

            entity.HasOne(d => d.OrganizationGroup)
                .WithMany(p => p.Organizations)
                .HasForeignKey(d => d.GroupId)
                .OnDelete(DeleteBehavior.SetNull)
                .HasConstraintName("fk_organization_group");
        });
    }

    private void ConfigureApplication(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Application>(entity =>
        {
            entity.Property(e => e.Id).HasComment("Clave primaria técnica requerida por Helix6 (IEntityBase)");
            entity.Property(e => e.ApplicationId).HasComment("Identificador único de negocio auto-generado inmutable");
            entity.Property(e => e.AuditCreationDate).HasComment("Audit - Creation Date#Registry creation date");
            entity.Property(e => e.AuditCreationUser).HasComment("Audit - Creation User#Registry creation user");
            entity.Property(e => e.AuditDeletionDate).HasComment("Audit - Deletion Date#Logic registry deletion date");
            entity.Property(e => e.AuditModificationDate).HasComment("Audit - Modification Date#Last registry modification date");
            entity.Property(e => e.AuditModificationUser).HasComment("Audit - Modification User#Registry modification User");
        });
    }

    private void ConfigureApplicationSecurity(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<ApplicationSecurity>(entity =>
        {
            entity.Property(e => e.Id).HasComment("Clave primaria técnica");
            entity.Property(e => e.AuditCreationDate).HasComment("Audit - Creation Date#Registry creation date");
            entity.Property(e => e.AuditCreationUser).HasComment("Audit - Creation User#Registry creation user");
            entity.Property(e => e.AuditDeletionDate).HasComment("Audit - Deletion Date#Logic registry deletion date");
            entity.Property(e => e.AuditModificationDate).HasComment("Audit - Modification Date#Last registry modification date");
            entity.Property(e => e.AuditModificationUser).HasComment("Audit - Modification User#Registry modification User");

            entity.HasOne(d => d.Application)
                .WithMany(p => p.ApplicationSecurities)
                .HasForeignKey(d => d.ApplicationId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("fk_appsecurity_application");
        });
    }

    private void ConfigureApplicationModule(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<ApplicationModule>(entity =>
        {
            entity.Property(e => e.Id).HasComment("Clave primaria técnica");
            entity.Property(e => e.AuditCreationDate).HasComment("Audit - Creation Date#Registry creation date");
            entity.Property(e => e.AuditCreationUser).HasComment("Audit - Creation User#Registry creation user");
            entity.Property(e => e.AuditDeletionDate).HasComment("Audit - Deletion Date#Logic registry deletion date");
            entity.Property(e => e.AuditModificationDate).HasComment("Audit - Modification Date#Last registry modification date");
            entity.Property(e => e.AuditModificationUser).HasComment("Audit - Modification User#Registry modification User");

            entity.HasOne(d => d.Application)
                .WithMany(p => p.ApplicationModules)
                .HasForeignKey(d => d.ApplicationId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("fk_applicationmodule_application");
        });
    }

    private void ConfigureApplicationRole(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<ApplicationRole>(entity =>
        {
            entity.Property(e => e.Id).HasComment("Clave primaria técnica");
            entity.Property(e => e.AuditCreationDate).HasComment("Audit - Creation Date#Registry creation date");
            entity.Property(e => e.AuditCreationUser).HasComment("Audit - Creation User#Registry creation user");
            entity.Property(e => e.AuditDeletionDate).HasComment("Audit - Deletion Date#Logic registry deletion date");
            entity.Property(e => e.AuditModificationDate).HasComment("Audit - Modification Date#Last registry modification date");
            entity.Property(e => e.AuditModificationUser).HasComment("Audit - Modification User#Registry modification User");

            entity.HasOne(d => d.Application)
                .WithMany(p => p.ApplicationRoles)
                .HasForeignKey(d => d.ApplicationId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("fk_applicationrole_application");
        });
    }

    private void ConfigureOrganizationApplicationModule(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<OrganizationApplicationModule>(entity =>
        {
            entity.Property(e => e.Id).HasComment("Clave primaria técnica");
            entity.Property(e => e.AuditCreationDate).HasComment("Audit - Creation Date#Registry creation date");
            entity.Property(e => e.AuditCreationUser).HasComment("Audit - Creation User#Registry creation user");
            entity.Property(e => e.AuditDeletionDate).HasComment("Audit - Deletion Date#Logic registry deletion date");
            entity.Property(e => e.AuditModificationDate).HasComment("Audit - Modification Date#Last registry modification date");
            entity.Property(e => e.AuditModificationUser).HasComment("Audit - Modification User#Registry modification User");

            entity.HasOne(d => d.Organization)
                .WithMany(p => p.OrganizationApplicationModules)
                .HasForeignKey(d => d.OrganizationId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("fk_orgappmodule_organization");

            entity.HasOne(d => d.ApplicationModule)
                .WithMany(p => p.OrganizationApplicationModules)
                .HasForeignKey(d => d.ApplicationModuleId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("fk_orgappmodule_module");
        });
    }

    private void ConfigureAuditLog(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<AuditLog>(entity =>
        {
            entity.Property(e => e.Id).HasComment("Clave primaria técnica");
            entity.Property(e => e.AuditCreationDate).HasComment("Audit - Creation Date#Registry creation date");
            entity.Property(e => e.AuditCreationUser).HasComment("Audit - Creation User#Registry creation user");
            entity.Property(e => e.AuditDeletionDate).HasComment("Audit - Deletion Date#Logic registry deletion date");
            entity.Property(e => e.AuditModificationDate).HasComment("Audit - Modification Date#Last registry modification date");
            entity.Property(e => e.AuditModificationUser).HasComment("Audit - Modification User#Registry modification User");
        });
    }

    private void ConfigureEventHash(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<EventHash>(entity =>
        {
            entity.Property(e => e.Id).HasComment("Clave primaria técnica");
            entity.Property(e => e.AuditCreationDate).HasComment("Audit - Creation Date#Registry creation date");
            entity.Property(e => e.AuditCreationUser).HasComment("Audit - Creation User#Registry creation user");
            entity.Property(e => e.AuditDeletionDate).HasComment("Audit - Deletion Date#Logic registry deletion date");
            entity.Property(e => e.AuditModificationDate).HasComment("Audit - Modification Date#Last registry modification date");
            entity.Property(e => e.AuditModificationUser).HasComment("Audit - Modification User#Registry modification User");
        });
    }

    private void ConfigureUserCache(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<UserCache>(entity =>
        {
            entity.Property(e => e.Id).HasComment("Clave primaria técnica requerida por Helix6 (IEntityBase)");
            entity.Property(e => e.AuditCreationDate).HasComment("Audit - Creation Date#Registry creation date");
            entity.Property(e => e.AuditCreationUser).HasComment("Audit - Creation User#Registry creation user");
            entity.Property(e => e.AuditDeletionDate).HasComment("Audit - Deletion Date#Logic registry deletion date");
            entity.Property(e => e.AuditModificationDate).HasComment("Audit - Modification Date#Last registry modification date");
            entity.Property(e => e.AuditModificationUser).HasComment("Audit - Modification User#Registry modification User");
        });
    }

    private void ConfigureViews(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<VTA_ActiveOrganizations>(entity =>
        {
            entity.HasNoKey();
            entity.ToView("vw_ActiveOrganizations", "infoportone");
        });

        modelBuilder.Entity<VTA_ActiveApplications>(entity =>
        {
            entity.HasNoKey();
            entity.ToView("vw_ActiveApplications", "infoportone");
        });

        modelBuilder.Entity<VTA_ApplicationSecurityCredentials>(entity =>
        {
            entity.HasNoKey();
            entity.ToView("vw_ApplicationSecurityCredentials", "infoportone");
        });

        modelBuilder.Entity<VTA_ActiveApplicationModules>(entity =>
        {
            entity.HasNoKey();
            entity.ToView("vw_ActiveApplicationModules", "infoportone");
        });

        modelBuilder.Entity<VTA_OrganizationModuleAccess>(entity =>
        {
            entity.HasNoKey();
            entity.ToView("vw_OrganizationModuleAccess", "infoportone");
        });
    }
}
