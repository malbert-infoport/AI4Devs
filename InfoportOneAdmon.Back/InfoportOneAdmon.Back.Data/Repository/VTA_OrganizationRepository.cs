using System;
using System.Collections.Generic;
using Helix6.Base.Application;
using Helix6.Base.Domain.Parameters;
using Helix6.Base.Domain.Security;
using Helix6.Base.Repository;
using InfoportOneAdmon.Back.Data.Repository.Interfaces;
using InfoportOneAdmon.Back.DataModel;

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
        public override Task<List<VTA_Organization>> GetAll(QueryParams queryParams, IGenericFilter? genericFilter = null)
        {
            return base.GetAll(queryParams, genericFilter);
        }
    }
}
