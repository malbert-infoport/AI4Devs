using InfoportOneAdmon.Back.Data;
using InfoportOneAdmon.Back.DataModel.Base;
using InfoportOneAdmon.Back.Entities.View.Base;
using InfoportOneAdmon.Back.Entities.Views.Base;
using InfoportOneAdmon.Back.Entities.Views.Base.Metadata;
using Helix6.Base.Application;
using Helix6.Base.Domain.Parameters;
using Helix6.Base.Domain.Security;
using Helix6.Base.Repository;
using Helix6.Base.Service;

namespace InfoportOneAdmon.Back.Services.Base
{
    public class SecurityProfileService : BaseService<SecurityProfileView, SecurityProfile, SecurityProfileViewMetadata>
    {
        private readonly IBaseService<SecurityModuleView, SecurityModule, SecurityProfileViewMetadata> _securityModuleService;

        public SecurityProfileService(IApplicationContext applicationContext, IUserContext userContext, IBaseRepository<SecurityProfile> repository, IBaseService<SecurityModuleView, SecurityModule, SecurityProfileViewMetadata> securityModuleService) : base(applicationContext, userContext, repository)
        {
            _securityModuleService = securityModuleService;
        }

        public override async Task<SecurityProfileView?> GetById(int id, QueryParams queryParams)
        {
            var profileView = await base.GetById(id, queryParams);

            if (profileView != null && queryParams.ConfigurationName == DataConsts.LoadingConfigurations.SecurityProfile.PROFILE_WITH_MODULES)
            {
                //Obtenemos el listado completo de módulos con sus opciones de acceso
                var modules = await _securityModuleService.GetAll(DataConsts.LoadingConfigurations.SecurityModule.MODULE_WITH_SECURITYOPTIONS);
                if (modules != null)
                {
                    foreach (var module in modules)
                    {
                        foreach (var securityAccessOption in module.SecurityAccessOption)
                        {
                            if (profileView.SecurityProfile_SecurityAccessOption != null &&
                                profileView.SecurityProfile_SecurityAccessOption.Any(pa => pa.SecurityAccessOptionId == securityAccessOption.Id))
                                securityAccessOption.includedInProfile = true;
                            else
                                securityAccessOption.includedInProfile = false;
                        }
                    }
                }
                profileView.SecurityModule = modules;
            }

            return profileView;
        }

        public override async Task<int> Insert(SecurityProfileView view, SetParamsService setParams)
        {
            if (view != null && setParams.ConfigurationName == DataConsts.LoadingConfigurations.SecurityProfile.PROFILE_WITH_MODULES)
            {
                if (view.SecurityModule != null)
                {
                    view.SecurityProfile_SecurityAccessOption = new List<SecurityProfile_SecurityAccessOptionView>();
                    foreach (var module in view.SecurityModule)
                    {
                        foreach (var securityAccessOption in module.SecurityAccessOption.Where(sa => sa.includedInProfile == true))
                        {
                            if (!view.SecurityProfile_SecurityAccessOption.Any(x => x.SecurityAccessOptionId == securityAccessOption.Id))
                            {
                                SecurityProfile_SecurityAccessOptionView newSecurityProfileAccessOption = new()
                                {
                                    SecurityAccessOptionId = securityAccessOption.Id
                                };
                                view.SecurityProfile_SecurityAccessOption.Add(newSecurityProfileAccessOption);
                            }
                        }
                    }

                }
            }
            if (view != null)
                return await base.Insert(view, setParams);
            return 0;
        }

        public override async Task<bool> Update(SecurityProfileView view, SetParamsService setParams)
        {
            if (view != null && setParams.ConfigurationName == DataConsts.LoadingConfigurations.SecurityProfile.PROFILE_WITH_MODULES)
            {
                if (view.SecurityModule != null)
                {
                    var securityProfileDB = await GetById(view.Id, setParams.GetQueryParams());

                    if (securityProfileDB != null)
                    {
                        //Recargamos las opciones de acceso del perfil de BBDD
                        view.SecurityProfile_SecurityAccessOption = securityProfileDB.SecurityProfile_SecurityAccessOption;

                        List<int> securityOptionsToDelete = new();
                        foreach (var module in view.SecurityModule)
                        {
                            //Añadimos las opciones de acceso que hayan sido incluidas en el perfil
                            foreach (var moduleSecurityOption in module.SecurityAccessOption
                                                                 .Where(sa => sa.includedInProfile == true &&
                                                                        !view.SecurityProfile_SecurityAccessOption.Any(s => s.SecurityAccessOptionId == sa.Id)))
                            {
                                SecurityProfile_SecurityAccessOptionView newSecurityProfileAccessOption = new()
                                {
                                    SecurityAccessOptionId = moduleSecurityOption.Id,
                                    SecurityProfileId = view.Id
                                };
                                view.SecurityProfile_SecurityAccessOption.Add(newSecurityProfileAccessOption);
                            }
                            //Eliminamos aquellas opciones de acceso del perfil que hayan sido quitadas
                            foreach (var moduleSecurityOption in module.SecurityAccessOption
                                                             .Where(sa => sa.includedInProfile == false &&
                                                                    view.SecurityProfile_SecurityAccessOption.Any(s => s.SecurityAccessOptionId == sa.Id)))
                            {
                                securityOptionsToDelete.Add(moduleSecurityOption.Id);
                            }
                        }
                        if (securityOptionsToDelete.Count > 0)
                            view.SecurityProfile_SecurityAccessOption.RemoveAll(s => securityOptionsToDelete.Contains(s.SecurityAccessOptionId));
                    }
                }
            }
            if (view != null)
                return await base.Update(view, setParams);
            return false;
        }

        public override async Task<SecurityProfileView?> GetNewEntity()
        {
            var result = new SecurityProfileView
            {
                SecurityCompanyId = UserContext.Applications[0].SecurityCompanyId,
                Description = string.Empty,
                Rol = string.Empty,
                SecurityModule = await _securityModuleService.GetAll(DataConsts.LoadingConfigurations.SecurityModule.MODULE_WITH_SECURITYOPTIONS)
            };
            foreach (var module in result.SecurityModule)
            {
                foreach (var securityoption in module.SecurityAccessOption)
                {
                    securityoption.includedInProfile = false;
                }
            }
            return result;
        }
    }
}
