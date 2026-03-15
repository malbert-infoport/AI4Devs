using Npgsql;
using InfoportOneAdmon.Back.Api.IntegrationTests.Infrastructure;

namespace InfoportOneAdmon.Back.Api.IntegrationTests.Scenarios;

[Collection("IntegrationTests")]
public sealed class DatabaseInitializationIntegrationTests
{
    private readonly PostgresContainerFixture _fixture;

    public DatabaseInitializationIntegrationTests(PostgresContainerFixture fixture)
    {
        _fixture = fixture;
    }

    [Fact]
    [Trait("Category", "Critical")]
    public async Task DbUp_CreatesExpectedSchemasAndTables_OnApiStartup()
    {
        using var factory = new IntegrationTestFactory(_fixture.ConnectionString);
        using var client = factory.CreateClient();

        var swaggerResponse = await client.GetAsync("/swagger/v1/swagger.json");
        swaggerResponse.EnsureSuccessStatusCode();

        await using var connection = new NpgsqlConnection(_fixture.ConnectionString);
        await connection.OpenAsync();

        var existsOrganization = await TableExistsAsync(connection, "Admon", "Organization");
        var existsSecurityUser = await TableExistsAsync(connection, "Helix6_Security", "SecurityUser");

        Assert.True(existsOrganization);
        Assert.True(existsSecurityUser);
    }

    private static async Task<bool> TableExistsAsync(NpgsqlConnection connection, string schema, string table)
    {
        await using var command = new NpgsqlCommand(@"
SELECT EXISTS (
  SELECT 1
  FROM information_schema.tables
  WHERE table_schema = @schema
    AND table_name = @table
);", connection);

        command.Parameters.AddWithValue("schema", schema);
        command.Parameters.AddWithValue("table", table);

        var result = await command.ExecuteScalarAsync();
        return result is bool exists && exists;
    }
}
