using System;
using System.Collections.Generic;
using Helix6.Base.Repository;
using Helix6.Base.Application;
using Helix6.Base.Domain.Security;
using __ENTITY_NAMESPACE__;
using __NAMESPACE__.Interfaces;

namespace __NAMESPACE__
{
    public class __ENTITY_NAME__Repository : __BASE_REPOSITORY__, I__ENTITY_NAME__Repository
    {
        public __ENTITY_NAME__Repository(
            IApplicationContext applicationContext,
            IUserContext userContext,
            IBaseEFRepository<__ENTITY_NAME__> baseEFRepository,
            IBaseDapperRepository<__ENTITY_NAME__> baseDapperRepository)
            : base(applicationContext, userContext, baseEFRepository, baseDapperRepository)
        {
        }
    }
}
