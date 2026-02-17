using InfoportOneAdmon.Back.DataModel.Base;
using Microsoft.EntityFrameworkCore;

namespace InfoportOneAdmon.Back.Data.DataModel;

public partial class EntityModel : DbContext
{
    public virtual DbSet<VTA_Attachment> VTA_Attachment { get; set; }
    public virtual DbSet<Attachment> Attachment { get; set; }

    public virtual DbSet<AttachmentFile> AttachmentFile { get; set; }

    public virtual DbSet<AttachmentType> AttachmentType { get; set; }

    public virtual DbSet<Permissions> Permissions { get; set; }

    public virtual DbSet<SecurityAccessOption> SecurityAccessOption { get; set; }

    public virtual DbSet<SecurityAccessOptionLevel> SecurityAccessOptionLevel { get; set; }

    public virtual DbSet<SecurityCompany> SecurityCompany { get; set; }

    public virtual DbSet<SecurityCompanyConfiguration> SecurityCompanyConfiguration { get; set; }

    public virtual DbSet<SecurityCompanyGroup> SecurityCompanyGroup { get; set; }

    public virtual DbSet<SecurityModule> SecurityModule { get; set; }

    public virtual DbSet<SecurityProfile> SecurityProfile { get; set; }

    public virtual DbSet<SecurityProfile_SecurityAccessOption> SecurityProfile_SecurityAccessOption { get; set; }

    public virtual DbSet<SecurityUser> SecurityUser { get; set; }

    public virtual DbSet<SecurityUserConfiguration> SecurityUserConfiguration { get; set; }

    public virtual DbSet<SecurityUserGridConfiguration> SecurityUserGridConfiguration { get; set; }

    public virtual DbSet<SecurityVersion> SecurityVersion { get; set; }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Attachment>(entity =>
        {
            entity.Property(e => e.Id).HasComment("ID#Table identifier");
            entity.Property(e => e.AuditCreationDate).HasComment("Audit - Creation Date#Registry creation date");
            entity.Property(e => e.AuditCreationUser).HasComment("Audit - Creation User#Registry creation user");
            entity.Property(e => e.AuditDeletionDate).HasComment("Audit - Deletion Date#Logic registry deletion date");
            entity.Property(e => e.AuditModificationDate).HasComment("Audit - Modification Date#Last registry modification date");
            entity.Property(e => e.AuditModificationUser).HasComment("Audit - Modification User#Registry modification User");

            entity.HasOne(d => d.AttachmentFile).WithMany(p => p.Attachment).HasConstraintName("FK_Attachment_AttachmentFile");

            entity.HasOne(d => d.AttachmentType).WithMany(p => p.Attachment).HasConstraintName("FK_Attachment_AttachmentType");
        });

        modelBuilder.Entity<AttachmentFile>(entity =>
        {
            entity.Property(e => e.Id).HasComment("ID#Table identifier");
            entity.Property(e => e.AuditCreationDate).HasComment("Audit - Creation Date#Registry creation date");
            entity.Property(e => e.AuditCreationUser).HasComment("Audit - Creation User#Registry creation user");
            entity.Property(e => e.AuditDeletionDate).HasComment("Audit - Deletion Date#Logic registry deletion date");
            entity.Property(e => e.AuditModificationDate).HasComment("Audit - Modification Date#Last registry modification date");
            entity.Property(e => e.AuditModificationUser).HasComment("Audit - Modification User#Registry modification User");
        });

        modelBuilder.Entity<AttachmentType>(entity =>
        {
            entity.Property(e => e.Id).HasComment("ID#Table identifier");
            entity.Property(e => e.AuditCreationDate).HasComment("Audit - Creation Date#Registry creation date");
            entity.Property(e => e.AuditCreationUser).HasComment("Audit - Creation User#Registry creation user");
            entity.Property(e => e.AuditDeletionDate).HasComment("Audit - Deletion Date#Logic registry deletion date");
            entity.Property(e => e.AuditModificationDate).HasComment("Audit - Modification Date#Last registry modification date");
            entity.Property(e => e.AuditModificationUser).HasComment("Audit - Modification User#Registry modification User");
        });

        modelBuilder.Entity<VTA_Attachment>(entity =>
        {
            entity.ToView("VTA_Attachment", "Helix6_Attachment");
        });

        modelBuilder.Entity<Permissions>(entity =>
        {
            entity.ToView("Permissions", "Helix6_Security");
        });

        modelBuilder.Entity<SecurityAccessOption>(entity =>
        {
            entity.ToTable("SecurityAccessOption", "Helix6_Security", tb => tb.HasComment("Opciones de Acceso#Opciones de acceso que determinan todos los puntos controlados por la seguridad del sistema, sobre los cuales se pueden dotar permisos de acceso##Seguridad"));

            entity.Property(e => e.Id)
                .ValueGeneratedNever()
                .HasComment("ID#Table identifier");
            entity.Property(e => e.AuditCreationDate).HasComment("Audit - Creation Date#Registry creation date");
            entity.Property(e => e.AuditCreationUser).HasComment("Audit - Creation User#Registry creation user");
            entity.Property(e => e.AuditDeletionDate).HasComment("Audit - Deletion Date#Logic registry deletion date");
            entity.Property(e => e.AuditModificationDate).HasComment("Audit - Modification Date#Last registry modification date");
            entity.Property(e => e.AuditModificationUser).HasComment("Audit - Modification User#Registry modification User");
            entity.Property(e => e.Description).HasComment("Descripción#Descripcíon de la opción de acceso");
            entity.Property(e => e.SecurityModuleId).HasComment("Módulo#Módulo al que pertenece la opción de acceso");

            entity.HasOne(d => d.SecurityModule).WithMany(p => p.SecurityAccessOption)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_SecurityAccessOption_SecurityModule");
        });

        modelBuilder.Entity<SecurityAccessOptionLevel>(entity =>
        {
            entity.Property(e => e.Id)
                .ValueGeneratedNever()
                .HasComment("ID#Table identifier");
            entity.Property(e => e.AuditCreationDate).HasComment("Audit - Creation Date#Registry creation date");
            entity.Property(e => e.AuditCreationUser).HasComment("Audit - Creation User#Registry creation user");
            entity.Property(e => e.AuditDeletionDate).HasComment("Audit - Deletion Date#Logic registry deletion date");
            entity.Property(e => e.AuditModificationDate).HasComment("Audit - Modification Date#Last registry modification date");
            entity.Property(e => e.AuditModificationUser).HasComment("Audit - Modification User#Registry modification User");

            entity.HasOne(d => d.SecurityAccessOption).WithMany(p => p.SecurityAccessOptionLevel)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_SecurityAccessOptionLevel_SecurityAccessOption");
        });

        modelBuilder.Entity<SecurityCompany>(entity =>
        {
            entity.ToTable("SecurityCompany", "Helix6_Security", tb => tb.HasComment("Empresas Seguridad#En un entorno multiempresa esta tabla contiene la lista de empresas configuradas que podrán trabajar con la aplicación##Seguridad"));

            entity.Property(e => e.Id)
                .ValueGeneratedNever()
                .HasComment("ID#Table identifier");
            entity.Property(e => e.AuditCreationDate).HasComment("Audit - Creation Date#Registry creation date");
            entity.Property(e => e.AuditCreationUser).HasComment("Audit - Creation User#Registry creation user");
            entity.Property(e => e.AuditDeletionDate).HasComment("Audit - Deletion Date#Logic registry deletion date");
            entity.Property(e => e.AuditModificationDate).HasComment("Audit - Modification Date#Last registry modification date");
            entity.Property(e => e.AuditModificationUser).HasComment("Audit - Modification User#Registry modification User");
            entity.Property(e => e.Cif).HasComment("Cif#Cif de la empresa de seguridad");
            entity.Property(e => e.Name).HasComment("Nombre#Nombre de la empresa de seguridad");
            entity.Property(e => e.SecurityCompanyConfigurationId).HasComment("Configuración#Configuración general de la aplicación asociada a la empresa de seguridad que para cada aplicación tiene unos campos distintos");

            entity.HasOne(d => d.SecurityCompanyConfiguration).WithMany(p => p.SecurityCompany).HasConstraintName("FK_SecurityCompany_SecurityCompanyConfiguration");

            entity.HasOne(d => d.SecurityCompanyGroup).WithMany(p => p.SecurityCompany)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_SecurityCompany_SecurityCompanyGroup");
        });

        modelBuilder.Entity<SecurityCompanyConfiguration>(entity =>
        {
            entity.ToTable("SecurityCompanyConfiguration", "Helix6_Security", tb => tb.HasComment("Empresas Seguridad#En un entorno multiempresa esta tabla contiene la lista de empresas configuradas que podrán trabajar con la aplicación##Seguridad"));

            entity.Property(e => e.Id)
                .ValueGeneratedNever()
                .HasComment("ID#Table identifier");
            entity.Property(e => e.AuditCreationDate).HasComment("Audit - Creation Date#Registry creation date");
            entity.Property(e => e.AuditCreationUser).HasComment("Audit - Creation User#Registry creation user");
            entity.Property(e => e.AuditDeletionDate).HasComment("Audit - Deletion Date#Logic registry deletion date");
            entity.Property(e => e.AuditModificationDate).HasComment("Audit - Modification Date#Last registry modification date");
            entity.Property(e => e.AuditModificationUser).HasComment("Audit - Modification User#Registry modification User");
        });

        modelBuilder.Entity<SecurityCompanyGroup>(entity =>
        {
            entity.ToTable("SecurityCompanyGroup", "Helix6_Security", tb => tb.HasComment("Empresas Seguridad#En un entorno multiempresa esta tabla contiene la lista de empresas configuradas que podrán trabajar con la aplicación##Seguridad"));

            entity.Property(e => e.Id)
                .ValueGeneratedNever()
                .HasComment("ID#Table identifier");
            entity.Property(e => e.AuditCreationDate).HasComment("Audit - Creation Date#Registry creation date");
            entity.Property(e => e.AuditCreationUser).HasComment("Audit - Creation User#Registry creation user");
            entity.Property(e => e.AuditDeletionDate).HasComment("Audit - Deletion Date#Logic registry deletion date");
            entity.Property(e => e.AuditModificationDate).HasComment("Audit - Modification Date#Last registry modification date");
            entity.Property(e => e.AuditModificationUser).HasComment("Audit - Modification User#Registry modification User");
            entity.Property(e => e.Name).HasComment("Nombre#Nombre de la empresa de seguridad");
        });

        modelBuilder.Entity<SecurityModule>(entity =>
        {
            entity.ToTable("SecurityModule", "Helix6_Security", tb => tb.HasComment("Modulos#Módulos que engloban las funcionalidades de más alto nivel del sistema##Seguridad"));

            entity.Property(e => e.Id)
                .ValueGeneratedNever()
                .HasComment("ID#Table identifier");
            entity.Property(e => e.AuditCreationDate).HasComment("Audit - Creation Date#Registry creation date");
            entity.Property(e => e.AuditCreationUser).HasComment("Audit - Creation User#Registry creation user");
            entity.Property(e => e.AuditDeletionDate).HasComment("Audit - Deletion Date#Logic registry deletion date");
            entity.Property(e => e.AuditModificationDate).HasComment("Audit - Modification Date#Last registry modification date");
            entity.Property(e => e.AuditModificationUser).HasComment("Audit - Modification User#Registry modification User");
            entity.Property(e => e.Description).HasComment("Descripción#Descripción del módulo contenedor de opciones de acceso.");
        });

        modelBuilder.Entity<SecurityProfile>(entity =>
        {
            entity.ToTable("SecurityProfile", "Helix6_Security", tb => tb.HasComment("Perfiles de Seguridad#Perfiles a los que pertenecen los usuarios del sistema y que condiciona los permisos de los mismos##Seguridad"));

            entity.Property(e => e.Id).HasComment("ID#Table identifier");
            entity.Property(e => e.AuditCreationDate).HasComment("Audit - Creation Date#Registry creation date");
            entity.Property(e => e.AuditCreationUser).HasComment("Audit - Creation User#Registry creation user");
            entity.Property(e => e.AuditDeletionDate).HasComment("Audit - Deletion Date#Logic registry deletion date");
            entity.Property(e => e.AuditModificationDate).HasComment("Audit - Modification Date#Last registry modification date");
            entity.Property(e => e.AuditModificationUser).HasComment("Audit - Modification User#Registry modification User");
            entity.Property(e => e.Description).HasComment("Descripción#Descripción del perfil");
            entity.Property(e => e.SecurityCompanyId).HasComment("Empresa Seguridad#Empresa del entorno multiempresa de la aplicación a la que pertenece esta entidad.");

            entity.HasOne(d => d.SecurityCompany).WithMany(p => p.SecurityProfile)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_SecurityProfile_SecurityCompany");
        });

        modelBuilder.Entity<SecurityProfile_SecurityAccessOption>(entity =>
        {
            entity.ToTable("SecurityProfile_SecurityAccessOption", "Helix6_Security", tb => tb.HasComment("Accesos#Permisos de acceso para un determinado perfil de seguridad y las distintas opciones de acceso##Seguridad"));

            entity.Property(e => e.Id).HasComment("ID#Table identifier");
            entity.Property(e => e.AuditCreationDate).HasComment("Audit - Creation Date#Registry creation date");
            entity.Property(e => e.AuditCreationUser).HasComment("Audit - Creation User#Registry creation user");
            entity.Property(e => e.AuditDeletionDate).HasComment("Audit - Deletion Date#Logic registry deletion date");
            entity.Property(e => e.AuditModificationDate).HasComment("Audit - Modification Date#Last registry modification date");
            entity.Property(e => e.AuditModificationUser).HasComment("Audit - Modification User#Registry modification User");
            entity.Property(e => e.SecurityAccessOptionId).HasComment("Opción de Acceso#Opción de acceso accesible para el perfil indicado");
            entity.Property(e => e.SecurityProfileId).HasComment("Perfil#Perfil con permiso de acceso a la opción de acceso indicada");

            entity.HasOne(d => d.SecurityAccessOption).WithMany(p => p.SecurityProfile_SecurityAccessOption)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_SecurityProfile_SecurityAccessOption_SecurityAccessOption");

            entity.HasOne(d => d.SecurityProfile).WithMany(p => p.SecurityProfile_SecurityAccessOption)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_SecurityProfile_SecurityAccessOption_SecurityProfile");
        });

        modelBuilder.Entity<SecurityUser>(entity =>
        {
            entity.ToTable("SecurityUser", "Helix6_Security", tb => tb.HasComment("Usuarios#Usuarios pertenecientes a una empresa de seguridad##Seguridad"));

            entity.Property(e => e.Id).HasComment("ID#Table identifier");
            entity.Property(e => e.AuditCreationDate).HasComment("Audit - Creation Date#Registry creation date");
            entity.Property(e => e.AuditCreationUser).HasComment("Audit - Creation User#Registry creation user");
            entity.Property(e => e.AuditDeletionDate).HasComment("Audit - Deletion Date#Logic registry deletion date");
            entity.Property(e => e.AuditModificationDate).HasComment("Audit - Modification Date#Last registry modification date");
            entity.Property(e => e.AuditModificationUser).HasComment("Audit - Modification User#Registry modification User");
            entity.Property(e => e.DisplayName).HasComment("Nombre#Nombre del usuario");
            entity.Property(e => e.Login).HasComment("Login#Login de acceso del usuario");
            entity.Property(e => e.Mail).HasComment("Mail#Mail del usuario");
            entity.Property(e => e.Name).HasComment("Nombre#Nombre del usuario");
            entity.Property(e => e.OrganizationCif).HasComment("Nombre#Nombre del usuario");
            entity.Property(e => e.OrganizationCode).HasComment("Nombre#Nombre del usuario");
            entity.Property(e => e.OrganizationName).HasComment("Nombre#Nombre del usuario");
            entity.Property(e => e.SecurityCompanyId).HasComment("Empresa Seguridad#Empresa del entorno multiempresa de la aplicación a la que pertenece esta entidad.");
            entity.Property(e => e.SecurityUserConfigurationId).HasComment("Configuración Usuario#Configuración específica del usuario logueado para esta aplicación ");
            entity.Property(e => e.UserIdentifier).HasComment("Identificado de Usuario#Identificador del usuario procedente del gestor de identidades ");

            entity.HasOne(d => d.SecurityCompany).WithMany(p => p.SecurityUser)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_SecurityUser_SecurityCompany");

            entity.HasOne(d => d.SecurityUserConfiguration).WithMany(p => p.SecurityUser).HasConstraintName("FK_SecurityUser_SecurityUserConfiguration");
        });

        modelBuilder.Entity<SecurityUserConfiguration>(entity =>
        {
            entity.ToTable("SecurityUserConfiguration", "Helix6_Security", tb => tb.HasComment("Personalización de Usuario#Parámetros de configuración asociados al usuario que determinan temas como la paginación o el idioma de la aplicación.##Seguridad"));

            entity.Property(e => e.Id).HasComment("ID#Table identifier");
            entity.Property(e => e.AuditCreationDate).HasComment("Audit - Creation Date#Registry creation date");
            entity.Property(e => e.AuditCreationUser).HasComment("Audit - Creation User#Registry creation user");
            entity.Property(e => e.AuditDeletionDate).HasComment("Audit - Deletion Date#Logic registry deletion date");
            entity.Property(e => e.AuditModificationDate).HasComment("Audit - Modification Date#Last registry modification date");
            entity.Property(e => e.AuditModificationUser).HasComment("Audit - Modification User#Registry modification User");
            entity.Property(e => e.LastConnectionDate).HasComment("Audit - Deletion Date#Logic registry deletion date");
            entity.Property(e => e.ModalPagination).HasComment("Paginación Modal#Registros por página que se podrán visualizar para este usuario en las ventanas emergentes con listas de registros");
            entity.Property(e => e.Pagination).HasComment("Paginación#Registros por página que se podrán visualizar para este usuario en las ventanas con listas de registros");
        });

        modelBuilder.Entity<SecurityUserGridConfiguration>(entity =>
        {
            entity.Property(e => e.Id).HasComment("ID#Table identifier");
            entity.Property(e => e.AuditCreationDate).HasComment("Audit - Creation Date#Registry creation date");
            entity.Property(e => e.AuditCreationUser).HasComment("Audit - Creation User#Registry creation user");
            entity.Property(e => e.AuditDeletionDate).HasComment("Audit - Deletion Date#Logic registry deletion date");
            entity.Property(e => e.AuditModificationDate).HasComment("Audit - Modification Date#Last registry modification date");
            entity.Property(e => e.AuditModificationUser).HasComment("Audit - Modification User#Registry modification User");

            entity.HasOne(d => d.SecurityUser).WithMany(p => p.SecurityUserGridConfiguration)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_SecurityUserGridConfiguration_SecurityUser");
        });

        modelBuilder.Entity<SecurityVersion>(entity =>
        {
            entity.Property(e => e.Id).HasComment("ID#Table identifier");
            entity.Property(e => e.AuditCreationDate).HasComment("Audit - Creation Date#Registry creation date");
            entity.Property(e => e.AuditCreationUser).HasComment("Audit - Creation User#Registry creation user");
            entity.Property(e => e.AuditDeletionDate).HasComment("Audit - Deletion Date#Logic registry deletion date");
            entity.Property(e => e.AuditModificationDate).HasComment("Audit - Modification Date#Last registry modification date");
            entity.Property(e => e.AuditModificationUser).HasComment("Audit - Modification User#Registry modification User");
            entity.Property(e => e.Version).IsFixedLength();
        });
    }

}
