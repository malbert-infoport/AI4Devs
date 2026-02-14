using Helix6.Base.Domain.Resources;
using Microsoft.Extensions.Localization;

namespace InfoportOneAdmon.Back.Api.Resources
{
    public class SharedResource : ISharedResource
    {
        private readonly IStringLocalizer _localizer;

        public SharedResource(IStringLocalizer<SharedResource> localizer)
        {
            _localizer = localizer;
        }

        public string? GetTranslation(string key, params string[] parameters)
        {
            var translation = _localizer[key].ToString();

            if (translation != null && parameters != null && parameters.Length > 0)
                translation = String.Format(translation, parameters);

            return translation;

        }
    }
}
