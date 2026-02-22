#!/usr/bin/env bash
set -e

echo "== System update =="
sudo dnf upgrade -y

echo "== Base tools =="
sudo dnf groupinstall -y "Development Tools"
sudo dnf install -y \
    git curl wget unzip htop neovim tmux jq tree \
    openssl ca-certificates zsh make \
    gnupg2 pass \
    postgresql redis \
    direnv \
    python3 python3-pip \
    util-linux-user

echo "== Microsoft repo =="
sudo rpm -Uvh https://packages.microsoft.com/config/fedora/$(rpm -E %fedora)/packages-microsoft-prod.rpm

echo "== Install .NET SDKs =="
sudo dnf install -y dotnet-sdk-8.0
sudo dnf install -y dotnet-sdk-9.0 || true
sudo dnf install -y aspnetcore-runtime-8.0

echo "== VS Code repo =="
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=VS Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo dnf install -y code

echo "== Install VS Code extensions =="
code --install-extension ms-dotnettools.csharp
code --install-extension ms-dotnettools.csdevkit
code --install-extension ms-azuretools.vscode-docker
code --install-extension eamodio.gitlens
code --install-extension esbenp.prettier-vscode
code --install-extension redhat.vscode-yaml
code --install-extension ms-vscode.makefile-tools
code --install-extension ms-vscode-remote.remote-containers

echo "== Docker CE =="
sudo dnf install -y dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io \
    docker-buildx-plugin docker-compose-plugin
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER

echo "== Podman (optional parallel container runtime) =="
sudo dnf install -y podman buildah skopeo

echo "== Node LTS =="
curl -fsSL https://rpm.nodesource.com/setup_lts.x | sudo bash -
sudo dnf install -y nodejs

echo "== asdf version manager =="
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0
echo '. "$HOME/.asdf/asdf.sh"' >> ~/.bashrc
echo '. "$HOME/.asdf/completions/asdf.bash"' >> ~/.bashrc

echo "== direnv hook =="
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc

echo "== Install starship prompt =="
curl -sS https://starship.rs/install.sh | sh -s -- -y
echo 'eval "$(starship init bash)"' >> ~/.bashrc

echo "== Install lazygit =="
sudo dnf install -y lazygit || true

echo "== Install global dotnet tools =="
dotnet tool install -g dotnet-ef
dotnet tool install -g dotnet-aspnet-codegenerator
dotnet tool install -g dotnet-reportgenerator-globaltool

echo 'export PATH="$PATH:$HOME/.dotnet/tools"' >> ~/.bashrc

echo "== Enable Redis =="
sudo systemctl enable redis
sudo systemctl start redis

echo "== Create dev directories =="
mkdir -p ~/dev/projects
mkdir -p ~/dev/containers
mkdir -p ~/dev/scripts

echo "== Done. Reboot or re-login for docker group and shell changes. =="