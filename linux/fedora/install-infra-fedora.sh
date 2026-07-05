#!/usr/bin/env bash
# Fedora infra / Kubernetes tooling — OPTIONAL, opt-in.
#
# NOT run by setup.sh. Run it yourself when you need infra tools:
#   cd linux/fedora && ./install-infra-fedora.sh
#
# Installs: kubectl, k9s, flux.
# To add more tools (helm, kustomize, argocd, terraform, ...), drop a new
# `step` block at the marker near the bottom — reuse install_gh_bin for
# single-binary GitHub tarballs, or add a dnf-repo block like kubectl's.

set -o pipefail
step() { printf '\n\033[1;34m::\033[0m %s\n' "$1"; }

# install_gh_bin <cmd> <tarball-url> <path-of-binary-inside-tar>
# Idempotent (skips if <cmd> is already on PATH), installs to /usr/local/bin.
install_gh_bin() {
  local cmd="$1" url="$2" inner="$3" tmp
  if command -v "$cmd" >/dev/null; then echo "  $cmd already installed — skipping"; return; fi
  tmp="$(mktemp -d)"
  curl -sL "$url" -o "$tmp/dl.tar.gz"
  tar -C "$tmp" -xzf "$tmp/dl.tar.gz" "$inner"
  sudo install "$tmp/$inner" /usr/local/bin/"$cmd"
  rm -rf "$tmp"
}

sudo -v

step "kubectl (official Kubernetes dnf repo)"
if ! command -v kubectl >/dev/null; then
  # pkgs.k8s.io repos are per-minor-version — the minor MUST appear in the URL.
  # Derive it from the current stable release so this doesn't rot over time.
  K8S_STABLE="$(curl -sL https://dl.k8s.io/release/stable.txt)"   # e.g. v1.36.2
  K8S_MINOR="${K8S_STABLE%.*}"                                    # -> v1.36
  sudo sh -c "cat > /etc/yum.repos.d/kubernetes.repo <<EOF
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/${K8S_MINOR}/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/${K8S_MINOR}/rpm/repodata/repomd.xml.key
EOF"
  sudo dnf install -q -y kubectl
fi

step "k9s (GitHub release binary)"
install_gh_bin k9s \
  "https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz" \
  k9s

step "flux (GitHub release binary)"
if ! command -v flux >/dev/null; then
  # flux release assets embed the version (no leading v): flux_<ver>_linux_amd64.tar.gz
  FLUX_VER="$(curl -s https://api.github.com/repos/fluxcd/flux2/releases/latest | grep -Po '"tag_name": "v\K[^"]*')"
  install_gh_bin flux \
    "https://github.com/fluxcd/flux2/releases/latest/download/flux_${FLUX_VER}_linux_amd64.tar.gz" \
    flux
fi

# ── Add more infra tools below ──────────────────────────────────────────────
# e.g.  step "helm";  install_gh_bin helm "<url>" linux-amd64/helm
# kubectl already ships an oh-my-zsh completion plugin; flux's is added here.

step "Shell completions → ~/.zsh_functions"
# ~/.zsh_functions is already on fpath via config/shell/.zshrc (see LEARNINGS.md).
mkdir -p "$HOME/.zsh_functions"
command -v flux >/dev/null && flux completion zsh > "$HOME/.zsh_functions/_flux"

step "Infra tooling complete."
command -v kubectl >/dev/null && kubectl version --client 2>/dev/null | head -1
command -v k9s     >/dev/null && echo "  k9s $(k9s version -s 2>/dev/null | awk '/Version/{print $2}')"
command -v flux    >/dev/null && flux --version
echo "  New completions: run 'rm -f ~/.zcompdump* && exec zsh' if they don't show up."
