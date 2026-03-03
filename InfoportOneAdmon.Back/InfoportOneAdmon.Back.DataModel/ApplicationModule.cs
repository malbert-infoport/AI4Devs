using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Helix6.Base.Domain.BaseInterfaces;
// using Microsoft.EntityFrameworkCore;

namespace InfoportOneAdmon.Back.DataModel {

[Table("ApplicationModule", Schema = "Admon")]
// [Index("ApplicationId", Name = "IX_ApplicationModule_ApplicationId")]
// [Index("ApplicationId", "ModuleName", Name = "UX_ApplicationModule_AppId_ModuleName", IsUnique = true)]
public partial class ApplicationModule : IEntityBase
{
    [Key]
    public int Id { get; set; }

    public int ApplicationId { get; set; }

    [StringLength(100)]
    public string ModuleName { get; set; }

    [StringLength(500)]
    public string Description { get; set; }

    public int? DisplayOrder { get; set; }

    [StringLength(255)]
    public string AuditCreationUser { get; set; }

    public DateTime? AuditCreationDate { get; set; }

    [StringLength(255)]
    public string AuditModificationUser { get; set; }

    public DateTime? AuditModificationDate { get; set; }

    public DateTime? AuditDeletionDate { get; set; }

    [ForeignKey("ApplicationId")]
    [InverseProperty("ApplicationModule")]
    public virtual Application Application { get; set; }

    [InverseProperty("ApplicationModule")]
    public virtual ICollection<Organization_ApplicationModule> Organization_ApplicationModule { get; } = new List<Organization_ApplicationModule>();
}}
