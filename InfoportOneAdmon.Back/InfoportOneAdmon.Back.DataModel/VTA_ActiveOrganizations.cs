using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace InfoportOneAdmon.Back.DataModel
{
    public partial class VTA_ActiveOrganizations
    {
        public int Id { get; set; }
        public int SecurityCompanyId { get; set; }
        
        [Column(TypeName = "citext")]
        public string Name { get; set; }
        
        [Column(TypeName = "citext")]
        public string Acronym { get; set; }
        
        [Column(TypeName = "citext")]
        public string TaxId { get; set; }
        
        [Column(TypeName = "citext")]
        public string Address { get; set; }
        
        [Column(TypeName = "citext")]
        public string City { get; set; }
        
        [Column(TypeName = "citext")]
        public string Country { get; set; }
        
        [Column(TypeName = "citext")]
        public string ContactEmail { get; set; }
        
        [Column(TypeName = "citext")]
        public string ContactPhone { get; set; }
        
        public int? GroupId { get; set; }
        
        [Column(TypeName = "citext")]
        public string AuditCreationUser { get; set; }
        
        [Column(TypeName = "timestamp")]
        public DateTime? AuditCreationDate { get; set; }
        
        [Column(TypeName = "citext")]
        public string AuditModificationUser { get; set; }
        
        [Column(TypeName = "timestamp")]
        public DateTime? AuditModificationDate { get; set; }
        
        [Column(TypeName = "timestamp")]
        public DateTime? AuditDeletionDate { get; set; }
    }
}
