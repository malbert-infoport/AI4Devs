using Helix6.Base.Domain.BaseInterfaces;

namespace InfoportOneAdmon.Back.Entities.Views.Base
{
    public partial class AttachmentView : IAttachmentView
    {
        public string? FileContent { get; set; }
    }
}

