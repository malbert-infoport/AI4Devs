using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Helix6.Base.Domain.BaseInterfaces;
// using Microsoft.EntityFrameworkCore;

namespace InfoportOneAdmon.Back.DataModel {

/// <summary>
/// Control de eventos duplicados mediante hash SHA-256. Previene publicar eventos idénticos consecutivos
/// </summary>
[Table("EventHash", Schema = "Admon")]
// [Index("AuditDeletionDate", Name = "idx_eventhash_auditdeletiondate")]
// [Index("LastPublishedAt", Name = "idx_eventhash_lastpublishedat", AllDescending = true)]
// [Index("EntityType", "EntityId", Name = "uq_eventhash_entitytype_entityid", IsUnique = true)]
public partial class EventHash : IEntityBase
{
    [Key]
    public int Id { get; set; }

    /// <summary>
    /// Tipo de entidad: ORGANIZATION, APPLICATION, USER
    /// </summary>
    [Column(TypeName = "citext")]
    public string EntityType { get; set; }

    /// <summary>
    /// ID de la entidad
    /// </summary>
    public int EntityId { get; set; }

    /// <summary>
    /// Hash SHA-256 (64 caracteres) del Payload del último evento publicado
    /// </summary>
    [StringLength(64)]
    public string LastEventHash { get; set; }

    /// <summary>
    /// Timestamp de la última publicación exitosa
    /// </summary>
    [Column(TypeName = "timestamp without time zone")]
    public DateTime LastPublishedAt { get; set; }

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
