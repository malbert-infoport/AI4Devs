using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Helix6.Base.Domain.BaseInterfaces;
// using Microsoft.EntityFrameworkCore;

namespace InfoportOneAdmon.Back.DataModel {

/// <summary>
/// Módulos funcionales de aplicaciones. Permiten ventas granulares por funcionalidad
/// </summary>
[Table("ApplicationModule", Schema = "Admon")]
// [Index("ApplicationId", Name = "idx_applicationmodule_applicationid")]
// [Index("AuditDeletionDate", Name = "idx_applicationmodule_auditdeletiondate")]
// [Index("ApplicationId", "Name", Name = "uq_applicationmodule_application_name", IsUnique = true)]
public partial class ApplicationModule : IEntityBase
{
    [Key]
    public int Id { get; set; }

    public int ApplicationId { get; set; }

    /// <summary>
    /// Nombre del módulo siguiendo nomenclatura: M + Acronym + _ + nombre funcional
    /// </summary>
    [Column(TypeName = "citext")]
    public string Name { get; set; }

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
    /// Fecha de baja lógica del módulo
    /// </summary>
    [Column(TypeName = "timestamp without time zone")]
    public DateTime? AuditDeletionDate { get; set; }

    [ForeignKey("ApplicationId")]
    [InverseProperty("ApplicationModule")]
    public virtual Application Application { get; set; }

    [InverseProperty("ApplicationModule")]
    public virtual ICollection<OrganizationApplicationModule> OrganizationApplicationModule { get; } = new List<OrganizationApplicationModule>();
}}
