#!/usr/bin/env python3
"""
Generate JWT Secret Key for Apple Sign In with Supabase
"""

import jwt
import time
import sys

# 配置信息
TEAM_ID = 'YUNUL5V5R6'  # 您的 Team ID
CLIENT_ID = 'com.resonance.lifelab.service'  # Service ID
KEY_ID = 'M5MGJ54YZ6'  # 您的 Key ID

# Apple Private Key (从 .p8 文件复制)
PRIVATE_KEY = """-----BEGIN PRIVATE KEY-----
MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgBzU0PDjqKRocAC87
T9s1WLf7f5dHVfCoMFFmE3FR07OgCgYIKoZIzj0DAQehRANCAATHpHIE0aNWHMyh
TS6SfMu6DvqP9n5LtM3cdQDNE99bnkkAnDiEPiDtRqqJXhVMNUmzgnka+3E/26tZ
roLqlPAT
-----END PRIVATE KEY-----"""

def generate_jwt_secret(key_id):
    """
    生成 JWT Secret Key
    """
    # 当前时间戳
    now = int(time.time())
    
    # JWT Payload
    payload = {
        'iss': TEAM_ID,  # Team ID
        'iat': now,  # Issued at
        'exp': now + (86400 * 180),  # Expires in 6 months (180 days)
        'aud': 'https://appleid.apple.com',  # Audience
        'sub': CLIENT_ID  # Subject (Service ID)
    }
    
    # JWT Headers
    headers = {
        'kid': key_id,  # Key ID
        'alg': 'ES256'  # Algorithm
    }
    
    try:
        # 生成 JWT
        token = jwt.encode(
            payload,
            PRIVATE_KEY,
            algorithm='ES256',
            headers=headers
        )
        
        return token
    except Exception as e:
        print(f"❌ Error generating JWT: {e}")
        sys.exit(1)

def main():
    print("=" * 60)
    print("Apple Sign In - JWT Secret Key Generator")
    print("=" * 60)
    print()
    
    # 检查 Key ID
    if KEY_ID == 'YOUR_KEY_ID':
        print("⚠️  需要 Key ID 才能生成 JWT")
        print()
        print("如何获取 Key ID:")
        print("1. 登录 Apple Developer")
        print("2. 进入 Certificates, Identifiers & Profiles")
        print("3. 点击左侧 Keys")
        print("4. 找到您创建的 Key (LifeLab Apple Sign In Key)")
        print("5. 点击 Key，查看 Key ID (例如: ABC123DEF4)")
        print()
        
        key_id = input("请输入您的 Key ID: ").strip()
        
        if not key_id:
            print("❌ Key ID 不能为空")
            sys.exit(1)
    else:
        key_id = KEY_ID
    
    print()
    print("生成 JWT Secret Key...")
    print()
    
    # 生成 JWT
    jwt_token = generate_jwt_secret(key_id)
    
    print("=" * 60)
    print("✅ JWT Secret Key 生成成功！")
    print("=" * 60)
    print()
    print("复制以下内容到 Supabase:")
    print()
    print("-" * 60)
    print(jwt_token)
    print("-" * 60)
    print()
    print("配置信息:")
    print(f"  Team ID: {TEAM_ID}")
    print(f"  Key ID: {key_id}")
    print(f"  Client ID: {CLIENT_ID}")
    print()
    print("在 Supabase Dashboard:")
    print("  Authentication → Providers → Apple")
    print("  - Client ID: com.resonance.lifelab.service")
    print("  - Client Secret: (粘贴上面的 JWT)")
    print("  - Key ID: (粘贴上面的 Key ID)")
    print("  - Team ID: YUNUL5V5R6")
    print()

if __name__ == '__main__':
    main()
