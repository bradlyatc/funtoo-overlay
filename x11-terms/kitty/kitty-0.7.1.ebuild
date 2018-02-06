# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3_{5,6} )

inherit gnome2-utils xdg-utils flag-o-matic distutils-r1

DESCRIPTION="A modern, hackable, featureful, OpenGL based terminal emulator"
HOMEPAGE="https://github.com/kovidgoyal/kitty"
SRC_URI="https://github.com/kovidgoyal/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

IUSE="X imagemagick pillow wayland debug"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="*"

CDEPEND="media-libs/fontconfig:2
	media-libs/freetype
	x11-libs/libXcursor
	x11-libs/libXrandr
	x11-libs/libXinerama
	x11-libs/libxkbcommon
	>=media-libs/harfbuzz-1.5.0:=
	media-libs/libpng:0="
DEPEND="${PYTHON_DEPS}
	sys-libs/zlib
	virtual/pkgconfig
	wayland? ( >=dev-libs/wayland-protocols-1.12 )"
RDEPEND="X? ( || ( x11-apps/xrdb x11-misc/xsel ) )
	imagemagick? ( media-gfx/imagemagick )
	pillow? ( dev-python/pillow )"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

src_prepare() {
	default
	##remove unwanted -Werror and -pedantic-errors if not debug build
	if use !debug; then
		sed -i -e 's/-Werror//g;s/-pedantic-errors/-pedantic/g' setup.py || die
	fi
	##substitute hard coded -O3 with user controlled
	user_flag="$(get-flag -O)"
	sed -i -e "s/-O3/${user_flag}/g" setup.py || die
}

python_compile() {
	##check for debug build. call esetup.py to use correct system python.
	#linux-package is config option for linux packagers bundling. --prefix
	#can be set to place compiled files in ${ED} but there is no install script
	esetup.py -v $(usex debug --debug "") linux-package
}

src_install() {
	##manually install package, using --prefix doesn't play well with ebuild
	dobin linux-package/bin/*
	insinto /usr
	doins -r linux-package/{lib,share}

	DOCS=( *.asciidoc )
	einstalldocs
}
pkg_postinst() {
	gnome2_icon_cache_update
	xdg_desktop_database_update
	einfo
	elog "*PLEASE NOTE* the configuration file is located at:"
	elog "/usr/lib/kitty/kitty/kitty.conf"
	elog "Copy to ~/.config/kitty/ and make per user changes there."
	einfo
}

pkg_postrm() {
	gnome2_icon_cache_update
	xdg_desktop_database_update
}
