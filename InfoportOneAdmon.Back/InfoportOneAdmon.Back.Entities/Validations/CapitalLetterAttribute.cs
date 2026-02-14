using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace InfoportOneAdmon.Back.Entities.Validations
{
    [AttributeUsage(AttributeTargets.Property | AttributeTargets.Field | AttributeTargets.Parameter, AllowMultiple = false)]
    public class CapitalLetterAttribute : ValidationAttribute
    {
        private readonly string _resourceKey = "HELIX6VALIDATION_CAPITALLETTER";
        protected override ValidationResult? IsValid(object? value, ValidationContext validationContext)
        {
            if (value == null || string.IsNullOrEmpty(value.ToString()))
            {
                return ValidationResult.Success;
            }

            var firstLetter = value.ToString()[0].ToString();

            if (firstLetter != firstLetter.ToUpper())
            {
                return new ValidationResult(_resourceKey, new[] { validationContext.DisplayName });
            }

            return ValidationResult.Success;
        }
    }
}
