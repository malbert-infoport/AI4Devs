using InfoportOneAdmon.Back.DataModel.Base;
using InfoportOneAdmon.Back.Entities.Views.Base;
using InfoportOneAdmon.Back.Entities.Views.Base.Metadata;
using Helix6.Base.Application;
using Helix6.Base.Domain.Parameters;
using Helix6.Base.Domain.Security;
using Helix6.Base.Repository;
using Helix6.Base.Service;

namespace InfoportOneAdmon.Back.Services.Base
{
    public class SecurityUserConfigurationService : BaseService<SecurityUserConfigurationView, SecurityUserConfiguration, SecurityUserConfigurationViewMetadata>
    {
        private readonly SecurityUserService _securityUserService;

        public SecurityUserConfigurationService(IApplicationContext applicationContext, IUserContext userContext, IBaseRepository<SecurityUserConfiguration> repository, SecurityUserService securityUserService) : base(applicationContext, userContext, repository)
        {
            _securityUserService = securityUserService;
        }

        /// <summary>
        /// Obtiene la configuración del usuario
        /// </summary>
        /// <returns></returns>
        public async Task<SecurityUserConfigurationView?> GetUserConfiguration()
        {
            var securityUser = await _securityUserService.GetSecurityUser();
            if (securityUser != null && securityUser.SecurityUserConfigurationId.HasValue)
                return await GetById(securityUser.SecurityUserConfigurationId.Value);
            return null;
        }

        /// <summary>
        /// Permite actualizar los datos de configuración del usuario
        /// </summary>
        /// <param name="view"></param>
        /// <param name="setParams"></param>
        /// <returns></returns>
        public override async Task<bool> Update(SecurityUserConfigurationView view, SetParamsService setParams)
        {
            if (view != null)
            {
                var userConfiguration = await GetById(view.Id, setParams.GetQueryParams());
                if (userConfiguration != null)
                {
                    userConfiguration.Pagination = view.Pagination;
                    userConfiguration.ModalPagination = view.ModalPagination;
                    userConfiguration.Language = view.Language;
                    view = userConfiguration;
                }
                return await base.Update(view, setParams);
            }
            return false;
        }
    }
}
