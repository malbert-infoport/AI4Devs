using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Helix6.Base.Domain.BaseInterfaces;

namespace InfoportOneAdmon.Back.DataModel
{
    [Table("AuditLog", Schema = "admon")]
    public partial class AuditLog : IEntityBase
    {
        [Key]
        public int Id { get; set; }
        
        [Required]
        [StringLength(100)]
        [Column(TypeName = "citext")]
        public string Action { get; set; } = string.Empty;
        
        [Required]
        [StringLength(100)]
        [Column(TypeName = "citext")]
        public string EntityType { get; set; } = string.Empty;
        
        public int EntityId { get; set; }
        
        public int? UserId { get; set; }
        
        [Column(TypeName = "timestamp")]
        public DateTime Timestamp { get; set; }
        
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
