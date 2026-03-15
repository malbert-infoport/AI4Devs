using System.Text;
using System.Text.Json;
using InfoportOneAdmon.Back.Api.IntegrationTests.Infrastructure;
using Npgsql;

namespace InfoportOneAdmon.Back.Api.IntegrationTests.Scenarios;

[Collection("IntegrationTests")]
public sealed class ReliabilityIntegrationTests
{
    private readonly PostgresContainerFixture _fixture;

    public ReliabilityIntegrationTests(PostgresContainerFixture fixture)
    {
        _fixture = fixture;
    }

    [Fact]
    [Trait("Category", "Critical")]
    public async Task DbUp_IsIdempotent_WhenApiStartsMultipleTimes()
    {
        using (var firstFactory = new IntegrationTestFactory(_fixture.ConnectionString, allowAllPermissions: true))
        using (var firstClient = firstFactory.CreateClient())
        {
            var firstSwagger = await firstClient.GetAsync("/swagger/v1/swagger.json");
            firstSwagger.EnsureSuccessStatusCode();
        }

        var firstJournalCount = await GetDbUpJournalCountAsync(_fixture.ConnectionString);

        using (var secondFactory = new IntegrationTestFactory(_fixture.ConnectionString, allowAllPermissions: true))
        using (var secondClient = secondFactory.CreateClient())
        {
            var secondSwagger = await secondClient.GetAsync("/swagger/v1/swagger.json");
            secondSwagger.EnsureSuccessStatusCode();
        }

        var secondJournalCount = await GetDbUpJournalCountAsync(_fixture.ConnectionString);

        Assert.True(firstJournalCount > 0, "Expected DBUp journal to contain executed scripts after first startup.");
        Assert.Equal(firstJournalCount, secondJournalCount);
    }

    [Fact]
    [Trait("Category", "Critical")]
    public async Task OrganizationInsert_AllowsOnlyOneRow_WhenTwoConcurrentRequestsUseSameUniqueData()
    {
        using var factory = new IntegrationTestFactory(_fixture.ConnectionString, allowAllPermissions: true);
        using var client = factory.CreateClient();

        var swaggerResponse = await client.GetAsync("/swagger/v1/swagger.json");
        swaggerResponse.EnsureSuccessStatusCode();
        await _fixture.ResetDatabaseAsync();
        await EnsureCitextExtensionAsync(_fixture.ConnectionString);

        var uniqueSuffix = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
        var duplicatedName = $"Concurrent Org {uniqueSuffix}";
        var duplicatedTaxId = $"IT-CON-{uniqueSuffix}";

        var securityCompanyIdA = await GetNewSecurityCompanyIdAsync(client);
        var securityCompanyIdB = await GetNewSecurityCompanyIdAsync(client);

        var payloadA = BuildOrganizationInsertPayload(securityCompanyIdA, duplicatedName, duplicatedTaxId);
        var payloadB = BuildOrganizationInsertPayload(securityCompanyIdB, duplicatedName, duplicatedTaxId);

        var taskA = client.PostAsync("/api/Organization/Insert?reloadView=true", BuildJsonContent(payloadA));
        var taskB = client.PostAsync("/api/Organization/Insert?reloadView=true", BuildJsonContent(payloadB));

        var responses = await Task.WhenAll(taskA, taskB);
        var responseBodies = await Task.WhenAll(responses.Select(r => r.Content.ReadAsStringAsync()));

        var successCount = responses.Count(r => r.IsSuccessStatusCode);
        Assert.Equal(1, successCount);

        var storedRows = await CountOrganizationsByNameAndTaxIdAsync(_fixture.ConnectionString, duplicatedName, duplicatedTaxId);
        Assert.Equal(1, storedRows);

        var combinedBodies = string.Join("\n---\n", responseBodies);
        var hasExpectedConflictSignal =
            combinedBodies.Contains("ORGANIZATION_NAME_ALREADY_EXISTS", StringComparison.OrdinalIgnoreCase) ||
            combinedBodies.Contains("ORGANIZATION_TAXID_ALREADY_EXISTS", StringComparison.OrdinalIgnoreCase) ||
            combinedBodies.Contains("duplicate key value", StringComparison.OrdinalIgnoreCase) ||
            combinedBodies.Contains("unique", StringComparison.OrdinalIgnoreCase);

        Assert.True(
            hasExpectedConflictSignal,
            $"Expected a uniqueness/validation conflict signal in concurrent insert responses. Bodies={combinedBodies}");
    }

    private static object BuildOrganizationInsertPayload(int securityCompanyId, string name, string taxId)
    {
        return new
        {
            id = 0,
            securityCompanyId,
            groupId = (int?)null,
            name,
            acronym = "RACE",
            taxId,
            address = "Reliability street 1",
            city = "Valencia",
            postalCode = "46001",
            country = "Spain",
            contactEmail = "reliability@test.local",
            contactPhone = "+34 900 333 333",
            organization_ApplicationModule = Array.Empty<object>()
        };
    }

    private static StringContent BuildJsonContent(object payload)
    {
        var json = JsonSerializer.Serialize(payload);
        return new StringContent(json, Encoding.UTF8, "application/json");
    }

    private static async Task<int> GetNewSecurityCompanyIdAsync(HttpClient client)
    {
        var response = await client.GetAsync("/api/Organization/GetNewEntity");
        response.EnsureSuccessStatusCode();

        var json = await response.Content.ReadAsStringAsync();
        using var document = JsonDocument.Parse(json);
        return GetPropertyCaseInsensitive(document.RootElement, "securityCompanyId").GetInt32();
    }

    private static async Task<int> GetDbUpJournalCountAsync(string connectionString)
    {
        await using var connection = new NpgsqlConnection(connectionString);
        await connection.OpenAsync();

        const string sql = "SELECT COUNT(*) FROM \"DBUp\".\"schemaversions\";";
        await using var command = new NpgsqlCommand(sql, connection);
        var count = await command.ExecuteScalarAsync();

        return Convert.ToInt32(count);
    }

    private static async Task<int> CountOrganizationsByNameAndTaxIdAsync(string connectionString, string name, string taxId)
    {
        await using var connection = new NpgsqlConnection(connectionString);
        await connection.OpenAsync();

        const string sql = @"
SELECT COUNT(*)
FROM ""Admon"".""Organization""
WHERE ""Name"" = @name
    AND ""TaxId"" = @taxId
    AND ""AuditDeletionDate"" IS NULL;";

        await using var command = new NpgsqlCommand(sql, connection);
        command.Parameters.AddWithValue("name", name);
        command.Parameters.AddWithValue("taxId", taxId);

        var count = await command.ExecuteScalarAsync();
        return Convert.ToInt32(count);
    }

    private static JsonElement GetPropertyCaseInsensitive(JsonElement element, string propertyName)
    {
        foreach (var property in element.EnumerateObject())
        {
            if (string.Equals(property.Name, propertyName, StringComparison.OrdinalIgnoreCase))
                return property.Value;
        }

        throw new KeyNotFoundException($"Property '{propertyName}' was not found in JSON element.");
    }

    private static async Task EnsureCitextExtensionAsync(string connectionString)
    {
        await using var connection = new NpgsqlConnection(connectionString);
        await connection.OpenAsync();

        await using var command = new NpgsqlCommand("CREATE EXTENSION IF NOT EXISTS citext;", connection);
        await command.ExecuteNonQueryAsync();
        await connection.ReloadTypesAsync();
        NpgsqlConnection.ClearAllPools();
    }
}
