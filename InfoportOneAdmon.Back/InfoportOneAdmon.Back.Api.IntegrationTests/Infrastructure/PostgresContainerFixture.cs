using Npgsql;
using Respawn;
using Respawn.Graph;
using Testcontainers.PostgreSql;

namespace InfoportOneAdmon.Back.Api.IntegrationTests.Infrastructure;

public sealed class PostgresContainerFixture : IAsyncLifetime
{
    private readonly PostgreSqlContainer _container;
    private Respawner? _respawner;
    private string? _testConnectionString;

    public PostgresContainerFixture()
    {
        _container = new PostgreSqlBuilder("postgres:16")
            .WithDatabase("infoportoneadmon_it")
            .WithUsername("postgres")
            .WithPassword("postgres")
            .Build();
    }

    public string ConnectionString => _testConnectionString ?? _container.GetConnectionString();

    public async Task InitializeAsync()
    {
        await _container.StartAsync();

        var csBuilder = new NpgsqlConnectionStringBuilder(_container.GetConnectionString())
        {
            Pooling = false,
            IncludeErrorDetail = true
        };
        _testConnectionString = csBuilder.ConnectionString;

        await using (var conn = new NpgsqlConnection(ConnectionString))
        {
            await conn.OpenAsync();
            await using var cmd = new NpgsqlCommand("CREATE EXTENSION IF NOT EXISTS citext;", conn);
            await cmd.ExecuteNonQueryAsync();
            await conn.ReloadTypesAsync();
        }

        NpgsqlConnection.ClearAllPools();

        Environment.SetEnvironmentVariable("ASPNETCORE_ENVIRONMENT", "Development");
        Environment.SetEnvironmentVariable("HELIX6_ConnectionStrings__DefaultConnection", ConnectionString);
    }

    public async Task ResetDatabaseAsync()
    {
        await using var conn = new NpgsqlConnection(ConnectionString);
        await conn.OpenAsync();

        _respawner ??= await Respawner.CreateAsync(conn, new RespawnerOptions
        {
            DbAdapter = DbAdapter.Postgres,
            SchemasToInclude = new[] { "Admon" },
            TablesToIgnore = new[] { new Table("schemaversions", "DBUp") }
        });

        await _respawner.ResetAsync(conn);
    }

    public async Task DisposeAsync()
    {
        Environment.SetEnvironmentVariable("HELIX6_ConnectionStrings__DefaultConnection", null);
        await _container.DisposeAsync();
    }
}
