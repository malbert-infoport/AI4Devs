using InfoportOneAdmon.Back.Api.Attachments;
using InfoportOneAdmon.Back.Api.Resources;
using InfoportOneAdmon.Back.Data.DataModel;
using InfoportOneAdmon.Back.Entities.Views.Base;
using InfoportOneAdmon.Back.Services.Base;
using Helix6.Base.Application;
using Helix6.Base.Attachments;
using Helix6.Base.Domain.BaseInterfaces;
using Helix6.Base.Domain.Configuration;
using Helix6.Base.Domain.Endpoints;
using Helix6.Base.Domain.Resources;
using Helix6.Base.Domain.Security;
using Helix6.Base.Endpoints;
using Helix6.Base.Repository;
using Helix6.Base.Service;
using Microsoft.EntityFrameworkCore;
using System.Data;
using System.Reflection;

namespace InfoportOneAdmon.Back.Api.Extensions
{
    public static class DependencyInjection
    {
        public static void AddDependencyInjection(this IServiceCollection services, IApplicationContext? applicationContext)
        {
            //Contexto de EF
            services.AddScoped<DbContext>(c =>
            {
                var appSettings = c.GetRequiredService<AppSettings>();
                return new EntityModel(appSettings.ConnectionStrings.DefaultConnection);
            });
            //Conexión utilizada por Dapper
            services.AddScoped<IDbConnection>(c =>
            {
                var efModel = c.GetRequiredService<DbContext>();
                return efModel.Database.GetDbConnection();
            });
            //Contexto de aplicación
            if (applicationContext != null)
                services.AddSingleton(c => applicationContext);

            //Contexto del usuario que ha accedido a la API
            services.AddScoped<IUserContext, UserContext>();
            services.AddScoped<IUserPermissions, PermissionsService>();

            services.AddScoped(typeof(IBaseEFRepository<>), typeof(BaseEFRepository<>));
            services.AddScoped(typeof(IBaseDapperRepository<>), typeof(BaseDapperRepository<>));
            services.AddScoped(typeof(IBaseRepository<>), typeof(BaseRepository<>));
            services.AddScoped(typeof(IBaseVersionRepository<>), typeof(BaseVersionRepository<>));
            services.AddScoped(typeof(IBaseValidityRepository<>), typeof(BaseValidityRepository<>));
            services.AddScoped(typeof(IBaseService<,,>), typeof(BaseService<,,>));
            services.AddScoped(typeof(IBaseVersionService<,,>), typeof(BaseService<,,>));
            services.AddScoped(typeof(IBaseValidityService<,,>), typeof(BaseService<,,>));
            services.AddScoped(typeof(IBaseAttachmentService<AttachmentView>), typeof(AttachmentService));
            services.AddScoped(typeof(IAttachmentView), typeof(AttachmentView));

            //You can use AttachmentDBSource, AttachmentDriveSource or you can implement your own way to store attachments implementing the IAttachmentSource interface.
            //Comment/uncomment the following two lines in order to use AttachmentDBSource or AttachmentDriveSource.
            services.AddScoped(typeof(IAttachmentSource<AttachmentView>), typeof(AttachmentDBSource));
            //services.AddScoped(typeof(IAttachmentSource<AttachmentView>), typeof(Attachments.AttachmentDriveSource));

            //Mapeo entre la grid de Kendo y un IGenericFilter, por defecto HelixFilter
            services.AddSingleton(typeof(IGenericFilterMapping), typeof(HelixFilterMapping));
            //Recursos
            services.AddSingleton(typeof(ISharedResource), typeof(SharedResource));
        }

        public static void AddServicesRepositories(this IServiceCollection services, IApplicationContext? applicationContext)
        {
            var entryAssembly = Assembly.GetEntryAssembly();
            if (entryAssembly != null)
            {
                if (applicationContext != null)
                {
                    var assemblyNames = entryAssembly.GetReferencedAssemblies().Where(x => x.Name != null && x.Name.StartsWith(applicationContext.ApplicationName));
                    foreach (var asName in assemblyNames)
                    {
                        var ass = Assembly.Load(asName);
                    }
                }
            }

            // Registro de servicios y repositorios
            var types = AppDomain.CurrentDomain.GetAssemblies()
                .SelectMany(s => s.GetTypes())
                .Where(p => p.IsClass && !p.IsGenericType && p.BaseType != null &&
                        (
                            p.BaseType.Name.Equals(typeof(BaseRepository<>).Name) ||
                            p.BaseType.Name.Equals(typeof(BaseVersionRepository<>).Name) ||
                            p.BaseType.Name.Equals(typeof(BaseValidityRepository<>).Name) ||
                            p.BaseType.Name.Equals(typeof(BaseService<,,>).Name) ||
                            p.BaseType.Name.Equals(typeof(BaseVersionService<,,>).Name) ||
                            p.BaseType.Name.Equals(typeof(BaseValidityService<,,>).Name)
                        )
                       );
            foreach (var t in types)
            {
                var interfaces = t.GetInterfaces();
                var interfaceRepository = interfaces.Where(i => i.Name != typeof(IBaseRepository<>).Name &&
                                                                i.Name != typeof(IBaseValidityRepository<>).Name &&
                                                                i.Name != typeof(IBaseVersionRepository<>).Name)
                    .FirstOrDefault();
                if (interfaces.Select(i => i.Name).Contains(typeof(IBaseRepository<>).Name) && interfaceRepository != null)
                {
                    services.AddScoped(interfaceRepository, t);
                }
                else
                {
                    services.AddScoped(t);
                }
            }
        }
    }
}