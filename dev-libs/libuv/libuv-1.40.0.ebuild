# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit autotools

DESCRIPTION="Cross-platform asychronous I/O"
HOMEPAGE="https://github.com/libuv/libuv"
SRC_URI="https://github.com/libuv/libuv/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD BSD-2 ISC MIT"
SLOT="0/1"
KEYWORDS="*"
IUSE="static-libs"
RESTRICT="test"

BDEPEND="
	sys-devel/libtool
	virtual/pkgconfig
"

src_prepare() {
	default

	echo "m4_define([UV_EXTRA_AUTOMAKE_FLAGS], [serial-tests])" \
		> m4/libuv-extra-automake-flags.m4 || die

	# upstream fails to ship a configure script
	eautoreconf
}

src_configure() {
	local myeconfargs=(
		cc_cv_cflags__g=no
		$(use_enable static-libs static)
	)
	ECONF_SOURCE="${S}" econf "${myeconfargs[@]}"
}

src_test() {
	mkdir "${BUILD_DIR}"/test || die
	cp -pPR "${S}"/test/fixtures "${BUILD_DIR}"/test/fixtures || die
	default
}

src_install_all() {
	einstalldocs
	find "${D}" -name '*.la' -delete || die
}
