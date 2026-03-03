using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Helix6.Base.Domain.BaseInterfaces;
// using Microsoft.EntityFrameworkCore;

namespace InfoportOneAdmon.Back.DataModel {

[Table("AuditLog", Schema = "Admon")]
// [Index("EntityType", "EntityId", Name = "IX_AuditLog_EntityType_EntityId")]
// [Index("Timestamp", Name = "IX_AuditLog_Timestamp", AllDescending = true)]
// [Index("UserId", Name = "IX_AuditLog_UserId")]
public partial class AuditLog : IEntityBase
{
    [Key]
    public int Id { get; set; }

    [StringLength(50)]
    public string EntityType { get; set; }

    [StringLength(50)]
    public string EntityId { get; set; }

    [StringLength(100)]
    public string Action { get; set; }

    public int? UserId { get; set; }

    public DateTime Timestamp { get; set; }

    [StringLength(100)]
    public string CorrelationId { get; set; }

    [StringLength(255)]
    public string AuditCreationUser { get; set; }

    public DateTime? AuditCreationDate { get; set; }

    [StringLength(255)]
    public string AuditModificationUser { get; set; }

    public DateTime? AuditModificationDate { get; set; }

    public DateTime? AuditDeletionDate { get; set; }
}}
