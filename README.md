# ☁️ Azure WireGuard VPN - Infrastructure as Code

This project provides a complete **Infrastructure as Code (IaC)** solution to deploy your own private WireGuard VPN server on Microsoft Azure.

It uses **Terraform** to provision the cloud infrastructure (Virtual Machine, Networking, Firewall) and **Ansible** to automate the configuration (WireGuard installation, key generation, and client management).

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
│   ├── inventory.ini       # Defines the server IP and SSH connection details
│   └── vpn_multi_users.yml # Playbook to install WireGuard and manage users
├── Terraform
│   ├── main.tf             # Azure infrastructure definition
│   ├── terraform.tfstate   # (Created after apply)
│   └── ...
└── README.md
```

---

## 🛠️ Prerequisites

Ensure you have the following installed on your local machine:
* **Azure CLI** (`az`)
* **Terraform**
* **Ansible**
* **SSH Key Pair**: If you don't have one, generate it: `ssh-keygen -t rsa -f ~/.ssh/vpn_vm_key`

---

## 🚀 Setup & Configuration Guide

### Step 1: Azure Authentication

Before running any code, you must authenticate with Azure and retrieve your Subscription ID.

1.  Open your terminal and log in:
    ```bash
    az login
    ```
    *(This will open a browser window to authenticate).*

2.  Once logged in, list your accounts to find your **Subscription ID**:
    ```bash
    az account list --output table
    ```
    *Copy the `SubscriptionId` (e.g., `6ab21efd-xxxx-xxxx...`). You will need this for Terraform.*

### Step 2: Provision Infrastructure (Terraform)

1.  Navigate to the Terraform directory:
    ```bash
    cd Terraform
    ```

2.  Open **`main.tf`** and update the following values:
    * **`subscription_id`**: Paste the ID you copied in Step 1.
    * **`public_key`**: Ensure the path points to your actual public key (e.g., `~/.ssh/vpn_vm_key.pub`).
    * **`location`**: Currently set to `switzerlandnorth`. If you encounter region restrictions (common with Student accounts), try changing this to `eastus`.

3.  Initialize and apply the configuration:
    ```bash
    terraform init
    terraform apply
    ```
    *(Type `yes` when prompted).*

4.  **Critical:** At the end of the output, Terraform will display the **Public IP** of the created VM. **Note this IP down.**

### Step 3: Configure VPN & Clients (Ansible)

1.  Navigate to the Ansible directory:
    ```bash
    cd ../Ansible
    ```

2.  Edit **`inventory.ini`**:
    * Replace the placeholder IP with the **Public IP** you got from Terraform.
    * Ensure `ansible_ssh_private_key_file` points to your private key.

3.  Edit **`vpn_multi_users.yml`**:
    * Update `vpn_setup` (approx. line 6) with the same **Public IP**.
    * **Manage Users:** Add your devices to the `vpn_clients` list. The playbook will automatically calculate IPs and generate config files for every name in this list.
    ```yaml
    vpn_clients:
      - "laptop"
      - "iphone"
      - "tablet"
    ```

4.  Run the playbook:
    ```bash
    ansible-playbook -i inventory.ini vpn_setup.yml
    ```

---

## 📱 Connecting to the VPN

Once Ansible finishes successfully, it will download the configuration files to your local machine in a folder named **`vpn_configs`**.

1.  **On Linux (Laptop):**
    ```bash
    sudo wg-quick up ./vpn_configs/laptop_tudor.conf
    ```
    *(To disconnect: `sudo wg-quick down ./vpn_configs/laptop_tudor.conf`)*

---

## ⚠️ Important Notes for Student Subscriptions

* **Provider Registration:** The Terraform config includes `skip_provider_registration = true` to prevent permission errors common with Azure for Students.
* **Missing Providers:** If you receive a `MissingSubscriptionRegistration` error during Terraform apply, you must register the providers manually via CLI once:
    ```bash
    az provider register --namespace Microsoft.Network
    az provider register --namespace Microsoft.Compute
    ```
* **Regions:** Free/Student accounts are often restricted in popular regions like `westeurope`. If deployment fails with a "Policy" or "Quota" error, try US regions (`eastus`).

---

## 🔮 Roadmap / Future Updates

* [ ] **Dynamic Inventory:** Configure Terraform to automatically generate the `inventory.ini` file with the correct IP, eliminating the manual copy-paste step.
* [ ] **Docker Support:** Replace the bare-metal installation with a Docker container (like `wg-easy`) to provide a Web UI for easier client management and QR code generation.
* [ ] **Security Hardening:** Restrict SSH access in the Network Security Group (NSG) to allow connections only from your specific home IP address, rather than `*` (Any).
* [ ] **DNS Management:** Resolve `resolvconf` conflicts to allow pushing DNS settings directly from the VPN config.