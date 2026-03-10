using System;
using System.Collections.Generic;
using Helix6.Base.Application;
using Helix6.Base.Domain.Security;
using Helix6.Base.Service;
using Helix6.Base.Repository;
using InfoportOneAdmon.Back.DataModel;
using InfoportOneAdmon.Back.Entities.Views;
using InfoportOneAdmon.Back.Entities.Views.Metadata;


namespace InfoportOneAdmon.Back.Services
{
    public class OrganizationService : BaseService<OrganizationView, Organization, OrganizationViewMetadata>
    {
        

        public OrganizationService(
            IApplicationContext applicationContext,
            IUserContext userContext,
            IBaseRepository<Organization> repository
            )
            : base(applicationContext, userContext, repository)
        {
            
        }
    }
}
