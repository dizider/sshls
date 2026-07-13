# Maintainer: Matej Jehlicka <matej@jehlicka.eu>
pkgname=sshls-git
pkgver=1.0.0.r0.g4539084
pkgrel=1
pkgdesc="Interactive SSH host selector that parses ~/.ssh/config and picks with fzf"
arch=('any')
url="https://github.com/dizider/sshls"
license=('MIT')
groups=()
depends=('bash' 'fzf' 'openssh')
makedepends=('git')
provides=("sshls")
conflicts=("sshls")
replaces=()
backup=()
options=()
install=
source=("$pkgname::git+https://github.com/dizider/sshls.git")
noextract=()
sha256sums=('SKIP')

# Please refer to the 'USING VCS SOURCES' section of the PKGBUILD man page for
# a description of each element in the source array.

pkgver() {
  cd "$srcdir/$pkgname"
  # Latest tag if any, else r<commit-count>.<short-hash>
  git describe --long --tags 2>/dev/null | sed 's/\([^-]*-g\)/r\1/;s/-/./g' \
    || printf "r%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
}

package() {
  cd "$srcdir/$pkgname"
  install -Dm755 sshls   "$pkgdir/usr/bin/sshls"
  install -Dm644 _sshls  "$pkgdir/usr/share/zsh/site-functions/_sshls"
  install -Dm644 README.md "$pkgdir/usr/share/doc/sshls/README.md"
}

