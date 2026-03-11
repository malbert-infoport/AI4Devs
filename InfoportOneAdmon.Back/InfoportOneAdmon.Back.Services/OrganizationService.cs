using Helix6.Base.Application;
using Helix6.Base.Domain;
using Helix6.Base.Domain.Parameters;
using Helix6.Base.Domain.Security;
using Helix6.Base.Domain.Validations;
using Helix6.Base.Service;
using InfoportOneAdmon.Back.Data.Repository.Interfaces;
using InfoportOneAdmon.Back.DataModel;
using InfoportOneAdmon.Back.Entities;
using InfoportOneAdmon.Back.Entities.Views;
using InfoportOneAdmon.Back.Entities.Views.Metadata;


namespace InfoportOneAdmon.Back.Services
{
    public class OrganizationService : BaseService<OrganizationView, Organization, OrganizationViewMetadata>
    {
        private readonly IUserPermissions _userPermissions;
        private readonly IOrganizationRepository _organizationRepository;
        private readonly OrganizationGroupService _organizationGroupService;

        public OrganizationService(
            IApplicationContext applicationContext,
            IUserContext userContext,
            IOrganizationRepository repository,
            IUserPermissions userPermissions,
            OrganizationGroupService organizationGroupService
            )
            : base(applicationContext, userContext, repository)
        {
            _organizationRepository = repository;
            _userPermissions = userPermissions;
            _organizationGroupService = organizationGroupService;
        }

        public override async Task ValidateView(
            HelixValidationProblem validations,
            OrganizationView? view,
            HelixEnums.EnumActionType actionType,
            string? configurationName = null)
        {
            if (view == null)
            {
                await base.ValidateView(validations, view, actionType, configurationName);
                return;
            }

            var hasDataModificationPermission = await HasPermission(Consts.SecurityAccessOption.OrganizationOptions.ORGANIZATION_DATA_MODIFICATION);
            var hasModulesModificationPermission = await HasPermission(Consts.SecurityAccessOption.OrganizationOptions.ORGANIZATION_MODULES_MODIFICATION);

            if (actionType == HelixEnums.EnumActionType.Insert && !hasDataModificationPermission)
            {
                validations.AddError(Consts.Validations.Organization.CREATE_FORBIDDEN);
            }

            // Para Update no se bloquea por permisos aqui: se filtra payload en PreviousActions.
            // Para Insert, si vienen modulos sin permiso 204, se ignoran en PreviousActions.

            if (string.IsNullOrWhiteSpace(view.Name))
                validations.AddError(Consts.Validations.Organization.NAME_REQUIRED);

            if (string.IsNullOrWhiteSpace(view.TaxId))
                validations.AddError(Consts.Validations.Organization.TAXID_REQUIRED);

            if (!string.IsNullOrWhiteSpace(view.ContactEmail))
            {
                var emailAttribute = new System.ComponentModel.DataAnnotations.EmailAddressAttribute();
                if (!emailAttribute.IsValid(view.ContactEmail))
                    validations.AddError(Consts.Validations.Organization.CONTACT_EMAIL_INVALID);
            }

            await ValidateUniqueName(validations, view);
            await ValidateUniqueTaxId(validations, view);
            await ValidateGroup(validations, view);

            await base.ValidateView(validations, view, actionType, configurationName);
        }

        public override async Task PreviousActions(OrganizationView? view, HelixEnums.EnumActionType actionType, string? configurationName = null)
        {
            if (view == null)
            {
                await base.PreviousActions(view, actionType, configurationName);
                return;
            }

            var hasDataModificationPermission = await HasPermission(Consts.SecurityAccessOption.OrganizationOptions.ORGANIZATION_DATA_MODIFICATION);
            var hasModulesModificationPermission = await HasPermission(Consts.SecurityAccessOption.OrganizationOptions.ORGANIZATION_MODULES_MODIFICATION);

            OrganizationView? original = null;
            if (view.Id > 0 && (actionType == HelixEnums.EnumActionType.Update || actionType == HelixEnums.EnumActionType.LogicDelete))
            {
                var configurationToUse = string.IsNullOrWhiteSpace(configurationName)
                    ? Consts.LoadingConfigurations.Organization.ORGANIZATION_COMPLETE
                    : configurationName;

                original = await base.GetById(view.Id, new QueryParams(configurationToUse));
            }

            if (actionType == HelixEnums.EnumActionType.Update && view.Id > 0 && !hasDataModificationPermission)
            {
                if (original != null)
                {
                    view.Name = original.Name;
                    view.Acronym = original.Acronym;
                    view.TaxId = original.TaxId;
                    view.Address = original.Address;
                    view.City = original.City;
                    view.PostalCode = original.PostalCode;
                    view.Country = original.Country;
                    view.ContactEmail = original.ContactEmail;
                    view.ContactPhone = original.ContactPhone;
                    view.GroupId = original.GroupId;
                }
            }

            if (!hasModulesModificationPermission && original != null)
            {
                view.Organization_ApplicationModule = original.Organization_ApplicationModule;
            }
            else if (!hasModulesModificationPermission)
            {
                view.Organization_ApplicationModule = null;
            }

            await base.PreviousActions(view, actionType, configurationName);
        }

        public override async Task EndActions(OrganizationView? view, HelixEnums.EnumActionType actionType, string? configurationName)
        {
            // Placeholder: la publicacion de eventos y auditoria funcional se implementara aqui.
            await base.EndActions(view, actionType, configurationName);
        }

        public override async Task<OrganizationView?> GetNewEntity()
        {
            var result = await base.GetNewEntity();
            if (result != null)
            {
                result.SecurityCompanyId = await _organizationRepository.GetNextSecurityCompanyId();
            }

            return result;
        }

        public override async Task<OrganizationView?> MapEntityToView(Organization? entity, string? configurationName = null, OrganizationView? view = null)
        {
            var mappedView = await base.MapEntityToView(entity, configurationName, view);
            if (mappedView == null)
                return null;

            var canViewModules = await HasPermission(Consts.SecurityAccessOption.OrganizationOptions.ORGANIZATION_MODULES_QUERY);
            var canModifyModules = await HasPermission(Consts.SecurityAccessOption.OrganizationOptions.ORGANIZATION_MODULES_MODIFICATION);
            if (!canViewModules && !canModifyModules)
            {
                mappedView.Organization_ApplicationModule = new List<Organization_ApplicationModuleView>();
            }

            return mappedView;
        }

        private async Task<bool> HasPermission(int securityOption)
        {
            var authPermissions = await _userPermissions.GetUserPermissions();
            if (authPermissions == null)
                return false;

            if (authPermissions.Permissions != null && authPermissions.Permissions.Contains(securityOption))
                return true;

            return false;
        }

        private async Task ValidateUniqueName(HelixValidationProblem validations, OrganizationView view)
        {
            if (string.IsNullOrWhiteSpace(view.Name))
                return;

            var exists = await _organizationRepository.ExistsActiveByName(view.Name.Trim(), view.Id);
            if (exists)
                validations.AddError(Consts.Validations.Organization.NAME_ALREADY_EXISTS, view.Name);
        }

        private async Task ValidateUniqueTaxId(HelixValidationProblem validations, OrganizationView view)
        {
            if (string.IsNullOrWhiteSpace(view.TaxId))
                return;

            var exists = await _organizationRepository.ExistsActiveByTaxId(view.TaxId.Trim(), view.Id);
            if (exists)
                validations.AddError(Consts.Validations.Organization.TAXID_ALREADY_EXISTS, view.TaxId);
        }

        private async Task ValidateGroup(HelixValidationProblem validations, OrganizationView view)
        {
            if (!view.GroupId.HasValue)
                return;

            var group = await _organizationGroupService.GetById(view.GroupId.Value);
            var exists = group != null;
            if (!exists)
                validations.AddError(Consts.Validations.Organization.GROUP_NOT_FOUND_OR_INACTIVE, view.GroupId.Value.ToString());
        }
    }
}
