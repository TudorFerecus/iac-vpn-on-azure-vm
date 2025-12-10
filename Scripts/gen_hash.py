import bcrypt
import getpass

def generate():
    print("--- WireGuard Web UI Hash Generator ---")
    password = getpass.getpass("password:")
    
    if not password:
        print("Error: Password cannot be empty.")
        return

    # Generate salt and hash
    # wg-easy uses standard bcrypt
    bytes_password = password.encode('utf-8')
    salt = bcrypt.gensalt()
    hash_result = bcrypt.hashpw(bytes_password, salt)

    print("\n✅ DONE! Add the hash below to ./group_vars/vpn_server.yml file")
    print("-" * 60)

    # Decode to string for display
    print(f"web_password_hash='{hash_result.decode('utf-8')}'")
    print("-" * 60)

if __name__ == "__main__":
    generate()