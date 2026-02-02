/**
 * EmailService - Singleton Pattern
 * 
 * A simple, reusable email service for any Salesforce org
 * 12 features, zero dependencies, production-ready
 * 
 * MIT License
 * 
 * Copyright (c) 2025 PAVANSAI KODANDA
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 * 
 * Author: PAVANSAIKODANDA
 * Version: 1.0.0
 * Last Updated: February 2025
 * Repository: https://github.com/pavansaikodanda/EmailService.git
 * 
 * FEATURES:
 * 1. Send Simple Email (Text Only)
 * 2. Send to Multiple Recipients
 * 3. Send with CC
 * 4. Send with CC and BCC
 * 5. Send HTML Email
 * 6. Send Email with Template
 * 7. Send Email with Attachments
 * 8. Batch Send Emails (respects governor limits)
 * 9. Send from Org-Wide Email Address
 * 10. Send Email and Save as Activity
 * 11. Get Email Send Results (with error handling)
 * 12. Send HTML Email with Attachments
 * 
 * USAGE:
 *   EmailService emailService = EmailService.getInstance();
 *   emailService.sendEmail('user@example.com', 'Subject', 'Body');
 *   emailService.sendHtmlEmail(new List<String>{'user@example.com'}, 'Subject', '<h1>HTML</h1>');
 *   emailService.sendBatchEmails(emailMessages);
 * 
 * DEPENDENCIES: None
 * 
 * NOTES:
 * - This is a Singleton Pattern implementation
 * - Works with any Salesforce org
 * - Automatic batch management (sends in groups of 100)
 * - Built-in error handling and logging
 */
public class EmailService {
    private static EmailService instance;
    
    private EmailService() {
    }
    
    /**
     * Get singleton instance
     */
    public static EmailService getInstance() {
        if (instance == null) {
            instance = new EmailService();
        }
        return instance;
    }
    
    // ============================================================================
    // FEATURE 1: Send Simple Email (Text Only)
    // ============================================================================
    public void sendEmail(String toAddress, String subject, String body) {
        sendEmailInternal(new List<String>{toAddress}, subject, body, null, null);
    }
    
    // ============================================================================
    // FEATURE 2: Send to Multiple Recipients
    // ============================================================================
    public void sendEmail(List<String> toAddresses, String subject, String body) {
        sendEmailInternal(toAddresses, subject, body, null, null);
    }
    
    // ============================================================================
    // FEATURE 3: Send with CC
    // ============================================================================
    public void sendEmailWithCC(List<String> toAddresses, String subject, String body, List<String> ccAddresses) {
        sendEmailInternal(toAddresses, subject, body, ccAddresses, null);
    }
    
    // ============================================================================
    // FEATURE 4: Send with CC and BCC
    // ============================================================================
    public void sendEmailWithCCAndBCC(List<String> toAddresses, String subject, String body, 
                                      List<String> ccAddresses, List<String> bccAddresses) {
        sendEmailInternal(toAddresses, subject, body, ccAddresses, bccAddresses);
    }
    
    /**
     * Internal method to send email with all combinations
     */
    private void sendEmailInternal(List<String> toAddresses, String subject, String body,
                                   List<String> ccAddresses, List<String> bccAddresses) {
        try {
            if (toAddresses == null || toAddresses.isEmpty()) {
                System.debug('No recipients provided');
                return;
            }
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(listToArray(toAddresses));
            mail.setSubject(subject);
            mail.setPlainTextBody(body);
            
            if (ccAddresses != null && !ccAddresses.isEmpty()) {
                mail.setCcAddresses(listToArray(ccAddresses));
            }
            
            if (bccAddresses != null && !bccAddresses.isEmpty()) {
                mail.setBccAddresses(listToArray(bccAddresses));
            }
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
        } catch (Exception e) {
            System.debug('Error sending email: ' + e.getMessage());
        }
    }
    
    // ============================================================================
    // FEATURE 5: Send HTML Email
    // ============================================================================
    public void sendHtmlEmail(String toAddress, String subject, String htmlBody) {
        sendHtmlEmail(new List<String>{toAddress}, subject, htmlBody, null, null);
    }
    
    public void sendHtmlEmail(List<String> toAddresses, String subject, String htmlBody) {
        sendHtmlEmail(toAddresses, subject, htmlBody, null, null);
    }
    
    public void sendHtmlEmail(List<String> toAddresses, String subject, String htmlBody,
                             List<String> ccAddresses, List<String> bccAddresses) {
        try {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(listToArray(toAddresses));
            mail.setSubject(subject);
            mail.setHtmlBody(htmlBody);
            mail.setPlainTextBody(stripHtmlTags(htmlBody));
            
            if (ccAddresses != null && !ccAddresses.isEmpty()) {
                mail.setCcAddresses(listToArray(ccAddresses));
            }
            
            if (bccAddresses != null && !bccAddresses.isEmpty()) {
                mail.setBccAddresses(listToArray(bccAddresses));
            }
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
        } catch (Exception e) {
            System.debug('Error sending HTML email: ' + e.getMessage());
        }
    }
    
    // ============================================================================
    // FEATURE 6: Send Email with Template
    // ============================================================================
    public void sendTemplateEmail(String templateName, String toAddress, String targetObjectId) {
        sendTemplateEmail(templateName, new List<String>{toAddress}, targetObjectId, null, null);
    }
    
    public void sendTemplateEmail(String templateName, List<String> toAddresses, String targetObjectId) {
        sendTemplateEmail(templateName, toAddresses, targetObjectId, null, null);
    }
    
    public void sendTemplateEmail(String templateName, List<String> toAddresses, String targetObjectId,
                                 List<String> ccAddresses, List<String> bccAddresses) {
        try {
            EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE Name = :templateName LIMIT 1];
            
            if (template == null) {
                System.debug('Template not found: ' + templateName);
                return;
            }
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateId(template.Id);
            mail.setToAddresses(listToArray(toAddresses));
            mail.setTargetObjectId(targetObjectId);
            
            if (ccAddresses != null && !ccAddresses.isEmpty()) {
                mail.setCcAddresses(listToArray(ccAddresses));
            }
            
            if (bccAddresses != null && !bccAddresses.isEmpty()) {
                mail.setBccAddresses(listToArray(bccAddresses));
            }
            
            mail.setSaveAsActivity(true);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
        } catch (Exception e) {
            System.debug('Error sending template email: ' + e.getMessage());
        }
    }
    
    // ============================================================================
    // FEATURE 7: Send Email with Attachments
    // ============================================================================
    public void sendEmailWithAttachments(List<String> toAddresses, String subject, String body,
                                        List<String> attachmentIds) {
        try {
            List<Attachment> attachments = [
                SELECT Id, Body, Name, ContentType 
                FROM Attachment 
                WHERE Id IN :attachmentIds
            ];
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(listToArray(toAddresses));
            mail.setSubject(subject);
            mail.setPlainTextBody(body);
            
            List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();
            
            for (Attachment att : attachments) {
                Messaging.EmailFileAttachment emailAtt = new Messaging.EmailFileAttachment();
                emailAtt.setFileName(att.Name);
                emailAtt.setBody(att.Body);
                emailAtt.setContentType(att.ContentType);
                emailAttachments.add(emailAtt);
            }
            
            mail.setFileAttachments(emailAttachments);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
        } catch (Exception e) {
            System.debug('Error sending email with attachments: ' + e.getMessage());
        }
    }
    
    // ============================================================================
    // FEATURE 8: Batch Send Emails
    // ============================================================================
    public void sendBatchEmails(List<EmailMessage> emailMessages) {
        try {
            if (emailMessages == null || emailMessages.isEmpty()) {
                return;
            }
            
            List<Messaging.SingleEmailMessage> batchList = new List<Messaging.SingleEmailMessage>();
            
            for (EmailMessage emailMsg : emailMessages) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(listToArray(emailMsg.toAddresses));
                mail.setSubject(emailMsg.subject);
                mail.setPlainTextBody(emailMsg.body);
                
                if (emailMsg.ccAddresses != null && !emailMsg.ccAddresses.isEmpty()) {
                    mail.setCcAddresses(listToArray(emailMsg.ccAddresses));
                }
                
                if (emailMsg.bccAddresses != null && !emailMsg.bccAddresses.isEmpty()) {
                    mail.setBccAddresses(listToArray(emailMsg.bccAddresses));
                }
                
                batchList.add(mail);
                
                // Send when batch reaches 100 emails
                if (batchList.size() == 100) {
                    Messaging.sendEmail(batchList);
                    batchList = new List<Messaging.SingleEmailMessage>();
                }
            }
            
            // Send remaining emails
            if (!batchList.isEmpty()) {
                Messaging.sendEmail(batchList);
            }
        } catch (Exception e) {
            System.debug('Error in batch email sending: ' + e.getMessage());
        }
    }
    
    // ============================================================================
    // FEATURE 9: Send to Org-Wide Email Address
    // ============================================================================
    public void sendEmailFromOrgWideAddress(String orgWideEmailAddress, List<String> toAddresses, 
                                           String subject, String body) {
        try {
            OrgWideEmailAddress[] owaList = [
                SELECT Id FROM OrgWideEmailAddress 
                WHERE Address = :orgWideEmailAddress 
                LIMIT 1
            ];
            
            if (owaList.isEmpty()) {
                System.debug('Org-wide email address not found: ' + orgWideEmailAddress);
                return;
            }
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setOrgWideEmailAddressId(owaList[0].Id);
            mail.setToAddresses(listToArray(toAddresses));
            mail.setSubject(subject);
            mail.setPlainTextBody(body);
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
        } catch (Exception e) {
            System.debug('Error sending from org-wide email: ' + e.getMessage());
        }
    }
    
    // ============================================================================
    // FEATURE 10: Send Email and Save as Activity
    // ============================================================================
    public void sendEmailAndSaveActivity(String toAddress, String subject, String body) {
        try {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[]{toAddress});
            mail.setSubject(subject);
            mail.setPlainTextBody(body);
            mail.setSaveAsActivity(true);
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
        } catch (Exception e) {
            System.debug('Error sending email with activity: ' + e.getMessage());
        }
    }
    
    // ============================================================================
    // FEATURE 11: Get Email Send Results (with error handling)
    // ============================================================================
    public List<Messaging.SendEmailResult> sendEmailAndGetResults(List<String> toAddresses, 
                                                                  String subject, String body) {
        try {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(listToArray(toAddresses));
            mail.setSubject(subject);
            mail.setPlainTextBody(body);
            
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
            return results;
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            return new List<Messaging.SendEmailResult>();
        }
    }
    
    // ============================================================================
    // FEATURE 12: Send HTML Email with Attachments
    // ============================================================================
    public void sendHtmlEmailWithAttachments(List<String> toAddresses, String subject, String htmlBody,
                                            List<String> attachmentIds) {
        try {
            List<Attachment> attachments = [
                SELECT Id, Body, Name, ContentType 
                FROM Attachment 
                WHERE Id IN :attachmentIds
            ];
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(listToArray(toAddresses));
            mail.setSubject(subject);
            mail.setHtmlBody(htmlBody);
            mail.setPlainTextBody(stripHtmlTags(htmlBody));
            
            List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();
            
            for (Attachment att : attachments) {
                Messaging.EmailFileAttachment emailAtt = new Messaging.EmailFileAttachment();
                emailAtt.setFileName(att.Name);
                emailAtt.setBody(att.Body);
                emailAtt.setContentType(att.ContentType);
                emailAttachments.add(emailAtt);
            }
            
            mail.setFileAttachments(emailAttachments);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
        } catch (Exception e) {
            System.debug('Error sending HTML email with attachments: ' + e.getMessage());
        }
    }
    
    // ============================================================================
    // HELPER: Convert List to String Array
    // ============================================================================
    private String[] listToArray(List<String> stringList) {
        String[] result = new String[stringList.size()];
        for (Integer i = 0; i < stringList.size(); i++) {
            result[i] = stringList.get(i);
        }
        return result;
    }
    
    // ============================================================================
    // HELPER: Strip HTML Tags
    // ============================================================================
    private String stripHtmlTags(String htmlContent) {
        if (String.isBlank(htmlContent)) return '';
        return htmlContent.replaceAll('<[^>]+>', '');
    }
    
    // ============================================================================
    // INNER CLASS: Email Message
    // ============================================================================
    public class EmailMessage {
        public List<String> toAddresses;
        public List<String> ccAddresses;
        public List<String> bccAddresses;
        public String subject;
        public String body;
        
        public EmailMessage(String toAddress, String subject, String body) {
            this.toAddresses = new List<String>{toAddress};
            this.subject = subject;
            this.body = body;
        }
        
        public EmailMessage(List<String> toAddresses, String subject, String body) {
            this.toAddresses = toAddresses;
            this.subject = subject;
            this.body = body;
        }
    }
}