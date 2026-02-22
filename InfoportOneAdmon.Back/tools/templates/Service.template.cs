using System;
using System.Collections.Generic;
using Helix6.Base.Application;
using Helix6.Base.Domain.Security;
using Helix6.Base.Service;
using Helix6.Base.Repository;
using __ENTITY_NAMESPACE__;
using __VIEWS_NAMESPACE__;
using __METADATA_NAMESPACE__;
__REPO_USING__

namespace __NAMESPACE__
{
    public class __ENTITY_NAME__Service : __BASE_SERVICE__
    {
        __REPO_FIELD__

        public __ENTITY_NAME__Service(
            IApplicationContext applicationContext,
            IUserContext userContext,
            __REPO_PARAM__
            )
            : base(applicationContext, userContext, __REPO_BASE__)
        {
            __REPO_ASSIGN__
        }
    }
}
