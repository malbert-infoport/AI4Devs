using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Helix6.Base.Domain.BaseInterfaces;
// using Microsoft.EntityFrameworkCore;

namespace InfoportOneAdmon.Back.DataModel {

/// <summary>
/// Aplicaciones satélite del portfolio empresarial. Define el catálogo de aplicaciones disponibles
/// </summary>
[Table("Application", Schema = "Admon")]
// [Index("ApplicationId", Name = "idx_application_applicationid")]
// [Index("AuditDeletionDate", Name = "idx_application_auditdeletiondate")]
// [Index("Acronym", Name = "uq_application_acronym", IsUnique = true)]
// [Index("ApplicationId", Name = "uq_application_applicationid", IsUnique = true)]
// [Index("Name", Name = "uq_application_name", IsUnique = true)]
public partial class Application : IEntityBase
{
    /// <summary>
    /// Clave primaria técnica requerida por Helix6 (IEntityBase)
    /// </summary>
    [Key]
    public int Id { get; set; }

    /// <summary>
    /// Identificador único de negocio auto-generado inmutable
    /// </summary>
    public int ApplicationId { get; set; }

    [Column(TypeName = "citext")]
    public string Name { get; set; }

    /// <summary>
    /// Acrónimo único para nomenclatura de roles y módulos (ej: STP, CRM, ERP)
    /// </summary>
    [Column(TypeName = "citext")]
    public string Acronym { get; set; }

    [Column(TypeName = "citext")]
    public string Description { get; set; }

    [Column(TypeName = "citext")]
    public string AuditCreationUser { get; set; }

    [Column(TypeName = "timestamp without time zone")]
    public DateTime? AuditCreationDate { get; set; }

    [Column(TypeName = "citext")]
    public string AuditModificationUser { get; set; }

    [Column(TypeName = "timestamp without time zone")]
    public DateTime? AuditModificationDate { get; set; }

    /// <summary>
    /// Fecha de baja lógica. Al establecerse, revoca automáticamente todas sus credenciales en Keycloak
    /// </summary>
    [Column(TypeName = "timestamp without time zone")]
    public DateTime? AuditDeletionDate { get; set; }

    [InverseProperty("Application")]
    public virtual ICollection<ApplicationModule> ApplicationModule { get; } = new List<ApplicationModule>();

    [InverseProperty("Application")]
    public virtual ICollection<ApplicationRole> ApplicationRole { get; } = new List<ApplicationRole>();

    [InverseProperty("Application")]
    public virtual ICollection<ApplicationSecurity> ApplicationSecurity { get; } = new List<ApplicationSecurity>();
}}
