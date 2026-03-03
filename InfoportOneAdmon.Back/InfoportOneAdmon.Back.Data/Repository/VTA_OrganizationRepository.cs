using System;
using System.Collections.Generic;
using Helix6.Base.Repository;
using Helix6.Base.Application;
using Helix6.Base.Domain.Security;
using InfoportOneAdmon.Back.DataModel;
using InfoportOneAdmon.Back.Data.Repository.Interfaces;

namespace InfoportOneAdmon.Back.Data.Repository
{
    public class VTA_OrganizationRepository : BaseRepository<VTA_Organization>, IVTA_OrganizationRepository
    {
        public VTA_OrganizationRepository(
            IApplicationContext applicationContext,
            IUserContext userContext,
            IBaseEFRepository<VTA_Organization> baseEFRepository,
            IBaseDapperRepository<VTA_Organization> baseDapperRepository)
            : base(applicationContext, userContext, baseEFRepository, baseDapperRepository)
        {
        }
    }
}
