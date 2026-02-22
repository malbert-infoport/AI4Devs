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

        public override async Task<__VIEW__?> GetNewEntity()
        {
            // TODO: provide default values for a new entity
            return await base.GetNewEntity();
        }

        public override async Task ValidateView(
            HelixValidationProblem validations,
            __VIEW__? view,
            EnumActionType actionType,
            string? configurationName = null)
        {
            if (view != null)
            {
                // TODO: add business validations here
            }

            await base.ValidateView(validations, view, actionType, configurationName);
        }

        public override async Task PreviousActions(
            __VIEW__? view,
            EnumActionType actionType,
            string? configurationName = null)
        {
            // TODO: logic before Insert/Update/Delete
            await base.PreviousActions(view, actionType, configurationName);
        }

        public override async Task PostActions(
            __VIEW__? view,
            EnumActionType actionType,
            string? configurationName = null)
        {
            // TODO: logic after persistence (notifications, indexing...)
            await base.PostActions(view, actionType, configurationName);
        }

        public override async Task MapViewToEntity(
            __VIEW__? view,
            __ENTITY__? entity,
            EnumActionType actionType,
            string? configurationName = null)
        {
            // TODO: customize mapping if necessary
            await base.MapViewToEntity(view, entity, actionType, configurationName);
        }
    }
}
