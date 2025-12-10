subscription_id   = "6ab21efd-7635-46ff-9c98-179d2ba8fed1"     # Change to your Subscription ID
location          = "switzerlandnorth"                         # Change the location as needed
vm_user           = "useradmin"                                # Username for the VM
private_key_path  = "~/.ssh/vpn_vm_key"                        # Path to the private SSH key

# --- Optional: Cloudflare DNS & SSL ---
# Only set these if you want a custom domain + HTTPS
cloudflare_api    = "dpFwaSuygn_ZLdtGS77k24m5bKQLxOyt5XGhd2Ne" # Change to your Cloudflare API Token
dns_name          = "vpn"                                      # Change to your desired DNS name (will be used to create a Cloudflare DNS record)
domain_name       = "tudorferecus.ro"                          # Change to your domain name (must be managed in Cloudflare)
zone_id           = "7e2817cd772dd003b60a63c167f7acd3"         # Change to your Cloudflare Zone ID for the domain
account_id        = "b914d4d191f5d8e386581623de028f85"         # Change to your Cloudflare Account ID
create_dns_record = true                                       # Set to true to create a Cloudflare DNS record for the VPN server
