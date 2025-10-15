# Email Setup Options

## Option 1: Mailtrap (Recommended for Development)
**Easiest setup - no app passwords needed**

1. Go to https://mailtrap.io/
2. Sign up for free account
3. Go to "Email Testing" → "My Inbox"
4. Copy your SMTP credentials:
   - Username: (looks like: 1a2b3c4d5e6f7g8h)
   - Password: (looks like: 1a2b3c4d5e6f7g8h)
   - Host: smtp.mailtrap.io
   - Port: 2525

5. Update your .env file:
   ```
   MAILTRAP_USERNAME=your-username-here
   MAILTRAP_PASSWORD=your-password-here
   ```

## Option 2: SendGrid (Production-ready)
**For real email delivery to users**

1. Go to https://sendgrid.com/
2. Sign up for free account (100 emails/day free)
3. Create an API key
4. Verify your domain

## Option 3: Gmail (If you prefer)
**Requires App Password setup**

1. Enable 2-Step Authentication in Google Account
2. Create App Password
3. Use Gmail SMTP settings

## Current Status
✅ Magic link authentication works
📧 Emails configured for Mailtrap (easy testing)
🔄 Ready to test once you add Mailtrap credentials