# ☁️ Azure WireGuard VPN - Infrastructure as Code

This project provides a complete **Infrastructure as Code (IaC)** solution to deploy your own private WireGuard VPN server on Microsoft Azure.

It uses **Terraform** to provision the cloud infrastructure (Virtual Machine, Networking, Firewall) and **Ansible** to automate the configuration (Docker, WireGuard container, and Web UI deployment).

---

## ⁉️ Why would I want this???

It's simple: students like free or cheap stuff. Good VPNs are usually neither, but there are workarounds.

Azure offers a great grant for Students (about $100 in credit). Because life is never easy, that credit isn't enough to cover Azure's managed VPN Gateway service for the full 12 months.

**However**, it is more than enough to run a small 1-core VM (Standard B-series). This project lets you build your own VPN on that cheap VM, with the added bonus that you can use the remaining resources for other projects too.

If you are a student and need a VPN, this is a fun and practical way of getting one while learning some DevOps skills along the way.

## 📂 Project Structure

```text
.
├── Ansible
│   ├── inventory.ini           # Defines server IP, SSH key, and Web UI password hash
│   └── vpn_wg_docker.yml       # Playbook to deploy Docker and WireGuard (wg-easy)
├── Scripts
│   ├── gen_hash.py             # Helper script to generate secure password hashes
│   └── vpn_connect_dissconnect.sh # Helper script to easily connect/disconnect on Linux
├── Terraform
│   ├── main.tf                 # Azure infrastructure definition
│   ├── terraform.tfvars        # (Optional) External variables for customization
│   ├── variables.tf            # Variable declarations
│   ├── terraform.tfstate       # State file (generated)
│   └── terraform.tfstate.backup # Backup state (generated)
└── README.md

```

## 🛠️ Prerequisites

Ensure you have the following installed on your local machine:
* **Azure CLI** (`az`)
* **Terraform**
* **Ansible**
* **Python 3** (for the helper scripts)
* **SSH Key Pair**: If you don't have one, generate it: `ssh-keygen -t rsa -f ~/.ssh/vpn_vm_key`

---

# 🚀 Setup & Configuration Guide

## Step 1: Azure Authentication

Before running any code, you must authenticate with Azure and retrieve
your Subscription ID.

1.  Open your terminal and log in:

``` bash
az login
```

2.  Once logged in, list your accounts to find your **Subscription ID**:

``` bash
az account list --output table
```

Copy the `SubscriptionId`. You will need this for Terraform.

------------------------------------------------------------------------

## Step 2: Provision Infrastructure (Terraform)

1.  Navigate to the Terraform directory:

``` bash
cd Terraform
```

2.  Open `main.tf` and update the `subscription_id` and `public_key`
    path.

    -   **(Optional):** You can use `terraform.tfvars` to define
        variables externally (like `location` or specific IP
        allow-lists).

3.  Initialize and apply the configuration:

``` bash
terraform init
terraform apply
```

(Type **yes** when prompted).

4.  **Critical:** At the end of the output, Terraform will display the
    **Public IP** of the created VM.\
    Note this IP down.

------------------------------------------------------------------------

## Step 3: Configure VPN & Web UI (Ansible)

### 1. Generate a Secure Password Hash

WireGuard Easy requires a specific hash format for the Web UI password.
Run the provided helper script:

``` bash
python3 Scripts/gen_hash.py
```

Copy the resulting hash output (including the single quotes).

### 2. Update Inventory

Edit `Ansible/inventory.ini`. Replace the placeholder IP with your new
Public IP and paste the password hash generated above into the
`[vpn_servers:vars]` section.

### 3. Run the Playbook:

``` bash
cd Ansible
ansible-playbook -i inventory.ini vpn_wg_docker.yml
```

------------------------------------------------------------------------

# 🖥️ Managing Clients (Web UI)

Once Ansible finishes, the VPN server is running inside a Docker
container.

1.  Open your browser and navigate to:\
    `http://<YOUR_SERVER_IP>:51821`
2.  Log in with the password you set (the plain text version, not the
    hash).
3.  Click **"New Client"** to create users (e.g., `Laptop`, `Phone`).
4.  **For Mobile:** Click the QR code icon and scan it with the
    WireGuard app.
5.  **For Desktop:** Click the Download icon to save the `.conf` file
    (save it to the `Configs/` folder).

------------------------------------------------------------------------

# 🐧 Connecting to the VPN (Linux)

You can use the standard `wg-quick` command, or the provided helper
script for a smoother experience.

### Using the Helper Script:

``` bash
# To Connect
./Scripts/vpn_connect_disconnnect.sh ./Configs/Tudor.conf connect

# To Disconnect
./Scripts/vpn_connect_disconnnect.sh ./Configs/Tudor.conf disconnect
```

------------------------------------------------------------------------

### 🐧 Important Note for Linux Users (`resolvconf` error)

If you are using a distribution like **Arch Linux** or others where you manage DNS manually, you might encounter this error when connecting:
`resolvconf: signature mismatch: /etc/resolv.conf`

**The Fix:**
1.  Open your downloaded `.conf` file (e.g., `Configs/Tudor.conf`).
2.  Find the line starting with `DNS = ...`.
3.  **Comment it out** by adding a `#` at the start:
    ```ini
    [Interface]
    ...
    # DNS = 1.1.1.1
    ```
4.  Save and try connecting again.

*Note: This prevents the VPN from overwriting your local DNS settings, avoiding the conflict.*

# ⚠️ Important Notes for Student Subscriptions

1. Provider Registration: The Terraform config includes `skip_provider_registration = true` to prevent permission errors common with Azure for Students.

2. Regions: Free/Student accounts are often restricted in popular regions like westeurope. If deployment fails with a "Policy" or "Quota" error, try US regions (`eastus`).

# 🔮 Roadmap / Future Updates

* [x] Docker Support: Replaced bare-metal installation with wg-easy Docker container for Web UI management.

* [ ] Dynamic Inventory: Configure Terraform to automatically generate the inventory.ini file with the correct IP.

* [ ] Security Hardening: Restrict SSH access in the Network Security Group (NSG) to allow connections only from your specific home IP address.

* [ ] HTTPS: Add SSL certificates (Let's Encrypt) for the Web UI.