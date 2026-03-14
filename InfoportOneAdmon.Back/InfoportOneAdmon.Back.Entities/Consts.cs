namespace InfoportOneAdmon.Back.Entities;

public static class Consts
{
    public struct LoadingConfigurations
    {
        public struct Application
        {
            public const string APPLICATION_WITH_MODULES = "ApplicationWithModules";
        }
        public struct Organization
        {
            public const string ORGANIZATION_COMPLETE = "OrganizationComplete";
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
    public struct SecurityAccessOption
    {
        public struct OrganizationOptions
        {
            public const int ORGANIZATION_DATA_QUERY = 200;
            public const int ORGANIZATION_DATA_MODIFICATION = 201;
            public const int ORGANIZATION_MODULES_QUERY = 202;
            public const int ORGANIZATION_AUDIT_QUERY = 203;
            public const int ORGANIZATION_MODULES_MODIFICATION = 204;
        }

        public struct WorkerOptions
        {
            public const int WORKERS_QUERY = 100;
        }

    }

    public struct Problems
    {
        public struct Attachments
        {
            public const string ATTACHMENT_FILE_NOT_FOUND = "ATTACHMENT_FILE_NOT_FOUND";
        }
    }

    public struct Validations
    {

        public struct Organization
        {
            public const string CREATE_FORBIDDEN = "ORGANIZATION_CREATE_FORBIDDEN";
            public const string UPDATE_FORBIDDEN = "ORGANIZATION_UPDATE_FORBIDDEN";
            public const string MODULES_MODIFICATION_FORBIDDEN = "ORGANIZATION_MODULES_MODIFICATION_FORBIDDEN";
            public const string NAME_REQUIRED = "ORGANIZATION_NAME_REQUIRED";
            public const string TAXID_REQUIRED = "ORGANIZATION_TAXID_REQUIRED";
            public const string TAXID_INVALID_FORMAT = "ORGANIZATION_TAXID_INVALID_FORMAT";
            public const string CONTACT_EMAIL_INVALID = "ORGANIZATION_CONTACT_EMAIL_INVALID";
            public const string NAME_ALREADY_EXISTS = "ORGANIZATION_NAME_ALREADY_EXISTS";
            public const string TAXID_ALREADY_EXISTS = "ORGANIZATION_TAXID_ALREADY_EXISTS";
            public const string GROUP_NOT_FOUND_OR_INACTIVE = "ORGANIZATION_GROUP_NOT_FOUND_OR_INACTIVE";
        }
    }

    public struct EventLogTypes
    {
        public const string ModuleAssigned = "ModuleAssigned";
        public const string ModuleRemoved = "ModuleRemoved";
        public const string OrganizationDeactivatedManual = "OrganizationDeactivatedManual";
        public const string OrganizationAutoDeactivated = "OrganizationAutoDeactivated";
        public const string OrganizationReactivatedManual = "OrganizationReactivatedManual";
        public const string GroupChanged = "GroupChanged";
    }

    public struct EntityTypes
    {
        public const string Organization = "Organization";
        public const string Application = "Application";
        public const string ApplicationModule = "ApplicationModule";
        public const string AuditLog = "AuditLog";
    }
}

