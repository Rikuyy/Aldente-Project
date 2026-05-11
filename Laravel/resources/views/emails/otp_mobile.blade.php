<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Kode OTP CookCase</title>
    <style>
        body { font-family: Arial, sans-serif; background-color: #f5f5f5; margin: 0; padding: 0; }
        .container { max-width: 500px; margin: 40px auto; background: #ffffff; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 12px rgba(0,0,0,0.1); }
        .header { background-color: #FF7643; padding: 32px; text-align: center; }
        .header h1 { color: white; margin: 0; font-size: 28px; font-weight: 900; letter-spacing: -0.5px; }
        .header p { color: rgba(255,255,255,0.8); margin: 8px 0 0; font-size: 14px; }
        .body { padding: 32px; text-align: center; }
        .body p { color: #555; font-size: 15px; line-height: 1.6; }
        .otp-box { background: #FFF7ED; border: 2px dashed #FF7643; border-radius: 12px; padding: 24px; margin: 24px 0; }
        .otp-code { font-size: 48px; font-weight: 900; color: #FF7643; letter-spacing: 12px; margin: 0; }
        .otp-expire { color: #999; font-size: 13px; margin-top: 8px; }
        .footer { background: #f9f9f9; padding: 20px; text-align: center; border-top: 1px solid #eee; }
        .footer p { color: #aaa; font-size: 12px; margin: 0; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Cook<span style="color: #FFD700;">Case</span></h1>
            <p>Optimasi Budget Makan Mahasiswa</p>
        </div>
        <div class="body">
            <p>Halo! Kamu meminta kode OTP untuk reset password akun CookCase kamu.</p>
            <p>Gunakan kode berikut untuk melanjutkan:</p>
            <div class="otp-box">
                <p class="otp-code">{{ $kode }}</p>
                <p class="otp-expire">⏱ Kode berlaku selama <strong>2 menit</strong></p>
            </div>
            <p>Jika kamu tidak meminta reset password, abaikan email ini.</p>
            <p style="color: #FF7643; font-weight: bold;">Jangan bagikan kode ini kepada siapapun!</p>
        </div>
        <div class="footer">
            <p>© 2026 CookCase. Semua hak dilindungi.</p>
        </div>
    </div>
</body>
</html>