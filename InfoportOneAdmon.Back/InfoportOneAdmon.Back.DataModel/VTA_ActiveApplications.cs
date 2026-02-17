using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Helix6.Base.Domain.BaseInterfaces;
// using Microsoft.EntityFrameworkCore;

namespace InfoportOneAdmon.Back.DataModel {

// [Keyless]
public partial class VTA_ActiveApplications : IEntityBase
{
    public int Id { get; set; }

    public int? ApplicationId { get; set; }

    [Column(TypeName = "citext")]
    public string Name { get; set; }

    [Column(TypeName = "citext")]
    public string Acronym { get; set; }

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

    [Column(TypeName = "timestamp without time zone")]
    public DateTime? AuditDeletionDate { get; set; }
}}
