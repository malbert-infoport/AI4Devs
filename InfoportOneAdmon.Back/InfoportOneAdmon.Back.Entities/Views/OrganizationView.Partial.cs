using System;

namespace InfoportOneAdmon.Back.Entities.Views
{
    public partial class OrganizationView
    {
        // Internal flag used during service lifecycle to indicate that an OrganizationEvent
        // should be published in PostActions. Not persisted by itself (it's part of the View DTO).
        public bool PublishOrganizationEvent { get; set; }

        // Optional field to carry the persisted EventSent value back to frontend if needed.
        public bool? EventSent { get; set; }
    }
}
