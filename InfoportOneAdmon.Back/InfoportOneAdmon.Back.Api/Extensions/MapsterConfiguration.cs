using Mapster;

namespace InfoportOneAdmon.Back.Api.Extensions
{
    public static class MapsterConfiguration
    {
        public static void AddMapster(this IServiceCollection services)
        {
            //Evita los ciclos al mapear entidades
            TypeAdapterConfig.GlobalSettings.Default.PreserveReference(true);

        }
    }
}
