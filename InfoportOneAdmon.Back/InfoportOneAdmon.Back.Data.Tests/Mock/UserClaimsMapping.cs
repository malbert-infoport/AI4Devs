using Helix6.Base.Domain.Security;
using System.Security.Claims;

namespace InfoportOneAdmon.Back.Data.Tests.Mock
{
    public class UserClaimsMapping : IUserClaimsMapping
    {
        public List<AuthClaim> GetClaims(ClaimsPrincipal? principalUser)
        {
            return new List<AuthClaim>();
        }

        public string? GetDisplayName(ClaimsPrincipal? principalUser)
        {
            return "Adolfo Fernández San Juan";
        }

        public bool GetIsAdmin(ClaimsPrincipal? principalUser, string? rolPrefixesString = null)
        {
            return true;
        }

        public string? GetLogin(ClaimsPrincipal? principalUser)
        {
            return "afersa";
        }

        public string? GetMail(ClaimsPrincipal? principalUser)
        {
            return "afersa@gmail.com";
        }

        public string? GetOrganizationCif(ClaimsPrincipal? principalUser)
        {
            return "12345678Z";
        }

        public string? GetOrganizationCode(ClaimsPrincipal? principalUser)
        {
            return "0045";
        }

        public string? GetOrganizationName(ClaimsPrincipal? principalUser)
        {
            return "Company";
        }

        public List<string> GetRoles(ClaimsPrincipal? principalUser, string? rolPrefixes)
        {
            return new List<string>() { "admin", "test" };
        }

        public int GetSecurityCompanyId(ClaimsPrincipal? principalUser)
        {
            return 1;
        }

        public bool GetSendClaimsToFront()
        {
            return true;
        }

        public string? GetUserId(ClaimsPrincipal? principalUser)
        {
            return "1134";
        }

        public string? GetUserName(ClaimsPrincipal? principalUser)
        {
            return "Adolfo";
        }
    }
}
