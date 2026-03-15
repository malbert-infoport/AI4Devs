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

    [Column(TypeName = "citext")]
    public string ModuleName { get; set; }

    [Column(TypeName = "citext")]
    public string Description { get; set; }

    public int? DisplayOrder { get; set; }

    [Column(TypeName = "citext")]
    public string AuditCreationUser { get; set; }

    public DateTime? AuditCreationDate { get; set; }

    [Column(TypeName = "citext")]
    public string AuditModificationUser { get; set; }

    public DateTime? AuditModificationDate { get; set; }

    public DateTime? AuditDeletionDate { get; set; }

    [ForeignKey("ApplicationId")]
    [InverseProperty("ApplicationModule")]
    public virtual Application Application { get; set; }

    [InverseProperty("ApplicationModule")]
    public virtual ICollection<Organization_ApplicationModule> Organization_ApplicationModule { get; set; } = new List<Organization_ApplicationModule>();
}}
