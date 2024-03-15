using Newtonsoft.Json;
using System;
using System.Net.Mail;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using EasyNetQ;

namespace eDostava.Subscriber
{
    public class EmailService
    {
        public class EmailModelToParse
        {
            public string Sender { get; set; }
            public string Recipient { get; set; }
            public string Subject { get; set; }
            public string Content { get; set; }
        }
        public void SendEmail(string message)
        {
            try
            {
                string smtpServer = "smtp.gmail.com";
                int smtpPort = 587;
                string fromMail = "edostava9@gmail.com";
                string password = "rnkb bzps lqwl fuhs";

                var emailData = JsonConvert.DeserializeObject<EmailModelToParse>(message);
                var senderEmail = emailData.Sender;
                var recipientEmail = emailData.Recipient;
                var subject = emailData.Subject;
                var content = emailData.Content;

                MailMessage MailMessageObj = new MailMessage();

                MailMessageObj.From = new MailAddress(fromMail);
                MailMessageObj.Subject = subject;
                MailMessageObj.To.Add(recipientEmail);
                MailMessageObj.Body = content;

                var smtpClient = new SmtpClient()
                {
                    Host = smtpServer,
                    Port = smtpPort,
                    Credentials = new NetworkCredential(fromMail, password),
                    EnableSsl = true
                };

                smtpClient.Send(MailMessageObj);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error sending email: {ex.Message}");
            }
        }
    }
}
