using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Helix6.Base.Domain.BaseInterfaces;
//using Microsoft.EntityFrameworkCore;

namespace InfoportOneAdmon.Back.DataModel {

[Table("Organization", Schema = "Admon")]
//[Index("GroupId", Name = "IX_Organization_GroupId")]
//[Index("Name", Name = "UX_Organization_Name", IsUnique = true)]
//[Index("SecurityCompanyId", Name = "UX_Organization_SecurityCompanyId", IsUnique = true)]
//[Index("TaxId", Name = "UX_Organization_TaxId", IsUnique = true)]
public partial class Organization : IEntityBase
{
    /// <summary>
    /// ID#Table identifier
    /// </summary>
    [Key]
    public int Id { get; set; }

    public int SecurityCompanyId { get; set; }

    public int? GroupId { get; set; }

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

    /// <summary>
    /// Audit - Creation User#Registry creation user
    /// </summary>
    [Column(TypeName = "citext")]
    public string AuditCreationUser { get; set; }

    /// <summary>
    /// Audit - Creation Date#Registry creation date
    /// </summary>
    public DateTime? AuditCreationDate { get; set; }

    /// <summary>
    /// Audit - Modification User#Registry modification User
    /// </summary>
    [Column(TypeName = "citext")]
    public string AuditModificationUser { get; set; }

    /// <summary>
    /// Audit - Modification Date#Last registry modification date
    /// </summary>
    public DateTime? AuditModificationDate { get; set; }

    /// <summary>
    /// Audit - Deletion Date#Logic registry deletion date
    /// </summary>
    public DateTime? AuditDeletionDate { get; set; }

    [ForeignKey("GroupId")]
    [InverseProperty("Organization")]
    public virtual OrganizationGroup Group { get; set; }

    [InverseProperty("Organization")]
    public virtual ICollection<Organization_ApplicationModule> Organization_ApplicationModule { get; set; } = new List<Organization_ApplicationModule>();
}}
