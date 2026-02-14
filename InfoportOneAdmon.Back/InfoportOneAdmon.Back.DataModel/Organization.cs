using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Helix6.Base.Domain.BaseInterfaces;

namespace InfoportOneAdmon.Back.DataModel
{
    [Table("Organization", Schema = "admon")]
    public partial class Organization : IEntityBase
    {
        [Key]
        public int Id { get; set; }
        
        // Campo auto-generado (GENERATED ALWAYS AS IDENTITY)
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int SecurityCompanyId { get; set; }
        
        [Required]
        [StringLength(200)]
        [Column(TypeName = "citext")]
        public string Name { get; set; } = string.Empty;
        
        [Required]
        [StringLength(10)]
        [Column(TypeName = "citext")]
        public string Acronym { get; set; } = string.Empty;
        
        [StringLength(50)]
        [Column(TypeName = "citext")]
        public string TaxId { get; set; }
        
        [StringLength(500)]
        [Column(TypeName = "citext")]
        public string Address { get; set; }
        
        [StringLength(100)]
        [Column(TypeName = "citext")]
        public string City { get; set; }
        
        [StringLength(100)]
        [Column(TypeName = "citext")]
        public string Country { get; set; }
        
        [StringLength(255)]
        [Column(TypeName = "citext")]
        public string ContactEmail { get; set; }
        
        [StringLength(50)]
        [Column(TypeName = "citext")]
        public string ContactPhone { get; set; }
        
        // Foreign Key a OrganizationGroup (nullable)
        [ForeignKey(nameof(OrganizationGroup))]
        public int? GroupId { get; set; }
        
        // Propiedad de navegación
        public virtual OrganizationGroup OrganizationGroup { get; set; }
        
        // Relación inversa con OrganizationApplicationModule
        [InverseProperty(nameof(OrganizationApplicationModule.Organization))]
        public virtual ICollection<OrganizationApplicationModule> OrganizationApplicationModules { get; set; }
        
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
