using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace InfoportOneAdmon.Back.DataModel
{
    public partial class VTA_ApplicationSecurityCredentials
    {
        public int Id { get; set; }
        public int ApplicationId { get; set; }
        public int AppBusinessId { get; set; }
        
        [Column(TypeName = "citext")]
        public string ApplicationName { get; set; }
        
        [Column(TypeName = "citext")]
        public string ClientId { get; set; }
        
        [Column(TypeName = "citext")]
        public string ClientType { get; set; }
        
        [Column(TypeName = "citext")]
        public string CredentialType { get; set; }
        
        [Column(TypeName = "citext")]
        public string Description { get; set; }
        
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
