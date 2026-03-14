using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Helix6.Base.Application;
using Helix6.Base.Domain;
using Helix6.Base.Domain.Parameters;
using Helix6.Base.Domain.Security;
using Helix6.Base.Domain.Validations;
using Helix6.Base.Service;
using InfoportOneAdmon.Back.Data.Repository.Interfaces;
using Helix6.Base.Repository;
using InfoportOneAdmon.Back.DataModel;
using InfoportOneAdmon.Back.Entities;
using InfoportOneAdmon.Back.Entities.Views;
using InfoportOneAdmon.Back.Entities.Views.Metadata;
using Microsoft.Extensions.Logging;

namespace InfoportOneAdmon.Back.Services
{
    public class OrganizationService : BaseService<OrganizationView, Organization, OrganizationViewMetadata>
    {
        private readonly IUserPermissions _userPermissions;
        private readonly IOrganizationRepository _organizationRepository;
        private readonly OrganizationGroupService _organizationGroupService;
        private readonly AuditLogService _auditLogService;
        private readonly IBaseRepository<ApplicationModule> _applicationModuleRepository;
        private readonly ILogger<OrganizationService> _logger;

        public OrganizationService(
            IApplicationContext applicationContext,
            IUserContext userContext,
            IOrganizationRepository repository,
            IUserPermissions userPermissions,
            OrganizationGroupService organizationGroupService,
            AuditLogService auditLogService,
            IBaseRepository<ApplicationModule> applicationModuleRepository,
            ILogger<OrganizationService> logger)
            : base(applicationContext, userContext, repository)
        {
            _organizationRepository = repository;
            _userPermissions = userPermissions;
            _organizationGroupService = organizationGroupService;
            _auditLogService = auditLogService;
            _applicationModuleRepository = applicationModuleRepository;
            _logger = logger;
        }

        public override async Task ValidateView(HelixValidationProblem validations, OrganizationView? view, HelixEnums.EnumActionType actionType, string? configurationName = null)
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
            _logger?.LogDebug("PreviousActions start: action={Action}, orgId={OrgId}", actionType, view?.Id);

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
                var configurationToUse = string.IsNullOrWhiteSpace(configurationName) ? Consts.LoadingConfigurations.Organization.ORGANIZATION_COMPLETE : configurationName;
                original = await base.GetById(view.Id, new QueryParams(configurationToUse));
            }

            if (actionType == HelixEnums.EnumActionType.Update && view.Id > 0 && !hasDataModificationPermission)
            {
                RestoreWithOriginalValues(view, original);
                _logger?.LogInformation("User lacks data modification permission; restored original values for orgId={OrgId}", view.Id);
            }

            if (!hasModulesModificationPermission && original != null)
            {
                view.Organization_ApplicationModule = original.Organization_ApplicationModule;
            }
            else if (!hasModulesModificationPermission)
            {
                view.Organization_ApplicationModule = null;
            }

            await ProcessAuditsAndLifecycleAsync(original, view, actionType);

            _logger?.LogDebug("PreviousActions end: action={Action}, orgId={OrgId}", actionType, view.Id);

            await base.PreviousActions(view, actionType, configurationName);
        }

        private static void RestoreWithOriginalValues(OrganizationView view, OrganizationView? original)
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

        private async Task ProcessAuditsAndLifecycleAsync(OrganizationView? original, OrganizationView view, HelixEnums.EnumActionType actionType)
        {
            try
            {
                await ProcessModuleChangesAsync(original, view);
                await ProcessGroupChangeAsync(original, view);
                await HandleManualDeactivateReactivateAsync(original, view, actionType);
            }
            catch (Exception ex)
            {
                _logger?.LogWarning(ex, "Error during audit/lifecycle processing for orgId={OrgId}", view.Id);
            }
        }

        private async Task ProcessModuleChangesAsync(OrganizationView? original, OrganizationView view)
        {
            var originalModuleIds = original?.Organization_ApplicationModule?.Select(m => m.ApplicationModuleId).ToList() ?? new List<int>();
            var newModuleIds = view.Organization_ApplicationModule?.Select(m => m.ApplicationModuleId).ToList() ?? new List<int>();

                var added = newModuleIds.Except(originalModuleIds).ToList();
            if (added.Any())
            {
                _logger?.LogInformation("Modules added for orgId={OrgId}: {Modules}", view.Id, string.Join(',', added));
                foreach (var modId in added)
                {
                    var moduleName = view.Organization_ApplicationModule?.FirstOrDefault(x => x.ApplicationModuleId == modId)?.ApplicationModule?.ModuleName;
                    if (string.IsNullOrWhiteSpace(moduleName))
                    {
                        var module = await _applicationModuleRepository.GetById(modId);
                        moduleName = module?.ModuleName;
                    }
                    var moduleText = !string.IsNullOrWhiteSpace(moduleName) ? moduleName : modId.ToString();
                    await LogAudit(view.Id > 0 ? view.Id : (int?)null, Consts.EventLogTypes.ModuleAssigned, $"Organization '{view.Name}' (Id={view.Id}) assigned Module '{moduleText}'");
                }
            }

            var removed = originalModuleIds.Except(newModuleIds).ToList();
            if (removed.Any())
            {
                _logger?.LogInformation("Modules removed for orgId={OrgId}: {Modules}", view.Id, string.Join(',', removed));
                foreach (var modId in removed)
                {
                    var moduleName = original?.Organization_ApplicationModule?.FirstOrDefault(x => x.ApplicationModuleId == modId)?.ApplicationModule?.ModuleName;
                    if (string.IsNullOrWhiteSpace(moduleName))
                    {
                        var module = await _applicationModuleRepository.GetById(modId);
                        moduleName = module?.ModuleName;
                    }
                    var moduleText = !string.IsNullOrWhiteSpace(moduleName) ? moduleName : modId.ToString();
                    await LogAudit(view.Id > 0 ? view.Id : (int?)null, Consts.EventLogTypes.ModuleRemoved, $"Organization '{view.Name}' (Id={view.Id}) removed Module '{moduleText}'");
                }
            }
        }

        private async Task ProcessGroupChangeAsync(OrganizationView? original, OrganizationView view)
        {
            if (original != null && original.GroupId != view.GroupId)
            {
                _logger?.LogInformation("Group changed for orgId={OrgId}: from {Old} to {New}", view.Id, original.GroupId, view.GroupId);
                string oldGroupName = original.GroupId.HasValue ? (await _organizationGroupService.GetById(original.GroupId.Value))?.GroupName ?? original.GroupId.Value.ToString() : "(none)";
                string newGroupName = view.GroupId.HasValue ? (await _organizationGroupService.GetById(view.GroupId.Value))?.GroupName ?? view.GroupId.Value.ToString() : "(none)";
                await LogAudit(view.Id > 0 ? view.Id : (int?)null, Consts.EventLogTypes.GroupChanged, $"Organization '{view.Name}' (Id={view.Id}) group changed from '{oldGroupName}' to '{newGroupName}'");
            }
        }

        private async Task HandleManualDeactivateReactivateAsync(OrganizationView? original, OrganizationView view, HelixEnums.EnumActionType actionType)
        {
            if (actionType != HelixEnums.EnumActionType.LogicDelete || original == null) return;

            if (original.AuditDeletionDate == null && view.AuditDeletionDate != null)
            {
                _logger?.LogInformation("Organization manually deactivated orgId={OrgId}", view.Id);
                await LogAudit(view.Id, Consts.EventLogTypes.OrganizationDeactivatedManual, $"Organization '{original.Name}' (Id={view.Id}) manually deactivated");
            }
            else if (original.AuditDeletionDate != null && view.AuditDeletionDate == null)
            {
                _logger?.LogInformation("Organization manually reactivated orgId={OrgId}", view.Id);
                await LogAudit(view.Id, Consts.EventLogTypes.OrganizationReactivatedManual, $"Organization '{original.Name}' (Id={view.Id}) manually reactivated");
            }
        }

        public override async Task EndActions(OrganizationView? view, HelixEnums.EnumActionType actionType, string? configurationName)
        {
            // Placeholder: event publication can be implemented here if needed
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
            if (mappedView == null) return null;

            var canViewModules = await HasPermission(Consts.SecurityAccessOption.OrganizationOptions.ORGANIZATION_MODULES_QUERY);
            var canModifyModules = await HasPermission(Consts.SecurityAccessOption.OrganizationOptions.ORGANIZATION_MODULES_MODIFICATION);
            if (!canViewModules && !canModifyModules)
                mappedView.Organization_ApplicationModule = new List<Organization_ApplicationModuleView>();

            return mappedView;
        }

        private async Task<bool> HasPermission(int securityOption)
        {
            var authPermissions = await _userPermissions.GetUserPermissions();
            if (authPermissions == null) return false;
            return authPermissions.Permissions != null && authPermissions.Permissions.Contains(securityOption);
        }

        private async Task ValidateUniqueName(HelixValidationProblem validations, OrganizationView view)
        {
            if (string.IsNullOrWhiteSpace(view.Name)) return;
            var exists = await _organizationRepository.ExistsActiveByName(view.Name.Trim(), view.Id);
            if (exists) validations.AddError(Consts.Validations.Organization.NAME_ALREADY_EXISTS, view.Name);
        }

        private async Task ValidateUniqueTaxId(HelixValidationProblem validations, OrganizationView view)
        {
            if (string.IsNullOrWhiteSpace(view.TaxId)) return;
            var exists = await _organizationRepository.ExistsActiveByTaxId(view.TaxId.Trim(), view.Id);
            if (exists) validations.AddError(Consts.Validations.Organization.TAXID_ALREADY_EXISTS, view.TaxId);
        }

        private async Task ValidateGroup(HelixValidationProblem validations, OrganizationView view)
        {
            if (!view.GroupId.HasValue) return;
            var group = await _organizationGroupService.GetById(view.GroupId.Value);
            var exists = group != null;
            if (!exists) validations.AddError(Consts.Validations.Organization.GROUP_NOT_FOUND_OR_INACTIVE, view.GroupId.Value.ToString());
        }

        private async Task LogAudit(int? entityId, string action, string? content = null)
        {
            try
            {
                await _auditLogService.LogAuditEntry(action, Consts.EntityTypes.Organization, entityId.HasValue ? entityId.Value.ToString() : string.Empty, content);
            }
            catch (Exception ex)
            {
                _logger?.LogWarning(ex, "Failed to write audit log for orgId={OrgId}, action={Action}", entityId, action);
            }
        }
    }
}
