using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Helix6.Base.Domain.BaseInterfaces;

namespace InfoportOneAdmon.Back.DataModel
{
    [Table("OrganizationGroup", Schema = "admon")]
    public partial class OrganizationGroup : IEntityBase
    {
        [Key]
        public int Id { get; set; }
        
        [Required]
        [StringLength(200)]
        [Column(TypeName = "citext")]
        public string Name { get; set; } = string.Empty;
        
        // Relación inversa con Organization
        [InverseProperty(nameof(Organization.OrganizationGroup))]
        public virtual ICollection<Organization> Organizations { get; set; }
        
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
