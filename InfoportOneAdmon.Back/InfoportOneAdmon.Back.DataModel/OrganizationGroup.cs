using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Helix6.Base.Domain.BaseInterfaces;
//using Microsoft.EntityFrameworkCore;

namespace InfoportOneAdmon.Back.DataModel {

[Table("OrganizationGroup", Schema = "Admon")]
//[Index("GroupName", Name = "UX_OrganizationGroup_GroupName", IsUnique = true)]
public partial class OrganizationGroup : IEntityBase
{
    /// <summary>
    /// ID#Table identifier
    /// </summary>
    [Key]
    public int Id { get; set; }

    [Column(TypeName = "citext")]
    public string GroupName { get; set; }

    [Column(TypeName = "citext")]
    public string Description { get; set; }

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

    [InverseProperty("Group")]
    public virtual ICollection<Organization> Organization { get; set; } = new List<Organization>();
}}
