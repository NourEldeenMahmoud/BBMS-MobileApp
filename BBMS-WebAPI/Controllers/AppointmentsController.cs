using Microsoft.AspNetCore.Mvc;
using BBMS_Business;
using BBMS_Data;
using System.Data;
using System.Data.SqlClient;
using System.ComponentModel.DataAnnotations;

namespace BBMS_WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AppointmentsController : ControllerBase
    {
        /// <summary>
        /// Get all donation appointments for a mobile user
        /// Note: Mobile users are Donors, not Patients
        /// </summary>
        [HttpGet("user/{mobileUserID}")]
        public IActionResult GetAppointments(int mobileUserID)
        {
            try
            {
                var mobileUser = clsMobileUser.Find(mobileUserID);
                if (mobileUser == null)
                {
                    return NotFound(new { message = "User not found" });
                }

                // Get Donor ID from PersonID
                var donor = clsDonor.FindByPersonID(mobileUser.PersonID);
                if (donor == null)
                {
                    // Donor doesn't exist yet - return empty list
                    return Ok(new { 
                        appointments = new List<object>(),
                        debug = new { 
                            mobileUserID = mobileUserID,
                            personID = mobileUser.PersonID,
                            donorID = "not found",
                            message = "Donor record not found for this user. User needs to book an appointment first."
                        }
                    });
                }

                // Get all donation appointments for this donor
                var donorAppointments = clsDonationAppointment.GetDonationAppointmentsByDonorID(donor.DonorID);
                var appointments = new List<object>();

                foreach (DataRow row in donorAppointments.Rows)
                {
                    try
                    {
                        int appointmentID = (int)row["DonationAppointmentID"];
                        var appointment = clsDonationAppointment.Find(appointmentID);
                        if (appointment != null)
                        {
                            // Get person name
                            string donorName = appointment.DonorData?.PersonData?.FullName() ?? "";
                            
                            appointments.Add(new
                            {
                                transfusionID = appointment.DonationAppointmentID, // Keep for backward compatibility
                                donationAppointmentID = appointment.DonationAppointmentID,
                                appointmentDate = appointment.AppointmentDate.ToString("yyyy-MM-dd"),
                                appointmentTime = appointment.AppointmentTime ?? "",
                                location = appointment.Location ?? "",
                                statusText = appointment.Status ?? "Pending",
                                status = appointment.Status ?? "Pending",
                                quantityRequested = 450, // Standard donation amount (for backward compatibility)
                                patientName = donorName, // Keep for backward compatibility
                                donorName = donorName,
                                transfusionRequestDate = appointment.CreatedDate.ToString("yyyy-MM-dd"), // Keep for backward compatibility
                                createdDate = appointment.CreatedDate.ToString("yyyy-MM-dd")
                            });
                        }
                    }
                    catch (Exception ex)
                    {
                        // Log error but continue processing other rows
                        System.Diagnostics.Debug.WriteLine($"Error processing appointment row: {ex.Message}");
                    }
                }

                return Ok(new { 
                    appointments,
                    debug = new { 
                        mobileUserID = mobileUserID,
                        personID = mobileUser.PersonID,
                        donorID = donor.DonorID,
                        appointmentsCount = appointments.Count
                    }
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = ex.Message, stackTrace = ex.StackTrace });
            }
        }

        /// <summary>
        /// Book a donation appointment (NOT a transfusion appointment)
        /// Mobile users are Donors, not Patients
        /// </summary>
        [HttpPost("book")]
        public IActionResult BookAppointment([FromBody] BookAppointmentRequest request)
        {
            try
            {
                // Validate model
                if (!ModelState.IsValid)
                {
                    var errors = ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage);
                    return BadRequest(new { success = false, message = "Validation failed", errors = errors });
                }
                
                var mobileUser = clsMobileUser.Find(request.MobileUserID);
                if (mobileUser == null)
                {
                    return NotFound(new { success = false, message = "User not found" });
                }

                // Get or create Donor record
                var donor = clsDonor.FindByPersonID(mobileUser.PersonID);
                if (donor == null)
                {
                    // Create donor record automatically if it doesn't exist
                    var person = clsPerson.Find(mobileUser.PersonID);
                    if (person == null)
                    {
                        return Ok(new { success = false, message = "Person record not found for this user" });
                    }
                    
                    // Check if donor exists but FindByPersonID returned null (race condition)
                    if (clsDonor.IsDonorExistByPersonID(mobileUser.PersonID))
                    {
                        donor = clsDonor.FindByPersonID(mobileUser.PersonID);
                    }
                    
                    if (donor == null)
                    {
                        // Create new donor record with default values
                        donor = new clsDonor
                        {
                            PersonID = mobileUser.PersonID,
                            Height = 0, // Will be updated later by admin
                            Weight = 0, // Will be updated later by admin
                            LastDonationDate = null,
                            MedicalRecord = "",
                            CanDonate = true, // Default to true, admin can update later
                            Mode = clsDonor.enMode.AddNew
                        };
                        
                        // Try to save donor
                        bool donorSaveResult = donor.Save();
                        
                        // Always reload donor after save attempt
                        donor = clsDonor.FindByPersonID(mobileUser.PersonID);
                        
                        if (donor == null)
                        {
                            // Donor still doesn't exist after save attempt
                            return Ok(new { 
                                success = false, 
                                message = $"Failed to create donor record for PersonID {mobileUser.PersonID} (MobileUserID: {request.MobileUserID}). " +
                                          $"Save() returned: {donorSaveResult}. " +
                                          $"Please check database constraints and connection." 
                            });
                        }
                    }
                }
                
                // Final check - donor should exist now
                if (donor == null)
                {
                    return Ok(new { 
                        success = false, 
                        message = "Donor record is still null after creation attempt. This should not happen." 
                    });
                }

                // Check if donor has active appointment
                if (clsDonationAppointment.DoesDonorHaveActiveAppointment(donor.DonorID))
                {
                    return Ok(new { success = false, message = "You already have an active appointment request" });
                }

                // Parse appointment date
                DateTime appointmentDate = DateTime.Now;
                if (!string.IsNullOrEmpty(request.AppointmentDate))
                {
                    if (DateTime.TryParse(request.AppointmentDate, out DateTime parsedDate))
                    {
                        appointmentDate = parsedDate;
                    }
                }

                // Prepare source (for DonationAppointments table)
                string source = request.Source ?? "Mobile";
                if (source.Equals("Mobile App", StringComparison.OrdinalIgnoreCase))
                {
                    source = "Mobile";
                }
                if (source.Length > 20)
                {
                    source = source.Substring(0, 20);
                }
                
                // Prepare location
                string location = (request.Location ?? "").Length > 200 ? (request.Location ?? "").Substring(0, 200) : (request.Location ?? "");
                
                // Create new donation appointment
                var donationAppointment = new clsDonationAppointment
                {
                    DonorID = donor.DonorID,
                    AppointmentDate = appointmentDate,
                    AppointmentTime = request.AppointmentTime ?? "",
                    Location = location,
                    Status = "Pending",
                    Source = source,
                    Notes = "",
                    Mode = clsDonationAppointment.enMode.AddNew
                };

                // Validate required fields
                if (donationAppointment.DonorID <= 0)
                {
                    return Ok(new { success = false, message = $"Invalid DonorID: {donationAppointment.DonorID}" });
                }

                // Verify DonorID exists in Donors table
                var verifyDonor = clsDonor.Find(donationAppointment.DonorID);
                if (verifyDonor == null)
                {
                    return Ok(new { 
                        success = false, 
                        message = $"DonorID {donationAppointment.DonorID} does not exist in Donors table. Foreign Key constraint will fail." 
                    });
                }

                // Clear any previous error messages before attempting to save
                clsDonationAppointmentData.ClearLastErrorMessage();
                
                // Try to save
                bool saveResult = donationAppointment.Save();
                
                if (saveResult && donationAppointment.DonationAppointmentID > 0)
                {
                    // Create notification for successful appointment booking
                    try
                    {
                        string appointmentDateStr = appointmentDate.ToString("yyyy-MM-dd");
                        string appointmentTimeStr = request.AppointmentTime ?? "";
                        string locationStr = location ?? "Blood Bank";
                        
                        var notification = new clsNotification
                        {
                            MobileUserID = request.MobileUserID,
                            TransfusionID = null,
                            DonationID = null,
                            Title = "موعد تبرع جديد",
                            Message = $"تم حجز موعد تبرع بنجاح.\nالتاريخ: {appointmentDateStr}\nالوقت: {appointmentTimeStr}\nالمكان: {locationStr}",
                            NotificationType = "Appointment",
                            IsRead = false,
                            Mode = clsNotification.enMode.AddNew
                        };
                        notification.Save();
                    }
                    catch (Exception ex)
                    {
                        // Log error but don't fail the appointment booking
                        System.Diagnostics.Debug.WriteLine($"Failed to create notification: {ex.Message}");
                    }
                    
                    return Ok(new { 
                        success = true, 
                        message = "Donation appointment booked successfully", 
                        donationAppointmentID = donationAppointment.DonationAppointmentID,
                        transfusionID = donationAppointment.DonationAppointmentID // Keep for backward compatibility
                    });
                }

                string sqlErrorMessage = clsDonationAppointmentData.GetLastErrorMessage();

                string errorMessage;
                if (!string.IsNullOrEmpty(sqlErrorMessage))
                {
                    errorMessage = $"Failed to book donation appointment. SQL Error: {sqlErrorMessage}";
                }
                else
                {
                    errorMessage = $"Failed to book donation appointment. Save() returned: {saveResult}, DonationAppointmentID: {donationAppointment.DonationAppointmentID}. " +
                                 $"Please check: 1) Database connection, 2) DonorID {donationAppointment.DonorID} exists in Donors table, " +
                                 $"3) Database constraints (Foreign Keys, NOT NULL fields).";
                }
                
                return Ok(new { success = false, message = errorMessage });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }

        /// <summary>
        /// Cancel a donation appointment
        /// </summary>
        [HttpPost("cancel/{appointmentID}")]
        public IActionResult CancelAppointment(int appointmentID)
        {
            try
            {
                var appointment = clsDonationAppointment.Find(appointmentID);
                if (appointment == null)
                {
                    return NotFound(new { success = false, message = "Appointment not found" });
                }

                // Get MobileUserID from Donor's PersonID before canceling
                int mobileUserID = -1;
                if (appointment.DonorData != null && appointment.DonorData.PersonID > 0)
                {
                    // Find MobileUser by PersonID using a direct query
                    SqlConnection connection = new SqlConnection(clsDataAccessSettings.ConnectionString);
                    string query = "SELECT MobileUserID FROM MobileUsers WHERE PersonID = @PersonID";
                    SqlCommand command = new SqlCommand(query, connection);
                    command.Parameters.AddWithValue("@PersonID", appointment.DonorData.PersonID);
                    
                    try
                    {
                        connection.Open();
                        object result = command.ExecuteScalar();
                        if (result != null && int.TryParse(result.ToString(), out int foundMobileUserID))
                        {
                            mobileUserID = foundMobileUserID;
                        }
                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Debug.WriteLine($"Error finding MobileUserID: {ex.Message}");
                    }
                    finally
                    {
                        connection.Close();
                    }
                }

                if (appointment.Cancel())
                {
                    // Create notification for appointment cancellation
                    if (mobileUserID > 0)
                    {
                        try
                        {
                            string appointmentDateStr = appointment.AppointmentDate.ToString("yyyy-MM-dd");
                            string appointmentTimeStr = appointment.AppointmentTime ?? "";
                            
                            var notification = new clsNotification
                            {
                                MobileUserID = mobileUserID,
                                TransfusionID = null,
                                DonationID = null,
                                Title = "إلغاء موعد تبرع",
                                Message = $"تم إلغاء موعد التبرع.\nالتاريخ: {appointmentDateStr}\nالوقت: {appointmentTimeStr}",
                                NotificationType = "Appointment",
                                IsRead = false,
                                Mode = clsNotification.enMode.AddNew
                            };
                            notification.Save();
                        }
                        catch (Exception ex)
                        {
                            // Log error but don't fail the cancellation
                            System.Diagnostics.Debug.WriteLine($"Failed to create cancellation notification: {ex.Message}");
                        }
                    }
                    
                    return Ok(new { success = true, message = "Appointment cancelled successfully" });
                }

                return Ok(new { success = false, message = "Failed to cancel appointment" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }

        /// <summary>
        /// Reschedule a donation appointment
        /// </summary>
        [HttpPost("reschedule/{appointmentID}")]
        public IActionResult RescheduleAppointment(int appointmentID, [FromBody] RescheduleRequest request)
        {
            try
            {
                // Validate model
                if (!ModelState.IsValid)
                {
                    var errors = ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage);
                    return BadRequest(new { success = false, message = "Validation failed", errors = errors });
                }
                
                var appointment = clsDonationAppointment.Find(appointmentID);
                if (appointment == null)
                {
                    string findErrorMsg = clsDonationAppointmentData.GetLastErrorMessage();
                    string message = $"Appointment with ID {appointmentID} not found.";
                    if (!string.IsNullOrEmpty(findErrorMsg))
                    {
                        message += $" Error: {findErrorMsg}";
                    }
                    return NotFound(new { success = false, message = message });
                }

                // Check if appointment is already cancelled
                if (appointment.Status == "Cancelled")
                {
                    return Ok(new { success = false, message = "Cannot reschedule a cancelled appointment" });
                }

                // Parse appointment date
                if (!string.IsNullOrEmpty(request.AppointmentDate))
                {
                    if (DateTime.TryParse(request.AppointmentDate, out DateTime parsedDate))
                    {
                        appointment.AppointmentDate = parsedDate;
                    }
                    else
                    {
                        return Ok(new { success = false, message = "Invalid date format. Use YYYY-MM-DD format." });
                    }
                }
                else
                {
                    return Ok(new { success = false, message = "Appointment date is required" });
                }
                
                if (string.IsNullOrEmpty(request.AppointmentTime))
                {
                    return Ok(new { success = false, message = "Appointment time is required" });
                }
                
                appointment.AppointmentTime = request.AppointmentTime;
                appointment.Mode = clsDonationAppointment.enMode.Update;
                
                if (appointment.Save())
                {
                    // Create notification for successful rescheduling
                    try
                    {
                        // Get MobileUserID from Donor's PersonID
                        int mobileUserID = -1;
                        if (appointment.DonorData != null && appointment.DonorData.PersonID > 0)
                        {
                            SqlConnection connection = new SqlConnection(clsDataAccessSettings.ConnectionString);
                            string query = "SELECT MobileUserID FROM MobileUsers WHERE PersonID = @PersonID";
                            SqlCommand command = new SqlCommand(query, connection);
                            command.Parameters.AddWithValue("@PersonID", appointment.DonorData.PersonID);
                            
                            try
                            {
                                connection.Open();
                                object result = command.ExecuteScalar();
                                if (result != null && int.TryParse(result.ToString(), out int foundMobileUserID))
                                {
                                    mobileUserID = foundMobileUserID;
                                }
                            }
                            catch (Exception ex)
                            {
                                System.Diagnostics.Debug.WriteLine($"Error finding MobileUserID: {ex.Message}");
                            }
                            finally
                            {
                                connection.Close();
                            }
                        }

                        if (mobileUserID > 0)
                        {
                            string appointmentDateStr = appointment.AppointmentDate.ToString("yyyy-MM-dd");
                            string appointmentTimeStr = appointment.AppointmentTime ?? "";
                            string locationStr = appointment.Location ?? "Blood Bank";
                            
                            var notification = new clsNotification
                            {
                                MobileUserID = mobileUserID,
                                TransfusionID = null,
                                DonationID = null,
                                Title = "تعديل موعد تبرع",
                                Message = $"تم تعديل موعد التبرع بنجاح.\nالتاريخ الجديد: {appointmentDateStr}\nالوقت الجديد: {appointmentTimeStr}\nالمكان: {locationStr}",
                                NotificationType = "Appointment",
                                IsRead = false,
                                Mode = clsNotification.enMode.AddNew
                            };
                            notification.Save();
                        }
                    }
                    catch (Exception ex)
                    {
                        // Log error but don't fail the rescheduling
                        System.Diagnostics.Debug.WriteLine($"Failed to create reschedule notification: {ex.Message}");
                    }
                    
                    return Ok(new { success = true, message = "Appointment rescheduled successfully" });
                }

                string saveErrorMsg = clsDonationAppointmentData.GetLastErrorMessage();
                string errorMessage = "Failed to reschedule appointment";
                if (!string.IsNullOrEmpty(saveErrorMsg))
                {
                    errorMessage += $". Error: {saveErrorMsg}";
                }
                
                return Ok(new { success = false, message = errorMessage });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }
    }

    public class BookAppointmentRequest
    {
        [Required(ErrorMessage = "Mobile user ID is required")]
        public int MobileUserID { get; set; }
        
        [Required(ErrorMessage = "Quantity requested is required")]
        [Range(1, 1000, ErrorMessage = "Quantity must be between 1 and 1000")]
        public int QuantityRequested { get; set; }
        
        /// <summary>
        /// Appointment date in format YYYY-MM-DD (optional, defaults to today)
        /// </summary>
        public string? AppointmentDate { get; set; }
        
        /// <summary>
        /// Appointment time in format HH:mm:ss (optional)
        /// </summary>
        public string? AppointmentTime { get; set; }
        
        /// <summary>
        /// Location of the appointment (optional)
        /// </summary>
        public string? Location { get; set; }
        
        /// <summary>
        /// Source of the appointment request (optional, e.g., "Mobile App")
        /// </summary>
        public string? Source { get; set; }
    }

    public class RescheduleRequest
    {
        public string AppointmentDate { get; set; } = "";
        public string AppointmentTime { get; set; } = "";
    }
}
