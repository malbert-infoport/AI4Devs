using Helix6.Base.Culture;
using Microsoft.OpenApi.Models;
using System.Globalization;

namespace InfoportOneAdmon.Back.Api.Extensions
{
    public static class SwaggerConfiguration
    {
        /// <summary>
        /// Adds Swagger configuration.
        /// </summary>
        /// <param name="services"></param>
        /// <param name="supportedCultures">List of supported cultures for Accept-Language header.</param>
        public static void AddSwagger(this IServiceCollection services, List<CultureInfo>? supportedCultures = null)
        {
            services.AddSwaggerGen(options =>
            {
                var scheme = new OpenApiSecurityScheme
                {
                    Name = "Authorization",
                    Description = "Enter the Bearer Authorization string as following: `Bearer GeneratedToken`",
                    In = ParameterLocation.Header,
                    Type = SecuritySchemeType.ApiKey,
                    Scheme = "Bearer"
                };

                options.AddSecurityDefinition("Bearer", scheme);

                options.AddSecurityRequirement(new OpenApiSecurityRequirement
                {
                    {
                        new OpenApiSecurityScheme
                        {
                            Name = "Bearer",
                            In = ParameterLocation.Header,
                            Reference = new OpenApiReference
                            {
                                Id = "Bearer",
                                Type = ReferenceType.SecurityScheme
                            }
                        },
                    new List<string>()
                    }
                });
                options.OperationFilter<AcceptlanguageSwaggerAttribute>(supportedCultures);
            });
        }
    }
}
