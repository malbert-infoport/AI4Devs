using Helix6.Base.Domain.Security;
using IdentityModel;
using System.Security.Claims;

namespace InfoportOneAdmon.Back.Api.Security
{
    public class APVClaimsMapping : IUserClaimsMapping
    {
        const string ISADMIN_CLAIM = "admin";
        const string USER_ID_CLAIM = "user_id";
        const string ORGANIZATION_CIF_CLAIM = "organizationcif";
        const string ORGANIZATION_NAME_CLAIM = "organization";
        const string ORGANIZATION_CODE_CLAIM = "organizationapvcode";
        const string ROLES_CLAIM = "groups";
        const bool SEND_CLAIMS_TO_FRONT = false;

        public int GetSecurityCompanyId(ClaimsPrincipal? principalUser)
        {
            return 1;
        }

        public string? GetUserId(ClaimsPrincipal? principalUser)
        {
            return GetClaimValue(USER_ID_CLAIM, principalUser);
        }

        public string? GetUserName(ClaimsPrincipal? principalUser)
        {
            return GetClaimValue(JwtClaimTypes.Name, principalUser);
        }

        public string? GetDisplayName(ClaimsPrincipal? principalUser)
        {
            return GetClaimValue(JwtClaimTypes.PreferredUserName, principalUser);
        }

        public string? GetLogin(ClaimsPrincipal? principalUser)
        {
            return GetClaimValue(JwtClaimTypes.Name, principalUser);
        }

        public string? GetMail(ClaimsPrincipal? principalUser)
        {
            return GetClaimValue(JwtClaimTypes.Subject, principalUser);
        }

        public string? GetOrganizationCif(ClaimsPrincipal? principalUser)
        {
            return GetClaimValue(ORGANIZATION_CIF_CLAIM, principalUser);
        }

        public string? GetOrganizationCode(ClaimsPrincipal? principalUser)
        {
            return GetClaimValue(ORGANIZATION_CODE_CLAIM, principalUser);
        }

        public string? GetOrganizationName(ClaimsPrincipal? principalUser)
        {
            return GetClaimValue(ORGANIZATION_NAME_CLAIM, principalUser);
        }

        public bool GetIsAdmin(ClaimsPrincipal? principalUser, string? rolPrefixesString = null)
        {
            var roles = GetRoles(principalUser, rolPrefixesString);
            return roles.Contains(ISADMIN_CLAIM);
        }

        public List<string> GetRoles(ClaimsPrincipal? principalUser, string? rolPrefixesString = null)
        {
            List<string> roles = new();
            var rolesClaimValue = GetClaimValue(ROLES_CLAIM, principalUser);
            if (rolesClaimValue != null)
            {
                roles = rolesClaimValue.Split(",").ToList();
                //Si se han indicado prefijos para los roles eliminamos aquellos que no empiecen con cada prefijo
                if (rolPrefixesString != null)
                {
                    roles = FilterRolesByPrefixes(rolPrefixesString, roles);
                }
            }
            return roles;
        }

        private List<string> FilterRolesByPrefixes(string rolPrefixesString, List<string> roles)
        {
            List<string> filteredRoles = new();

            List<string> rolPrefixes = rolPrefixesString.Split(",").ToList();
            foreach (var rolPrefix in rolPrefixes)
            {
                filteredRoles.AddRange(roles.Where(r => r.StartsWith(rolPrefix)).ToList());
            }

            return filteredRoles;
        }

        private string? GetClaimValue(string claimType, ClaimsPrincipal? principalUser)
        {
            if (principalUser != null)
            {
                var claim = principalUser.Claims.FirstOrDefault(c => c.Type == claimType);
                if (claim != null)
                    return claim.Value;
            }
            return null;
        }

        public bool GetSendClaimsToFront()
        {
            return SEND_CLAIMS_TO_FRONT;
        }
    }
}
