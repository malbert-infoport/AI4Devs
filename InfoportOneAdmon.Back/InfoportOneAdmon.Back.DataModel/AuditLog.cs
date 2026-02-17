using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Helix6.Base.Domain.BaseInterfaces;
// using Microsoft.EntityFrameworkCore;

namespace InfoportOneAdmon.Back.DataModel {

/// <summary>
/// Auditoría selectiva de acciones críticas en seguridad y permisos (complementa auditoría automática Helix6)
/// </summary>
[Table("AuditLog", Schema = "Admon")]
// [Index("AuditDeletionDate", Name = "idx_auditlog_auditdeletiondate")]
// [Index("EntityType", "EntityId", Name = "idx_auditlog_entitytype_entityid")]
// [Index("Timestamp", Name = "idx_auditlog_timestamp", AllDescending = true)]
// [Index("UserId", Name = "idx_auditlog_userid")]
public partial class AuditLog : IEntityBase
{
    [Key]
    public int Id { get; set; }

    /// <summary>
    /// Acción auditada: ModuleAssigned, ModuleRemoved, OrganizationDeactivatedManual, OrganizationAutoDeactivated, OrganizationReactivatedManual, GroupChanged
    /// </summary>
    [Column(TypeName = "citext")]
    public string Action { get; set; }

    /// <summary>
    /// Tipo de entidad afectada: Organization, ApplicationModule, OrganizationApplicationModule
    /// </summary>
    [Column(TypeName = "citext")]
    public string EntityType { get; set; }

    /// <summary>
    /// ID de la entidad afectada
    /// </summary>
    public int EntityId { get; set; }

    /// <summary>
    /// ID del usuario que ejecutó la acción (NULL si fue acción automática del sistema)
    /// </summary>
    public int? UserId { get; set; }

    [Column(TypeName = "timestamp without time zone")]
    public DateTime Timestamp { get; set; }

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
