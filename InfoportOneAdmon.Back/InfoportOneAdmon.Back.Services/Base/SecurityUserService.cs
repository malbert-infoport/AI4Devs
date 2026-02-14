using InfoportOneAdmon.Back.Data;
using InfoportOneAdmon.Back.Data.Repository.Base.Interfaces;
using InfoportOneAdmon.Back.DataModel.Base;
using InfoportOneAdmon.Back.Entities.Views.Base;
using InfoportOneAdmon.Back.Entities.Views.Base.Metadata;
using Helix6.Base.Application;
using Helix6.Base.Domain.Security;
using Helix6.Base.Service;

namespace InfoportOneAdmon.Back.Services.Base
{
    public class SecurityUserService : BaseService<SecurityUserView, SecurityUser, SecurityUserViewMetadata>
    {
        private readonly ISecurityUserRepository _repository;

        public SecurityUserService(IApplicationContext applicationContext, IUserContext userContext, ISecurityUserRepository repository) : base(applicationContext, userContext, repository)
        {
            _repository = repository;
        }

        /// <summary>
        /// Obtiene el SecurityUser en base al identificador de usuario devuelto por el Identity Manager.
        /// Si no existe lo crea en base al usuario del contexto del token recibido.
        /// Actualiza la fecha de última conexión del usuario.
        /// </summary>
        /// <returns></returns>
        public async Task<SecurityUserView> GetOrCreateSecurityUser()
        {
            DateTime? lastConnectionDate = null;
            var securityUserInRequest = GetSecurityUserViewFromUserContext(UserContext);
            var securityUser = await GetSecurityUser(DataConsts.LoadingConfigurations.SecurityUser.USER_WITH_CONFIGURATION);
            if (securityUser == null)
            {
                securityUser = securityUserInRequest;
                //Creamos un nuevo usuario con una configuración por defecto a partir del usuario de la request
                securityUser.SecurityUserConfiguration = GetDefaultSecurityUserConfiguration();
                await Insert(securityUser, DataConsts.LoadingConfigurations.SecurityUser.USER_WITH_CONFIGURATION);
            }
            else
            {
                //Si el usuario almacenado difiere del que se ha recibido con la request se actualiza. No se utiliza mapster para no machacar miniauditoria.
                if (!securityUserInRequest.Equals(securityUser))
                {
                    Copy(securityUserInRequest, securityUser);
                }
                lastConnectionDate = securityUser.SecurityUserConfiguration.LastConnectionDate;
                securityUser.SecurityUserConfiguration.LastConnectionDate = DateTime.UtcNow;
                await Update(securityUser, DataConsts.LoadingConfigurations.SecurityUser.USER_WITH_CONFIGURATION);
            }
            //Con el usaurio devolvemos la ultima fecha de conexión establecida, no la actualizada en este momento
            securityUser.SecurityUserConfiguration.LastConnectionDate = lastConnectionDate;
            return securityUser;
        }

        public async Task<SecurityUserView?> GetSecurityUser(string? configurationName = null)
        {
            return await MapEntityToView(await _repository.GetSecurityUserByUserIdentifier(configurationName), configurationName);
        }

        /// <summary>
        /// Obtiene el SecurityUser en base al identificador de usuario devuelto por el Identity Manager.
        /// </summary>
        /// <returns></returns>
        private static SecurityUserConfigurationView GetDefaultSecurityUserConfiguration()
        {
            return new SecurityUserConfigurationView
            {
                Pagination = 20,
                ModalPagination = 4,
                Language = "es-ES",
                LastConnectionDate = DateTime.UtcNow
            };
        }

        private static SecurityUserView GetSecurityUserViewFromUserContext(IUserContext userContext)
        {
            return new SecurityUserView
            {
                SecurityCompanyId = userContext.Applications[0].SecurityCompanyId,
                UserIdentifier = userContext.User.Id,
                Login = userContext.User.Login,
                Name = userContext.User.Name,
                DisplayName = userContext.User.DisplayName,
                Mail = userContext.User.Mail,
                OrganizationCif = userContext.User.OrganizationCif,
                OrganizationCode = userContext.User.OrganizationCode,
                OrganizationName = userContext.User.OrganizationName
            };
        }

        private static void Copy(SecurityUserView origin, SecurityUserView destination)
        {
            destination.SecurityCompanyId = origin.SecurityCompanyId;
            destination.UserIdentifier = origin.UserIdentifier;
            destination.Login = origin.Login;
            destination.Name = origin.Name;
            destination.DisplayName = origin.DisplayName;
            destination.Mail = origin.Mail;
            destination.OrganizationCif = origin.OrganizationCif;
            destination.OrganizationCode = origin.OrganizationCode;
            destination.OrganizationName = origin.OrganizationName;
        }
    }
}