using Helix6.Base.Domain.BaseInterfaces;

namespace InfoportOneAdmon.Back.Entities.Views.Base
{

    public partial class SecurityProfileView : IViewBase
    {
        public List<SecurityModuleView>? SecurityModule { get; set; }
    }
}
