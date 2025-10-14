# Security Guidelines for Secret Management

## 🚨 Never Commit Secrets

**CRITICAL**: Never commit API keys, passwords, tokens, or any sensitive data to version control.

## ✅ Best Practices

### 1. Use Rails Credentials
```bash
# Edit encrypted credentials
rails credentials:edit

# Edit environment-specific credentials
rails credentials:edit --environment=production
```

### 2. Environment Variables
Use environment variables for deployment secrets:
```ruby
# config/database.yml
password: <%= ENV["DATABASE_PASSWORD"] %>

# In code
Rails.application.credentials.dig(:aws, :secret_access_key)
```

### 3. Kamal Secrets Management
For deployment with Kamal:
```bash
# Add secrets to .kamal/secrets
echo "SECRET_VALUE=your_secret_here" >> .kamal/secrets

# Deploy with secrets
kamal deploy
```

## 🔍 Secret Detection

This project includes automated secret detection:

### Pre-commit Hooks
- **git-secrets** scans commits before they're made
- Automatically blocks commits containing potential secrets
- Configured patterns detect:
  - AWS access keys
  - API keys
  - Passwords
  - Tokens
  - Secret strings

### Manual Scanning
```bash
# Scan current changes
git secrets --scan

# Scan entire repository
git secrets --scan -r

# Scan specific files
git secrets --scan path/to/file
```

## 🚨 If You Committed a Secret

### Immediate Actions
1. **Revoke the secret** immediately from the service provider
2. **Remove from code** and replace with environment variable
3. **Rotate the secret** with a new value
4. **Consider git history rewrite** (see below)

### Git History Rewriting
⚠️ **WARNING**: Rewriting git history is dangerous and can break collaboration.

```bash
# Only if you're absolutely sure and understand the implications
git filter-branch --force --index-filter 'git rm --cached --ignore-unmatch path/to/file' --prune-empty --tag-name-filter cat -- --all

# Or use BFG Repo-Cleaner (safer alternative)
# Download: https://rtyley.github.io/bfg-repo-cleaner/
java -jar bfg.jar --delete-files file-with-secrets.txt
```

### After History Rewrite
```bash
git push origin --force --all
git push origin --force --tags
```

## 📋 Secret Types to Protect

- **API Keys**: Stripe, Twilio, Google Cloud, AWS
- **Database Credentials**: Passwords, connection strings
- **Third-party Tokens**: GitHub tokens, OAuth tokens
- **Encryption Keys**: JWT secrets, encryption keys
- **Service Credentials**: Redis, Sidekiq, cache keys

## 🛠️ Development Setup

### Environment Variables Template
Create `.env.example`:
```bash
# Database
DATABASE_HOST=localhost
DATABASE_PASSWORD=

# External Services
STRIPE_API_KEY=
TWILIO_AUTH_TOKEN=

# Rails
SECRET_KEY_BASE=
```

### Credentials Structure
```ruby
# config/credentials.yml.enc
aws:
  access_key_id: <%= ENV["AWS_ACCESS_KEY_ID"] %>
  secret_access_key: <%= ENV["AWS_SECRET_ACCESS_KEY"] %>

stripe:
  secret_key: <%= ENV["STRIPE_SECRET_KEY"] %>
  publishable_key: <%= ENV["STRIPE_PUBLISHABLE_KEY"] %>
```

## 🔒 Regular Security Practices

1. **Audit dependencies**: `bundle audit` regularly
2. **Scan for vulnerabilities**: `brakeman` for security issues
3. **Review access logs**: Monitor unusual access patterns
4. **Rotate secrets**: Regularly rotate all secrets
5. **Use least privilege**: Grant minimum necessary permissions

## 📞 Incident Response

If a secret is exposed:
1. **Immediate revocation** of exposed credentials
2. **Assess impact** - what could be accessed?
3. **Rotate all related secrets**
4. **Review access logs** for unusual activity
5. **Document the incident** for future prevention
6. **Communicate with team** about the breach

## 📚 Additional Resources

- [Rails Security Guide](https://guides.rubyonrails.org/security.html)
- [OWASP Secret Management](https://owasp.org/www-project-cheat-sheets/cheatsheets/Secret_Management_Cheat_Sheet.html)
- [git-secrets Documentation](https://github.com/awslabs/git-secrets)

---

**Remember**: The best secret management is not having secrets in your codebase at all!