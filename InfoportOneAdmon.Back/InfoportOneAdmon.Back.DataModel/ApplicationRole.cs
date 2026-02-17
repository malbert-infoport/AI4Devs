using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Helix6.Base.Domain.BaseInterfaces;
// using Microsoft.EntityFrameworkCore;

namespace InfoportOneAdmon.Back.DataModel {

/// <summary>
/// Catálogo maestro de roles de cada aplicación. Garantiza coherencia en nomenclatura
/// </summary>
[Table("ApplicationRole", Schema = "Admon")]
// [Index("ApplicationId", Name = "idx_applicationrole_applicationid")]
// [Index("AuditDeletionDate", Name = "idx_applicationrole_auditdeletiondate")]
// [Index("ApplicationId", "Name", Name = "uq_applicationrole_application_name", IsUnique = true)]
public partial class ApplicationRole : IEntityBase
{
    [Key]
    public int Id { get; set; }

    public int ApplicationId { get; set; }

    /// <summary>
    /// Nombre del rol siguiendo nomenclatura: Acronym + _ + nombre funcional (ej: STP_Supervisor)
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
    /// Fecha de baja lógica. Roles dados de baja no se asignan a nuevos usuarios
    /// </summary>
    [Column(TypeName = "timestamp without time zone")]
    public DateTime? AuditDeletionDate { get; set; }

    [ForeignKey("ApplicationId")]
    [InverseProperty("ApplicationRole")]
    public virtual Application Application { get; set; }
}}
