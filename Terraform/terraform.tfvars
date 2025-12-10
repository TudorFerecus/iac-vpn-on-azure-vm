subscription_id   = "X-X-X-X-X"     # Change to your Subscription ID
location          = "switzerlandnorth"                         # Change the location as needed
vm_user           = "useradmin"                                # Username for the VM
private_key_path  = "key path here"                        # Path to the private SSH key

# --- Optional: Cloudflare DNS & SSL ---
# Only set these if you want a custom domain + HTTPS
cloudflare_api    = "API here" # Change to your Cloudflare API Token
dns_name          = "Subdomain here"                                      # Change to your desired DNS name (will be used to create a Cloudflare DNS record)
domain_name       = "Domain here"                          # Change to your domain name (must be managed in Cloudflare)
zone_id           = "ID here"         # Change to your Cloudflare Zone ID for the domain
account_id        = "ID here"         # Change to your Cloudflare Account ID
create_dns_record = true                                       # Set to true to create a Cloudflare DNS record for the VPN server
