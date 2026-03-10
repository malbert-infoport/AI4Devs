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

    public virtual DbSet<AuditLog> AuditLog { get; set; }

    public virtual DbSet<Organization> Organization { get; set; }

    public virtual DbSet<OrganizationGroup> OrganizationGroup { get; set; }

    public virtual DbSet<Organization_ApplicationModule> Organization_ApplicationModule { get; set; }

    public virtual DbSet<VTA_Organization> VTA_Organization { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasPostgresExtension("citext");

        modelBuilder.Entity<Application>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("Application_pkey");
        });

        modelBuilder.Entity<ApplicationModule>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("ApplicationModule_pkey");

            entity.Property(e => e.DisplayOrder).HasDefaultValue(0);

            entity.HasOne(d => d.Application).WithMany(p => p.ApplicationModule).HasConstraintName("FK_ApplicationModule_Application");
        });

        modelBuilder.Entity<AuditLog>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("AuditLog_pkey");

            entity.Property(e => e.Timestamp).HasDefaultValueSql("CURRENT_TIMESTAMP");
        });

        modelBuilder.Entity<Organization>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("Organization_pkey");

            entity.Property(e => e.SecurityCompanyId).ValueGeneratedOnAdd();

            entity.HasOne(d => d.Group).WithMany(p => p.Organization)
                .OnDelete(DeleteBehavior.SetNull)
                .HasConstraintName("FK_Organization_OrganizationGroup");
        });

        modelBuilder.Entity<OrganizationGroup>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("OrganizationGroup_pkey");
        });

        modelBuilder.Entity<Organization_ApplicationModule>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("Organization_ApplicationModule_pkey");

            entity.HasOne(d => d.ApplicationModule).WithMany(p => p.Organization_ApplicationModule).HasConstraintName("FK_OrgAppModule_ApplicationModule");

            entity.HasOne(d => d.Organization).WithMany(p => p.Organization_ApplicationModule).HasConstraintName("FK_OrgAppModule_Organization");
        });

        modelBuilder.Entity<VTA_Organization>(entity =>
        {
            entity.ToView("VTA_Organization", "Admon");
        });
        modelBuilder.HasSequence("Organization_SecurityCompanyId_seq", "Admon").StartsAt(1001L);

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
