using Helix6.Base.Culture;
using Microsoft.AspNetCore.Localization;
using System.Globalization;

namespace InfoportOneAdmon.Back.Api.Extensions
{
    public static class CultureConfiguration
    {
        /// <summary>
        /// Adds cultures configuration.
        /// </summary>
        /// <param name="services"></param>
        /// <param name="supportedCultures">List of supported cultures for Accept-Language header.</param>
        public static void AddCultures(this IServiceCollection services, List<CultureInfo> supportedCultures)
        {
            services.AddLocalization(options => options.ResourcesPath = "");
            services.Configure<RequestLocalizationOptions>(options =>
            {
                options.DefaultRequestCulture = new RequestCulture("es-ES");
                options.SupportedCultures = supportedCultures;
                options.SupportedUICultures = supportedCultures;
                options.RequestCultureProviders.Clear();
                options.RequestCultureProviders.Add(new AcceptLanguageCultureProvider());
            });
        }
    }
}
