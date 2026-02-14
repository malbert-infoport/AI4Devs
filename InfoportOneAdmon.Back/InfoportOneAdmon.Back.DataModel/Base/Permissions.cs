using Helix6.Base.Domain.BaseInterfaces;
using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
//using Microsoft.EntityFrameworkCore;

namespace InfoportOneAdmon.Back.DataModel.Base
{

    //[Keyless]
    [Table("Permissions", Schema = "Helix6_Security")]
    public partial class Permissions : IEntityBase
    {
        public int Id { get; set; }

        public int SecurityAccessOptionId { get; set; }

        [StringLength(200)]
        //[Unicode(false)]
        public string SecurityAccessOption { get; set; }

        [StringLength(200)]
        //[Unicode(false)]
        public string Controller { get; set; }

        public int? SecurityLevel { get; set; }

        [StringLength(200)]
        //[Unicode(false)]
        public string Profile { get; set; }

        [StringLength(100)]
        //[Unicode(false)]
        public string Rol { get; set; }

        [StringLength(200)]
        //[Unicode(false)]
        public string Module { get; set; }

        public int? SecurityCompanyId { get; set; }

        [StringLength(200)]
        //[Unicode(false)]
        public string SecurityCompany { get; set; }

        [StringLength(70)]
        //[Unicode(false)]
        public string AuditCreationUser { get; set; }

        [StringLength(70)]
        //[Unicode(false)]
        public string AuditModificationUser { get; set; }

        [Column(TypeName = "datetime")]
        public DateTime? AuditCreationDate { get; set; }

        [Column(TypeName = "datetime")]
        public DateTime? AuditModificationDate { get; set; }

        [Column(TypeName = "datetime")]
        public DateTime? AuditDeletionDate { get; set; }
    }
}
