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

    [StringLength(200)]
    public string GroupName { get; set; }

    [StringLength(200)]
    public string Name { get; set; }

    [StringLength(50)]
    public string Acronym { get; set; }

    [StringLength(50)]
    public string TaxId { get; set; }

    [StringLength(300)]
    public string Address { get; set; }

    [StringLength(100)]
    public string City { get; set; }

    [StringLength(20)]
    public string PostalCode { get; set; }

    [StringLength(100)]
    public string Country { get; set; }

    [StringLength(255)]
    public string ContactEmail { get; set; }

    [StringLength(50)]
    public string ContactPhone { get; set; }

    [StringLength(255)]
    public string AuditCreationUser { get; set; }

    public DateTime? AuditCreationDate { get; set; }

    [StringLength(255)]
    public string AuditModificationUser { get; set; }

    public DateTime? AuditModificationDate { get; set; }

    public DateTime? AuditDeletionDate { get; set; }

    public int? ModuleCount { get; set; }

    public int? AppCount { get; set; }

    public string AppList { get; set; }
}}
