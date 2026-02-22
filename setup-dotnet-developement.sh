#!/usr/bin/env bash
set -e

echo "== Fedora Version =="
dnf --version

echo "== System Update =="
sudo dnf upgrade -y

echo "== Development Tools Group =="
sudo dnf install -y @development-tools

echo "== Base Tools =="
sudo dnf install -y \
    git curl wget unzip htop neovim tmux jq tree \
    openssl ca-certificates zsh make \
    gnupg2 pass \
    postgresql redis \
    direnv \
    python3 python3-pip \
    util-linux-user

echo "== Add Microsoft Repository =="
sudo rpm -Uvh https://packages.microsoft.com/config/fedora/$(rpm -E %fedora)/packages-microsoft-prod.rpm

echo "== Install .NET SDKs =="
sudo dnf install -y dotnet-sdk-8.0
sudo dnf install -y dotnet-sdk-9.0 || true
sudo dnf install -y aspnetcore-runtime-8.0

echo "== Add VS Code Repository =="
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo tee /etc/yum.repos.d/vscode.repo > /dev/null <<EOF
[code]
name=VS Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

echo "== Install VS Code =="
sudo dnf install -y code

echo "== Install VS Code Extensions =="
code --install-extension ms-dotnettools.csharp || true
code --install-extension ms-dotnettools.csdevkit || true
code --install-extension ms-azuretools.vscode-docker || true
code --install-extension eamodio.gitlens || true
code --install-extension esbenp.prettier-vscode || true
code --install-extension redhat.vscode-yaml || true
code --install-extension ms-vscode.makefile-tools || true
code --install-extension ms-vscode-remote.remote-containers || true

echo "== Docker CE Repository =="
sudo dnf install -y dnf-plugins-core
sudo dnf config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo

echo "== Install Docker CE =="
sudo dnf install -y docker-ce docker-ce-cli containerd.io \
    docker-buildx-plugin docker-compose-plugin

sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER

echo "== Install Podman Toolchain =="
sudo dnf install -y podman buildah skopeo

echo "== Install Node LTS =="
curl -fsSL https://rpm.nodesource.com/setup_lts.x | sudo bash -
sudo dnf install -y nodejs

echo "== Install asdf Version Manager =="
if [ ! -d "$HOME/.asdf" ]; then
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0
fi

grep -qxF '. "$HOME/.asdf/asdf.sh"' ~/.bashrc || echo '. "$HOME/.asdf/asdf.sh"' >> ~/.bashrc
grep -qxF '. "$HOME/.asdf/completions/asdf.bash"' ~/.bashrc || echo '. "$HOME/.asdf/completions/asdf.bash"' >> ~/.bashrc

echo "== Enable direnv =="
grep -qxF 'eval "$(direnv hook bash)"' ~/.bashrc || echo 'eval "$(direnv hook bash)"' >> ~/.bashrc

echo "== Install Starship Prompt =="
curl -sS https://starship.rs/install.sh | sh -s -- -y
grep -qxF 'eval "$(starship init bash)"' ~/.bashrc || echo 'eval "$(starship init bash)"' >> ~/.bashrc

echo "== Install LazyGit =="
sudo dnf install -y lazygit || true

echo "== Install Global .NET Tools =="
dotnet tool install -g dotnet-ef || true
dotnet tool install -g dotnet-aspnet-codegenerator || true
dotnet tool install -g dotnet-reportgenerator-globaltool || true

grep -qxF 'export PATH="$PATH:$HOME/.dotnet/tools"' ~/.bashrc || echo 'export PATH="$PATH:$HOME/.dotnet/tools"' >> ~/.bashrc

echo "== Enable Redis Service =="
sudo systemctl enable redis
sudo systemctl start redis

echo "== Create Dev Directory Structure =="
mkdir -p ~/dev/projects
mkdir -p ~/dev/containers
mkdir -p ~/dev/scripts

echo "== Installation Complete =="
echo "Log out and back in for Docker group + shell changes."