namespace InfoportOneAdmon.Back.Entities;

public static class Consts
{
    public struct LoadingConfigurations
    {
        public struct Organization
        {
            public const string ORGANIZATION_COMPLETE = "OrganizationComplete";
            public const string ORGANIZATION_LITE = "OrganizationLite";
        }
        public struct SecurityProfile
        {
            public const string PROFILE_WITH_MODULES = "ProfileWithModules";
        }
        public struct SecurityModule
        {
            public const string MODULE_WITH_SECURITYOPTIONS = "ModuleWithSecurityOptions";
        }
        public struct SecurityUser
        {
            public const string USER_WITH_CONFIGURATION = "UserWithConfiguration";
        }
    }
}

