using Microsoft.AspNetCore.Mvc;
using BBMS_Business;
using System.Security.Cryptography;
using System.Text;
using System.ComponentModel.DataAnnotations;

namespace BBMS_WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        [HttpPost("login")]
        public IActionResult Login([FromBody] LoginRequest request)
        {
            try
            {
                var mobileUser = clsMobileUser.FindByPhoneNumber(request.PhoneNumber);
                
                if (mobileUser == null || !mobileUser.IsActive)
                {
                    return Ok(new { success = false, message = "Invalid phone number or account is inactive" });
                }

                if (!mobileUser.VerifyPassword(request.Password))
                {
                    return Ok(new { success = false, message = "Invalid password" });
                }

                // Update last login date
                mobileUser.UpdateLastLogin();

                // Get person data
                // Note: Mobile users are Donors, not Patients
                // Blood type will be determined later by admin during lab tests
                var person = clsPerson.Find(mobileUser.PersonID);

                return Ok(new
                {
                    success = true,
                    token = GenerateToken(mobileUser.MobileUserID),
                    user = new
                    {
                        mobileUserID = mobileUser.MobileUserID,
                        personID = mobileUser.PersonID,
                        phoneNumber = mobileUser.PhoneNumber,
                        fullName = person?.FullName() ?? "",
                        email = person?.Email ?? "",
                        bloodType = "", // Blood type not determined yet - will be set by admin during lab tests
                        dateOfBirth = person?.DateOfBirth.ToString("yyyy-MM-dd"),
                        address = person?.Address ?? "",
                        imagePath = person?.ImagePath ?? ""
                    }
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }

        [HttpPost("register")]
        public IActionResult Register([FromBody] RegisterRequest request)
        {
            try
            {
                // Validate model
                if (!ModelState.IsValid)
                {
                    var errors = ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage);
                    return BadRequest(new { success = false, message = "Validation failed", errors = errors });
                }

                // Validate required fields
                if (string.IsNullOrWhiteSpace(request.PhoneNumber))
                {
                    return Ok(new { success = false, message = "Phone number is required" });
                }

                if (string.IsNullOrWhiteSpace(request.Password))
                {
                    return Ok(new { success = false, message = "Password is required" });
                }

                if (string.IsNullOrWhiteSpace(request.FirstName) && string.IsNullOrWhiteSpace(request.LastName))
                {
                    return Ok(new { success = false, message = "First name or last name is required" });
                }

                // Check if phone number already exists
                if (clsMobileUser.IsMobileUserExist(request.PhoneNumber))
                {
                    return Ok(new { success = false, message = "Phone number already registered" });
                }

                clsPerson person = null;
                int personID = -1;

                // If NationalNo is provided, check if person exists
                if (!string.IsNullOrEmpty(request.NationalNo))
                {
                    person = clsPerson.Find(request.NationalNo);
                    if (person != null)
                    {
                        personID = person.PersonID;
                        // Check if person already has mobile user account
                        if (clsMobileUser.IsMobileUserExistByPersonID(personID))
                        {
                            return Ok(new { success = false, message = "This person already has a mobile account" });
                        }
                    }
                }
                else
                {
                    person = null; // Explicitly set to null for new person
                }

                // If person doesn't exist, create new person
                if (person == null)
                {
                    // Generate a temporary NationalNo if not provided
                    // Note: NationalNo max length is 20 characters in database
                    string nationalNo = request.NationalNo ?? "";
                    if (string.IsNullOrEmpty(nationalNo))
                    {
                        // Generate unique NationalNo: MOB + last 9 digits of phone + last 8 digits of timestamp
                        // Format: MOB(9 phone digits)(8 timestamp digits) = 3 + 9 + 8 = 20 characters exactly
                        string phoneDigits = request.PhoneNumber.Replace(" ", "").Replace("-", "").Replace("+", "");
                        // Take last 9 digits of phone (or pad if shorter)
                        if (phoneDigits.Length > 9) 
                            phoneDigits = phoneDigits.Substring(phoneDigits.Length - 9);
                        else
                            phoneDigits = phoneDigits.PadLeft(9, '0');
                        
                        // Take last 8 digits of timestamp (yyyyMMddHHmmss = 14 chars)
                        string timestamp = DateTime.Now.ToString("yyyyMMddHHmmss");
                        string timestampSuffix = timestamp.Substring(Math.Max(0, timestamp.Length - 8)); // Last 8 digits
                        
                        nationalNo = $"MOB{phoneDigits}{timestampSuffix}";
                        
                        // Final safety check - must be exactly 20 characters or less
                        if (nationalNo.Length > 20)
                        {
                            nationalNo = nationalNo.Substring(0, 20);
                        }
                    }

                    // Check if generated NationalNo already exists
                    if (clsPerson.IsPersonExist(nationalNo))
                    {
                        // If exists, use a shorter format with ticks
                        // Format: MOB + last 9 digits of phone + last 8 digits of ticks
                        string phoneDigits = request.PhoneNumber.Replace(" ", "").Replace("-", "").Replace("+", "");
                        if (phoneDigits.Length > 9) 
                            phoneDigits = phoneDigits.Substring(phoneDigits.Length - 9);
                        else
                            phoneDigits = phoneDigits.PadLeft(9, '0');
                        
                        string ticks = DateTime.Now.Ticks.ToString();
                        string ticksSuffix = ticks.Length > 8 ? ticks.Substring(ticks.Length - 8) : ticks.PadLeft(8, '0');
                        
                        nationalNo = $"MOB{phoneDigits}{ticksSuffix}";
                        
                        // Final safety check
                        if (nationalNo.Length > 20)
                        {
                            nationalNo = nationalNo.Substring(0, 20);
                        }
                    }
                    
                    // Check if Email already exists (if provided)
                    if (!string.IsNullOrWhiteSpace(request.Email))
                    {
                        // Check if email exists in People table
                        var allPeople = clsPerson.GetAllPeople();
                        if (allPeople != null)
                        {
                            foreach (System.Data.DataRow row in allPeople.Rows)
                            {
                                if (row["Email"] != DBNull.Value && 
                                    row["Email"].ToString().Equals(request.Email, StringComparison.OrdinalIgnoreCase))
                                {
                                    return Ok(new { success = false, message = $"Email '{request.Email}' is already registered to another person." });
                                }
                            }
                        }
                    }

                    // Get default country (Egypt = 1, or first available country)
                    int countryID = -1;
                    string countryName = "";
                    
                    // Try to find Egypt country first
                    var egyptCountry = clsCountry.Find("Egypt");
                    if (egyptCountry != null)
                    {
                        countryID = egyptCountry.ID;
                        countryName = egyptCountry.CountryName;
                    }
                    else
                    {
                        // If Egypt not found, get first available country
                        var countries = clsCountry.GetAllCountries();
                        if (countries != null && countries.Rows.Count > 0)
                        {
                            // Get the first country ID from the DataTable
                            var firstRow = countries.Rows[0];
                            if (firstRow["CountryID"] != DBNull.Value)
                            {
                                countryID = Convert.ToInt32(firstRow["CountryID"]);
                                if (firstRow["CountryName"] != DBNull.Value)
                                {
                                    countryName = firstRow["CountryName"].ToString();
                                }
                            }
                        }
                    }
                    
                    // Validate countryID is valid and exists in database
                    if (countryID <= 0)
                    {
                        return Ok(new { success = false, message = "No countries found in database. Please run Add_Egypt_Country.sql or Seed_Data.sql to add 'Egypt' country first." });
                    }
                    
                    // Double-check that the country actually exists by querying it again
                    var verifyCountry = clsCountry.Find(countryID);
                    if (verifyCountry == null)
                    {
                        return Ok(new { 
                            success = false, 
                            message = $"Country ID {countryID} does not exist in database. " +
                                      $"This usually means the Countries table is empty or the ID is invalid. " +
                                      $"Please run Add_Egypt_Country.sql to add 'Egypt' country." 
                        });
                    }
                    
                    // Log the country being used (for debugging)
                    countryName = verifyCountry.CountryName;

                    // Parse date of birth
                    DateTime dateOfBirth = DateTime.Now.AddYears(-18); // Default to 18 years ago
                    if (!string.IsNullOrEmpty(request.DateOfBirth))
                    {
                        if (DateTime.TryParse(request.DateOfBirth, out DateTime parsedDate))
                        {
                            dateOfBirth = parsedDate;
                        }
                    }

                    // Note: First name or last name validation is already done above

                    // Based on database schema:
                    // - SecondName is NOT NULL (required) - must be empty string if not provided
                    // - Address is NOT NULL (required) - must be empty string if not provided
                    // - ThirdName is nullable (optional) - can be empty string
                    // - Email is nullable (optional) - can be empty string
                    // - ImagePath is nullable (optional) - can be empty string
                    
                    // Ensure required fields are not null (use empty string for NOT NULL columns)
                    string secondName = request.SecondName ?? "";
                    string address = request.Address ?? "";
                    
                    // Optional fields can be empty string (clsPerson uses empty strings, not null)
                    string thirdName = request.ThirdName ?? "";
                    string email = request.Email ?? "";
                    string imagePath = request.ImagePath ?? "";

                    // Create new person
                    // Note: clsPerson uses empty strings, not null
                    // Database requires: SecondName (NOT NULL), Address (NOT NULL)
                    person = new clsPerson
                    {
                        NationalNo = nationalNo,
                        FirstName = request.FirstName ?? "",
                        SecondName = secondName, // Required (NOT NULL) - already set to "" if null
                        ThirdName = thirdName,   // Optional - can be ""
                        LastName = request.LastName ?? "",
                        DateOfBirth = dateOfBirth,
                        Gendar = 0, // Default gender (0 = Unknown, 1 = Male, 2 = Female)
                        Address = address, // Required (NOT NULL) - already set to "" if null
                        Phone = request.PhoneNumber,
                        Email = email, // Optional - can be ""
                        NationalityCountryID = countryID,
                        ImagePath = imagePath, // Optional - can be ""
                        Mode = clsPerson.enMode.AddNew
                    };

                    // Try to save person
                    if (!person.Save())
                    {
                        // Check if NationalNo already exists (race condition)
                        if (clsPerson.IsPersonExist(nationalNo))
                        {
                            // Try with a new unique NationalNo
                            nationalNo = $"MOB{request.PhoneNumber.Replace(" ", "").Replace("-", "")}{DateTime.Now.Ticks}";
                            person.NationalNo = nationalNo;
                            
                            if (!person.Save())
                            {
                                return Ok(new { 
                                    success = false, 
                                    message = $"Failed to create person record after retry. " +
                                              $"Possible causes: " +
                                              $"1) Foreign key constraint: CountryID {countryID} may not exist in Countries table. " +
                                              $"   Solution: Run Add_Egypt_Country.sql or Seed_Data.sql. " +
                                              $"2) Unique constraint violation: NationalNo, Phone, or Email may already exist. " +
                                              $"3) Database connection issue. " +
                                              $"CountryID used: {countryID}, NationalNo: {nationalNo}" 
                                });
                            }
                        }
                        else
                        {
                            // Comprehensive diagnosis
                            bool nationalNoExists = clsPerson.IsPersonExist(nationalNo);
                            bool phoneExists = false;
                            bool emailExists = false;
                            
                            // Check if phone or email exists
                            var allPeople = clsPerson.GetAllPeople();
                            if (allPeople != null)
                            {
                                foreach (System.Data.DataRow row in allPeople.Rows)
                                {
                                    if (row["Phone"] != DBNull.Value && 
                                        row["Phone"].ToString() == request.PhoneNumber)
                                    {
                                        phoneExists = true;
                                    }
                                    if (!string.IsNullOrEmpty(email) && 
                                        row["Email"] != DBNull.Value && 
                                        row["Email"].ToString().Equals(email, StringComparison.OrdinalIgnoreCase))
                                    {
                                        emailExists = true;
                                    }
                                    if (phoneExists && (string.IsNullOrEmpty(email) || emailExists))
                                        break;
                                }
                            }
                            
                            // Verify country one more time
                            var finalCountryCheck = clsCountry.Find(countryID);
                            string countryStatus = finalCountryCheck != null 
                                ? $"Country '{finalCountryCheck.CountryName}' (ID: {countryID}) EXISTS ✅" 
                                : $"Country ID {countryID} DOES NOT EXIST ❌";
                            
                            // Build detailed error message
                            var errorMsg = new System.Text.StringBuilder();
                            errorMsg.AppendLine($"Failed to create person record. PersonID: {person.PersonID}");
                            errorMsg.AppendLine($"");
                            errorMsg.AppendLine($"Diagnosis:");
                            errorMsg.AppendLine($"  - {countryStatus}");
                            errorMsg.AppendLine($"  - NationalNo '{nationalNo}' exists: {(nationalNoExists ? "YES ❌" : "NO ✅")}");
                            errorMsg.AppendLine($"  - Phone '{request.PhoneNumber}' exists: {(phoneExists ? "YES ❌" : "NO ✅")}");
                            if (!string.IsNullOrEmpty(email))
                            {
                                errorMsg.AppendLine($"  - Email '{email}' exists: {(emailExists ? "YES ❌" : "NO ✅")}");
                            }
                            errorMsg.AppendLine($"");
                            errorMsg.AppendLine($"Possible causes:");
                            if (nationalNoExists || phoneExists || emailExists)
                            {
                                errorMsg.AppendLine($"  1) ❌ DUPLICATE DATA: NationalNo, Phone, or Email already exists");
                            }
                            else
                            {
                                errorMsg.AppendLine($"  1) Database constraint violation (check with CHECK_PERSON_CONSTRAINTS.sql)");
                                errorMsg.AppendLine($"  2) Required field missing or invalid");
                                errorMsg.AppendLine($"  3) Database connection issue");
                            }
                            errorMsg.AppendLine($"");
                            errorMsg.AppendLine($"ACTION: Run CHECK_PERSON_CONSTRAINTS.sql to see all constraints and indexes.");
                            
                            return Ok(new { 
                                success = false, 
                                message = errorMsg.ToString()
                            });
                        }
                    }

                    personID = person.PersonID;
                }

                // Note: Mobile users are Donors, not Patients
                // Blood type will be determined later by admin during lab tests
                // No Patient record should be created during mobile registration

                // Create mobile user
                var mobileUser = new clsMobileUser
                {
                    PersonID = personID,
                    PhoneNumber = request.PhoneNumber,
                    IsActive = true,
                    Mode = clsMobileUser.enMode.AddNew
                };
                mobileUser.SetPassword(request.Password);

                if (!mobileUser.Save())
                {
                    return Ok(new { success = false, message = $"Failed to create mobile user record. PersonID: {personID}, PhoneNumber: {request.PhoneNumber}. Check database connection and constraints." });
                }

                // Reload person to get updated data
                person = clsPerson.Find(personID);
                // Note: Mobile users are Donors, not Patients
                // No Patient record is created during mobile registration

                // Create welcome notification
                try
                {
                    var welcomeNotification = new clsNotification
                    {
                        MobileUserID = mobileUser.MobileUserID,
                        TransfusionID = null,
                        DonationID = null,
                        Title = "Welcome to BBMS!",
                        Message = $"Welcome {person?.FullName() ?? request.FirstName}! Thank you for joining our blood bank management system. You can now book appointments and track your donation history.",
                        NotificationType = "Info",
                        IsRead = false,
                        Mode = clsNotification.enMode.AddNew
                    };
                    welcomeNotification.Save();
                }
                catch (Exception ex)
                {
                    // Log error but don't fail registration
                    System.Diagnostics.Debug.WriteLine($"Failed to create welcome notification: {ex.Message}");
                }

                return Ok(new
                {
                    success = true,
                    message = "Registration successful",
                    token = GenerateToken(mobileUser.MobileUserID),
                    user = new
                    {
                        mobileUserID = mobileUser.MobileUserID,
                        personID = mobileUser.PersonID,
                        phoneNumber = mobileUser.PhoneNumber,
                        fullName = person?.FullName() ?? $"{request.FirstName} {request.LastName}",
                        email = person?.Email ?? request.Email ?? "",
                        bloodType = "", // Blood type not determined yet - will be set by admin during lab tests
                        dateOfBirth = person?.DateOfBirth.ToString("yyyy-MM-dd") ?? request.DateOfBirth,
                        address = person?.Address ?? request.Address ?? "",
                        imagePath = person?.ImagePath ?? request.ImagePath ?? ""
                    }
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }

        private string GenerateToken(int mobileUserID)
        {
            // Simple token generation - in production, use proper JWT
            var token = Convert.ToBase64String(Encoding.UTF8.GetBytes($"{mobileUserID}:{DateTime.Now.Ticks}"));
            return token;
        }
    }

    public class LoginRequest
    {
        [Required(ErrorMessage = "Phone number is required")]
        public string PhoneNumber { get; set; } = "";
        
        [Required(ErrorMessage = "Password is required")]
        public string Password { get; set; } = "";
    }

    public class RegisterRequest
    {
        /// <summary>
        /// National ID number (optional - will be auto-generated if not provided)
        /// </summary>
        public string? NationalNo { get; set; }
        
        [Required(ErrorMessage = "Phone number is required")]
        public string PhoneNumber { get; set; } = "";
        
        [Required(ErrorMessage = "Password is required")]
        [MinLength(6, ErrorMessage = "Password must be at least 6 characters")]
        public string Password { get; set; } = "";
        
        /// <summary>
        /// First name (required if last name is not provided)
        /// </summary>
        public string? FirstName { get; set; }
        
        /// <summary>
        /// Last name (required if first name is not provided)
        /// </summary>
        public string? LastName { get; set; }
        
        /// <summary>
        /// Second name (optional)
        /// </summary>
        public string? SecondName { get; set; }
        
        /// <summary>
        /// Third name (optional)
        /// </summary>
        public string? ThirdName { get; set; }
        
        /// <summary>
        /// Email address (optional)
        /// </summary>
        [EmailAddress(ErrorMessage = "Invalid email format")]
        public string? Email { get; set; }
        
        /// <summary>
        /// Blood type (deprecated - not used for mobile registration)
        /// Blood type will be determined later by admin during lab tests
        /// </summary>
        [Obsolete("Blood type is not collected during mobile registration. It will be determined by admin during lab tests.")]
        public string? BloodType { get; set; }
        
        /// <summary>
        /// Date of birth in format YYYY-MM-DD (optional, defaults to 18 years ago)
        /// </summary>
        public string? DateOfBirth { get; set; }
        
        /// <summary>
        /// Address (optional)
        /// </summary>
        public string? Address { get; set; }
        
        /// <summary>
        /// Image path/URL (optional)
        /// </summary>
        public string? ImagePath { get; set; }
    }
}
