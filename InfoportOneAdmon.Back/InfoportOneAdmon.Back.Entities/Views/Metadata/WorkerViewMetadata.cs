using InfoportOneAdmon.Back.Entities.Validations;
using Helix6.Base.Domain.BaseInterfaces;
using Helix6.Base.Domain.Validations.ModelValidations;

namespace InfoportOneAdmon.Back.Entities.Views.Metadata
{
    public class WorkerViewMetadata : IViewBaseMetadata
    {
        [HelixRange(18, 100)]
        public Int32? Age { get; set; }

        [CapitalLetter]
        public String Name { get; set; }
    }
}
