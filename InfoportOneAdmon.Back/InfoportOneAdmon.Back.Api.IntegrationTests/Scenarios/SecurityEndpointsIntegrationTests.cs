using InfoportOneAdmon.Back.Api.IntegrationTests.Infrastructure;
using System.Net.Http.Headers;

namespace InfoportOneAdmon.Back.Api.IntegrationTests.Scenarios;

[Collection("IntegrationTests")]
public sealed class SecurityEndpointsIntegrationTests
{
    private readonly PostgresContainerFixture _fixture;

    public SecurityEndpointsIntegrationTests(PostgresContainerFixture fixture)
    {
        _fixture = fixture;
    }

    [Fact]
    [Trait("Category", "Critical")]
    public async Task GetPermissions_ReturnsUnauthorized_WhenRequestHasNoAuth()
    {
        using var factory = new IntegrationTestFactory(_fixture.ConnectionString);
        using var client = factory.CreateClient();

        var response = await client.GetAsync("/api/Security/GetPermissions");

        Assert.Equal(System.Net.HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    [Trait("Category", "Critical")]
    public async Task GetPermissions_ReturnsOk_WhenRequestIsAuthenticated()
    {
        using var factory = new IntegrationTestFactory(
            _fixture.ConnectionString,
            enableTestJwtBypass: true,
            allowAllPermissions: true);
        using var client = factory.CreateClient();

        var token = TestJwtTokenFactory.CreateBearerToken();
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);

        var response = await client.GetAsync("/api/Security/GetPermissions");
        var body = await response.Content.ReadAsStringAsync();

        Assert.True(
            response.IsSuccessStatusCode,
            $"Expected success for authenticated permissions request. Status={(int)response.StatusCode}. Body={body}");
    }
}
