using Helix6.Base.Domain.BaseInterfaces;

namespace InfoportOneAdmon.Back.Entities.Views
{
	public partial class WorkerView : IViewBase
	{
		public string? DisplayName { get; set; }

        public override string ToString()
        {
            return $"{Name} {Surnames}";
        }
    }
}

