using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Helix6.Base.Domain.BaseInterfaces;
// using Microsoft.EntityFrameworkCore;

namespace InfoportOneAdmon.Back.DataModel {

[Table("Organization_ApplicationModule", Schema = "Admon")]
// [Index("OrganizationId", Name = "IX_OrgAppModule_OrganizationId")]
// [Index("ApplicationModuleId", "OrganizationId", Name = "UX_OrgAppModule_ModuleId_OrgId", IsUnique = true)]
public partial class Organization_ApplicationModule : IEntityBase
{
    [Key]
    public int Id { get; set; }

    public int ApplicationModuleId { get; set; }

    public int OrganizationId { get; set; }

    [StringLength(255)]
    public string AuditCreationUser { get; set; }

    public DateTime? AuditCreationDate { get; set; }

    [StringLength(255)]
    public string AuditModificationUser { get; set; }

    public DateTime? AuditModificationDate { get; set; }

    public DateTime? AuditDeletionDate { get; set; }

    [ForeignKey("ApplicationModuleId")]
    [InverseProperty("Organization_ApplicationModule")]
    public virtual ApplicationModule ApplicationModule { get; set; }

    [ForeignKey("OrganizationId")]
    [InverseProperty("Organization_ApplicationModule")]
    public virtual Organization Organization { get; set; }
}}
