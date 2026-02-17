using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Helix6.Base.Domain.BaseInterfaces;
// using Microsoft.EntityFrameworkCore;

namespace InfoportOneAdmon.Back.DataModel {

/// <summary>
/// Credenciales OAuth2 para autenticación de aplicaciones en Keycloak. Soporta múltiples credenciales por aplicación
/// </summary>
[Table("ApplicationSecurity", Schema = "Admon")]
// [Index("ApplicationId", Name = "idx_appsecurity_applicationid")]
// [Index("AuditDeletionDate", Name = "idx_appsecurity_auditdeletiondate")]
// [Index("ClientId", Name = "uq_appsecurity_clientid", IsUnique = true)]
public partial class ApplicationSecurity : IEntityBase
{
    [Key]
    public int Id { get; set; }

    /// <summary>
    /// ID de la aplicación (FK a Application.Id)
    /// </summary>
    public int ApplicationId { get; set; }

    /// <summary>
    /// OAuth2 client_id único para autenticación en Keycloak
    /// </summary>
    [Column(TypeName = "citext")]
    public string ClientId { get; set; }

    /// <summary>
    /// OAuth2 client_secret. NULL para public clients (SPAs con PKCE), requerido para confidential clients
    /// </summary>
    [Column(TypeName = "citext")]
    public string ClientSecret { get; set; }

    /// <summary>
    /// Tipo de cliente OAuth2: Public (Angular SPAs) o Confidential (APIs backend)
    /// </summary>
    [Column(TypeName = "citext")]
    public string ClientType { get; set; }

    /// <summary>
    /// Tipo de credencial: CODE_PKCE (acceso web) o CLIENT_CREDENTIALS (APIs externas)
    /// </summary>
    [Column(TypeName = "citext")]
    public string CredentialType { get; set; }

    [Column(TypeName = "citext")]
    public string Description { get; set; }

    [Column(TypeName = "citext")]
    public string AuditCreationUser { get; set; }

    [Column(TypeName = "timestamp without time zone")]
    public DateTime? AuditCreationDate { get; set; }

    [Column(TypeName = "citext")]
    public string AuditModificationUser { get; set; }

    [Column(TypeName = "timestamp without time zone")]
    public DateTime? AuditModificationDate { get; set; }

    /// <summary>
    /// Fecha de baja lógica. Al establecerse, revoca la credencial en Keycloak
    /// </summary>
    [Column(TypeName = "timestamp without time zone")]
    public DateTime? AuditDeletionDate { get; set; }

    [ForeignKey("ApplicationId")]
    [InverseProperty("ApplicationSecurity")]
    public virtual Application Application { get; set; }
}}
