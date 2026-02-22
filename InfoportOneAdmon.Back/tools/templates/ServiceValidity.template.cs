using System;
using System.Collections.Generic;
using System.Threading.Tasks;
__REPO_USING__
using __ENTITY_NAMESPACE__;
using __VIEWS_NAMESPACE__;
using __METADATA_NAMESPACE__;

namespace __NAMESPACE__
{
    public class __ENTITY_NAME__Service : __BASE_SERVICE__
    {
        __REPO_FIELD__

        public __ENTITY_NAME__Service(
            IApplicationContext applicationContext,
            IUserContext userContext,
            __REPO_PARAM__)
            : base(applicationContext, userContext, __REPO_BASE__)
        {
            __REPO_ASSIGN__
        }

        // Validity-entity specific overrides can be placed here
        public override async Task ValidateView(
            HelixValidationProblem validations,
            __VIEW__? view,
            EnumActionType actionType,
            string? configurationName = null)
        {
            if (view != null)
            {
                // TODO: Validate ValidityFrom/ValidityTo rules
            }

            await base.ValidateView(validations, view, actionType, configurationName);
        }

        public override async Task PreviousActions(
            __VIEW__? view,
            EnumActionType actionType,
            string? configurationName = null)
        {
            // TODO: handle validity windows before persistence
            await base.PreviousActions(view, actionType, configurationName);
        }
    }
}
