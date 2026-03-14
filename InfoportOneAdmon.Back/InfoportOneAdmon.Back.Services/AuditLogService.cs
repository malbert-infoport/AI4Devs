using Helix6.Base.Application;
using Helix6.Base.Domain.Parameters;
using Helix6.Base.Domain.Security;
using Helix6.Base.Repository;
using Helix6.Base.Service;
using InfoportOneAdmon.Back.DataModel;
using InfoportOneAdmon.Back.Entities.Views;
using InfoportOneAdmon.Back.Entities.Views.Metadata;
using Microsoft.Extensions.Logging;

namespace InfoportOneAdmon.Back.Services
{
    public class AuditLogService : BaseService<AuditLogView, AuditLog, AuditLogViewMetadata>
    {
        private readonly IApplicationContext _applicationContext;
        private readonly IUserContext _userContext;
        private readonly ILogger<AuditLogService> _logger;

        public AuditLogService(
            IApplicationContext applicationContext,
            IUserContext userContext,
            IBaseRepository<AuditLog> repository,
            ILogger<AuditLogService> logger)
            : base(applicationContext, userContext, repository)
        {
            _applicationContext = applicationContext;
            _userContext = userContext;
            _logger = logger;
        }

        // Expose a simple helper to insert audit entries from other services
        public async Task LogAuditEntry(string action, string entityType, string entityId, string? content = null)
        {
            var view = new AuditLogView
            {
                Action = action,
                EntityType = entityType,
                EntityId = entityId,
                UserLogin = string.Empty,
                Timestamp = DateTime.UtcNow,
                Content = content,
            };

            try
            {
                try
                {
                    // Prefer explicit login/name available in IUserContext.User
                    view.UserLogin = _userContext?.User?.Login ?? _userContext?.User?.DisplayName ?? _userContext?.User?.Name ?? string.Empty;
                }
                catch { /* ignore errors, keep empty */ }

                _logger?.LogDebug("Inserting audit log: Action={Action}, Entity={Entity}, EntityId={EntityId}, UserLogin={UserLogin}", action, entityType, entityId, view.UserLogin);
                await Insert(view, new SetParamsService { ReloadView = false });
                _logger?.LogInformation("Audit log inserted: Action={Action}, EntityId={EntityId}", action, entityId);
            }
            catch (Exception ex)
            {
                _logger?.LogError(ex, "Failed to insert audit log: Action={Action}, EntityId={EntityId}", action, entityId);
                throw;
            }
        }
    }
}
