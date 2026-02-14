using Helix6.Base.Domain.Security;
using Helix6.Base.Extensions;
using IdentityModel;
using System.Security.Claims;
using System.Text.Json;

namespace InfoportOneAdmon.Back.Api.Security
{
    public class KeyCloakUserClaimsMapping : IUserClaimsMapping
    {
        const int DEFAULT_SECURITY_COMPANY_ID = 1;
        public const string SECURITY_COMPANY_ID_CLAIM = "c_id";
        public const string ORGANIZATION_CIF_CLAIM = "o_cif";
        public const string ORGANIZATION_CODE_CLAIM = "o_code";
        public const string ORGANIZATION_NAME_CLAIM = "o_name";
        const string ISADMIN_CLAIM = "HLX_IsAdmin";
        const string REALM_ROLES_CLAIM = "realm_access";
        const string RESOURCE_ROLES_CLAIM = "resource_access";
        const string CLIENT_NAME = "angularclient";
        const string NODE_ROLES = "roles";
        const bool SEND_CLAIMS_TO_FRONT = false;

        public int GetSecurityCompanyId(ClaimsPrincipal? principalUser)
        {
            string? companyId = principalUser.GetClaimValue(SECURITY_COMPANY_ID_CLAIM);
            if (companyId == null)
                return DEFAULT_SECURITY_COMPANY_ID;
            return Convert.ToInt32(companyId);
        }

        public string? GetUserId(ClaimsPrincipal? principalUser)
        {
            return principalUser.GetClaimValue(JwtClaimTypes.Subject);
        }

        public string? GetUserName(ClaimsPrincipal? principalUser)
        {
            return principalUser.GetClaimValue(JwtClaimTypes.GivenName);
        }

        public string? GetDisplayName(ClaimsPrincipal? principalUser)
        {
            return principalUser.GetClaimValue(JwtClaimTypes.Name);
        }

        public string? GetLogin(ClaimsPrincipal? principalUser)
        {
            return principalUser.GetClaimValue(JwtClaimTypes.PreferredUserName);
        }

        public string? GetMail(ClaimsPrincipal? principalUser)
        {
            return principalUser.GetClaimValue(JwtClaimTypes.Email);
        }

        public string? GetOrganizationCif(ClaimsPrincipal? principalUser)
        {
            return principalUser.GetClaimValue(ORGANIZATION_CIF_CLAIM);
        }

        public string? GetOrganizationCode(ClaimsPrincipal? principalUser)
        {
            return principalUser.GetClaimValue(ORGANIZATION_CODE_CLAIM);
        }

        public string? GetOrganizationName(ClaimsPrincipal? principalUser)
        {
            return principalUser.GetClaimValue(ORGANIZATION_NAME_CLAIM);
        }

        public bool GetIsAdmin(ClaimsPrincipal? principalUser, string? rolPrefixesString = null)
        {
            var roles = GetRoles(principalUser, rolPrefixesString);
            return roles.Contains(ISADMIN_CLAIM);
        }

        public List<string> GetRoles(ClaimsPrincipal? principalUser, string? rolPrefixesString = null)
        {
            List<string> roles = new();
            var realm_access = principalUser.GetClaimValue(REALM_ROLES_CLAIM);
            if (realm_access != null && realm_access.Contains(NODE_ROLES))
            {
                using (JsonDocument document = JsonDocument.Parse(realm_access))
                {
                    JsonElement root = document.RootElement;
                    JsonElement propertyRoles = root.GetProperty(NODE_ROLES);
                    foreach (JsonElement element in propertyRoles.EnumerateArray())
                    {
                        if (element.ValueKind == JsonValueKind.String)
                        {
                            var rol = element.GetString();
                            if (rol != null)
                                roles.Add(rol);
                        }
                    }
                }
            }
            var resource_access = principalUser.GetClaimValue(RESOURCE_ROLES_CLAIM);
            if (resource_access != null && resource_access.Contains(CLIENT_NAME) && resource_access.Contains(NODE_ROLES))
            {
                using (JsonDocument document = JsonDocument.Parse(resource_access))
                {
                    JsonElement root = document.RootElement;
                    JsonElement propertyClient = root.GetProperty(CLIENT_NAME);
                    using (JsonDocument documentClient = JsonDocument.Parse(propertyClient.ToString()))
                    {
                        JsonElement rootClient = documentClient.RootElement;
                        JsonElement propertyRoles = rootClient.GetProperty(NODE_ROLES);
                        foreach (JsonElement element in propertyRoles.EnumerateArray())
                        {
                            if (element.ValueKind == JsonValueKind.String)
                            {
                                var rol = element.GetString();
                                if (rol != null)
                                    roles.Add(rol);
                            }
                        }
                    }
                }
            }
            //Si se han indicado prefijos para los roles eliminamos aquellos que no empiecen con cada prefijo
            if (rolPrefixesString != null)
            {
                roles = FilterRolesByPrefixes(rolPrefixesString, roles);
            }

            return roles;
        }

        public bool GetSendClaimsToFront()
        {
            return SEND_CLAIMS_TO_FRONT;
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

    }
}
