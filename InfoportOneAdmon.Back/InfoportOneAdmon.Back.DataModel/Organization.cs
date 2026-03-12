using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Helix6.Base.Domain.BaseInterfaces;
// using Microsoft.EntityFrameworkCore;

namespace InfoportOneAdmon.Back.DataModel
{

    [Table("Organization", Schema = "Admon")]
    // [Index("GroupId", Name = "IX_Organization_GroupId")]
    // [Index("Name", Name = "UX_Organization_Name", IsUnique = true)]
    // [Index("SecurityCompanyId", Name = "UX_Organization_SecurityCompanyId", IsUnique = true)]
    // [Index("TaxId", Name = "UX_Organization_TaxId", IsUnique = true)]
    public partial class Organization : IEntityBase
    {
        [Key]
        public int Id { get; set; }

        public int SecurityCompanyId { get; set; }

        public int? GroupId { get; set; }

        [StringLength(200)]
        public string Name { get; set; }

        [StringLength(50)]
        public string Acronym { get; set; }

        [StringLength(50)]
        public string TaxId { get; set; }

        [StringLength(300)]
        public string Address { get; set; }

        [StringLength(100)]
        public string City { get; set; }

        [StringLength(20)]
        public string PostalCode { get; set; }

        [StringLength(100)]
        public string Country { get; set; }

        [StringLength(255)]
        public string ContactEmail { get; set; }

        [StringLength(50)]
        public string ContactPhone { get; set; }

        [StringLength(255)]
        public string AuditCreationUser { get; set; }

        public DateTime? AuditCreationDate { get; set; }

        [StringLength(255)]
        public string AuditModificationUser { get; set; }

        public DateTime? AuditModificationDate { get; set; }

        public DateTime? AuditDeletionDate { get; set; }

        [ForeignKey("GroupId")]
        [InverseProperty("Organization")]
        public virtual OrganizationGroup Group { get; set; }

        [InverseProperty("Organization")]
        public virtual ICollection<Organization_ApplicationModule> Organization_ApplicationModule { get; set; } = new List<Organization_ApplicationModule>();
    }
}
