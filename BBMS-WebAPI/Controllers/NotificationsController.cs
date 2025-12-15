using Microsoft.AspNetCore.Mvc;
using BBMS_Business;
using System.Data;

namespace BBMS_WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class NotificationsController : ControllerBase
    {
        [HttpGet("{mobileUserID}")]
        public IActionResult GetNotifications(int mobileUserID)
        {
            try
            {
                var notifications = clsNotification.GetNotificationsByMobileUserID(mobileUserID);
                var notificationList = new List<object>();

                foreach (DataRow row in notifications.Rows)
                {
                    notificationList.Add(new
                    {
                        notificationID = (int)row["NotificationID"],
                        title = row["Title"].ToString(),
                        message = row["Message"].ToString(),
                        notificationType = row["NotificationType"].ToString(),
                        isRead = (bool)row["IsRead"],
                        createdDate = ((DateTime)row["CreatedDate"]).ToString("yyyy-MM-ddTHH:mm:ss"),
                        transfusionID = row["TransfusionID"] != DBNull.Value ? (int?)row["TransfusionID"] : null,
                        donationID = row["DonationID"] != DBNull.Value ? (int?)row["DonationID"] : null
                    });
                }

                return Ok(new { notifications = notificationList });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = ex.Message });
            }
        }

        [HttpPost("read/{notificationID}")]
        public IActionResult MarkAsRead(int notificationID)
        {
            try
            {
                var notification = clsNotification.Find(notificationID);
                if (notification == null)
                {
                    return NotFound(new { success = false, message = "Notification not found" });
                }

                if (notification.MarkAsRead())
                {
                    return Ok(new { success = true, message = "Notification marked as read" });
                }

                return Ok(new { success = false, message = "Failed to mark notification as read" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }

        [HttpPost("clear/{mobileUserID}")]
        public IActionResult ClearAllNotifications(int mobileUserID)
        {
            try
            {
                if (clsNotification.DeleteAll(mobileUserID))
                {
                    return Ok(new { success = true, message = "All notifications cleared" });
                }

                return Ok(new { success = false, message = "Failed to clear notifications" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }
    }
}
