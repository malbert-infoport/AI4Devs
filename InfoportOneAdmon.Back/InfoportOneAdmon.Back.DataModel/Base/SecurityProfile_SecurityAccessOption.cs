using Helix6.Base.Domain.BaseInterfaces;
using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
//using Microsoft.EntityFrameworkCore;

namespace InfoportOneAdmon.Back.DataModel.Base
{

    /// <summary>
    /// Accesos#Permisos de acceso para un determinado perfil de seguridad y las distintas opciones de acceso##Seguridad
    /// </summary>
    [Table("SecurityProfile_SecurityAccessOption", Schema = "Helix6_Security")]
    //[Index("SecurityAccessOptionId", "SecurityProfileId", Name = "UK_SecurityProfile_SecurityAccessOption", IsUnique = true)]
    public partial class SecurityProfile_SecurityAccessOption : IEntityBase
    {
        /// <summary>
        /// ID#Table identifier
        /// </summary>
        [Key]
        public int Id { get; set; }

        /// <summary>
        /// Perfil#Perfil con permiso de acceso a la opción de acceso indicada
        /// </summary>
        public int SecurityProfileId { get; set; }

        /// <summary>
        /// Opción de Acceso#Opción de acceso accesible para el perfil indicado
        /// </summary>
        public int SecurityAccessOptionId { get; set; }

        /// <summary>
        /// Audit - Creation User#Registry creation user
        /// </summary>
        [StringLength(70)]
        //[Unicode(false)]
        public string AuditCreationUser { get; set; }

        /// <summary>
        /// Audit - Modification User#Registry modification User
        /// </summary>
        [StringLength(70)]
        //[Unicode(false)]
        public string AuditModificationUser { get; set; }

        /// <summary>
        /// Audit - Creation Date#Registry creation date
        /// </summary>
        [Column(TypeName = "datetime")]
        public DateTime? AuditCreationDate { get; set; }

        /// <summary>
        /// Audit - Modification Date#Last registry modification date
        /// </summary>
        [Column(TypeName = "datetime")]
        public DateTime? AuditModificationDate { get; set; }

        /// <summary>
        /// Audit - Deletion Date#Logic registry deletion date
        /// </summary>
        [Column(TypeName = "datetime")]
        public DateTime? AuditDeletionDate { get; set; }

        [ForeignKey("SecurityAccessOptionId")]
        [InverseProperty("SecurityProfile_SecurityAccessOption")]
        public virtual SecurityAccessOption SecurityAccessOption { get; set; }

        [ForeignKey("SecurityProfileId")]
        [InverseProperty("SecurityProfile_SecurityAccessOption")]
        public virtual SecurityProfile SecurityProfile { get; set; }
    }
}
