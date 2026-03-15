using InfoportOneAdmon.Back.Api.IntegrationTests.Collections;
using InfoportOneAdmon.Back.Api.IntegrationTests.Infrastructure;

namespace InfoportOneAdmon.Back.Api.IntegrationTests.Scenarios;

[Collection("IntegrationTests")]
public sealed class ApiStartupIntegrationTests
{
    private readonly PostgresContainerFixture _fixture;

    public ApiStartupIntegrationTests(PostgresContainerFixture fixture)
    {
        _fixture = fixture;
    }

    [Fact]
    [Trait("Category", "Critical")]
    public async Task SwaggerEndpoint_ReturnsOk_WhenApiBootstrapsAgainstContainerDatabase()
    {
        using var factory = new IntegrationTestFactory(_fixture.ConnectionString);
        using var client = factory.CreateClient();

        var response = await client.GetAsync("/swagger/v1/swagger.json");

        response.EnsureSuccessStatusCode();
        var content = await response.Content.ReadAsStringAsync();
        Assert.Contains("openapi", content, StringComparison.OrdinalIgnoreCase);
    }
}
