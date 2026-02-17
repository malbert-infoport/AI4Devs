using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Helix6.Base.Domain.BaseInterfaces;
// using Microsoft.EntityFrameworkCore;

namespace InfoportOneAdmon.Back.DataModel {

/// <summary>
/// Organizaciones clientes del ecosistema. Fuente de verdad para multi-tenancy
/// </summary>
[Table("Organization", Schema = "Admon")]
// [Index("AuditDeletionDate", Name = "idx_organization_auditdeletiondate")]
// [Index("GroupId", Name = "idx_organization_groupid")]
// [Index("Name", Name = "idx_organization_name")]
// [Index("SecurityCompanyId", Name = "idx_organization_securitycompanyid")]
// [Index("Acronym", Name = "uq_organization_acronym", IsUnique = true)]
// [Index("SecurityCompanyId", Name = "uq_organization_securitycompanyid", IsUnique = true)]
// [Index("TaxId", Name = "uq_organization_taxid", IsUnique = true)]
public partial class Organization : IEntityBase
{
    /// <summary>
    /// Clave primaria técnica requerida por Helix6 (IEntityBase)
    /// </summary>
    [Key]
    public int Id { get; set; }

    /// <summary>
    /// Identificador único inmutable de la organización. Se propaga en claim c_ids de tokens JWT
    /// </summary>
    public int SecurityCompanyId { get; set; }

    [Column(TypeName = "citext")]
    public string Name { get; set; }

    /// <summary>
    /// Acrónimo único de la organización (máx. 10 caracteres) para identificación rápida
    /// </summary>
    [Column(TypeName = "citext")]
    public string Acronym { get; set; }

    /// <summary>
    /// Identificador fiscal de la organización (CIF/NIF)
    /// </summary>
    [Column(TypeName = "citext")]
    public string TaxId { get; set; }

    [Column(TypeName = "citext")]
    public string Address { get; set; }

    [Column(TypeName = "citext")]
    public string City { get; set; }

    [Column(TypeName = "citext")]
    public string Country { get; set; }

    [Column(TypeName = "citext")]
    public string ContactEmail { get; set; }

    [Column(TypeName = "citext")]
    public string ContactPhone { get; set; }

    /// <summary>
    /// ID del grupo al que pertenece (holding, consorcio). NULL si no pertenece a ningún grupo
    /// </summary>
    public int? GroupId { get; set; }

    [Column(TypeName = "citext")]
    public string AuditCreationUser { get; set; }

    [Column(TypeName = "timestamp without time zone")]
    public DateTime? AuditCreationDate { get; set; }

    [Column(TypeName = "citext")]
    public string AuditModificationUser { get; set; }

    [Column(TypeName = "timestamp without time zone")]
    public DateTime? AuditModificationDate { get; set; }

    /// <summary>
    /// Fecha de baja lógica. Al establecerse, bloquea acceso inmediato y propaga baja de usuarios a Keycloak
    /// </summary>
    [Column(TypeName = "timestamp without time zone")]
    public DateTime? AuditDeletionDate { get; set; }

    [ForeignKey("GroupId")]
    [InverseProperty("Organization")]
    public virtual OrganizationGroup Group { get; set; }

    [InverseProperty("Organization")]
    public virtual ICollection<OrganizationApplicationModule> OrganizationApplicationModule { get; } = new List<OrganizationApplicationModule>();
}}
