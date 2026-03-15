using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Helix6.Base.Domain.BaseInterfaces;
// using Microsoft.EntityFrameworkCore;

namespace InfoportOneAdmon.Back.DataModel {

[Table("OrganizationGroup", Schema = "Admon")]
// [Index("GroupName", Name = "UX_OrganizationGroup_GroupName", IsUnique = true)]
public partial class OrganizationGroup : IEntityBase
{
    [Key]
    public int Id { get; set; }

    [Column(TypeName = "citext")]
    public string GroupName { get; set; }

    [Column(TypeName = "citext")]
    public string Description { get; set; }

    [Column(TypeName = "citext")]
    public string AuditCreationUser { get; set; }

    public DateTime? AuditCreationDate { get; set; }

    [Column(TypeName = "citext")]
    public string AuditModificationUser { get; set; }

    public DateTime? AuditModificationDate { get; set; }

    public DateTime? AuditDeletionDate { get; set; }

    [InverseProperty("Group")]
    public virtual ICollection<Organization> Organization { get; set; } = new List<Organization>();
}}
