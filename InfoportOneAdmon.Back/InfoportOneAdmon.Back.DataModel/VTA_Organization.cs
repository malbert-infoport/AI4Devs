using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Helix6.Base.Domain.BaseInterfaces;
// using Microsoft.EntityFrameworkCore;

namespace InfoportOneAdmon.Back.DataModel {

// [Keyless]
[Table("VTA_Organization", Schema = "Admon")]
public partial class VTA_Organization : IEntityBase
{
    public int Id { get; set; }

    public int? SecurityCompanyId { get; set; }

    [Column(TypeName = "citext")]
    public string GroupName { get; set; }

    [Column(TypeName = "citext")]
    public string Name { get; set; }

    [Column(TypeName = "citext")]
    public string Acronym { get; set; }

    [Column(TypeName = "citext")]
    public string TaxId { get; set; }

    [Column(TypeName = "citext")]
    public string Address { get; set; }

    [Column(TypeName = "citext")]
    public string City { get; set; }

    [Column(TypeName = "citext")]
    public string PostalCode { get; set; }

    [Column(TypeName = "citext")]
    public string Country { get; set; }

    [Column(TypeName = "citext")]
    public string ContactEmail { get; set; }

    [Column(TypeName = "citext")]
    public string ContactPhone { get; set; }

    [Column(TypeName = "citext")]
    public string AuditCreationUser { get; set; }

    public DateTime? AuditCreationDate { get; set; }

    [Column(TypeName = "citext")]
    public string AuditModificationUser { get; set; }

    public DateTime? AuditModificationDate { get; set; }

    public DateTime? AuditDeletionDate { get; set; }

    public int? ModuleCount { get; set; }

    public int? AppCount { get; set; }

    public string AppList { get; set; }
}}
