# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Virtual for Rust language compiler"
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="${PV}/stable"
KEYWORDS="amd64 arm arm64 ppc64 x86"

BDEPEND=""
RDEPEND="|| ( =dev-lang/rust-bin-${PV}* =dev-lang/rust-${PV}* )"
