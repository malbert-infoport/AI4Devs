using System;
using System.Collections.Generic;
using Helix6.Base.Application;
using Helix6.Base.Domain.Security;
using Helix6.Base.Service;
using Helix6.Base.Repository;
using InfoportOneAdmon.Back.DataModel;
using InfoportOneAdmon.Back.Entities.Views;
using InfoportOneAdmon.Back.Entities.Views.Metadata;
using InfoportOneAdmon.Back.Data.Repository.Interfaces;

namespace InfoportOneAdmon.Back.Services
{
    public class VTA_OrganizationService : BaseService<VTA_OrganizationView, VTA_Organization, VTA_OrganizationViewMetadata>
    {
        private readonly IVTA_OrganizationRepository _repository;

        public VTA_OrganizationService(
            IApplicationContext applicationContext,
            IUserContext userContext,
            IVTA_OrganizationRepository repository
            )
            : base(applicationContext, userContext, repository)
        {
            _repository = repository;
        }
    }
}
