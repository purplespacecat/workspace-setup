#!/usr/bin/env bash
# Fedora infra / Kubernetes tooling — OPTIONAL, opt-in.
#
# NOT run by setup.sh. Run it yourself when you need infra tools:
#   cd linux/fedora && ./install-infra-fedora.sh
#
# Installs: kubectl, k9s, flux, helm, kustomize.
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

step "helm (get.helm.sh release binary)"
if ! command -v helm >/dev/null; then
  # Distributed from get.helm.sh (not GitHub assets); binary is nested at
  # linux-amd64/helm inside the tarball.
  HELM_VER="$(curl -s https://api.github.com/repos/helm/helm/releases/latest | grep -Po '"tag_name": "\K[^"]*')"
  install_gh_bin helm \
    "https://get.helm.sh/helm-${HELM_VER}-linux-amd64.tar.gz" \
    linux-amd64/helm
fi

step "kustomize (GitHub release binary)"
if ! command -v kustomize >/dev/null; then
  # The kustomize repo publishes several products; releases are tagged
  # kustomize/vX.Y.Z, so filter for that tag rather than using /latest. The
  # slash in the tag is URL-encoded (%2F) in the download path.
  KUSTOMIZE_TAG="$(curl -s 'https://api.github.com/repos/kubernetes-sigs/kustomize/releases?per_page=30' | grep -Po '"tag_name": "\Kkustomize/v[^"]*' | head -1)"
  KVER="${KUSTOMIZE_TAG#kustomize/}"
  install_gh_bin kustomize \
    "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KVER}/kustomize_${KVER}_linux_amd64.tar.gz" \
    kustomize
fi

# ── Add more infra tools below ──────────────────────────────────────────────
# e.g.  step "argocd";  install_gh_bin argocd "<url>" <path-in-tar>
# kubectl already ships an oh-my-zsh completion plugin; flux's is added here.

step "Shell completions → ~/.zsh_functions"
# ~/.zsh_functions is already on fpath via config/shell/.zshrc (see LEARNINGS.md).
mkdir -p "$HOME/.zsh_functions"
command -v flux      >/dev/null && flux completion zsh      > "$HOME/.zsh_functions/_flux"
command -v helm      >/dev/null && helm completion zsh      > "$HOME/.zsh_functions/_helm"
command -v kustomize >/dev/null && kustomize completion zsh > "$HOME/.zsh_functions/_kustomize"

step "Infra tooling complete."
command -v kubectl   >/dev/null && kubectl version --client 2>/dev/null | head -1
command -v k9s       >/dev/null && echo "  k9s $(k9s version -s 2>/dev/null | awk '/Version/{print $2}')"
command -v flux      >/dev/null && flux --version
command -v helm      >/dev/null && echo "  $(helm version --short 2>/dev/null)"
command -v kustomize >/dev/null && kustomize version 2>/dev/null | head -1
echo "  New completions: run 'rm -f ~/.zcompdump* && exec zsh' if they don't show up."
