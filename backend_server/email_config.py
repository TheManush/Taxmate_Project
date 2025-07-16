# Email Configuration for Password Reset

# Email settings (update these for production)
EMAIL_CONFIG = {
    "smtp_server": "smtp.gmail.com",
    "smtp_port": 587,
    "smtp_username": "ahnafk8@gmail.com",  # Your Gmail address
    "smtp_password": "nnfz obce jkei pfyo",     # Your Gmail app password
    "sender_name": "TaxMate Team"
}

# Email templates
EMAIL_TEMPLATES = {
    "password_reset": {
        "subject": "Password Reset Request - TaxMate",
        "body_template": """
        <html>
        <body>
            <h2>Password Reset Request</h2>
            <p>Hello {user_name},</p>
            <p>You have requested to reset your password.</p>
            
            <h3>Your Reset Token:</h3>
            <div style="background-color: #f5f5f5; padding: 15px; border-radius: 5px; font-family: monospace; font-size: 16px; border: 2px solid #ddd; margin: 10px 0;">
                <strong>{reset_link}</strong>
            </div>
            
            <h3>Instructions:</h3>
            <ol>
                <li>Open the TaxMate app on your device</li>
                <li>Go to "Forgot Password" page</li>
                <li>Click "Test Reset Password (Dev)" button</li>
                <li>Copy the token above and paste it when prompted</li>
                <li>Enter your new password</li>
            </ol>
            
            <p><em>This token will expire in 1 hour.</em></p>
            <p>If you didn't request this password reset, please ignore this email.</p>
            <br>
            <p>Best regards,<br>TaxMate Team</p>
        </body>
        </html>
        """
    }
}

# Instructions for Gmail:
# 1. Enable 2FA on your Gmail account
# 2. Generate an "App Password" for this application
# 3. Use the app password instead of your regular password

# DETAILED STEPS TO GET GMAIL APP PASSWORD:
# 
# Step 1: Enable 2-Factor Authentication (2FA)
# 1. Go to https://myaccount.google.com/security
# 2. Under "Signing in to Google", click "2-Step Verification"
# 3. Follow the prompts to enable 2FA
#
# Step 2: Generate App Password
# 1. Go to https://myaccount.google.com/apppasswords
#    (or Google Account → Security → App passwords)
# 2. Select "Mail" as the app
# 3. Select "Other (custom name)" as the device
# 4. Enter "TaxMate App" as the custom name
# 5. Click "Generate"
# 6. Copy the 16-character password (like: abcd efgh ijkl mnop)
# 7. Use this password in EMAIL_CONFIG["smtp_password"]
#
# Step 3: Update Configuration
# Replace "your-app-password" with the generated app password
# Replace "your-email@gmail.com" with your actual Gmail address
#
# Example:
# EMAIL_CONFIG = {
#     "smtp_username": "yourname@gmail.com",
#     "smtp_password": "abcd efgh ijkl mnop",  # The generated app password
#     ...
# }

# Alternative Email Services:
# - SendGrid: Use SendGrid API for production
# - AWS SES: Amazon Simple Email Service
# - Mailgun: Mailgun API
# - Outlook: smtp-mail.outlook.com:587

# For development testing:
# - Check the console output for reset tokens
# - Tokens expire after 1 hour
# - Use the token to test the reset password endpoint
