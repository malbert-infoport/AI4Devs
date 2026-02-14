using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Helix6.Base.Domain.BaseInterfaces;

namespace InfoportOneAdmon.Back.DataModel
{
    [Table("ApplicationRole", Schema = "admon")]
    public partial class ApplicationRole : IEntityBase
    {
        [Key]
        public int Id { get; set; }

        // Foreign Key a Application
        [ForeignKey(nameof(Application))]
        public int ApplicationId { get; set; }

        [Required]
        [StringLength(200)]
        [Column(TypeName = "citext")]
        public string Name { get; set; } = string.Empty;

        [StringLength(1000)]
        [Column(TypeName = "citext")]
        public string Description { get; set; }

        // Propiedad de navegación
        public virtual Application Application { get; set; }

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
