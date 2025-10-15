# Gmail SMTP Setup Instructions

## Step 1: Create Gmail App Password

1. **Go to your Google Account**: https://myaccount.google.com/
2. **Enable 2-Step Authentication** (if not already enabled):
   - Go to Security → 2-Step Verification
   - Turn it on
3. **Create App Password**:
   - Go to Security → App Passwords
   - Select "Mail" from the app dropdown
   - Select "Other (custom name)" from device dropdown
   - Name it "ProdFinder"
   - Click "Generate"
   - Copy the 16-character password (it will look like: xxxx xxxx xxxx xxxx)

## Step 2: Update Environment Variables

Once you have the app password, I'll update the configuration file.

## Step 3: Test the Configuration

I'll test the email delivery to make sure it works.