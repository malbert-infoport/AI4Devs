using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Helix6.Base.Domain.BaseInterfaces;

namespace InfoportOneAdmon.Back.DataModel
{
    [Table("Application", Schema = "admon")]
    public partial class Application : IEntityBase
    {
        [Key]
        public int Id { get; set; }

        // Campo auto-generado (GENERATED ALWAYS AS IDENTITY)
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int ApplicationId { get; set; }

        [Required]
        [StringLength(200)]
        [Column(TypeName = "citext")]
        public string Name { get; set; } = string.Empty;

        [Required]
        [StringLength(10)]
        [Column(TypeName = "citext")]
        public string Acronym { get; set; } = string.Empty;

        [StringLength(1000)]
        [Column(TypeName = "citext")]
        public string Description { get; set; }

        // Relaciones inversas (sin ? en C# 7.3)
        [InverseProperty(nameof(ApplicationSecurity.Application))]
        public virtual ICollection<ApplicationSecurity> ApplicationSecurities { get; set; }

        [InverseProperty(nameof(ApplicationModule.Application))]
        public virtual ICollection<ApplicationModule> ApplicationModules { get; set; }

        [InverseProperty(nameof(ApplicationRole.Application))]
        public virtual ICollection<ApplicationRole> ApplicationRoles { get; set; }

        // Campos de auditoría Helix6 (OBLIGATORIOS en IEntityBase)
        [Required]
        [StringLength(255)]
        [Column(TypeName = "citext")]
        public string AuditCreationUser { get; set; } = string.Empty;

        [Column(TypeName = "timestamp")]
        public DateTime? AuditCreationDate { get; set; }

        [Required]
        [StringLength(255)]
        [Column(TypeName = "citext")]
        public string AuditModificationUser { get; set; } = string.Empty;

        [Column(TypeName = "timestamp")]
        public DateTime? AuditModificationDate { get; set; }

        [Column(TypeName = "timestamp")]
        public DateTime? AuditDeletionDate { get; set; }
    }
}
