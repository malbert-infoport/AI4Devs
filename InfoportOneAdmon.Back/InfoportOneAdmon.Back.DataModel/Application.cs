using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Helix6.Base.Domain.BaseInterfaces;
// using Microsoft.EntityFrameworkCore;

namespace InfoportOneAdmon.Back.DataModel {

[Table("Application", Schema = "Admon")]
// [Index("AppName", Name = "UX_Application_AppName", IsUnique = true)]
// [Index("RolePrefix", Name = "UX_Application_RolePrefix", IsUnique = true)]
public partial class Application : IEntityBase
{
    [Key]
    public int Id { get; set; }

    [StringLength(100)]
    public string AppName { get; set; }

    [StringLength(500)]
    public string Description { get; set; }

    [StringLength(10)]
    public string RolePrefix { get; set; }

    [StringLength(255)]
    public string AuditCreationUser { get; set; }

    public DateTime? AuditCreationDate { get; set; }

    [StringLength(255)]
    public string AuditModificationUser { get; set; }

    public DateTime? AuditModificationDate { get; set; }

    public DateTime? AuditDeletionDate { get; set; }

    [InverseProperty("Application")]
    public virtual ICollection<ApplicationModule> ApplicationModule { get; } = new List<ApplicationModule>();
}}
