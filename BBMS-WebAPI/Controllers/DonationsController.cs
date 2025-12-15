using Microsoft.AspNetCore.Mvc;
using BBMS_Business;
using System.Data;

namespace BBMS_WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class DonationsController : ControllerBase
    {
        [HttpGet("history/{mobileUserID}")]
        public IActionResult GetDonationHistory(int mobileUserID)
        {
            try
            {
                var mobileUser = clsMobileUser.Find(mobileUserID);
                if (mobileUser == null)
                {
                    return NotFound(new { message = "User not found" });
                }

                // Get donor ID from person
                var donor = clsDonor.FindByPersonID(mobileUser.PersonID);
                if (donor == null)
                {
                    return Ok(new { donations = new List<object>() });
                }

                var allDonations = clsDonation.GetAllDonations();
                var donations = new List<object>();

                foreach (DataRow row in allDonations.Rows)
                {
                    if ((int)row["DonorID"] == donor.DonorID)
                    {
                        var donation = clsDonation.Find((int)row["DonationID"]);
                        if (donation != null)
                        {
                            donations.Add(new
                            {
                                donationID = donation.DonationID,
                                donationDate = donation.DonationDate.ToString("yyyy-MM-dd"),
                                bloodVolume = (double)donation.BloodVolume,
                                location = "" // Add location if available
                            });
                        }
                    }
                }

                return Ok(new { donations });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = ex.Message });
            }
        }

        [HttpGet("stats/{mobileUserID}")]
        public IActionResult GetDonationStats(int mobileUserID)
        {
            try
            {
                var mobileUser = clsMobileUser.Find(mobileUserID);
                if (mobileUser == null)
                {
                    return NotFound(new { message = "User not found" });
                }

                // Get donor ID from person
                var donor = clsDonor.FindByPersonID(mobileUser.PersonID);
                if (donor == null)
                {
                    return Ok(new
                    {
                        totalDonations = 0,
                        totalVolume = 0,
                        lastDonationDate = (string?)null
                    });
                }

                var allDonations = clsDonation.GetAllDonations();
                int totalDonations = 0;
                double totalVolume = 0;
                DateTime? lastDonation = null;

                foreach (DataRow row in allDonations.Rows)
                {
                    if ((int)row["DonorID"] == donor.DonorID)
                    {
                        totalDonations++;
                        totalVolume += Convert.ToDouble(row["BloodVolume"]);
                        var donationDate = (DateTime)row["DonationDate"];
                        if (lastDonation == null || donationDate > lastDonation)
                        {
                            lastDonation = donationDate;
                        }
                    }
                }

                return Ok(new
                {
                    totalDonations,
                    totalVolume,
                    lastDonationDate = lastDonation?.ToString("yyyy-MM-dd")
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = ex.Message });
            }
        }
    }
}
