using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace InfoportOneAdmon.Back.DataModel
{
    public partial class VTA_OrganizationModuleAccess
    {
        public int Id { get; set; }
        public int OrganizationId { get; set; }
        public int SecurityCompanyId { get; set; }
        
        [Column(TypeName = "citext")]
        public string OrganizationName { get; set; }
        
        public int ApplicationId { get; set; }
        public int AppBusinessId { get; set; }
        
        [Column(TypeName = "citext")]
        public string ApplicationName { get; set; }
        
        public int ApplicationModuleId { get; set; }
        
        [Column(TypeName = "citext")]
        public string ApplicationModuleName { get; set; }
        
        [Column(TypeName = "citext")]
        public string AuditCreationUser { get; set; }
        
        [Column(TypeName = "timestamp")]
        public DateTime? AccessGrantedDate { get; set; }
        
        [Column(TypeName = "citext")]
        public string AuditModificationUser { get; set; }
        
        [Column(TypeName = "timestamp")]
        public DateTime? AuditModificationDate { get; set; }
        
        [Column(TypeName = "timestamp")]
        public DateTime? AuditDeletionDate { get; set; }
    }
}
