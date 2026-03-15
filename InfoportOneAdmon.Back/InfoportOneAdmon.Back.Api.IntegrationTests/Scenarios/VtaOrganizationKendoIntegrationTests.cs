using System.Text;
using System.Text.Json;
using InfoportOneAdmon.Back.Api.IntegrationTests.Infrastructure;

namespace InfoportOneAdmon.Back.Api.IntegrationTests.Scenarios;

[Collection("IntegrationTests")]
public sealed class VtaOrganizationKendoIntegrationTests
{
    private readonly PostgresContainerFixture _fixture;

    public VtaOrganizationKendoIntegrationTests(PostgresContainerFixture fixture)
    {
        _fixture = fixture;
    }

    [Fact]
    [Trait("Category", "Critical")]
    public async Task VtaOrganizationGetAllKendoFilter_ReturnsPagedResults()
    {
        using var factory = new IntegrationTestFactory(_fixture.ConnectionString, allowAllPermissions: true);
        using var client = factory.CreateClient();

        await InitializeDatabaseAsync(client);

        var suffix = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
        await InsertOrganizationAsync(client, $"Kendo Page A {suffix}", $"IT-KP-A-{suffix}");
        await InsertOrganizationAsync(client, $"Kendo Page B {suffix}", $"IT-KP-B-{suffix}");
        await InsertOrganizationAsync(client, $"Kendo Page C {suffix}", $"IT-KP-C-{suffix}");

        var payload = new
        {
            data = new
            {
                page = 1,
                pageSize = 2,
                skip = 0,
                take = 2,
                sort = new[]
                {
                    new { field = "name", dir = "asc" }
                }
            }
        };

        var response = await client.PutAsync(
            "/api/VTA_Organization/GetAllKendoFilter",
            BuildJsonContent(payload));

        var body = await response.Content.ReadAsStringAsync();
        Assert.True(response.IsSuccessStatusCode, $"Kendo paged query failed. Body={body}");

        using var document = JsonDocument.Parse(body);
        var list = GetPropertyCaseInsensitive(document.RootElement, "list");
        var count = GetPropertyCaseInsensitive(document.RootElement, "count").GetInt32();

        Assert.Equal(JsonValueKind.Array, list.ValueKind);
        Assert.Equal(2, list.GetArrayLength());
        Assert.True(count >= 3, $"Expected at least 3 total rows, got {count}. Body={body}");
    }

    [Fact]
    [Trait("Category", "Critical")]
    public async Task VtaOrganizationGetAllKendoFilter_AppliesFilterAndSort()
    {
        using var factory = new IntegrationTestFactory(_fixture.ConnectionString, allowAllPermissions: true);
        using var client = factory.CreateClient();

        await InitializeDatabaseAsync(client);

        var suffix = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
        await InsertOrganizationAsync(client, $"Sortable Org Alpha {suffix}", $"IT-KS-A-{suffix}");
        await InsertOrganizationAsync(client, $"Sortable Org Gamma {suffix}", $"IT-KS-G-{suffix}");
        await InsertOrganizationAsync(client, $"Unrelated Org {suffix}", $"IT-KS-U-{suffix}");

        var payload = new
        {
            data = new
            {
                page = 1,
                pageSize = 10,
                skip = 0,
                take = 10,
                sort = new[]
                {
                    new { field = "name", dir = "desc" }
                },
                filter = new
                {
                    logic = "and",
                    filters = new[]
                    {
                        new { field = "name", @operator = "contains", value = "Sortable Org" }
                    }
                }
            }
        };

        var response = await client.PutAsync(
            "/api/VTA_Organization/GetAllKendoFilter",
            BuildJsonContent(payload));

        var body = await response.Content.ReadAsStringAsync();
        Assert.True(response.IsSuccessStatusCode, $"Kendo filter/sort query failed. Body={body}");

        using var document = JsonDocument.Parse(body);
        var list = GetPropertyCaseInsensitive(document.RootElement, "list");
        var count = GetPropertyCaseInsensitive(document.RootElement, "count").GetInt32();

        Assert.Equal(2, count);
        Assert.Equal(2, list.GetArrayLength());

        var names = list.EnumerateArray()
            .Select(item => GetPropertyCaseInsensitive(item, "name").GetString() ?? string.Empty)
            .ToList();

        Assert.All(names, name => Assert.Contains("Sortable Org", name, StringComparison.OrdinalIgnoreCase));
        var expectedOrder = names.OrderByDescending(n => n, StringComparer.OrdinalIgnoreCase).ToList();
        Assert.Equal(expectedOrder, names);
    }

    [Fact]
    [Trait("Category", "Critical")]
    public async Task VtaOrganizationGetAllKendoFilter_IncludeDeleted_TogglesDeletedRowsVisibility()
    {
        using var factory = new IntegrationTestFactory(_fixture.ConnectionString, allowAllPermissions: true);
        using var client = factory.CreateClient();

        await InitializeDatabaseAsync(client);

        var suffix = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
        var inserted = await InsertOrganizationAsync(client, $"IncludeDeleted Org {suffix}", $"IT-KD-{suffix}");
        var organizationId = GetPropertyCaseInsensitive(inserted, "id").GetInt32();

        var deleteResponse = await client.DeleteAsync($"/api/Organization/DeleteUndeleteLogicById?id={organizationId}");
        var deleteBody = await deleteResponse.Content.ReadAsStringAsync();
        Assert.True(deleteResponse.IsSuccessStatusCode, $"Soft delete failed. Body={deleteBody}");

        var payload = new
        {
            data = new
            {
                page = 1,
                pageSize = 50,
                skip = 0,
                take = 50,
                filter = new
                {
                    logic = "and",
                    filters = new[]
                    {
                        new { field = "id", @operator = "eq", value = organizationId }
                    }
                }
            }
        };

        var withoutDeletedResponse = await client.PutAsync(
            "/api/VTA_Organization/GetAllKendoFilter",
            BuildJsonContent(payload));
        var withoutDeletedBody = await withoutDeletedResponse.Content.ReadAsStringAsync();
        Assert.True(withoutDeletedResponse.IsSuccessStatusCode, $"Kendo query without includeDeleted failed. Body={withoutDeletedBody}");

        using var withoutDeletedDocument = JsonDocument.Parse(withoutDeletedBody);
        var withoutDeletedCount = GetPropertyCaseInsensitive(withoutDeletedDocument.RootElement, "count").GetInt32();
        Assert.Equal(0, withoutDeletedCount);

        var withDeletedResponse = await client.PutAsync(
            "/api/VTA_Organization/GetAllKendoFilter?includeDeleted=true",
            BuildJsonContent(payload));
        var withDeletedBody = await withDeletedResponse.Content.ReadAsStringAsync();
        Assert.True(withDeletedResponse.IsSuccessStatusCode, $"Kendo query with includeDeleted failed. Body={withDeletedBody}");

        using var withDeletedDocument = JsonDocument.Parse(withDeletedBody);
        var withDeletedCount = GetPropertyCaseInsensitive(withDeletedDocument.RootElement, "count").GetInt32();
        Assert.Equal(1, withDeletedCount);

        var withDeletedList = GetPropertyCaseInsensitive(withDeletedDocument.RootElement, "list");
        var item = withDeletedList.EnumerateArray().Single();
        var deletedAt = GetPropertyCaseInsensitive(item, "auditDeletionDate");
        Assert.Equal(JsonValueKind.String, deletedAt.ValueKind);
    }

    private async Task InitializeDatabaseAsync(HttpClient client)
    {
        var swaggerResponse = await client.GetAsync("/swagger/v1/swagger.json");
        swaggerResponse.EnsureSuccessStatusCode();
        await _fixture.ResetDatabaseAsync();
        await EnsureCitextExtensionAsync(_fixture.ConnectionString);
    }

    private static async Task<JsonElement> InsertOrganizationAsync(HttpClient client, string name, string taxId)
    {
        var getNewEntityResponse = await client.GetAsync("/api/Organization/GetNewEntity");
        getNewEntityResponse.EnsureSuccessStatusCode();

        var getNewEntityBody = await getNewEntityResponse.Content.ReadAsStringAsync();
        using var getNewEntityDoc = JsonDocument.Parse(getNewEntityBody);
        var securityCompanyId = GetPropertyCaseInsensitive(getNewEntityDoc.RootElement, "securityCompanyId").GetInt32();

        var payload = new
        {
            id = 0,
            securityCompanyId,
            groupId = (int?)null,
            name,
            acronym = "KENDO",
            taxId,
            address = "Kendo street 1",
            city = "Valencia",
            postalCode = "46001",
            country = "Spain",
            contactEmail = "kendo.integration@test.local",
            contactPhone = "+34 900 000 001",
            organization_ApplicationModule = Array.Empty<object>()
        };

        var response = await client.PostAsync("/api/Organization/Insert?reloadView=true", BuildJsonContent(payload));
        var body = await response.Content.ReadAsStringAsync();
        Assert.True(response.IsSuccessStatusCode, $"Insert for Kendo setup failed. Body={body}");

        using var document = JsonDocument.Parse(body);
        return document.RootElement.Clone();
    }

    private static StringContent BuildJsonContent(object payload)
    {
        var json = JsonSerializer.Serialize(payload);
        return new StringContent(json, Encoding.UTF8, "application/json");
    }

    private static async Task EnsureCitextExtensionAsync(string connectionString)
    {
        await using var connection = new Npgsql.NpgsqlConnection(connectionString);
        await connection.OpenAsync();

        await using var command = new Npgsql.NpgsqlCommand("CREATE EXTENSION IF NOT EXISTS citext;", connection);
        await command.ExecuteNonQueryAsync();
        await connection.ReloadTypesAsync();
        Npgsql.NpgsqlConnection.ClearAllPools();
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
}