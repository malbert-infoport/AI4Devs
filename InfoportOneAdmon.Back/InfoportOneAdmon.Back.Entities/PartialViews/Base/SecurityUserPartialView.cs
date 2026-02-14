namespace InfoportOneAdmon.Back.Entities.Views.Base
{

    public partial class SecurityUserView
    {
        public override bool Equals(object? obj)
        {
            var other = (SecurityUserView?)obj;
            if (other != null)
            {
                return SecurityCompanyId == other.SecurityCompanyId &&
                        UserIdentifier == other.UserIdentifier &&
                        Login == other.Login &&
                        Name == other.Name &&
                        DisplayName == other.DisplayName &&
                        Mail == other.Mail &&
                        OrganizationCif == other.OrganizationCif &&
                        OrganizationCode == other.OrganizationCode &&
                        OrganizationName == other.OrganizationName;
            }
            return false;
        }

        public override int GetHashCode()
        {
            return UserIdentifier.GetHashCode();
        }
    }
}
