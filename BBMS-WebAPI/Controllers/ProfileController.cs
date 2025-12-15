using Microsoft.AspNetCore.Mvc;
using BBMS_Business;

namespace BBMS_WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ProfileController : ControllerBase
    {
        [HttpGet("{mobileUserID}")]
        public IActionResult GetProfile(int mobileUserID)
        {
            try
            {
                var mobileUser = clsMobileUser.Find(mobileUserID);
                if (mobileUser == null)
                {
                    return NotFound(new { message = "User not found" });
                }

                var person = clsPerson.Find(mobileUser.PersonID);
                var patient = clsPatient.FindByPersonID(mobileUser.PersonID);

                return Ok(new
                {
                    mobileUserID = mobileUser.MobileUserID,
                    personID = mobileUser.PersonID,
                    phoneNumber = mobileUser.PhoneNumber,
                    fullName = person?.FullName() ?? "",
                    email = person?.Email ?? "",
                    bloodType = patient?.BloodType ?? "",
                    dateOfBirth = person?.DateOfBirth.ToString("yyyy-MM-dd"),
                    address = person?.Address ?? "",
                    imagePath = person?.ImagePath ?? ""
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = ex.Message });
            }
        }

        [HttpPost("update/{mobileUserID}")]
        public IActionResult UpdateProfile(int mobileUserID, [FromBody] UpdateProfileRequest request)
        {
            try
            {
                var mobileUser = clsMobileUser.Find(mobileUserID);
                if (mobileUser == null)
                {
                    return NotFound(new { success = false, message = "User not found" });
                }

                var person = clsPerson.Find(mobileUser.PersonID);
                if (person == null)
                {
                    return NotFound(new { success = false, message = "Person not found" });
                }

                // Update person data
                if (!string.IsNullOrEmpty(request.Email))
                    person.Email = request.Email;
                if (!string.IsNullOrEmpty(request.Address))
                    person.Address = request.Address;
                if (!string.IsNullOrEmpty(request.ImagePath))
                    person.ImagePath = request.ImagePath;

                person.Mode = clsPerson.enMode.Update;
                if (person.Save())
                {
                    return Ok(new { success = true, message = "Profile updated successfully" });
                }

                return Ok(new { success = false, message = "Failed to update profile" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }
    }

    public class UpdateProfileRequest
    {
        public string? Email { get; set; }
        public string? Address { get; set; }
        public string? ImagePath { get; set; }
    }
}
