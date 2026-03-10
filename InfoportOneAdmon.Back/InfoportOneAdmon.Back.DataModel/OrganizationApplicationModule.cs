using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Helix6.Base.Domain.BaseInterfaces;
// // // // // using Microsoft.EntityFrameworkCore;

namespace InfoportOneAdmon.Back.DataModel {

/// <summary>
/// Permisos de acceso a mÃ³dulos por organizaciÃ³n. Habilita ventas granulares por funcionalidad
/// </summary>
[Table("OrganizationApplicationModule", Schema = "Admon")]
// // // // // [Index("ApplicationModuleId", Name = "idx_orgappmodule_ApplicationModuleId")]
// // // // // [Index("AuditDeletionDate", Name = "idx_orgappmodule_auditdeletiondate")]
// // // // // [Index("OrganizationId", Name = "idx_orgappmodule_organizationid")]
// // // // // [Index("OrganizationId", "ApplicationModuleId", Name = "uq_orgappmodule_org_module", IsUnique = true)]
public partial class OrganizationApplicationModule : IEntityBase
{
    [Key]
    public int Id { get; set; }

    /// <summary>
    /// ID de la organizaciÃ³n cliente (Organization.Id)
    /// </summary>
    public int OrganizationId { get; set; }

    /// <summary>
    /// ID del mÃ³dulo al que tiene acceso la organizaciÃ³n
    /// </summary>
    public int ApplicationModuleId { get; set; }

    [Column(TypeName = "citext")]
    public string AuditCreationUser { get; set; }

    [Column(TypeName = "timestamp without time zone")]
    public DateTime? AuditCreationDate { get; set; }

    [Column(TypeName = "citext")]
    public string AuditModificationUser { get; set; }

    [Column(TypeName = "timestamp without time zone")]
    public DateTime? AuditModificationDate { get; set; }

    /// <summary>
    /// Fecha de revocaciÃ³n de acceso al mÃ³dulo
    /// </summary>
    [Column(TypeName = "timestamp without time zone")]
    public DateTime? AuditDeletionDate { get; set; }

    [ForeignKey("ApplicationModuleId")]
    [InverseProperty("OrganizationApplicationModule")]
    public virtual ApplicationModule ApplicationModule { get; set; }

    [ForeignKey("OrganizationId")]
    [InverseProperty("OrganizationApplicationModule")]
    public virtual Organization Organization { get; set; }
}}

