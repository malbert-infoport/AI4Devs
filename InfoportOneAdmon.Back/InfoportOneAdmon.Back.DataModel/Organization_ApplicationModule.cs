using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Helix6.Base.Domain.BaseInterfaces;
//using Microsoft.EntityFrameworkCore;

namespace InfoportOneAdmon.Back.DataModel {

[Table("Organization_ApplicationModule", Schema = "Admon")]
//[Index("OrganizationId", Name = "IX_OrgAppModule_OrganizationId")]
//[Index("ApplicationModuleId", "OrganizationId", Name = "UX_OrgAppModule_ModuleId_OrgId", IsUnique = true)]
public partial class Organization_ApplicationModule : IEntityBase
{
    /// <summary>
    /// ID#Table identifier
    /// </summary>
    [Key]
    public int Id { get; set; }

    public int ApplicationModuleId { get; set; }

    public int OrganizationId { get; set; }

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

    [ForeignKey("ApplicationModuleId")]
    [InverseProperty("Organization_ApplicationModule")]
    public virtual ApplicationModule ApplicationModule { get; set; }

    [ForeignKey("OrganizationId")]
    [InverseProperty("Organization_ApplicationModule")]
    public virtual Organization Organization { get; set; }
}}
