using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Helix6.Base.Domain.BaseInterfaces;

namespace InfoportOneAdmon.Back.DataModel
{
    [Table("OrganizationApplicationModule", Schema = "admon")]
    public partial class OrganizationApplicationModule : IEntityBase
    {
        [Key]
        public int Id { get; set; }
        
        // Foreign Key a Organization
        [ForeignKey(nameof(Organization))]
        public int OrganizationId { get; set; }
        
        // Foreign Key a ApplicationModule
        [ForeignKey(nameof(ApplicationModule))]
        public int ApplicationModuleId { get; set; }
        
        // Propiedades de navegación
        public virtual Organization Organization { get; set; }
        public virtual ApplicationModule ApplicationModule { get; set; }
        
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
