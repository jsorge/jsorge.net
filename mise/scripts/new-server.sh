#!/bin/bash
set -e

# =============================================================================
# Digital Ocean Droplet Setup Script
# Creates a new droplet, configures SSH, installs Docker, and prepares for
# running the jsorge.net docker-compose setup.
# =============================================================================

# =============================================================================
# TODO: Improvements for next time
# =============================================================================
#
# 1. PKCS#8 to OpenSSH key format conversion
#    - 1Password stores SSH keys in PKCS#8 format (-----BEGIN PRIVATE KEY-----)
#    - OpenSSH requires its own format (-----BEGIN OPENSSH PRIVATE KEY-----)
#    - The script needs to convert the key before using it for SSH commands
#    - Either use Python + cryptography lib, or ssh-keygen with proper input
#    - See: https://github.com/openssh/openssh-portable/blob/master/PROTOCOL.key
#
# 2. SSH service name on Ubuntu 24.04 (FIXED)
#    - Now tries 'ssh' first, falls back to 'sshd'
#
# 3. Add local SSH config entry automatically
#    - After server creation, add entry to ~/.ssh/config for easy access
#    - Include IdentitiesOnly=yes to avoid "too many auth failures"
#
# 4. Fetch Ubuntu versions dynamically
#    - Currently hardcoded in select_ubuntu_version()
#    - Use: doctl compute image list --public | grep -i ubuntu
#    - Or: doctl compute image list-distribution --public
#    - Filter for LTS versions and present as options
#
# =============================================================================

# Configuration
DEFAULT_REGION="sfo3"
DEFAULT_SIZE="s-1vcpu-1gb"
DEFAULT_USERNAME="jsorge"
SSH_KEY_NAME="jsorge.net Server"
DO_TOKEN_ITEM="DigitalOcean Personal Access Token"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# -----------------------------------------------------------------------------
# Helper functions
# -----------------------------------------------------------------------------

info() {
	echo -e "${BLUE}→${NC} $1"
}

success() {
	echo -e "${GREEN}✓${NC} $1"
}

warn() {
	echo -e "${YELLOW}!${NC} $1"
}

error() {
	echo -e "${RED}✗${NC} $1"
	exit 1
}

prompt() {
	echo -e "${GREEN}?${NC} $1"
}

# -----------------------------------------------------------------------------
# Dependency checks
# -----------------------------------------------------------------------------

check_dependencies() {
	info "Checking dependencies..."

	local missing=()

	if ! command -v op &>/dev/null; then
		missing+=("op (1Password CLI)")
	fi

	if ! command -v doctl &>/dev/null; then
		missing+=("doctl (Digital Ocean CLI)")
	fi

	if ! command -v ssh-keygen &>/dev/null; then
		missing+=("ssh-keygen")
	fi

	if ! command -v jq &>/dev/null; then
		missing+=("jq")
	fi

	if [ ${#missing[@]} -ne 0 ]; then
		error "Missing required tools:\n  ${missing[*]}\n\nInstall with:\n  brew install 1password-cli doctl jq"
	fi

	success "All dependencies installed"
}

# -----------------------------------------------------------------------------
# 1Password integration
# -----------------------------------------------------------------------------

check_op_signin() {
	info "Checking 1Password CLI authentication..."

	if ! op account list &>/dev/null; then
		error "Not signed in to 1Password CLI. Run: op signin"
	fi

	success "1Password CLI authenticated"
}

get_or_create_do_token() {
	info "Checking for Digital Ocean API token in 1Password..."

	if op item get "$DO_TOKEN_ITEM" &>/dev/null; then
		# Try common field names for API tokens
		DO_TOKEN=$(op read "op://Private/$DO_TOKEN_ITEM/token" 2>/dev/null || true)
		[ -z "$DO_TOKEN" ] && DO_TOKEN=$(op read "op://Private/$DO_TOKEN_ITEM/credential" 2>/dev/null || true)
		[ -z "$DO_TOKEN" ] && DO_TOKEN=$(op read "op://Private/$DO_TOKEN_ITEM/password" 2>/dev/null || true)

		if [ -n "$DO_TOKEN" ]; then
			success "Found existing DO API token"
			return 0
		fi
	fi

	warn "Digital Ocean API token not found in 1Password"
	echo ""
	echo "Please create an API token at:"
	echo "  https://cloud.digitalocean.com/account/api/tokens"
	echo ""
	echo "Create a token with read/write access, then enter it below."
	echo ""

	read -sp "$(prompt 'Enter your Digital Ocean API token: ')" DO_TOKEN
	echo ""

	if [ -z "$DO_TOKEN" ]; then
		error "No token provided"
	fi

	info "Storing token in 1Password..."
	op item create \
		--category="API Credential" \
		--title="$DO_TOKEN_ITEM" \
		--vault="Private" \
		"token=$DO_TOKEN" >/dev/null

	success "Token stored in 1Password"
}

setup_doctl() {
	info "Configuring doctl with API token..."

	# Export token for all subsequent doctl commands
	export DIGITALOCEAN_ACCESS_TOKEN="$DO_TOKEN"

	# Verify it works
	if ! doctl account get >/dev/null 2>&1; then
		error "Failed to authenticate with Digital Ocean. Check your API token."
	fi

	success "doctl configured"
}

get_or_create_ssh_key() {
	info "Checking for SSH key '$SSH_KEY_NAME' in 1Password..."

	SSH_KEY_FILE=$(mktemp)
	SSH_PUBKEY_FILE="${SSH_KEY_FILE}.pub"

	# Try to get existing key from 1Password
	if op item get "$SSH_KEY_NAME" &>/dev/null; then
		# Try to read the private key
		PRIVATE_KEY=$(op read "op://Private/$SSH_KEY_NAME/private key" 2>/dev/null || true)

		if [ -n "$PRIVATE_KEY" ]; then
			success "Found existing SSH key in 1Password"
			echo "$PRIVATE_KEY" >"$SSH_KEY_FILE"
			chmod 600 "$SSH_KEY_FILE"

			# Get public key from 1Password
			PUBLIC_KEY=$(op read "op://Private/$SSH_KEY_NAME/public key" 2>/dev/null || true)
			if [ -n "$PUBLIC_KEY" ]; then
				echo "$PUBLIC_KEY" >"$SSH_PUBKEY_FILE"
			else
				# Derive public key from private
				ssh-keygen -y -f "$SSH_KEY_FILE" >"$SSH_PUBKEY_FILE"
			fi
			return 0
		fi
	fi

	info "Creating new SSH keypair in 1Password..."

	# Let 1Password generate the SSH key directly
	op item create \
		--category="SSH Key" \
		--title="$SSH_KEY_NAME" \
		--vault="Private" \
		--ssh-generate-key=ed25519 >/dev/null

	# Now retrieve the keys we just created
	PRIVATE_KEY=$(op read "op://Private/$SSH_KEY_NAME/private key")
	echo "$PRIVATE_KEY" >"$SSH_KEY_FILE"
	chmod 600 "$SSH_KEY_FILE"

	# Derive public key from private
	ssh-keygen -y -f "$SSH_KEY_FILE" >"$SSH_PUBKEY_FILE"

	success "SSH key created and stored in 1Password"
}

add_ssh_key_to_do() {
	info "Checking if SSH key exists in Digital Ocean..."

	PUBLIC_KEY=$(cat "$SSH_PUBKEY_FILE")

	# First check if key exists by name
	EXISTING_KEY=$(doctl compute ssh-key list --format ID,Name --no-header | grep "$SSH_KEY_NAME" || true)
	if [ -n "$EXISTING_KEY" ]; then
		DO_SSH_KEY_ID=$(echo "$EXISTING_KEY" | awk '{print $1}')
		success "SSH key already exists in Digital Ocean (ID: $DO_SSH_KEY_ID)"
		return 0
	fi

	# Try to create the key, handle "already exists" error
	info "Adding SSH key to Digital Ocean..."
	if DO_SSH_KEY_ID=$(doctl compute ssh-key create "$SSH_KEY_NAME" --public-key "$PUBLIC_KEY" --format ID --no-header 2>&1); then
		success "SSH key added to Digital Ocean (ID: $DO_SSH_KEY_ID)"
	else
		# Key might exist with different name, search by checking all keys
		warn "Could not create key, checking existing keys..."
		# Get the first key ID as fallback (you may have multiple keys)
		DO_SSH_KEY_ID=$(doctl compute ssh-key list --format ID --no-header | head -1)
		if [ -n "$DO_SSH_KEY_ID" ]; then
			success "Using existing SSH key (ID: $DO_SSH_KEY_ID)"
		else
			error "No SSH keys found in Digital Ocean account"
		fi
	fi
}

# -----------------------------------------------------------------------------
# Droplet creation
# -----------------------------------------------------------------------------

select_ubuntu_version() {
	echo ""
	prompt "Select Ubuntu version:"
	echo ""
	echo "  1) Ubuntu 24.04 LTS (Noble Numbat) - Latest LTS (Recommended)"
	echo "  2) Ubuntu 22.04 LTS (Jammy Jellyfish) - Previous LTS"
	echo "  3) Ubuntu 20.04 LTS (Focal Fossa) - Older LTS"
	echo ""

	read -p "Enter choice [1-3] (default: 1): " choice

	case "${choice:-1}" in
	1) UBUNTU_IMAGE="ubuntu-24-04-x64" ;;
	2) UBUNTU_IMAGE="ubuntu-22-04-x64" ;;
	3) UBUNTU_IMAGE="ubuntu-20-04-x64" ;;
	*)
		warn "Invalid choice, using Ubuntu 24.04 LTS"
		UBUNTU_IMAGE="ubuntu-24-04-x64"
		;;
	esac

	success "Selected: $UBUNTU_IMAGE"
}

get_droplet_name() {
	echo ""
	read -p "$(prompt 'Enter droplet name (e.g., jsorge-net-1): ')" DROPLET_NAME

	if [ -z "$DROPLET_NAME" ]; then
		DROPLET_NAME="jsorge-net-$(date +%Y%m%d)"
	fi

	success "Droplet name: $DROPLET_NAME"
}

create_droplet() {
	info "Creating droplet..."

	DROPLET_ID=$(doctl compute droplet create "$DROPLET_NAME" \
		--image "$UBUNTU_IMAGE" \
		--size "$DEFAULT_SIZE" \
		--region "$DEFAULT_REGION" \
		--ssh-keys "$DO_SSH_KEY_ID" \
		--tag-names "jsorge-net,blog" \
		--wait \
		--format ID \
		--no-header)

	success "Droplet created (ID: $DROPLET_ID)"

	# Get the IP address
	DROPLET_IP=$(doctl compute droplet get "$DROPLET_ID" --format PublicIPv4 --no-header)
	success "Droplet IP: $DROPLET_IP"
}

# -----------------------------------------------------------------------------
# Server configuration
# -----------------------------------------------------------------------------

wait_for_ssh() {
	info "Waiting for SSH to become available..."

	local max_attempts=30
	local attempt=1

	while [ $attempt -le $max_attempts ]; do
		if ssh -i "$SSH_KEY_FILE" -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o BatchMode=yes root@"$DROPLET_IP" exit 2>/dev/null; then
			success "SSH is available"
			return 0
		fi
		echo -n "."
		sleep 5
		attempt=$((attempt + 1))
	done

	error "SSH not available after $max_attempts attempts"
}

configure_server() {
	info "Configuring server..."

	PUBLIC_KEY=$(cat "$SSH_PUBKEY_FILE")

	# TODO: The SSH_KEY_FILE from 1Password is in PKCS#8 format which SSH can't read.
	# This script will fail at the ssh command below until TODO #1 is implemented.
	# For now, you may need to manually configure the server after droplet creation.
	# See the TODO section at the top of this file.

	# Get GitHub Actions SSH public key for authorized_keys
	info "Fetching GitHub Actions SSH key from 1Password..."
	GITHUB_ACTIONS_PUBKEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE6G+cYoFytzyJpdjqrTNDg2kZ8dTVLcbe1kwV2drv0Z deployments@jsorge.net"

	# Get Git deploy key for pulling from GitHub
	GIT_DEPLOY_KEY=$(op document get "jsorge.net Git Deploy Key" 2>/dev/null)
	if [ -z "$GIT_DEPLOY_KEY" ]; then
		warn "Could not fetch Git deploy key from 1Password, GitHub Actions deploys won't work"
		GIT_DEPLOY_KEY=""
	fi

	ssh -i "$SSH_KEY_FILE" -o StrictHostKeyChecking=no root@"$DROPLET_IP" bash <<REMOTE_SCRIPT
set -e

echo "→ Updating system packages..."
apt-get update -qq
apt-get upgrade -y -qq

echo "→ Installing required packages..."
apt-get install -y -qq \
    libssl-dev \
    pkg-config \
    curl \
    git \
    ufw \
    fail2ban

echo "→ Creating user $DEFAULT_USERNAME..."
if ! id "$DEFAULT_USERNAME" &>/dev/null; then
    useradd -m -s /bin/bash -G sudo "$DEFAULT_USERNAME"
    echo "$DEFAULT_USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$DEFAULT_USERNAME
fi

echo "→ Setting up SSH for $DEFAULT_USERNAME..."
mkdir -p /home/$DEFAULT_USERNAME/.ssh
cat > /home/$DEFAULT_USERNAME/.ssh/authorized_keys << AUTHKEYS
$PUBLIC_KEY
$GITHUB_ACTIONS_PUBKEY
AUTHKEYS
chmod 700 /home/$DEFAULT_USERNAME/.ssh
chmod 600 /home/$DEFAULT_USERNAME/.ssh/authorized_keys
chown -R $DEFAULT_USERNAME:$DEFAULT_USERNAME /home/$DEFAULT_USERNAME/.ssh

echo "→ Installing GitHub deploy key..."
cat > /home/$DEFAULT_USERNAME/.ssh/github_deploy_key << DEPLOYKEY
$GIT_DEPLOY_KEY
DEPLOYKEY
chmod 600 /home/$DEFAULT_USERNAME/.ssh/github_deploy_key

cat > /home/$DEFAULT_USERNAME/.ssh/config << SSHCONFIG
Host github.com-deploy
    HostName github.com
    User git
    IdentityFile ~/.ssh/github_deploy_key
SSHCONFIG
chmod 600 /home/$DEFAULT_USERNAME/.ssh/config
chown -R $DEFAULT_USERNAME:$DEFAULT_USERNAME /home/$DEFAULT_USERNAME/.ssh

echo "→ Hardening SSH configuration..."
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
# Ubuntu 24.04 uses 'ssh', older versions use 'sshd'
systemctl restart ssh || systemctl restart sshd

echo "→ Configuring firewall..."
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

echo "→ Installing Docker..."
curl -fsSL https://get.docker.com | sh
usermod -aG docker $DEFAULT_USERNAME

echo "→ Installing Docker Compose..."
apt-get install -y -qq docker-compose-plugin

echo "→ Enabling Docker service..."
systemctl enable docker
systemctl start docker

echo "→ Creating website directory..."
mkdir -p /var/www/jsorge.net
chown $DEFAULT_USERNAME:$DEFAULT_USERNAME /var/www/jsorge.net

echo "✓ Server configuration complete!"
REMOTE_SCRIPT

	success "Server configured successfully"
}

cleanup() {
	info "Cleaning up temporary files..."
	rm -f "$SSH_KEY_FILE" "$SSH_PUBKEY_FILE"
	success "Cleanup complete"
}

# -----------------------------------------------------------------------------
# Main script
# -----------------------------------------------------------------------------

main() {
	echo ""
	echo "╔════════════════════════════════════════════════════════════════╗"
	echo "║        Digital Ocean Droplet Setup for jsorge.net              ║"
	echo "╚════════════════════════════════════════════════════════════════╝"
	echo ""

	# Setup
	check_dependencies
	check_op_signin
	get_or_create_do_token
	setup_doctl
	get_or_create_ssh_key
	add_ssh_key_to_do

	# Droplet creation
	select_ubuntu_version
	get_droplet_name
	create_droplet

	# Server configuration
	wait_for_ssh
	configure_server

	# Cleanup
	cleanup

	echo ""
	echo "╔════════════════════════════════════════════════════════════════╗"
	echo "║                     Setup Complete!                            ║"
	echo "╚════════════════════════════════════════════════════════════════╝"
	echo ""
	echo "Droplet Details:"
	echo "  Name:     $DROPLET_NAME"
	echo "  IP:       $DROPLET_IP"
	echo "  Region:   $DEFAULT_REGION"
	echo "  Size:     $DEFAULT_SIZE"
	echo "  Image:    $UBUNTU_IMAGE"
	echo ""
	echo "SSH Access:"
	echo "  ssh $DEFAULT_USERNAME@$DROPLET_IP"
	echo ""
	echo "Next Steps:"
	echo "  1. Clone your repo on the server:"
	echo "     ssh $DEFAULT_USERNAME@$DROPLET_IP"
	echo "     cd /var/www/jsorge.net"
	echo "     GIT_SSH_COMMAND='ssh -i ~/.ssh/github_deploy_key' git clone git@github.com:jsorge/jsorge.net.git ."
	echo ""
	echo "  2. Or sync your local files:"
	echo "     rsync -avz --exclude='.git' ./ $DEFAULT_USERNAME@$DROPLET_IP:/var/www/jsorge.net/"
	echo ""
	echo "  3. Restore Maverick's R2, encryption, admin, and provider secrets:"
	echo "     cd /var/www/jsorge.net"
	echo "     bash mise/deploy/provision_broadcast_secrets.sh"
	echo "     See mise/deploy/BROADCASTING.md for the fail-closed restore checklist."
	echo ""
	echo "  4. Start the services with broadcasting still disabled:"
	echo "     mise run serve"
	echo ""
	echo "  5. Verify the prior R2 revision in /_admin/broadcast, then enable broadcasting"
	echo ""
	echo "  6. Update DNS (Cloudflare) to point jsorge.net to $DROPLET_IP"
	echo ""
	echo "  7. Update GitHub secrets with new SSH_HOST IP if changed"
	echo ""

	# Store the IP in a file for reference
	echo "$DROPLET_IP" >.last-droplet-ip
	info "Droplet IP saved to .last-droplet-ip"
}

# Run main function
main "$@"
