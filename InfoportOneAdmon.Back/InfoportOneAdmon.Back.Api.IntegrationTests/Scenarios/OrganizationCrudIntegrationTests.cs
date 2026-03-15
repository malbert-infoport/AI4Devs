using System.Text;
using System.Text.Json;
using InfoportOneAdmon.Back.Api.IntegrationTests.Infrastructure;
using InfoportOneAdmon.Back.Entities;
using Npgsql;

namespace InfoportOneAdmon.Back.Api.IntegrationTests.Scenarios;

[Collection("IntegrationTests")]
public sealed class OrganizationCrudIntegrationTests
{
    private readonly PostgresContainerFixture _fixture;

    public OrganizationCrudIntegrationTests(PostgresContainerFixture fixture)
    {
        _fixture = fixture;
    }

    [Fact]
    [Trait("Category", "Critical")]
    public async Task OrganizationCrud_Works_EndToEnd_WithContainerDatabase()
    {
        using var factory = new IntegrationTestFactory(
            _fixture.ConnectionString,
            enableTestJwtBypass: false,
            allowAllPermissions: true);

        using var client = factory.CreateClient();

        // Ensure database is initialized through startup and then clean data for isolation.
        var swaggerResponse = await client.GetAsync("/swagger/v1/swagger.json");
        swaggerResponse.EnsureSuccessStatusCode();
        await _fixture.ResetDatabaseAsync();
        await EnsureCitextExtensionAsync(_fixture.ConnectionString);
        var dbDiagnostics = await GetCitextDiagnosticsAsync(_fixture.ConnectionString);

        var getNewEntityResponse = await client.GetAsync("/api/Organization/GetNewEntity");
        getNewEntityResponse.EnsureSuccessStatusCode();

        var getNewEntityJson = await getNewEntityResponse.Content.ReadAsStringAsync();
        using var getNewEntityDocument = JsonDocument.Parse(getNewEntityJson);
        var securityCompanyId = getNewEntityDocument.RootElement.GetProperty("securityCompanyId").GetInt32();

        var uniqueSuffix = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
        var organizationName = $"Integration Org {uniqueSuffix}";
        var taxId = $"IT{uniqueSuffix}";

        var insertPayload = new
        {
            id = 0,
            securityCompanyId,
            groupId = (int?)null,
            name = organizationName,
            acronym = "ITORG",
            taxId,
            address = "Test street 1",
            city = "Valencia",
            postalCode = "46001",
            country = "Spain",
            contactEmail = "integration@test.local",
            contactPhone = "+34 900 000 000",
            organization_ApplicationModule = Array.Empty<object>()
        };

        var insertResponse = await client.PostAsync(
            "/api/Organization/Insert?reloadView=true",
            BuildJsonContent(insertPayload));
        var insertBody = await insertResponse.Content.ReadAsStringAsync();
        Assert.True(
            insertResponse.IsSuccessStatusCode,
            $"Insert failed with status {(int)insertResponse.StatusCode}: {insertBody}\nDB diagnostics: {dbDiagnostics}");

        var insertJson = insertBody;
        using var insertDocument = JsonDocument.Parse(insertJson);
        var createdId = insertDocument.RootElement.GetProperty("id").GetInt32();

        var getByIdResponse = await client.GetAsync($"/api/Organization/GetById?id={createdId}");
        getByIdResponse.EnsureSuccessStatusCode();

        var getByIdJson = await getByIdResponse.Content.ReadAsStringAsync();
        using var getByIdDocument = JsonDocument.Parse(getByIdJson);
        Assert.Equal(organizationName, getByIdDocument.RootElement.GetProperty("name").GetString());

        var updatePayload = new
        {
            id = createdId,
            securityCompanyId,
            groupId = (int?)null,
            name = organizationName + " Updated",
            acronym = "ITUPD",
            taxId,
            address = "Updated street 2",
            city = "Castellon",
            postalCode = "12001",
            country = "Spain",
            contactEmail = "integration.updated@test.local",
            contactPhone = "+34 900 111 111",
            organization_ApplicationModule = Array.Empty<object>()
        };

        var updateResponse = await client.PutAsync(
            "/api/Organization/Update?reloadView=true",
            BuildJsonContent(updatePayload));
        var updateBody = await updateResponse.Content.ReadAsStringAsync();
        Assert.True(
            updateResponse.IsSuccessStatusCode,
            $"Update failed with status {(int)updateResponse.StatusCode}: {updateBody}");

        var deleteResponse = await client.DeleteAsync($"/api/Organization/DeleteUndeleteLogicById?id={createdId}");
        var deleteBody = await deleteResponse.Content.ReadAsStringAsync();
        Assert.True(
            deleteResponse.IsSuccessStatusCode,
            $"Delete failed with status {(int)deleteResponse.StatusCode}: {deleteBody}");

        Assert.Contains("true", deleteBody, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    [Trait("Category", "Critical")]
    public async Task OrganizationInsert_ReturnsValidationError_WhenNameAlreadyExists()
    {
        using var factory = new IntegrationTestFactory(
            _fixture.ConnectionString,
            enableTestJwtBypass: false,
            allowAllPermissions: true);

        using var client = factory.CreateClient();

        var swaggerResponse = await client.GetAsync("/swagger/v1/swagger.json");
        swaggerResponse.EnsureSuccessStatusCode();
        await _fixture.ResetDatabaseAsync();
        await EnsureCitextExtensionAsync(_fixture.ConnectionString);

        var uniqueSuffix = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
        var duplicatedName = $"Integration Duplicate Name {uniqueSuffix}";

        var firstSecurityCompanyId = await GetNewSecurityCompanyIdAsync(client);
        var firstInsertPayload = BuildOrganizationInsertPayload(
            firstSecurityCompanyId,
            duplicatedName,
            $"IT-A-{uniqueSuffix}");

        var firstInsertResponse = await client.PostAsync(
            "/api/Organization/Insert?reloadView=true",
            BuildJsonContent(firstInsertPayload));
        var firstInsertBody = await firstInsertResponse.Content.ReadAsStringAsync();
        Assert.True(
            firstInsertResponse.IsSuccessStatusCode,
            $"First insert should succeed. Status={(int)firstInsertResponse.StatusCode}. Body={firstInsertBody}");

        var secondSecurityCompanyId = await GetNewSecurityCompanyIdAsync(client);
        var secondInsertPayload = BuildOrganizationInsertPayload(
            secondSecurityCompanyId,
            duplicatedName,
            $"IT-B-{uniqueSuffix}");

        var secondInsertResponse = await client.PostAsync(
            "/api/Organization/Insert?reloadView=true",
            BuildJsonContent(secondInsertPayload));
        var secondInsertBody = await secondInsertResponse.Content.ReadAsStringAsync();

        Assert.False(
            secondInsertResponse.IsSuccessStatusCode,
            $"Second insert should fail for duplicated name. Body={secondInsertBody}");
        Assert.Contains(
            "ORGANIZATION_NAME_ALREADY_EXISTS",
            secondInsertBody,
            StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    [Trait("Category", "Critical")]
    public async Task OrganizationInsert_ReturnsValidationError_WhenTaxIdAlreadyExists()
    {
        using var factory = new IntegrationTestFactory(
            _fixture.ConnectionString,
            enableTestJwtBypass: false,
            allowAllPermissions: true);

        using var client = factory.CreateClient();

        var swaggerResponse = await client.GetAsync("/swagger/v1/swagger.json");
        swaggerResponse.EnsureSuccessStatusCode();
        await _fixture.ResetDatabaseAsync();
        await EnsureCitextExtensionAsync(_fixture.ConnectionString);

        var uniqueSuffix = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
        var duplicatedTaxId = $"IT-TAX-{uniqueSuffix}";

        var firstSecurityCompanyId = await GetNewSecurityCompanyIdAsync(client);
        var firstInsertPayload = BuildOrganizationInsertPayload(
            firstSecurityCompanyId,
            $"Integration Tax A {uniqueSuffix}",
            duplicatedTaxId);

        var firstInsertResponse = await client.PostAsync(
            "/api/Organization/Insert?reloadView=true",
            BuildJsonContent(firstInsertPayload));
        var firstInsertBody = await firstInsertResponse.Content.ReadAsStringAsync();
        Assert.True(
            firstInsertResponse.IsSuccessStatusCode,
            $"First insert should succeed. Status={(int)firstInsertResponse.StatusCode}. Body={firstInsertBody}");

        var secondSecurityCompanyId = await GetNewSecurityCompanyIdAsync(client);
        var secondInsertPayload = BuildOrganizationInsertPayload(
            secondSecurityCompanyId,
            $"Integration Tax B {uniqueSuffix}",
            duplicatedTaxId);

        var secondInsertResponse = await client.PostAsync(
            "/api/Organization/Insert?reloadView=true",
            BuildJsonContent(secondInsertPayload));
        var secondInsertBody = await secondInsertResponse.Content.ReadAsStringAsync();

        Assert.False(
            secondInsertResponse.IsSuccessStatusCode,
            $"Second insert should fail for duplicated taxId. Body={secondInsertBody}");
        Assert.Contains(
            "ORGANIZATION_TAXID_ALREADY_EXISTS",
            secondInsertBody,
            StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    [Trait("Category", "Critical")]
    public async Task OrganizationInsert_ReturnsCreateForbidden_WhenUserLacksDataModificationPermission()
    {
        var grantedPermissions = new[]
        {
            Consts.SecurityAccessOption.OrganizationOptions.ORGANIZATION_DATA_QUERY,
            Consts.SecurityAccessOption.OrganizationOptions.ORGANIZATION_MODULES_QUERY,
            Consts.SecurityAccessOption.OrganizationOptions.ORGANIZATION_AUDIT_QUERY
        };

        using var factory = new IntegrationTestFactory(
            _fixture.ConnectionString,
            enableTestJwtBypass: true,
            allowAllPermissions: false,
            grantedPermissions: grantedPermissions);

        using var client = factory.CreateClient();
        client.DefaultRequestHeaders.Authorization =
            new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", TestJwtTokenFactory.CreateBearerToken());

        var swaggerResponse = await client.GetAsync("/swagger/v1/swagger.json");
        swaggerResponse.EnsureSuccessStatusCode();
        await _fixture.ResetDatabaseAsync();
        await EnsureCitextExtensionAsync(_fixture.ConnectionString);

        var securityCompanyId = await GetNewSecurityCompanyIdAsync(client);
        var uniqueSuffix = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
        var insertPayload = BuildOrganizationInsertPayload(
            securityCompanyId,
            $"Integration NoPerm {uniqueSuffix}",
            $"IT-NOPERM-{uniqueSuffix}");

        var response = await client.PostAsync(
            "/api/Organization/Insert?reloadView=true",
            BuildJsonContent(insertPayload));
        var body = await response.Content.ReadAsStringAsync();

        Assert.False(response.IsSuccessStatusCode, $"Insert should fail without data modification permission. Body={body}");
        Assert.Contains("ORGANIZATION_CREATE_FORBIDDEN", body, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    [Trait("Category", "Critical")]
    public async Task OrganizationUpdate_DoesNotChangeProtectedFields_WhenUserLacksDataModificationPermission()
    {
        using var setupFactory = new IntegrationTestFactory(
            _fixture.ConnectionString,
            enableTestJwtBypass: false,
            allowAllPermissions: true);
        using var setupClient = setupFactory.CreateClient();

        var swaggerResponse = await setupClient.GetAsync("/swagger/v1/swagger.json");
        swaggerResponse.EnsureSuccessStatusCode();
        await _fixture.ResetDatabaseAsync();
        await EnsureCitextExtensionAsync(_fixture.ConnectionString);

        var uniqueSuffix = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
        var securityCompanyId = await GetNewSecurityCompanyIdAsync(setupClient);
        var originalName = $"Integration Protected {uniqueSuffix}";
        var originalTaxId = $"IT-PROT-{uniqueSuffix}";

        var insertPayload = BuildOrganizationInsertPayload(securityCompanyId, originalName, originalTaxId);
        var insertResponse = await setupClient.PostAsync("/api/Organization/Insert?reloadView=true", BuildJsonContent(insertPayload));
        var insertBody = await insertResponse.Content.ReadAsStringAsync();
        Assert.True(insertResponse.IsSuccessStatusCode, $"Seed insert failed. Body={insertBody}");

        using var insertDocument = JsonDocument.Parse(insertBody);
        var organizationId = insertDocument.RootElement.GetProperty("id").GetInt32();

        var limitedPermissions = new[]
        {
            Consts.SecurityAccessOption.OrganizationOptions.ORGANIZATION_DATA_QUERY,
            Consts.SecurityAccessOption.OrganizationOptions.ORGANIZATION_MODULES_QUERY,
            Consts.SecurityAccessOption.OrganizationOptions.ORGANIZATION_AUDIT_QUERY
        };

        using var restrictedFactory = new IntegrationTestFactory(
            _fixture.ConnectionString,
            enableTestJwtBypass: true,
            allowAllPermissions: false,
            grantedPermissions: limitedPermissions);
        using var restrictedClient = restrictedFactory.CreateClient();
        restrictedClient.DefaultRequestHeaders.Authorization =
            new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", TestJwtTokenFactory.CreateBearerToken());

        var updatePayload = new
        {
            id = organizationId,
            securityCompanyId,
            groupId = (int?)null,
            name = originalName + " Changed",
            acronym = "CHG",
            taxId = originalTaxId + "X",
            address = "Changed address",
            city = "Madrid",
            postalCode = "28001",
            country = "Spain",
            contactEmail = "changed@test.local",
            contactPhone = "+34 900 222 333",
            organization_ApplicationModule = Array.Empty<object>()
        };

        var updateResponse = await restrictedClient.PutAsync("/api/Organization/Update?reloadView=true", BuildJsonContent(updatePayload));
        var updateBody = await updateResponse.Content.ReadAsStringAsync();
        Assert.True(updateResponse.IsSuccessStatusCode, $"Update request should complete but keep protected fields. Body={updateBody}");

        var getByIdResponse = await restrictedClient.GetAsync($"/api/Organization/GetById?id={organizationId}");
        getByIdResponse.EnsureSuccessStatusCode();
        var getByIdBody = await getByIdResponse.Content.ReadAsStringAsync();
        using var getByIdDocument = JsonDocument.Parse(getByIdBody);

        Assert.Equal(originalName, getByIdDocument.RootElement.GetProperty("name").GetString());
        Assert.Equal(originalTaxId, getByIdDocument.RootElement.GetProperty("taxId").GetString());
    }

    [Fact]
    [Trait("Category", "Critical")]
    public async Task OrganizationDeleteUndeleteLogic_TogglesAuditDeletionDate()
    {
        using var factory = new IntegrationTestFactory(
            _fixture.ConnectionString,
            enableTestJwtBypass: false,
            allowAllPermissions: true);
        using var client = factory.CreateClient();

        var swaggerResponse = await client.GetAsync("/swagger/v1/swagger.json");
        swaggerResponse.EnsureSuccessStatusCode();
        await _fixture.ResetDatabaseAsync();
        await EnsureCitextExtensionAsync(_fixture.ConnectionString);

        var uniqueSuffix = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
        var securityCompanyId = await GetNewSecurityCompanyIdAsync(client);
        var insertPayload = BuildOrganizationInsertPayload(
            securityCompanyId,
            $"Integration Toggle {uniqueSuffix}",
            $"IT-TGL-{uniqueSuffix}");

        var insertResponse = await client.PostAsync("/api/Organization/Insert?reloadView=true", BuildJsonContent(insertPayload));
        var insertBody = await insertResponse.Content.ReadAsStringAsync();
        Assert.True(insertResponse.IsSuccessStatusCode, $"Seed insert failed. Body={insertBody}");

        using var insertDocument = JsonDocument.Parse(insertBody);
        var organizationId = insertDocument.RootElement.GetProperty("id").GetInt32();

        var deleteResponse = await client.DeleteAsync($"/api/Organization/DeleteUndeleteLogicById?id={organizationId}");
        var deleteBody = await deleteResponse.Content.ReadAsStringAsync();
        Assert.True(deleteResponse.IsSuccessStatusCode, $"Delete (logic) failed. Body={deleteBody}");

        var afterDeleteAudit = await GetOrganizationAuditAsync(_fixture.ConnectionString, organizationId);
        Assert.NotNull(afterDeleteAudit.AuditDeletionDate);

        var undeleteResponse = await client.DeleteAsync($"/api/Organization/DeleteUndeleteLogicById?id={organizationId}");
        var undeleteBody = await undeleteResponse.Content.ReadAsStringAsync();
        Assert.True(undeleteResponse.IsSuccessStatusCode, $"Undelete (logic) failed. Body={undeleteBody}");

        var afterUndeleteAudit = await GetOrganizationAuditAsync(_fixture.ConnectionString, organizationId);
        Assert.Null(afterUndeleteAudit.AuditDeletionDate);
    }

    [Fact]
    [Trait("Category", "Critical")]
    public async Task OrganizationCrud_PopulatesAuditFields_AcrossLifecycle()
    {
        using var factory = new IntegrationTestFactory(
            _fixture.ConnectionString,
            enableTestJwtBypass: false,
            allowAllPermissions: true);
        using var client = factory.CreateClient();

        var swaggerResponse = await client.GetAsync("/swagger/v1/swagger.json");
        swaggerResponse.EnsureSuccessStatusCode();
        await _fixture.ResetDatabaseAsync();
        await EnsureCitextExtensionAsync(_fixture.ConnectionString);

        var uniqueSuffix = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
        var securityCompanyId = await GetNewSecurityCompanyIdAsync(client);
        var insertPayload = BuildOrganizationInsertPayload(
            securityCompanyId,
            $"Integration Audit {uniqueSuffix}",
            $"IT-AUD-{uniqueSuffix}");

        var insertResponse = await client.PostAsync("/api/Organization/Insert?reloadView=true", BuildJsonContent(insertPayload));
        var insertBody = await insertResponse.Content.ReadAsStringAsync();
        Assert.True(insertResponse.IsSuccessStatusCode, $"Insert failed. Body={insertBody}");

        using var insertDocument = JsonDocument.Parse(insertBody);
        var organizationId = insertDocument.RootElement.GetProperty("id").GetInt32();

        var afterInsertAudit = await GetOrganizationAuditAsync(_fixture.ConnectionString, organizationId);
        Assert.NotNull(afterInsertAudit.AuditCreationDate);
        Assert.NotNull(afterInsertAudit.AuditCreationUser);

        var updatePayload = new
        {
            id = organizationId,
            securityCompanyId,
            groupId = (int?)null,
            name = $"Integration Audit {uniqueSuffix} Updated",
            acronym = "AUD",
            taxId = $"IT-AUD-{uniqueSuffix}",
            address = "Audit street 2",
            city = "Castellon",
            postalCode = "12001",
            country = "Spain",
            contactEmail = "audit.updated@test.local",
            contactPhone = "+34 900 123 123",
            organization_ApplicationModule = Array.Empty<object>()
        };

        var updateResponse = await client.PutAsync("/api/Organization/Update?reloadView=true", BuildJsonContent(updatePayload));
        var updateBody = await updateResponse.Content.ReadAsStringAsync();
        Assert.True(updateResponse.IsSuccessStatusCode, $"Update failed. Body={updateBody}");

        var afterUpdateAudit = await GetOrganizationAuditAsync(_fixture.ConnectionString, organizationId);
        Assert.NotNull(afterUpdateAudit.AuditModificationDate);
        Assert.NotNull(afterUpdateAudit.AuditModificationUser);
        Assert.NotNull(afterUpdateAudit.AuditCreationDate);
        Assert.True(afterUpdateAudit.AuditModificationDate >= afterUpdateAudit.AuditCreationDate);

        var deleteResponse = await client.DeleteAsync($"/api/Organization/DeleteUndeleteLogicById?id={organizationId}");
        var deleteBody = await deleteResponse.Content.ReadAsStringAsync();
        Assert.True(deleteResponse.IsSuccessStatusCode, $"Delete (logic) failed. Body={deleteBody}");

        var afterDeleteAudit = await GetOrganizationAuditAsync(_fixture.ConnectionString, organizationId);
        Assert.NotNull(afterDeleteAudit.AuditDeletionDate);
    }

    private static StringContent BuildJsonContent(object payload)
    {
        var json = JsonSerializer.Serialize(payload);
        return new StringContent(json, Encoding.UTF8, "application/json");
    }

    private static object BuildOrganizationInsertPayload(int securityCompanyId, string name, string taxId)
    {
        return new
        {
            id = 0,
            securityCompanyId,
            groupId = (int?)null,
            name,
            acronym = "ITORG",
            taxId,
            address = "Test street 1",
            city = "Valencia",
            postalCode = "46001",
            country = "Spain",
            contactEmail = "integration@test.local",
            contactPhone = "+34 900 000 000",
            organization_ApplicationModule = Array.Empty<object>()
        };
    }

    private static async Task<int> GetNewSecurityCompanyIdAsync(HttpClient client)
    {
        var response = await client.GetAsync("/api/Organization/GetNewEntity");
        response.EnsureSuccessStatusCode();

        var json = await response.Content.ReadAsStringAsync();
        using var document = JsonDocument.Parse(json);
        return document.RootElement.GetProperty("securityCompanyId").GetInt32();
    }

    private static async Task<OrganizationAuditSnapshot> GetOrganizationAuditAsync(string connectionString, int organizationId)
    {
        await using var connection = new NpgsqlConnection(connectionString);
        await connection.OpenAsync();

        const string sql = @"
SELECT
    ""AuditCreationUser"",
    ""AuditCreationDate"",
    ""AuditModificationUser"",
    ""AuditModificationDate"",
    ""AuditDeletionDate""
FROM ""Admon"".""Organization""
WHERE ""Id"" = @id;";

        await using var command = new NpgsqlCommand(sql, connection);
        command.Parameters.AddWithValue("id", organizationId);

        await using var reader = await command.ExecuteReaderAsync();
        Assert.True(await reader.ReadAsync(), $"Organization {organizationId} was not found in database.");

        var auditCreationUser = reader.IsDBNull(0) ? null : reader.GetString(0);
        var auditCreationDate = reader.IsDBNull(1) ? (DateTime?)null : reader.GetDateTime(1);
        var auditModificationUser = reader.IsDBNull(2) ? null : reader.GetString(2);
        var auditModificationDate = reader.IsDBNull(3) ? (DateTime?)null : reader.GetDateTime(3);
        var auditDeletionDate = reader.IsDBNull(4) ? (DateTime?)null : reader.GetDateTime(4);

        return new OrganizationAuditSnapshot(
            auditCreationUser,
            auditCreationDate,
            auditModificationUser,
            auditModificationDate,
            auditDeletionDate);
    }

    private sealed record OrganizationAuditSnapshot(
        string? AuditCreationUser,
        DateTime? AuditCreationDate,
        string? AuditModificationUser,
        DateTime? AuditModificationDate,
        DateTime? AuditDeletionDate);

    private static async Task EnsureCitextExtensionAsync(string connectionString)
    {
        await using var connection = new NpgsqlConnection(connectionString);
        await connection.OpenAsync();

        await using var command = new NpgsqlCommand("CREATE EXTENSION IF NOT EXISTS citext;", connection);
        await command.ExecuteNonQueryAsync();
        await connection.ReloadTypesAsync();

        NpgsqlConnection.ClearAllPools();
    }

    private static async Task<string> GetCitextDiagnosticsAsync(string connectionString)
    {
        await using var connection = new NpgsqlConnection(connectionString);
        await connection.OpenAsync();

        const string sql = @"
SELECT
    current_database() AS db,
    EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'citext') AS citext_installed,
    EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'Admon'
          AND table_name = 'Organization'
          AND data_type = 'USER-DEFINED'
          AND udt_name = 'citext'
    ) AS organization_has_citext;";

        await using var command = new NpgsqlCommand(sql, connection);
        await using var reader = await command.ExecuteReaderAsync();
        if (!await reader.ReadAsync())
            return "No diagnostics rows returned";

        var db = reader.GetString(0);
        var extensionInstalled = reader.GetBoolean(1);
        var organizationHasCitext = reader.GetBoolean(2);
        return $"db={db}; citext_installed={extensionInstalled}; organization_has_citext={organizationHasCitext}";
    }
}
