using InfoportOneAdmon.Back.Api.IntegrationTests.Infrastructure;

namespace InfoportOneAdmon.Back.Api.IntegrationTests.Collections;

[CollectionDefinition("IntegrationTests")]
public sealed class IntegrationTestCollection : ICollectionFixture<PostgresContainerFixture>
{
}
