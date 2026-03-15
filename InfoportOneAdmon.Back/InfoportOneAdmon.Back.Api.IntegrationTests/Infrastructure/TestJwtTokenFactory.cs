using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using Microsoft.IdentityModel.Tokens;
using System.Text;

namespace InfoportOneAdmon.Back.Api.IntegrationTests.Infrastructure;

public static class TestJwtTokenFactory
{
    public static string CreateBearerToken()
    {
        var claims = new List<Claim>
        {
            new("sub", "integration-user"),
            new("name", "Integration User"),
            new("preferred_username", "integration.user"),
            new("email", "integration.user@test.local"),
            new("c_ids", "1"),
            new("o_cif", "B12345678"),
            new("o_code", "0045"),
            new("o_name", "Company"),
            new("realm_access", "{\"roles\":[\"ADMON_admin\",\"HLX_IsAdmin\"]}")
        };

        var jwt = new JwtSecurityToken(
            issuer: "integration-tests",
            audience: "integration-tests",
            claims: claims,
            signingCredentials: new SigningCredentials(
                new SymmetricSecurityKey(Encoding.UTF8.GetBytes("integration-tests-signing-key-32bytes!")),
                SecurityAlgorithms.HmacSha256),
            notBefore: DateTime.UtcNow.AddMinutes(-5),
            expires: DateTime.UtcNow.AddHours(1));

        return new JwtSecurityTokenHandler().WriteToken(jwt);
    }
}
