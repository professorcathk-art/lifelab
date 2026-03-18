# Supabase Custom SMTP with Google Workspace

Configure Supabase Auth to send emails (OTP, password reset, confirmation) via your Google Workspace SMTP.

## Prerequisites

1. **2-Step Verification** – Enable on your Google Workspace admin account at [myaccount.google.com/security](https://myaccount.google.com/security) (not in the admin console).
2. **App Password** – Required; regular Gmail password will not work.

## Step 1: Create an App Password

1. Go to [myaccount.google.com/security](https://myaccount.google.com/security)
2. Enable **2-Step Verification** if not already enabled
3. Open **App passwords** (search for it in the security page)
4. Choose **Mail** as the app and select your device
5. Copy the 16-character password

## Step 2: Configure Supabase SMTP

1. Open your project: [Supabase Dashboard](https://supabase.com/dashboard) → **Authentication** → **SMTP Settings**
2. Enable **Custom SMTP**
3. Use these values:

| Setting | Value |
|---------|-------|
| **SMTP Host** | `smtp.gmail.com` (or `smtp-relay.gmail.com` for relay) |
| **SMTP Port** | `465` (SSL) or `587` (TLS) |
| **SMTP Username** | Your Google Workspace admin email (e.g. `admin@yourdomain.com`) |
| **SMTP Password** | The 16-character app password from Step 1 |
| **Sender email** | Same as username or `no-reply@yourdomain.com` |
| **Sender name** | Your app name (e.g. `LifeLab`) |

### Port notes

- **smtp.gmail.com**: Port 465 or 587
- **smtp-relay.gmail.com**: Port 465 only

## Step 3: Test

Use **Send test email** in the Supabase SMTP settings to confirm delivery.

## Troubleshooting

- **"Invalid credentials"** – Use an app password, not your normal password
- **"Less secure apps"** – Google no longer supports this; use app passwords
- **Delivery issues** – Configure SPF, DKIM, DMARC for your domain
- **Rate limits** – Supabase applies limits; adjust in **Auth** → **Rate Limits**

## Alternative providers

If Google SMTP is unreliable, Supabase recommends:

- [Resend](https://resend.com/docs/send-with-supabase-smtp)
- [SendGrid](https://www.twilio.com/docs/sendgrid/for-developers/sending-email/getting-started-smtp)
- [AWS SES](https://docs.aws.amazon.com/ses/latest/dg/send-email-smtp.html)
- [Mailgun](https://documentation.mailgun.com/en/latest/user_manual.html#smtp-relay)
