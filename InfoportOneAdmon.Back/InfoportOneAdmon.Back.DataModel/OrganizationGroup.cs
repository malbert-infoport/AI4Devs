using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Helix6.Base.Domain.BaseInterfaces;
// using Microsoft.EntityFrameworkCore;

namespace InfoportOneAdmon.Back.DataModel {

/// <summary>
/// Agrupaciones lógicas de organizaciones para facilitar gestión colectiva (holdings, consorcios)
/// </summary>
[Table("OrganizationGroup", Schema = "Admon")]
// [Index("AuditDeletionDate", Name = "idx_organizationgroup_auditdeletiondate")]
// [Index("Name", Name = "uq_organizationgroup_name", IsUnique = true)]
public partial class OrganizationGroup : IEntityBase
{
    [Key]
    public int Id { get; set; }

    /// <summary>
    /// Nombre del grupo de organizaciones
    /// </summary>
    [Column(TypeName = "citext")]
    public string Name { get; set; }

    [Column(TypeName = "citext")]
    public string AuditCreationUser { get; set; }

    [Column(TypeName = "timestamp without time zone")]
    public DateTime? AuditCreationDate { get; set; }

    [Column(TypeName = "citext")]
    public string AuditModificationUser { get; set; }

    [Column(TypeName = "timestamp without time zone")]
    public DateTime? AuditModificationDate { get; set; }

    /// <summary>
    /// Fecha de baja lógica (soft delete). NULL = activo
    /// </summary>
    [Column(TypeName = "timestamp without time zone")]
    public DateTime? AuditDeletionDate { get; set; }

    [InverseProperty("Group")]
    public virtual ICollection<Organization> Organization { get; } = new List<Organization>();
}}
