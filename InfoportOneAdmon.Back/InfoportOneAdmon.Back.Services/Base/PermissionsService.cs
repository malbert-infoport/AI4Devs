using InfoportOneAdmon.Back.Data.Repository.Base.Interfaces;
using InfoportOneAdmon.Back.DataModel.Base;
using InfoportOneAdmon.Back.Entities.Views.Base;
using InfoportOneAdmon.Back.Entities.Views.Base.Metadata;
using Helix6.Base.Application;
using Helix6.Base.Domain.Security;
using Helix6.Base.Service;

namespace InfoportOneAdmon.Back.Services.Base
{
    public class PermissionsService : BaseService<PermissionsView, Permissions, PermissionsViewMetadata>, IUserPermissions
    {
        private static readonly List<UserPermissionsCache> _userPermissionsCache = new();
        private readonly IPermissionsRepository _repository;

        public PermissionsService(IApplicationContext applicationContext, IUserContext userContext, IPermissionsRepository repository) : base(applicationContext, userContext, repository)
        {
            _repository = repository;
        }

        public static void CleanUserPermissionsCache()
        {
            _userPermissionsCache.Clear();
        }

        public string GetAuthenticationType()
        {
            return UserContext.AuthenticationType;
        }

        public async Task<AuthPermissions> GetUserPermissions()
        {
            AuthPermissions? authPermissions = GetUserPermissionsFromCache(UserContext.User.Id, ApplicationContext.PermisionsMinutesCache);
            if (authPermissions == null)
            {
                authPermissions = new();
                var permissions = await _repository.GetPermissions();

                //SecurityOptions
                authPermissions.Permissions = permissions.Select(p => p.SecurityAccessOptionId).Distinct().ToList();

                //Controller Levels
                foreach (var permission in permissions.Where(p => p.Controller != null && p.SecurityLevel != null))
                {
                    if (permission.SecurityLevel != null)
                    {
                        if (!authPermissions.EndpointLevels.Any(c => c.EndpointName == permission.Controller && (int)c.Level == permission.SecurityLevel))
                        {
                            AuthControllerLevel controllerLevel = new()
                            {
                                EndpointName = permission.Controller,
                                Level = (Helix6.Base.Domain.HelixEnums.SecurityLevel)permission.SecurityLevel
                            };
                            authPermissions.EndpointLevels.Add(controllerLevel);
                        }
                    }
                }
                AddUserPermissionsToCache(UserContext.User.Id, ApplicationContext.PermisionsMinutesCache, authPermissions);
            }
            return authPermissions;
        }

        private static void AddUserPermissionsToCache(string userId, int? permisionsMinutesCache, AuthPermissions permissions)
        {
            if (permisionsMinutesCache != null)
            {
                UserPermissionsCache userPermissionsCache = new()
                {
                    ExpirationDate = DateTime.UtcNow.AddMinutes(permisionsMinutesCache.Value),
                    UserId = userId,
                    Permissions = permissions
                };
                _userPermissionsCache.Add(userPermissionsCache);
            }
        }

        private static AuthPermissions? GetUserPermissionsFromCache(string userId, int? permissionsMinutesCache)
        {
            if (permissionsMinutesCache != null)
            {
                //Eliminamos cache caducada
                _userPermissionsCache.RemoveAll(t => t.ExpirationDate <= System.DateTime.UtcNow);
                //Obtenemos los permisos a partir del identificador del usuario
                return _userPermissionsCache.Where(t => t.UserId == userId).Select(t => t.Permissions).FirstOrDefault();
            }
            return null;
        }
    }

    public class UserPermissionsCache
    {
        public UserPermissionsCache()
        {
            UserId = string.Empty;
            Permissions = new();
        }

        public DateTime ExpirationDate { get; set; }
        public AuthPermissions Permissions { get; set; }
        public string UserId { get; set; }
    }
}