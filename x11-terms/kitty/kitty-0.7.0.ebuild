# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3_{5,6} )

inherit gnome2-utils xdg-utils flag-o-matic toolchain-funcs distutils-r1

DESCRIPTION="A modern, hackable, featureful, OpenGL based terminal emulator"
HOMEPAGE="https://github.com/kovidgoyal/kitty"
SRC_URI="https://github.com/kovidgoyal/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

IUSE="X imagemagick pillow wayland debug"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="*"

CDEPEND="media-libs/fontconfig
	media-libs/freetype
	x11-libs/libXcursor
	x11-libs/libXrandr
	x11-libs/libXinerama
	x11-libs/libxkbcommon
	>=media-libs/harfbuzz-1.5.0
	media-libs/libpng:*"
DEPEND="${PYTHON_DEPS}
	sys-libs/zlib
	virtual/pkgconfig
	wayland? ( >=dev-libs/wayland-protocols-1.6 )"
RDEPEND="X? ( || ( x11-apps/xrdb x11-misc/xsel ) )
	imagemagick? ( media-gfx/imagemagick )
	pillow? ( dev-python/pillow )"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

src_prepare() {
	default
	##remove unwanted -Werror if not debug build
	if use !debug; then
		sed -i -e 's/-Werror//g' setup.py || die
	fi
	##substitute hard coded -O with user controlled
	user_flag="$(get-flag -O)"
	sed -i -e "s/-O3/${user_flag}/g" setup.py || die
}

python_compile() {
	##check for debug build. call esetup.py to use correct system python.
	#linux-package is config option for linux packagers bundling. --prefix
	#can be set to place compiled files in ${ED} but there is no install script
	if use debug; then
		einfo
		elog "USE=debug detected: **DEBUGGING BUILD ENABLED**"
		einfo
		esetup.py -v --debug linux-package
	else
		esetup.py -v linux-package
	fi
}

src_install() {
	##manually install package, using --prefix doesn't play well with ebuild
	dobin linux-package/bin/kitty
	insinto /usr/lib
	doins -r linux-package/lib/kitty
	insinto /usr/share
	doins -r linux-package/share/{applications,icons,terminfo,}

	DOCS=( *.asciidoc )
	einstalldocs
}
pkg_postinst() {
	gnome2_icon_cache_update
	xdg_desktop_database_update
	einfo
	elog "The configuration file is extensive and very well documented."
	elog "*PLEASE NOTE* the configuration file is located at:"
	elog "/usr/lib/kitty/kitty/kitty.conf"
	elog "Copy to ~/.config/kitty/ and make per user changes there."
	einfo
}

pkg_postrm() {
	gnome2_icon_cache_update
	xdg_desktop_database_update
}
