using InfoportOneAdmon.Back.DataModel.Base;
using InfoportOneAdmon.Back.Entities.Views.Base;
using InfoportOneAdmon.Back.Entities.Views.Base.Metadata;
using InfoportOneAdmon.Back.Services.Base;
using Helix6.Base.Domain;
using Helix6.Base.Domain.Endpoints;
using Helix6.Base.Domain.Security;
using Helix6.Base.Helpers;
using Helix6.Base.Service;
using Microsoft.AspNetCore.Mvc;

namespace InfoportOneAdmon.Back.Api.Endpoints.Base.Generator
{
    public static class AttachmentEndpoints
	{
        /// <summary>
        /// Maps selected endpoints of the entity <type>Attachment</type>.
        /// </summary>
        /// <param name="app"></param>
        public static void MapAttachmentEndpoints(this WebApplication app)
        {
            //Obtener el contenido de un adjunto en Base64
            app.MapGet("/api/Attachment/GetAttachmentContent", async ([FromServices] IUserPermissions userPermissions, AttachmentService attachmentService, [FromQuery] int attachmentId) =>
            {
                var validateAccess = await EndpointHelper.ValidateAccess<Attachment>(new EndpointAccess(HelixEnums.SecurityLevel.Read), userPermissions);
                if (!validateAccess) return Results.Forbid();

                var content = await attachmentService.GetAttachmentContent(attachmentId);
                return Results.Ok(content);

            }).Produces(StatusCodes.Status200OK, typeof(AttachmentView))
            .WithSummary("Obtiene el contenido de un fichero adjunto en Base64 en base al identificador del adjunto.")
            .WithOpenApi().RequireAuthorization()
            .WithTags("Attachment");
            EndpointHelper.GenerateGetNewEntityEndpoint<AttachmentService, AttachmentView, Attachment, AttachmentViewMetadata>(app, "/api/Attachment/GetNewEntity", new EndpointAccess(HelixEnums.SecurityLevel.Modify));
            EndpointHelper.GenerateGetByIdEndpoint<AttachmentService, AttachmentView, Attachment, AttachmentViewMetadata>(app, "/api/Attachment/GetById", new EndpointAccess(HelixEnums.SecurityLevel.Read));
            EndpointHelper.GenerateGetByIdsEndpoint<AttachmentService, AttachmentView, Attachment, AttachmentViewMetadata>(app, "/api/Attachment/GetByIds", new EndpointAccess(HelixEnums.SecurityLevel.Read));
            EndpointHelper.GenerateInsertEndpoint<AttachmentService, AttachmentView, Attachment, AttachmentViewMetadata>(app, "/api/Attachment/Insert", new EndpointAccess(HelixEnums.SecurityLevel.Modify));
            EndpointHelper.GenerateInsertManyEndpoint<AttachmentService, AttachmentView, Attachment, AttachmentViewMetadata>(app, "/api/Attachment/InsertMany", new EndpointAccess(HelixEnums.SecurityLevel.Modify));
            EndpointHelper.GenerateUpdateEndpoint<AttachmentService, AttachmentView, Attachment, AttachmentViewMetadata>(app, "/api/Attachment/Update", new EndpointAccess(HelixEnums.SecurityLevel.Modify));
            EndpointHelper.GenerateUpdateManyEndpoint<AttachmentService, AttachmentView, Attachment, AttachmentViewMetadata>(app, "/api/Attachment/UpdateMany", new EndpointAccess(HelixEnums.SecurityLevel.Modify));
            EndpointHelper.GenerateDeleteByIdEndpoint<AttachmentService, AttachmentView, Attachment, AttachmentViewMetadata>(app, "/api/Attachment/DeleteById", new EndpointAccess(HelixEnums.SecurityLevel.Modify));
            EndpointHelper.GenerateDeleteByIdsEndpoint<AttachmentService, AttachmentView, Attachment, AttachmentViewMetadata>(app, "/api/Attachment/DeleteByIds", new EndpointAccess(HelixEnums.SecurityLevel.Modify));
            EndpointHelper.GenerateDeleteUndeleteLogicByIdEndpoint<AttachmentService, AttachmentView, Attachment, AttachmentViewMetadata>(app, "/api/Attachment/DeleteUndeleteLogicById", new EndpointAccess(HelixEnums.SecurityLevel.Modify));
            EndpointHelper.GenerateDeleteUndeleteLogicByIdsEndpoint<AttachmentService, AttachmentView, Attachment, AttachmentViewMetadata>(app, "/api/Attachment/DeleteUndeleteLogicByIds", new EndpointAccess(HelixEnums.SecurityLevel.Modify));
            EndpointHelper.GenerateUpdateEndpoint<IBaseService<AttachmentTypeView, AttachmentType, AttachmentTypeViewMetadata>, AttachmentTypeView, AttachmentType, AttachmentTypeViewMetadata>(app, "/api/AttachmentType/Update", new EndpointAccess(HelixEnums.SecurityLevel.Modify));
            EndpointHelper.GenerateDeleteByIdEndpoint<IBaseService<AttachmentTypeView, AttachmentType, AttachmentTypeViewMetadata>, AttachmentTypeView, AttachmentType, AttachmentTypeViewMetadata>(app, "/api/AttachmentType/DeleteById", new EndpointAccess(HelixEnums.SecurityLevel.Modify));
            EndpointHelper.GenerateInsertEndpoint<IBaseService<AttachmentTypeView, AttachmentType, AttachmentTypeViewMetadata>, AttachmentTypeView, AttachmentType, AttachmentTypeViewMetadata>(app, "/api/AttachmentType/Insert", new EndpointAccess(HelixEnums.SecurityLevel.Modify));
            EndpointHelper.GenerateGetAllKendoFilterEndpoint<IBaseService<AttachmentTypeView, AttachmentType, AttachmentTypeViewMetadata>, AttachmentTypeView, AttachmentType, AttachmentTypeViewMetadata>(app, "/api/AttachmentType/GetAllKendoFilter", new EndpointAccess(HelixEnums.SecurityLevel.Read));
            EndpointHelper.GenerateGetNewEntityEndpoint<IBaseService<AttachmentTypeView, AttachmentType, AttachmentTypeViewMetadata>, AttachmentTypeView, AttachmentType, AttachmentTypeViewMetadata>(app, "/api/AttachmentType/GetNewEntity", new EndpointAccess(HelixEnums.SecurityLevel.Modify));
            EndpointHelper.GenerateGetByIdEndpoint<IBaseService<AttachmentTypeView, AttachmentType, AttachmentTypeViewMetadata>, AttachmentTypeView, AttachmentType, AttachmentTypeViewMetadata>(app, "/api/AttachmentType/GetById", new EndpointAccess(HelixEnums.SecurityLevel.Read));
            EndpointHelper.GenerateGetAllEndpoint<IBaseService<AttachmentTypeView, AttachmentType, AttachmentTypeViewMetadata>, AttachmentTypeView, AttachmentType, AttachmentTypeViewMetadata>(app, "/api/AttachmentType/GetAll", new EndpointAccess(HelixEnums.SecurityLevel.Read));
        }
	}
}