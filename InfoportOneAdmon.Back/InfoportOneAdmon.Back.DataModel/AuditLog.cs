using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Helix6.Base.Domain.BaseInterfaces;
// using Microsoft.EntityFrameworkCore;

namespace InfoportOneAdmon.Back.DataModel {

[Table("AuditLog", Schema = "Admon")]
public partial class AuditLog : IEntityBase
{
    [Key]
    public int Id { get; set; }

    [Column(TypeName = "citext")]
    public string EntityType { get; set; }

    [Column(TypeName = "citext")]
    public string EntityId { get; set; }

    [Column(TypeName = "citext")]
    public string Action { get; set; }

    [Column(TypeName = "citext")]
    public string UserLogin { get; set; }

    public DateTime Timestamp { get; set; }

    [Column(TypeName = "citext")]
    public string Content { get; set; }

    [Column(TypeName = "citext")]
    public string AuditCreationUser { get; set; }

    public DateTime? AuditCreationDate { get; set; }

    [Column(TypeName = "citext")]
    public string AuditModificationUser { get; set; }

    public DateTime? AuditModificationDate { get; set; }

    public DateTime? AuditDeletionDate { get; set; }
}}
