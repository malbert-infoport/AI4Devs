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
    public class ApplicationService : BaseService<ApplicationView, Application, ApplicationViewMetadata>
    {
        

        public ApplicationService(
            IApplicationContext applicationContext,
            IUserContext userContext,
            IBaseRepository<Application> repository
            )
            : base(applicationContext, userContext, repository)
        {
            
        }
    }
}
