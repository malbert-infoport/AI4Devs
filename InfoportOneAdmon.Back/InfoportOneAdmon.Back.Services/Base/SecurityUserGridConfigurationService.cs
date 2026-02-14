using InfoportOneAdmon.Back.Data.Repository.Base.Interfaces;
using InfoportOneAdmon.Back.DataModel.Base;
using InfoportOneAdmon.Back.Entities.Views.Base;
using InfoportOneAdmon.Back.Entities.Views.Base.Metadata;
using Helix6.Base.Application;
using Helix6.Base.Domain;
using Helix6.Base.Domain.Parameters;
using Helix6.Base.Domain.Security;
using Helix6.Base.Service;

namespace InfoportOneAdmon.Back.Services.Base
{
    public class SecurityUserGridConfigurationService : BaseService<SecurityUserGridConfigurationView, SecurityUserGridConfiguration, SecurityUserGridConfigurationViewMetadata>
    {
        private readonly ISecurityUserGridConfigurationRepository _repository;
        private readonly SecurityUserService _securityUserService;

        public SecurityUserGridConfigurationService(IApplicationContext applicationContext, IUserContext userContext, ISecurityUserGridConfigurationRepository repository, SecurityUserService securityUserService) : base(applicationContext, userContext, repository)
        {
            _repository = repository;
            _securityUserService = securityUserService;
        }

        /// <summary>
        /// Al crear una nueva entidad se actualiza la propiedad SecurityUserId
        /// </summary>
        /// <returns></returns>
        public override async Task<SecurityUserGridConfigurationView?> GetNewEntity()
        {
            var result = await base.GetNewEntity();
            if (result != null)
                result.SecurityUserId = await GetSecurityUserId();
            return result;
        }

        /// <summary>
        /// Obtiene la la lista de configuraciones de grid de un usuario por nombre de entidad gestionada en la grid
        /// </summary>
        /// <returns></returns>
        public async Task<List<SecurityUserGridConfigurationView>?> GetUserGridConfigurations(string entityName, int securityUserId = 0)
        {
            var result = new List<SecurityUserGridConfigurationView>();

            if (securityUserId == 0)
                securityUserId = await GetSecurityUserId();

            if (securityUserId != 0)
                result = await MapEntitiesToViews(await _repository.GetConfigurations(entityName, securityUserId));

            return result;
        }

        /// <summary>
        /// Si la configuración de grid recibida es la configuración por defecto si existe otra configuración por defecto se pone a false. Además se controla que se inserta o actualiza la configuración para el usuario que hace la llamada.
        /// </summary>
        /// <param name="view"></param>
        /// <param name="actionType"></param>
        /// <param name="configurationName"></param>
        /// <returns></returns>
        public override async Task PreviousActions(SecurityUserGridConfigurationView? view, HelixEnums.EnumActionType actionType, string? configurationName = null)
        {
            if (view != null)
            {
                if (actionType == HelixEnums.EnumActionType.Insert || actionType == HelixEnums.EnumActionType.Update)
                {
                    var user = await _securityUserService.GetSecurityUser();
                    if (user != null)
                    {
                        view.SecurityUserId = user.Id;
                        view.SecurityUser = user;
                    }

                    if (view.DefaultConfiguration)
                    {
                        var defaultConfiguration = await GetDefaultUserGridConfigurationByEntityName(view.Entity, view.SecurityUserId);
                        if (defaultConfiguration != null && defaultConfiguration.Id != view.Id)
                        {
                            var setParams = new SetParamsService
                            {
                                ExecutePreviousActions = false
                            };
                            defaultConfiguration.DefaultConfiguration = false;
                            await Update(defaultConfiguration, setParams);
                        }
                    }
                }
            }
        }
        /// <summary>
        /// Obtiene la la lista de configuraciones de grid de un usuario por nombre de entidad gestionada en la grid
        /// </summary>
        /// <returns></returns>
        private async Task<SecurityUserGridConfigurationView?> GetDefaultUserGridConfigurationByEntityName(string entityName, int securityUserId = 0)
        {
            if (securityUserId == 0)
                securityUserId = await GetSecurityUserId();

            if (securityUserId != 0)
                return await MapEntityToView(await _repository.GetDefaultUserGridConfiguration(entityName, securityUserId));

            return null;
        }

        private async Task<int> GetSecurityUserId()
        {
            var securityUser = await _securityUserService.GetSecurityUser();
            if (securityUser != null)
            {
                return securityUser.Id;
            }
            return 0;
        }
    }
}