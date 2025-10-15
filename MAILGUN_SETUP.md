# Mailgun Setup Instructions

## Step 1: Create Mailgun Account
1. Go to https://www.mailgun.com/
2. Sign up for free account (5,000 free emails/month)
3. Verify your email address

## Step 2: Get Your SMTP Credentials

### Option A: Use Sandbox Domain (Easiest for testing)
1. Go to your Mailgun dashboard
2. Click on "Domains" in the left sidebar
3. You'll see a sandbox domain like: `sandbox1234567890.mailgun.org`
4. Click on the sandbox domain
5. Scroll down to "SMTP Credentials"
6. Copy:
   - **Domain**: sandbox1234567890.mailgun.org
   - **Username**: postmaster@sandbox1234567890.mailgun.org
   - **Password**: [your SMTP password]

### Option B: Use Your Own Domain (For production)
1. Add and verify your domain in Mailgun
2. Update DNS records as instructed
3. Use your domain credentials

## Step 3: Update .env File
Replace the placeholder values in your `.env` file:

```bash
MAILGUN_DOMAIN=your-actual-sandbox-domain.mailgun.org
MAILGUN_USERNAME=postmaster@your-actual-sandbox-domain.mailgun.org
MAILGUN_PASSWORD=your-actual-smtp-password
```

## Step 4: Test Email Delivery
Once configured, I'll test the magic link delivery to your real email.

## Benefits of Mailgun
✅ 5,000 free emails per month
✅ Reliable delivery
✅ Email analytics
✅ Easy setup with sandbox domain
✅ Production-ready
✅ No app passwords needed