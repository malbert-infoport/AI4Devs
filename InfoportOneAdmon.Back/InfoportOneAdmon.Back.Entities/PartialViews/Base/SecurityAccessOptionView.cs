using Helix6.Base.Domain.BaseInterfaces;


namespace InfoportOneAdmon.Back.Entities.Views.Base
{

    public partial class SecurityAccessOptionView : IViewBase
    {
        public bool? includedInProfile { get; set; }
    }
}
