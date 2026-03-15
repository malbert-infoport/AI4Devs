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

    [Column(TypeName = "citext")]
    public string AppName { get; set; }

    [Column(TypeName = "citext")]
    public string Description { get; set; }

    [Column(TypeName = "citext")]
    public string RolePrefix { get; set; }

    [Column(TypeName = "citext")]
    public string AuditCreationUser { get; set; }

    public DateTime? AuditCreationDate { get; set; }

    [Column(TypeName = "citext")]
    public string AuditModificationUser { get; set; }

    public DateTime? AuditModificationDate { get; set; }

    public DateTime? AuditDeletionDate { get; set; }

    [InverseProperty("Application")]
    public virtual ICollection<ApplicationModule> ApplicationModule { get; set; } = new List<ApplicationModule>();
}}
