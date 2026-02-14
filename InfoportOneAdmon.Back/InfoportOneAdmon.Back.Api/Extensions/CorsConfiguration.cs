using Helix6.Base.Culture;
using Helix6.Base.Domain.Configuration;
using Microsoft.OpenApi.Models;
using System.Globalization;

namespace InfoportOneAdmon.Back.Api.Extensions
{
    public static class CorsConfiguration
    {
        /// <summary>
        /// Adds Swagger configuration.
        /// </summary>
        /// <param name="services"></param>
        /// <param name="supportedCultures">List of supported cultures for Accept-Language header.</param>
        public static void AddCors(this IServiceCollection services, string policyName, AppSettings appSettings)
        {
            var corsOrigins = GetCorsOrigins(appSettings);
            services.AddCors(options =>
            {
                options.AddPolicy(policyName,
                    policy =>
                    {
                        if (corsOrigins.Count > 0)
                            policy.WithOrigins(corsOrigins.ToArray())
                            .AllowAnyHeader()
                            .AllowAnyMethod();
                        else
                            policy.AllowAnyOrigin()
                            .AllowAnyHeader()
                            .AllowAnyMethod();
                    });
            });
        }

        static List<string> GetCorsOrigins(AppSettings appSettings)
        {
            List<string> corsOrigins = new();
            if (appSettings.Authentication.UseJWTSchemes)
            {
                foreach (var scheme in appSettings.Authentication.Schemes)
                {
                    if (!string.IsNullOrEmpty(scheme.AllowedCorsOrigins))
                    {
                        var origins = scheme.AllowedCorsOrigins.Split(",").Distinct().ToList();
                        foreach (var origin in origins)
                        {
                            if (!string.IsNullOrEmpty(origin) && !corsOrigins.Contains(origin))
                                corsOrigins.Add(origin);
                        }
                    }
                }
            }
            else
            {
                foreach (var scheme in appSettings.Authentication.ReferenceTokenSchemes)
                {
                    if (!string.IsNullOrEmpty(scheme.AllowedCorsOrigins))
                    {
                        var origins = scheme.AllowedCorsOrigins.Split(",").Distinct().ToList();
                        foreach (var origin in origins)
                        {
                            if (!corsOrigins.Contains(origin))
                                corsOrigins.Add(origin);
                        }
                    }
                }
            }
            return corsOrigins;
        }
    }
}
