import http.server
import ssl
from pathlib import Path
import subprocess

# Function to generate a self-signed certificate
def generate_certificate(domain):
    key_file = f"{domain}.key"
    cert_file = f"{domain}.crt"

    # Check if the certificate already exists
    if not Path(key_file).exists() or not Path(cert_file).exists():
        print(f"Generating self-signed certificate for {domain}...")
        subprocess.run([
            "openssl", "req", "-x509", "-newkey", "rsa:4096", "-sha256", "-days", "365",
            "-nodes", "-keyout", key_file, "-out", cert_file,
            "-subj", f"/CN={domain}"
        ])
    else:
        print(f"Using existing certificate for {domain}")

    return key_file, cert_file

# Generate certificate for polyfill.io
key_file, cert_file = generate_certificate("polyfill.io")

# Set up the HTTP server
server_address = ('', 9000)
httpd = http.server.HTTPServer(server_address, http.server.SimpleHTTPRequestHandler)

# Wrap the server with SSL
httpd.socket = ssl.wrap_socket(httpd.socket, keyfile=key_file, certfile=cert_file, server_side=True)

print(f"Serving on https://localhost:9000...")
httpd.serve_forever()
