using InfoportOneAdmon.Back.DataModel.Base;
using InfoportOneAdmon.Back.Entities.Views.Base;
using InfoportOneAdmon.Back.Entities.Views.Base.Metadata;
using InfoportOneAdmon.Back.Services.Base;
using Helix6.Base.Application;
using Helix6.Base.Domain;
using Helix6.Base.Domain.Endpoints;
using Helix6.Base.Domain.Security;
using Helix6.Base.Helpers;
using Helix6.Base.Security;
using Helix6.Base.Service;
using Microsoft.AspNetCore.Mvc;

namespace InfoportOneAdmon.Back.Api.Endpoints.Base
{
    public static class SecurityEndpoints
    {
        public static void MapSecurityEndpoints(this WebApplication app)
        {
            //Permisos del usuario
            app.MapGet("/api/Security/GetPermissions", async ([FromServices] IUserContext userContext, SecurityUserService securityUserService, PermissionsService permissionsService) =>
            {
                //Se deben obtener la configuración específica del usuario
                var securityUser = await securityUserService.GetOrCreateSecurityUser();
                userContext.User.UserConfiguration.RowsPerPage = securityUser.SecurityUserConfiguration.Pagination;
                userContext.User.UserConfiguration.ModalRowsPerPage = securityUser.SecurityUserConfiguration.ModalPagination;
                userContext.User.UserConfiguration.Language = securityUser.SecurityUserConfiguration.Language;
                userContext.User.UserConfiguration.LastConnectionDate = securityUser.SecurityUserConfiguration.LastConnectionDate.HasValue ? DateTime.SpecifyKind(securityUser.SecurityUserConfiguration.LastConnectionDate.Value, DateTimeKind.Utc) : null;

                //Cargamos las opciones de acceso a las que tiene acceso el usuario
                var authPermissions = await permissionsService.GetUserPermissions();
                userContext.Applications[0].Permissions = authPermissions.Permissions;

                //Si no se deben mandar las claims al front se clona el objeto y se anula la propiedad
                if (!userContext.SendClaimsToFront)
                {
                    var userContextCloned = (IUserContext)userContext.Clone();
                    userContextCloned.Claims = null;
                    return Results.Ok(userContextCloned);
                }
                return Results.Ok(userContext);
            }).Produces(StatusCodes.Status200OK, typeof(UserContext))
            .WithSummary("Obtiene los permisos para autorizar al usuario.")
            .WithOpenApi().RequireAuthorization()
            .WithTags("Security");

            //Limpieza de la cache de los reference token y de los permisos de usuario
            app.MapDelete("/api/Security/CleanCache", async ([FromServices] IUserPermissions userPermissions) =>
            {
                var validateAccess = await EndpointHelper.ValidateAccess<SecurityProfile>(new EndpointAccess(HelixEnums.SecurityLevel.Modify), userPermissions);
                if (!validateAccess) return Results.Forbid();

                ReferenceTokenAuthenticationHandler.CleanReferenceTokenCache();
                PermissionsService.CleanUserPermissionsCache();
                return Results.Ok();
            }).Produces(StatusCodes.Status200OK)
            .WithSummary("Elimina la cache de los ReferenceTokens activos y los permisos de usuario.")
            .WithOpenApi().RequireAuthorization()
            .WithTags("Security");

            #region SecurityProfile

            EndpointHelper.GenerateGetAllKendoFilterEndpoint<SecurityProfileService, SecurityProfileView, SecurityProfile, SecurityProfileViewMetadata>(app, "/api/SecurityProfile/GetAllKendoFilter", new EndpointAccess(HelixEnums.SecurityLevel.Read));
            EndpointHelper.GenerateGetByIdEndpoint<SecurityProfileService, SecurityProfileView, SecurityProfile, SecurityProfileViewMetadata>(app, "/api/SecurityProfile/GetById", new EndpointAccess(HelixEnums.SecurityLevel.Read));
            EndpointHelper.GenerateGetNewEntityEndpoint<SecurityProfileService, SecurityProfileView, SecurityProfile, SecurityProfileViewMetadata>(app, "/api/SecurityProfile/GetNewEntity", new EndpointAccess(HelixEnums.SecurityLevel.Modify));
            EndpointHelper.GenerateInsertEndpoint<SecurityProfileService, SecurityProfileView, SecurityProfile, SecurityProfileViewMetadata>(app, "/api/SecurityProfile/Insert", new EndpointAccess(HelixEnums.SecurityLevel.Modify));
            EndpointHelper.GenerateUpdateEndpoint<SecurityProfileService, SecurityProfileView, SecurityProfile, SecurityProfileViewMetadata>(app, "/api/SecurityProfile/Update", new EndpointAccess(HelixEnums.SecurityLevel.Modify));
            EndpointHelper.GenerateDeleteByIdEndpoint<SecurityProfileService, SecurityProfileView, SecurityProfile, SecurityProfileViewMetadata>(app, "/api/SecurityProfile/DeleteById", new EndpointAccess(HelixEnums.SecurityLevel.Modify));

            #endregion SecurityProfile

            #region SecurityUserConfiguration

            EndpointHelper.GenerateUpdateEndpoint<SecurityUserConfigurationService, SecurityUserConfigurationView, SecurityUserConfiguration, SecurityUserConfigurationViewMetadata>(app, "/api/SecurityUserConfiguration/Update", new EndpointAccess(HelixEnums.SecurityLevel.Modify));

            app.MapGet("/api/SecurityUserConfiguration/GetUserConfiguration", async ([FromServices] IUserPermissions userPermissions, SecurityUserConfigurationService securityUserConfigurationService) =>
            {
                var validateAccess = await EndpointHelper.ValidateAccess<SecurityUserConfiguration>(new EndpointAccess(HelixEnums.SecurityLevel.Read), userPermissions);
                if (!validateAccess) return Results.Forbid();

                var configuration = await securityUserConfigurationService.GetUserConfiguration();
                return Results.Ok(configuration);
            }).Produces(StatusCodes.Status200OK, typeof(SecurityUserConfigurationView))
           .WithSummary("Obtiene la configuración del usuario.")
           .WithOpenApi().RequireAuthorization()
           .WithTags("SecurityUserConfiguration");

            #endregion SecurityUserConfiguration

            #region SecurityUserGridConfiguration

            EndpointHelper.GenerateGetNewEntityEndpoint<SecurityUserGridConfigurationService, SecurityUserGridConfigurationView, SecurityUserGridConfiguration, SecurityUserGridConfigurationViewMetadata>(app, "/api/SecurityUserGridConfiguration/GetNewEntity", new EndpointAccess(HelixEnums.SecurityLevel.Modify));
            EndpointHelper.GenerateInsertEndpoint<SecurityUserGridConfigurationService, SecurityUserGridConfigurationView, SecurityUserGridConfiguration, SecurityUserGridConfigurationViewMetadata>(app, "/api/SecurityUserGridConfiguration/Insert", new EndpointAccess(HelixEnums.SecurityLevel.Modify));
            EndpointHelper.GenerateUpdateEndpoint<SecurityUserGridConfigurationService, SecurityUserGridConfigurationView, SecurityUserGridConfiguration, SecurityUserGridConfigurationViewMetadata>(app, "/api/SecurityUserGridConfiguration/Update", new EndpointAccess(HelixEnums.SecurityLevel.Modify));
            EndpointHelper.GenerateDeleteByIdEndpoint<SecurityUserGridConfigurationService, SecurityUserGridConfigurationView, SecurityUserGridConfiguration, SecurityUserGridConfigurationViewMetadata>(app, "/api/SecurityUserGridConfiguration/DeleteById", new EndpointAccess(HelixEnums.SecurityLevel.Modify));
            app.MapGet("/api/SecurityUserGridConfiguration/GetUserGridConfigurations", async ([FromServices] IUserPermissions userPermissions, SecurityUserGridConfigurationService securityUserGridConfigurationService, [FromQuery] string entityName) =>
            {
                var validateAccess = await EndpointHelper.ValidateAccess<SecurityUserGridConfiguration>(new EndpointAccess(HelixEnums.SecurityLevel.Read), userPermissions);
                if (!validateAccess) return Results.Forbid();

                var configurations = await securityUserGridConfigurationService.GetUserGridConfigurations(entityName);
                return Results.Ok(configurations);
            }).Produces(StatusCodes.Status200OK, typeof(List<SecurityUserGridConfigurationView>))
           .WithSummary("Obtiene la lista de configuraciones de grid para una entidad del usuario.")
           .WithOpenApi().RequireAuthorization()
           .WithTags("SecurityUserGridConfiguration");

            #endregion SecurityUserGridConfiguration

            #region SecurityCompany

            EndpointHelper.GenerateGetByIdEndpoint<IBaseService<SecurityCompanyView, SecurityCompany, SecurityCompanyViewMetadata>, SecurityCompanyView, SecurityCompany, SecurityCompanyViewMetadata>(app, "/api/SecurityCompany/GetById", new EndpointAccess(HelixEnums.SecurityLevel.Read));
            EndpointHelper.GenerateUpdateEndpoint<IBaseService<SecurityCompanyView, SecurityCompany, SecurityCompanyViewMetadata>, SecurityCompanyView, SecurityCompany, SecurityCompanyViewMetadata>(app, "/api/SecurityCompany/Update", new EndpointAccess(HelixEnums.SecurityLevel.Modify));

            #endregion SecurityCompany

            #region SecurityVersion

            EndpointHelper.GenerateGetAllEndpoint<IBaseService<SecurityVersionView, SecurityVersion, SecurityVersionViewMetadata>, SecurityVersionView, SecurityVersion, SecurityVersionViewMetadata>(app, "/api/SecurityVersion/GetAll", new EndpointAccess(HelixEnums.SecurityLevel.Read));

            #endregion SecurityVersion
        }
    }
}