using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;

namespace InfoportOneAdmon.Back.Data.DataModel;

public partial class EntityModel : DbContext
{
    private readonly string? _connectionString;

    public EntityModel(string connectionString)
    {
        _connectionString = connectionString;
    }

    protected override void ConfigureConventions(ModelConfigurationBuilder configurationBuilder)
    {
        configurationBuilder
        .Properties<DateTime>()
        .HaveConversion(typeof(UtcValueConverter));
    }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        if (!string.IsNullOrEmpty(_connectionString))
            optionsBuilder.UseNpgsql(_connectionString);
    }

    /// <summary>
    /// Value converter for converting DateTime values to UTC.
    /// </summary>
    private class UtcValueConverter : ValueConverter<DateTime, DateTime>
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="UtcValueConverter"/> class.
        /// </summary>
        public UtcValueConverter()
            : base(v => v, v => DateTime.SpecifyKind(v, DateTimeKind.Utc))
        {
        }
    }
}