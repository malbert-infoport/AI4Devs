using System.Net;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using System.Text.Json.Nodes;
using InfoportOneAdmon.Back.Api.IntegrationTests.Infrastructure;

namespace InfoportOneAdmon.Back.Api.IntegrationTests.Scenarios;

[Collection("IntegrationTests")]
public sealed class SecurityConfigurationIntegrationTests
{
    private readonly PostgresContainerFixture _fixture;

    public SecurityConfigurationIntegrationTests(PostgresContainerFixture fixture)
    {
        _fixture = fixture;
    }

    [Fact]
    [Trait("Category", "Critical")]
    public async Task SecurityCleanCache_ReturnsUnauthorizedWithoutAuth_AndOkWhenAuthorized()
    {
        await EnsureApiInitializedAsync();

        using (var unauthorizedFactory = new IntegrationTestFactory(_fixture.ConnectionString))
        using (var unauthorizedClient = unauthorizedFactory.CreateClient())
        {
            var unauthorizedResponse = await unauthorizedClient.DeleteAsync("/api/Security/CleanCache");
            Assert.Equal(HttpStatusCode.Unauthorized, unauthorizedResponse.StatusCode);
        }

        using var authorizedFactory = new IntegrationTestFactory(
            _fixture.ConnectionString,
            enableTestJwtBypass: true,
            allowAllPermissions: true);
        using var authorizedClient = authorizedFactory.CreateClient();
        AddBearerToken(authorizedClient);

        var authorizedResponse = await authorizedClient.DeleteAsync("/api/Security/CleanCache");
        var body = await authorizedResponse.Content.ReadAsStringAsync();

        Assert.True(authorizedResponse.IsSuccessStatusCode, $"Expected authorized CleanCache to succeed. Body={body}");
    }

    [Fact]
    [Trait("Category", "Critical")]
    public async Task SecurityUserConfiguration_GetAndUpdate_PersistsUserValues()
    {
        await EnsureApiInitializedAsync();

        using var factory = new IntegrationTestFactory(
            _fixture.ConnectionString,
            enableTestJwtBypass: true,
            allowAllPermissions: true);
        using var client = factory.CreateClient();
        AddBearerToken(client);

        var permissionsResponse = await client.GetAsync("/api/Security/GetPermissions");
        permissionsResponse.EnsureSuccessStatusCode();

        var getConfigurationResponse = await client.GetAsync("/api/SecurityUserConfiguration/GetUserConfiguration");
        var getConfigurationBody = await getConfigurationResponse.Content.ReadAsStringAsync();
        Assert.True(getConfigurationResponse.IsSuccessStatusCode, $"GetUserConfiguration failed. Body={getConfigurationBody}");

        var configNode = JsonNode.Parse(getConfigurationBody)?.AsObject();
        Assert.NotNull(configNode);

        var configurationId = configNode!["id"]?.GetValue<int>() ?? 0;
        Assert.True(configurationId > 0, $"Expected configuration id > 0. Body={getConfigurationBody}");

        var uniqueLanguage = "en-GB";
        var updatedPagination = 37;
        var updatedModalPagination = 9;

        configNode["pagination"] = updatedPagination;
        configNode["modalPagination"] = updatedModalPagination;
        configNode["language"] = uniqueLanguage;

        var updateResponse = await client.PutAsync(
            "/api/SecurityUserConfiguration/Update?reloadView=true",
            BuildJsonContent(configNode));
        var updateBody = await updateResponse.Content.ReadAsStringAsync();
        Assert.True(updateResponse.IsSuccessStatusCode, $"Update user configuration failed. Body={updateBody}");

        var getAfterUpdateResponse = await client.GetAsync("/api/SecurityUserConfiguration/GetUserConfiguration");
        var getAfterUpdateBody = await getAfterUpdateResponse.Content.ReadAsStringAsync();
        Assert.True(getAfterUpdateResponse.IsSuccessStatusCode, $"GetUserConfiguration after update failed. Body={getAfterUpdateBody}");

        using var getAfterUpdateDocument = JsonDocument.Parse(getAfterUpdateBody);
        var root = getAfterUpdateDocument.RootElement;

        Assert.Equal(updatedPagination, GetPropertyCaseInsensitive(root, "pagination").GetInt32());
        Assert.Equal(updatedModalPagination, GetPropertyCaseInsensitive(root, "modalPagination").GetInt32());
        Assert.Equal(uniqueLanguage, GetPropertyCaseInsensitive(root, "language").GetString());
    }

    [Fact]
    [Trait("Category", "Critical")]
    public async Task SecurityUserGridConfiguration_InsertUpdateList_ManagesDefaultConfiguration()
    {
        await EnsureApiInitializedAsync();

        using var factory = new IntegrationTestFactory(
            _fixture.ConnectionString,
            enableTestJwtBypass: true,
            allowAllPermissions: true);
        using var client = factory.CreateClient();
        AddBearerToken(client);

        var permissionsResponse = await client.GetAsync("/api/Security/GetPermissions");
        permissionsResponse.EnsureSuccessStatusCode();

        var getNewEntityResponse = await client.GetAsync("/api/SecurityUserGridConfiguration/GetNewEntity");
        var getNewEntityBody = await getNewEntityResponse.Content.ReadAsStringAsync();
        Assert.True(getNewEntityResponse.IsSuccessStatusCode, $"GetNewEntity failed. Body={getNewEntityBody}");

        using var getNewEntityDocument = JsonDocument.Parse(getNewEntityBody);
        var securityUserId = GetPropertyCaseInsensitive(getNewEntityDocument.RootElement, "securityUserId").GetInt32();
        Assert.True(securityUserId > 0, $"Expected SecurityUserId > 0. Body={getNewEntityBody}");

        var uniqueSuffix = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
        var entityName = $"OrganizationGrid{uniqueSuffix}";

        var insertPayload = new
        {
            id = 0,
            securityUserId,
            entity = entityName,
            description = "Grid config integration",
            defaultConfiguration = true,
            configuration = "{\"columns\":[\"name\",\"taxId\"]}"
        };

        var insertResponse = await client.PostAsync(
            "/api/SecurityUserGridConfiguration/Insert?reloadView=true",
            BuildJsonContent(insertPayload));
        var insertBody = await insertResponse.Content.ReadAsStringAsync();
        Assert.True(insertResponse.IsSuccessStatusCode, $"Insert grid configuration failed. Body={insertBody}");

        using var insertDocument = JsonDocument.Parse(insertBody);
        var insertedId = GetPropertyCaseInsensitive(insertDocument.RootElement, "id").GetInt32();
        Assert.True(insertedId > 0);

        var listResponse = await client.GetAsync($"/api/SecurityUserGridConfiguration/GetUserGridConfigurations?entityName={entityName}");
        var listBody = await listResponse.Content.ReadAsStringAsync();
        Assert.True(listResponse.IsSuccessStatusCode, $"List grid configurations failed. Body={listBody}");

        using var listDocument = JsonDocument.Parse(listBody);
        var listItems = listDocument.RootElement;
        Assert.Equal(JsonValueKind.Array, listItems.ValueKind);
        Assert.Single(listItems.EnumerateArray());

        var firstItem = listItems.EnumerateArray().First();
        Assert.True(GetPropertyCaseInsensitive(firstItem, "defaultConfiguration").GetBoolean());

        var updatePayload = new
        {
            id = insertedId,
            securityUserId,
            entity = entityName,
            description = "Grid config integration updated",
            defaultConfiguration = false,
            configuration = "{\"columns\":[\"city\"]}"
        };

        var updateResponse = await client.PutAsync(
            "/api/SecurityUserGridConfiguration/Update?reloadView=true",
            BuildJsonContent(updatePayload));
        var updateBody = await updateResponse.Content.ReadAsStringAsync();
        Assert.True(updateResponse.IsSuccessStatusCode, $"Update grid configuration failed. Body={updateBody}");

        var listAfterUpdateResponse = await client.GetAsync($"/api/SecurityUserGridConfiguration/GetUserGridConfigurations?entityName={entityName}");
        var listAfterUpdateBody = await listAfterUpdateResponse.Content.ReadAsStringAsync();
        Assert.True(listAfterUpdateResponse.IsSuccessStatusCode, $"List after update failed. Body={listAfterUpdateBody}");

        using var listAfterUpdateDocument = JsonDocument.Parse(listAfterUpdateBody);
        var updatedItem = listAfterUpdateDocument.RootElement.EnumerateArray().Single();

        Assert.False(GetPropertyCaseInsensitive(updatedItem, "defaultConfiguration").GetBoolean());
        Assert.Equal("Grid config integration updated", GetPropertyCaseInsensitive(updatedItem, "description").GetString());
    }

    private async Task EnsureApiInitializedAsync()
    {
        using var warmupFactory = new IntegrationTestFactory(_fixture.ConnectionString, allowAllPermissions: true);
        using var warmupClient = warmupFactory.CreateClient();
        var swaggerResponse = await warmupClient.GetAsync("/swagger/v1/swagger.json");
        swaggerResponse.EnsureSuccessStatusCode();
    }

    private static void AddBearerToken(HttpClient client)
    {
        client.DefaultRequestHeaders.Authorization =
            new AuthenticationHeaderValue("Bearer", TestJwtTokenFactory.CreateBearerToken());
    }

    private static StringContent BuildJsonContent(object payload)
    {
        var json = payload is JsonNode node
            ? node.ToJsonString()
            : JsonSerializer.Serialize(payload);
        return new StringContent(json, Encoding.UTF8, "application/json");
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
