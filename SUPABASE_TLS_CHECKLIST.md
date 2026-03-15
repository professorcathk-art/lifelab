# Supabase TLS/SSL Certificate Checklist

## 🔍 What to Check in Supabase Dashboard

### Step 1: Verify SSL Certificate Status

1. **Login to Supabase Dashboard**
   - Go to: https://app.supabase.com
   - Select your project: `inlzhosqbccyynofbmjt`

2. **Check Project Settings**
   - Navigate to: **Settings** → **General**
   - Look for SSL/TLS settings
   - Verify certificate status is "Active" or "Valid"

### Step 2: Test SSL Certificate Online

Use online SSL checker tools to verify your Supabase domain:

**Your Supabase URL**: `https://inlzhosqbccyynofbmjt.supabase.co`

**SSL Checker Tools**:
1. **SSL Labs**: https://www.ssllabs.com/ssltest/
   - Enter: `inlzhosqbccyynofbmjt.supabase.co`
   - Check for:
     - ✅ Certificate is valid
     - ✅ Certificate chain is complete
     - ✅ TLS 1.2+ supported
     - ✅ TLS 1.3 supported (preferred)

2. **SSL Checker**: https://www.sslshopper.com/ssl-checker.html
   - Enter: `inlzhosqbccyynofbmjt.supabase.co`
   - Verify all checks pass

### Step 3: Check Certificate Chain

**What to Look For**:
- ✅ **Certificate is valid** (not expired)
- ✅ **Certificate chain is complete** (includes intermediate certificates)
- ✅ **Root certificate is trusted** (by iOS/Apple)
- ✅ **TLS 1.2 supported** (minimum for iOS 26.3)
- ✅ **TLS 1.3 supported** (preferred for iOS 26.3)

**Common Issues**:
- ❌ Missing intermediate certificates
- ❌ Expired certificate
- ❌ Self-signed certificate (not trusted)
- ❌ Certificate doesn't match domain

### Step 4: Verify TLS Versions

**Check Supported TLS Versions**:
- TLS 1.0 ❌ (deprecated, iOS 26.3 won't accept)
- TLS 1.1 ❌ (deprecated, iOS 26.3 won't accept)
- TLS 1.2 ✅ (minimum required)
- TLS 1.3 ✅ (preferred, iOS 26.3 default)

**How to Check**:
```bash
# Using openssl (on Mac Terminal)
openssl s_client -connect inlzhosqbccyynofbmjt.supabase.co:443 -tls1_2
openssl s_client -connect inlzhosqbccyynofbmjt.supabase.co:443 -tls1_3
```

### Step 5: Check Supabase Status Page

**Supabase Status**: https://status.supabase.com/

**What to Check**:
- ✅ All services are operational
- ✅ No SSL/TLS incidents reported
- ✅ No certificate issues

### Step 6: Contact Supabase Support (If Needed)

**If SSL Certificate Issues Found**:

1. **Supabase Support**: https://supabase.com/support
2. **Email**: support@supabase.com
3. **Discord**: https://discord.supabase.com

**What to Report**:
- Your project URL: `inlzhosqbccyynofbmjt.supabase.co`
- Issue: "TLS errors on iOS 26.3 devices"
- Error message: "A TLS error caused the secure connection to fail"
- Request: Verify SSL certificate chain is complete and TLS 1.2+ is supported

## 🔧 Supabase Dashboard Actions

### Option 1: Check Project Settings

1. **Go to**: Settings → General
2. **Look for**:
   - SSL/TLS configuration
   - Certificate status
   - TLS version settings

### Option 2: Check API Settings

1. **Go to**: Settings → API
2. **Verify**:
   - Project URL is correct: `https://inlzhosqbccyynofbmjt.supabase.co`
   - API endpoints are using HTTPS (not HTTP)

### Option 3: Check Database Settings

1. **Go to**: Settings → Database
2. **Verify**:
   - Connection pooling is enabled
   - SSL mode is set to "require" or "prefer"

## 🧪 Test Your Supabase Connection

### Test from Terminal (Mac)

```bash
# Test HTTPS connection
curl -v https://inlzhosqbccyynofbmjt.supabase.co/rest/v1/

# Test TLS 1.2
curl --tlsv1.2 -v https://inlzhosqbccyynofbmjt.supabase.co/rest/v1/

# Test TLS 1.3
curl --tlsv1.3 -v https://inlzhosqbccyynofbmjt.supabase.co/rest/v1/
```

**Expected Result**: Should connect successfully with TLS 1.2 or 1.3

### Test from Browser

1. **Open**: https://inlzhosqbccyynofbmjt.supabase.co/rest/v1/
2. **Check browser console** (F12 → Console)
3. **Look for**: SSL/TLS errors or certificate warnings

## 📋 Quick Checklist

- [ ] SSL certificate is valid (not expired)
- [ ] Certificate chain is complete (includes intermediate certs)
- [ ] TLS 1.2 is supported
- [ ] TLS 1.3 is supported (preferred)
- [ ] Certificate matches domain (`*.supabase.co`)
- [ ] No certificate warnings in browser
- [ ] SSL Labs test shows A or A+ rating
- [ ] Supabase status page shows all services operational

## 🚨 If Issues Found

### Issue: Certificate Chain Incomplete

**Solution**: Supabase needs to update their SSL certificate configuration
- Contact Supabase support
- Request complete certificate chain

### Issue: TLS 1.2 Not Supported

**Solution**: Supabase needs to enable TLS 1.2+
- Contact Supabase support
- Request TLS 1.2+ support

### Issue: Certificate Expired

**Solution**: Supabase needs to renew certificate
- Contact Supabase support immediately
- This is a critical issue

## ✅ Expected Result

After checking, you should see:
- ✅ Valid SSL certificate
- ✅ Complete certificate chain
- ✅ TLS 1.2+ supported
- ✅ No certificate warnings
- ✅ SSL Labs rating: A or A+

If all checks pass, the TLS error is likely due to:
- iOS 26.3 stricter validation (handled by our code)
- Temporary network issues (handled by retry logic)
- Apple's review environment (should be resolved with our fixes)

## 📞 Next Steps

1. **Run SSL Labs test** on your Supabase URL
2. **Check Supabase status page** for any incidents
3. **Contact Supabase support** if certificate issues found
4. **Share results** with Apple if Supabase confirms certificate is valid
