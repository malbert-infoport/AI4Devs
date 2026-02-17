using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Helix6.Base.Domain.BaseInterfaces;
// using Microsoft.EntityFrameworkCore;

namespace InfoportOneAdmon.Back.DataModel {

/// <summary>
/// Caché de usuarios consolidados multi-organización. Optimiza procesamiento del Background Worker
/// </summary>
[Table("UserCache", Schema = "Admon")]
// [Index("AuditDeletionDate", Name = "idx_usercache_auditdeletiondate")]
// [Index("LastUpdated", Name = "idx_usercache_lastupdated", AllDescending = true)]
// [Index("Email", Name = "uq_usercache_email", IsUnique = true)]
public partial class UserCache : IEntityBase
{
    /// <summary>
    /// Clave primaria técnica requerida por Helix6 (IEntityBase)
    /// </summary>
    [Key]
    public int Id { get; set; }

    /// <summary>
    /// Email del usuario (único, case-insensitive)
    /// </summary>
    [Column(TypeName = "citext")]
    public string Email { get; set; }

    /// <summary>
    /// Array JSON con todos los SecurityCompanyId del usuario: [12345, 67890, 11111]
    /// </summary>
    public string ConsolidatedCompanyIds { get; set; }

    /// <summary>
    /// Array JSON con todos los roles consolidados del usuario de todas las apps: [&quot;CRM_Vendedor&quot;, &quot;ERP_Contable&quot;]
    /// </summary>
    public string ConsolidatedRoles { get; set; }

    /// <summary>
    /// Timestamp de la última consolidación
    /// </summary>
    [Column(TypeName = "timestamp without time zone")]
    public DateTime LastUpdated { get; set; }

    /// <summary>
    /// Hash SHA-256 del último evento procesado para este usuario
    /// </summary>
    [StringLength(64)]
    public string LastEventHash { get; set; }

    [Column(TypeName = "citext")]
    public string AuditCreationUser { get; set; }

    [Column(TypeName = "timestamp without time zone")]
    public DateTime? AuditCreationDate { get; set; }

    [Column(TypeName = "citext")]
    public string AuditModificationUser { get; set; }

    [Column(TypeName = "timestamp without time zone")]
    public DateTime? AuditModificationDate { get; set; }

    [Column(TypeName = "timestamp without time zone")]
    public DateTime? AuditDeletionDate { get; set; }
}}
