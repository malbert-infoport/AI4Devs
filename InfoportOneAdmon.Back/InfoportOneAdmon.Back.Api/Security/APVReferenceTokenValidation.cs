using Helix6.Base.Domain.Configuration;
using Helix6.Base.Domain.Security;
using IdentityModel;
using System.Net.Http.Headers;
using System.Security.Claims;
using System.Security.Principal;
using System.Text;
using System.Text.Json;

namespace InfoportOneAdmon.Back.Api.Security
{
    public class APVReferenceTokenValidation : IReferenceTokenValidation
    {
        private readonly AppSettings _appSettings;

        public APVReferenceTokenValidation(AppSettings appSettings)
        {
            _appSettings = appSettings;
        }

        public async Task<bool> ValidateReferenceToken(string? referenceToken, string scheme)
        {
            if (referenceToken != null && scheme != null)
            {
                var referenceTokenScheme = GetReferenceTokenScheme(scheme);
                if (referenceTokenScheme != null)
                {
                    using var httpClientHandler = new HttpClientHandler();
                    if (referenceTokenScheme.DisableHttpsCertificate)
                        httpClientHandler.ServerCertificateCustomValidationCallback = (message, cert, chain, errors) => { return true; };
                    using var client = new HttpClient(httpClientHandler);
                    var byteArray = Encoding.ASCII.GetBytes(referenceTokenScheme.IntrospectionUser + ":" + referenceTokenScheme.IntrospectionPassword);
                    client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Basic", Convert.ToBase64String(byteArray));
                    var url = referenceTokenScheme.IntrospectionEndpoint.TrimEnd('/');
                    var data = new List<KeyValuePair<string, string>>
                    {
                        new KeyValuePair<string, string>("token", referenceToken)
                    };
                    var req = new HttpRequestMessage(HttpMethod.Post, url) { Content = new FormUrlEncodedContent(data) };
                    var response = await client.SendAsync(req);
                    response.EnsureSuccessStatusCode();

                    if (response != null && response.Content != null)
                    {
                        string jsonResult = response.Content.ReadAsStringAsync().Result;
                        var jsonDocument = JsonDocument.Parse(jsonResult);
                        var contextClientId = GetStringProperty(jsonDocument, JwtClaimTypes.ClientId);
                        if (!string.IsNullOrEmpty(contextClientId) && !string.IsNullOrEmpty(referenceTokenScheme.AllowedClientIds))
                        {
                            var allowedClientIds = referenceTokenScheme.AllowedClientIds.Split(",").ToList();
                            if (!allowedClientIds.Contains(contextClientId))
                                return false;
                        }
                        bool active = GetBooleanProperty(jsonDocument, "active");
                        return active;
                    }
                }
            }
            return false;
        }

        public async Task<ClaimsPrincipal?> CompleteUserInfoFromReferenceToken(string? referenceToken, string scheme)
        {
            if (referenceToken != null && scheme != null)
            {
                var referenceTokenScheme = GetReferenceTokenScheme(scheme);
                if (referenceTokenScheme != null)
                {
                    if (string.IsNullOrEmpty(referenceTokenScheme.UserInfoEndpoint))
                        return CreateEmptyClaimsPrincipal(scheme, referenceToken, referenceTokenScheme);
                    else
                    {
                        using var httpClientHandler = new HttpClientHandler();
                        if (referenceTokenScheme.DisableHttpsCertificate)
                            httpClientHandler.ServerCertificateCustomValidationCallback = (message, cert, chain, errors) => { return true; };
                        using var client = new HttpClient(httpClientHandler);
                        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", referenceToken);
                        var url = referenceTokenScheme.UserInfoEndpoint.TrimEnd('/');
                        var req = new HttpRequestMessage(HttpMethod.Get, url);
                        var response = await client.SendAsync(req);
                        response.EnsureSuccessStatusCode();
                        if (response != null && response.Content != null)
                        {
                            string jsonResult = response.Content.ReadAsStringAsync().Result;
                            int minutesCache = 5;
                            if (referenceTokenScheme.MinutesCache.HasValue)
                                minutesCache = referenceTokenScheme.MinutesCache.Value;
                            return MapUserInfo(scheme, jsonResult, minutesCache);
                        }
                    }
                }
            }
            return null;
        }

        private HelixReferenceTokenScheme? GetReferenceTokenScheme(string scheme)
        {
            return _appSettings.Authentication.ReferenceTokenSchemes.FirstOrDefault(a => a.AuthenticationScheme == scheme); ;
        }

        private static ClaimsPrincipal CreateEmptyClaimsPrincipal(string scheme, string referenceToken, HelixReferenceTokenScheme referenceTokenScheme)
        {
            List<Claim> claims = new()
            {
                new Claim(JwtClaimTypes.Locale, "es-ES")
            };
            int minutesCache = 5;
            if (referenceTokenScheme.MinutesCache.HasValue)
                minutesCache = referenceTokenScheme.MinutesCache.Value;
            DateTimeOffset dtoExpiration = new(DateTime.UtcNow.AddMinutes(minutesCache), TimeSpan.Zero);
            claims.Add(new Claim(JwtClaimTypes.Expiration, dtoExpiration.ToUnixTimeSeconds().ToString()));
            claims.Add(new Claim("user_id", referenceToken));
            claims.Add(new Claim(JwtClaimTypes.Name, referenceTokenScheme.AuthenticationScheme));

            IIdentity identity = new ClaimsIdentity(claims, scheme);
            ClaimsPrincipal principal = new(identity);
            return principal;
        }
        private static ClaimsPrincipal MapUserInfo(string scheme, string jsonResult, int minutesCache)
        {
            var jsonDocument = JsonDocument.Parse(jsonResult);

            List<Claim> claims = new()
            {
                new Claim(JwtClaimTypes.Locale, "es-ES")
            };
            DateTimeOffset dtoExpiration = new(DateTime.UtcNow.AddMinutes(minutesCache), TimeSpan.Zero);
            claims.Add(new Claim(JwtClaimTypes.Expiration, dtoExpiration.ToUnixTimeSeconds().ToString()));

            var claimSub = GetStringProperty(jsonDocument, JwtClaimTypes.Subject);
            if (claimSub != null)
                claims.Add(new Claim(JwtClaimTypes.Subject, claimSub));

            var claimUserId = GetStringProperty(jsonDocument, "user_id");
            if (claimUserId != null)
                claims.Add(new Claim("user_id", claimUserId));

            var claimOrganization = GetStringProperty(jsonDocument, "organization");
            if (claimOrganization != null)
                claims.Add(new Claim("organization", claimOrganization));

            var claimName = GetStringProperty(jsonDocument, JwtClaimTypes.Name);
            if (claimName != null)
                claims.Add(new Claim(JwtClaimTypes.Name, claimName));

            var claimOrganizationApvCode = GetStringProperty(jsonDocument, "organizationapvcode");
            if (claimOrganizationApvCode != null)
                claims.Add(new Claim("organizationapvcode", claimOrganizationApvCode));

            var claimPreferredUserName = GetStringProperty(jsonDocument, JwtClaimTypes.PreferredUserName);
            if (claimPreferredUserName != null)
                claims.Add(new Claim(JwtClaimTypes.PreferredUserName, claimPreferredUserName));

            var claimOrganizationCIF = GetStringProperty(jsonDocument, "organizationcif");
            if (claimOrganizationCIF != null)
                claims.Add(new Claim("organizationcif", claimOrganizationCIF));

            var claimGroups = GetStringProperty(jsonDocument, "groups");
            if (claimGroups != null)
            {
                var roles = claimGroups.Split(Convert.ToChar(",")).ToList();
                roles = EliminarDominiosRoles(roles);
                claimGroups = string.Empty;
                foreach (var rol in roles)
                {
                    if (claimGroups == string.Empty)
                        claimGroups = rol;
                    else
                        claimGroups += "," + rol;
                }
                claims.Add(new Claim("groups", claimGroups));
            }
            IIdentity identity = new ClaimsIdentity(claims, scheme);
            ClaimsPrincipal principal = new(identity);
            return principal;
        }

        private static bool GetBooleanProperty(JsonDocument? jsonDocument, string propertyName)
        {
            bool result = false;
            if (jsonDocument != null)
                result = jsonDocument.RootElement.GetProperty(propertyName).GetBoolean();
            return result;
        }

        private static string? GetStringProperty(JsonDocument? jsonDocument, string propertyName)
        {
            string? result = null;
            if (jsonDocument != null)
                result = jsonDocument.RootElement.GetProperty(propertyName).GetString();
            return result;
        }

        private static List<string> EliminarDominiosRoles(List<string> roles)
        {
            var result = new List<string>();
            foreach (var rol in roles)
            {
                var rolSinDominios = rol.Split(Convert.ToChar("/")).Last();
                rolSinDominios = rolSinDominios.Split(Convert.ToChar("\\")).Last();
                result.Add(rolSinDominios);
            }
            return result;
        }
    }
}
