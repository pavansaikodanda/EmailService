# EmailService

A simple, reusable email service for any Salesforce org with 12 powerful features.

## Features

1. **Send Simple Email** - Text-only emails
2. **Multiple Recipients** - Send to many users at once
3. **CC Support** - Add CC recipients
4. **CC and BCC Support** - Add CC and BCC recipients
5. **HTML Emails** - Send rich HTML emails with automatic plain text fallback
6. **Email Templates** - Use Salesforce email templates with merge fields
7. **Attachments** - Send emails with file attachments
8. **Batch Sending** - Send hundreds of emails efficiently (auto-batches by 100)
9. **Org-Wide Email** - Send from configured org-wide email addresses
10. **Save as Activity** - Automatically log emails as activities
11. **Get Results** - Retrieve email send results for error handling
12. **HTML + Attachments** - Combine HTML emails with attachments

## Installation

1. Copy `EmailService.cls` to your Salesforce org
2. Copy `EmailServiceTest.cls` to your Salesforce org (for testing)
3. Run tests to verify: `Setup > Apex Test Execution`
4. Deploy to production

## Quick Start

```apex
// Get singleton instance
EmailService emailService = EmailService.getInstance();

// Send a simple email
emailService.sendEmail('user@example.com', 'Subject', 'Body text');

// Send HTML email
emailService.sendHtmlEmail(
    new List<String>{'user@example.com'},
    'Welcome!',
    '<h1>Hello</h1><p>Welcome to our service</p>'
);

// Send using email template
emailService.sendTemplateEmail('WelcomeEmail', 'user@example.com', '003xx000000001');

// Send batch emails
List<EmailService.EmailMessage> messages = new List<EmailService.EmailMessage>();
for (Integer i = 0; i < 500; i++) {
    messages.add(new EmailService.EmailMessage(
        'user' + i + '@example.com',
        'Newsletter',
        'Check out what\'s new this month!'
    ));
}
emailService.sendBatchEmails(messages);
```

## Usage Examples

### Send to Multiple Recipients with CC and BCC

```apex
EmailService emailService = EmailService.getInstance();

emailService.sendEmailWithCCAndBCC(
    new List<String>{'user@example.com', 'user2@example.com'},
    'Important Update',
    'This is important information',
    new List<String>{'cc@example.com'},
    new List<String>{'bcc@example.com'}
);
```

### Send Email with Attachments

```apex
EmailService emailService = EmailService.getInstance();

// Get attachment IDs
List<String> attachmentIds = new List<String>{'069xx000000001', '069xx000000002'};

emailService.sendEmailWithAttachments(
    new List<String>{'user@example.com'},
    'Your Invoice',
    'Please find your invoice attached',
    attachmentIds
);
```

### Send HTML Email with Attachments

```apex
EmailService emailService = EmailService.getInstance();

String htmlBody = '<h2>Invoice</h2><p>Amount: $1000</p>';
List<String> attachmentIds = new List<String>{'069xx000000001'};

emailService.sendHtmlEmailWithAttachments(
    new List<String>{'user@example.com'},
    'Invoice #123',
    htmlBody,
    attachmentIds
);
```

### Send from Org-Wide Email Address

```apex
EmailService emailService = EmailService.getInstance();

emailService.sendEmailFromOrgWideAddress(
    'noreply@company.com',
    new List<String>{'user@example.com'},
    'Order Confirmation',
    'Your order has been confirmed'
);
```

### Send and Save as Activity

```apex
EmailService emailService = EmailService.getInstance();

emailService.sendEmailAndSaveActivity(
    'user@example.com',
    'Follow Up',
    'Following up on our previous conversation'
);
```

### Get Email Send Results (for error handling)

```apex
EmailService emailService = EmailService.getInstance();

List<Messaging.SendEmailResult> results = emailService.sendEmailAndGetResults(
    new List<String>{'user@example.com'},
    'Subject',
    'Body'
);

for (Messaging.SendEmailResult result : results) {
    if (result.isSuccess()) {
        System.debug('Email sent successfully');
    } else {
        for (Messaging.SendEmailError error : result.getErrors()) {
            System.debug('Error: ' + error.getMessage());
        }
    }
}
```

## Design Pattern: Singleton

This implementation uses the **Singleton Pattern** which ensures:

- **Only one instance** of EmailService exists in your org
- **Consistent configuration** across all email operations
- **Memory efficient** - single instance for entire application
- **Easy to use** - `getInstance()` everywhere

```apex
// These both return the SAME instance
EmailService service1 = EmailService.getInstance();
EmailService service2 = EmailService.getInstance();

System.assertEquals(service1, service2); // true
```

## Batch Sending

The batch sending feature automatically respects Salesforce governor limits:

- Sends emails in groups of 100
- No manual batching needed
- Handles 1 to 5000 emails per day
- Automatic error handling

```apex
// Send 500 emails automatically batched
List<EmailService.EmailMessage> messages = new List<EmailService.EmailMessage>();
for (Integer i = 0; i < 500; i++) {
    messages.add(new EmailService.EmailMessage(
        'user' + i + '@example.com',
        'Subject',
        'Body'
    ));
}

// Automatically sends in 5 batches of 100
emailService.sendBatchEmails(messages);
```

## Testing

The package includes 12 comprehensive test cases covering:

- Singleton pattern verification
- All email sending methods
- Multiple recipients
- CC/BCC functionality
- HTML emails
- Email templates
- Attachments
- Batch operations
- Activity saving
- Error handling

Run tests in Salesforce:
```
Setup > Development > Apex Test Execution > Select EmailServiceTest > Run Tests
```

Expected result: **12/12 tests pass**

## Dependencies

**None!** This service works with vanilla Salesforce Apex. No external dependencies required.

## Error Handling

All methods include built-in error handling:

```apex
try {
    emailService.sendEmail('user@example.com', 'Subject', 'Body');
} catch (Exception e) {
    System.debug('Email error: ' + e.getMessage());
}
```

Errors are logged to `System.debug()` and don't crash your code.

## Governor Limits

This service respects Salesforce governor limits:

- Email sending limit: 5,000 per org per day
- Recipients per email: 100
- Batch size: 100 emails at a time
- Auto-detection and graceful failure

## License

MIT License - see LICENSE file for details

## Author

PAVANSAIKODANDA

## Version

1.0.0 (February 2025)

## Contributing

Feel free to fork, modify, and improve this service for your org's needs.

## Support

For issues or questions:
1. Check the code comments
2. Review test cases for usage examples
3. Check Salesforce email API documentation

## Changelog

### v1.0.0 (February 2025)
- Initial release
- 12 email features
- Singleton pattern implementation
- Comprehensive test suite
- MIT License
