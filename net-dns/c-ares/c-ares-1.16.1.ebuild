# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools eutils

DESCRIPTION="C library that resolves names asynchronously"
HOMEPAGE="https://c-ares.haxx.se/"
SRC_URI="https://${PN}.haxx.se/download/${P}.tar.gz"

LICENSE="MIT"
KEYWORDS="*"
IUSE="static-libs"

# Subslot = SONAME of libcares.so.2
SLOT="0/2"

DOCS=( AUTHORS CHANGES NEWS README.md RELEASE-NOTES TODO )

src_prepare() {
	eapply "${FILESDIR}"/${PN}-1.12.0-remove-tests.patch
	eapply_user
	eautoreconf
}

src_configure() {
	ECONF_SOURCE=${S} \
	econf \
		--enable-nonblocking \
		--enable-symbol-hiding \
		$(use_enable static-libs static)
}

