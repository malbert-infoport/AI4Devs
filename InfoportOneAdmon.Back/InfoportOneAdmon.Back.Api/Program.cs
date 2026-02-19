using System.Globalization;
using System.IO;
using System.Text.Json.Serialization;
using Helix6.Base.Domain.Configuration;
using Helix6.Base.Middleware;
using InfoportOneAdmon.Back.Api.Endpoints;
using InfoportOneAdmon.Back.Api.Endpoints.Base;
using InfoportOneAdmon.Back.Api.Endpoints.Base.Generator;
using InfoportOneAdmon.Back.Api.Extensions;
using InfoportOneAdmon.Back.Api.Infrastructure;
using InfoportOneAdmon.Back.Data.DataModel;
using Microsoft.AspNetCore.Http.Json;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Npgsql;
using Serilog;
using Swashbuckle.AspNetCore.SwaggerUI;

var builder = WebApplication.CreateBuilder(args);

//Settings configuration and environment variables
var environment = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT");
var configBuilder = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
                    .AddJsonFile($"appsettings.{environment ?? "Production"}.json", optional: true)
                    .AddEnvironmentVariables(prefix: "HELIX6_")
                    .Build();

//Logging configuration with Serilog
builder.Host.UseSerilog((context, configuration)
    => configuration.ReadFrom.Configuration(context.Configuration, sectionName: "Serilog"));

//Localization
List<CultureInfo> supportedCultures = new()
    {
        new CultureInfo("es-ES"),
        new CultureInfo("en-GB")
    };
builder.Services.AddCultures(supportedCultures);

//Appsettings binding
var appSettings = new AppSettings();
configBuilder.Bind(appSettings);
builder.Services.AddSingleton(c => { return appSettings; });

builder.Services.AddHttpContextAccessor();

//Authentication and Authorization
builder.Services.AddAuthentication(appSettings, environment);

//Dependency Injection
var applicationContext = appSettings.GetApplicationContext();
builder.Services.AddDependencyInjection(applicationContext);
builder.Services.AddServicesRepositories(applicationContext);

//Inyectamos el contexto de EF para usar sin repositorio la obtenci�n de integraciones de VAlenciaport
var defaultConnection = builder.Configuration.GetSection("ConnectionStrings:DefaultConnection").Value;
if (defaultConnection != null)
{
    //Inyecto el contexto como scope
    builder.Services.AddDbContext<EntityModel>(options =>
        options.UseNpgsql(defaultConnection, npgsqlOptions =>
            // Usar la tabla de historial de migraciones en el esquema 'Admon'
            npgsqlOptions.MigrationsHistoryTable("__EFMigrationsHistory", "Admon")
        )
        // Suprimir advertencia de cambios pendientes en el modelo
        // Esto es necesario cuando se usa scaffolding (Database-First) junto con migraciones (Code-First)
        // Los scripts SQL embebidos son la fuente de verdad
        .ConfigureWarnings(warnings =>
            warnings.Ignore(Microsoft.EntityFrameworkCore.Diagnostics.RelationalEventId.PendingModelChangesWarning)
        )
    );
}

//Mapster
builder.Services.AddMapster();

//Serialization: Ignore NULL
builder.Services.Configure<JsonOptions>(options =>
{
    options.SerializerOptions.DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull;
});

//CORS
var corsPolicyName = "AllowedOrigins";
builder.Services.AddCors(corsPolicyName, appSettings);

builder.Services.AddEndpointsApiExplorer();

//Swagger
builder.Services.AddSwagger(supportedCultures);

//Problem details
builder.Services.AddProblemDetails();

var app = builder.Build();

app.UseStaticFiles();

app.UseExceptionHandler();
app.UseStatusCodePages();

//Serilog logging with request data
app.UseSerilogRequestLogging();

app.UseRequestLocalization();
app.UseCors(corsPolicyName);
app.UseAuthentication();
app.UseAuthorization();

//HelixException middleware
app.UseMiddleware<HelixExceptionsMiddleware>();

//Endpoints
app.MapGenericEndpoints();
app.MapSecurityEndpoints();
app.MapAttachmentEndpoints();
app.MapVTA_AttachmentEndpoints();
app.MapSpecificEndpoints();

app.UseSwagger();
app.UseSwaggerUI(c =>
{
    c.EnableFilter();
    c.InjectStylesheet("/css/swagger-custom.css");
    c.DocExpansion(DocExpansion.None);
});

// Runtime policy: apply migrations on startup via DbUp runner
DbUpRunner.Run(builder, app, appSettings);

app.Run();
