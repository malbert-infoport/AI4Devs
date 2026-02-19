using System;
using DbUp;
using DbUp.Engine.Output;
using Helix6.Base.Domain.Configuration;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Npgsql;

namespace InfoportOneAdmon.Back.Api.Infrastructure
{
    internal class DbUpLoggerAdapter : IUpgradeLog
    {
        private readonly ILogger _logger;
        public DbUpLoggerAdapter(ILogger logger) => _logger = logger;
        public void LogTrace(string format, params object[] args) => _logger.LogTrace(format, args);
        public void LogDebug(string format, params object[] args) => _logger.LogDebug(format, args);
        public void LogInformation(string format, params object[] args) => _logger.LogInformation(format, args);
        public void LogWarning(string format, params object[] args) => _logger.LogWarning(format, args);
        public void LogError(string format, params object[] args) => _logger.LogError(format, args);
        public void LogError(Exception ex, string format, params object[] args) => _logger.LogError(ex, format, args);
    }

    public static class DbUpRunner
    {
        public static void Run(WebApplicationBuilder builder, WebApplication app, AppSettings appSettings)
        {
            using var serviceProvider = app.Services.CreateScope();
            var logger = serviceProvider.ServiceProvider.GetRequiredService<ILogger<Program>>();

            logger.LogInformation("...Aplicando migraciones en BBDD ....");

            var connectionString = appSettings.ConnectionStrings?.DefaultConnection;
            if (string.IsNullOrWhiteSpace(connectionString))
            {
                logger.LogError("DefaultConnection is not configured in ConnectionStrings");
                throw new Exception("DefaultConnection is not configured");
            }

            var csBuilder = new NpgsqlConnectionStringBuilder(connectionString);
            string databaseName = csBuilder.Database;

            if (string.IsNullOrEmpty(databaseName))
            {
                logger.LogError("Connection string does not specify a database name");
                throw new Exception("Connection string does not specify a database name");
            }

            string envName = builder.Environment.EnvironmentName;

            if (envName == "Development" || envName == "Local")
            {
                logger.LogInformation($"{databaseName}: No se aplican migraciones en entorno {envName}");
                return;
            }

            try
            {
                const string journalSchema = "DBUp";
                const string journalTable = "schemaversions";
                const long advisoryLockId = 847362514;

                using var connection = new NpgsqlConnection(connectionString);
                // Control whether automatic CREATE DATABASE is allowed
                var allowCreate = string.Equals(Environment.GetEnvironmentVariable("HELIX6_ALLOW_CREATE_DB"), "true", StringComparison.OrdinalIgnoreCase);
                try
                {
                    connection.Open();
                }
                catch (PostgresException pex)
                {
                    if (pex.SqlState == "3D000") // invalid_catalog_name: database does not exist
                    {
                        if (!allowCreate)
                        {
                            logger.LogError(pex, "{db}: Database does not exist and HELIX6_ALLOW_CREATE_DB is not true. Aborting.", databaseName);
                            throw;
                        }

                        logger.LogWarning("{db}: Database does not exist. HELIX6_ALLOW_CREATE_DB=true, attempting to create it using maintenance DB.", databaseName);

                        var maintenanceCsBuilder = new NpgsqlConnectionStringBuilder(connectionString)
                        {
                            Database = "postgres"
                        };

                        using var maintenanceConnection = new NpgsqlConnection(maintenanceCsBuilder.ConnectionString);
                        maintenanceConnection.Open();

                        using (var checkCmd = new NpgsqlCommand("SELECT 1 FROM pg_database WHERE datname = @dbName", maintenanceConnection))
                        {
                            checkCmd.Parameters.AddWithValue("dbName", databaseName);
                            var exists = checkCmd.ExecuteScalar() != null;
                            if (!exists)
                            {
                                using var createCmd = new NpgsqlCommand($"CREATE DATABASE \"{databaseName}\";", maintenanceConnection);
                                createCmd.ExecuteNonQuery();
                                logger.LogInformation("{db}: Database created.", databaseName);
                            }
                            else
                            {
                                logger.LogInformation("{db}: Database not found earlier but now exists.", databaseName);
                            }
                        }

                        // Try opening the target connection again
                        connection.Open();
                    }
                    else
                    {
                        throw;
                    }
                }

                logger.LogInformation($"{databaseName}: Intentando adquirir advisory lock...");

                using (var lockCmd = new NpgsqlCommand("SELECT pg_advisory_lock(@lockId);", connection))
                {
                    lockCmd.Parameters.AddWithValue("lockId", advisoryLockId);
                    lockCmd.ExecuteNonQuery();
                }

                logger.LogInformation($"{databaseName}: Advisory lock adquirido.");

                try
                {
                    using (var cmd = new NpgsqlCommand($"CREATE SCHEMA IF NOT EXISTS \"{journalSchema}\";", connection))
                    {
                        cmd.ExecuteNonQuery();
                    }

                    var upgrader = DeployChanges.To
                        .PostgresqlDatabase(connectionString)
                        .JournalToPostgresqlTable(journalSchema, journalTable)
                        .WithScriptsEmbeddedInAssembly(
                            typeof(InfoportOneAdmon.Back.DB.Migrations.Marker).Assembly,
                            s => s.StartsWith("InfoportOneAdmon.Back.DB.Scripts"))
                        .LogTo(new DbUpLoggerAdapter(logger))
                        .Build();

                    var result = upgrader.PerformUpgrade();

                    if (!result.Successful)
                    {
                        logger.LogError(result.Error, $"{databaseName}: Error al aplicar migraciones de base de datos");
                        throw new Exception("Error al aplicar migraciones");
                    }

                    logger.LogInformation($"{databaseName}: Migraciones aplicadas correctamente");
                }
                finally
                {
                    using var unlockCmd = new NpgsqlCommand("SELECT pg_advisory_unlock(@lockId);", connection);
                    unlockCmd.Parameters.AddWithValue("lockId", advisoryLockId);
                    unlockCmd.ExecuteNonQuery();

                    logger.LogInformation($"{databaseName}: Advisory lock liberado.");
                }

                logger.LogInformation("...Fin Aplicando migraciones en BBDD ....");
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "Excepción durante la ejecución de migraciones");
                throw;
            }
        }
    }
}
