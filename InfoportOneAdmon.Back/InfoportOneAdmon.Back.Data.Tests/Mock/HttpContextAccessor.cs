using Microsoft.AspNetCore.Http;

namespace InfoportOneAdmon.Back.Data.Tests.Mock
{
    internal class HttpContextAccessor : IHttpContextAccessor
    {
        public HttpContext? HttpContext { get; set; }
    }
}
