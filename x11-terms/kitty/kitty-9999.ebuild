# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3_{5,6,7} )

inherit git-r3 gnome2-utils xdg-utils flag-o-matic toolchain-funcs distutils-r1

DESCRIPTION="A modern, hackable, featureful, OpenGL based terminal emulator"
HOMEPAGE="https://github.com/kovidgoyal/kitty"
EGIT_REPO_URI="https://github.com/kovidgoyal/${PN}.git"

IUSE="X imagemagick pillow wayland clang clang_build debug sanitize profile"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""

CDEPEND="media-libs/fontconfig
	media-libs/freetype:2
	x11-libs/libXcursor
	x11-libs/libXrandr
	x11-libs/libXinerama
	x11-libs/libXi
	>=x11-libs/libxkbcommon-0.5
	>=media-libs/harfbuzz-1.5.0:=
	media-libs/libpng:0="
DEPEND="${PYTHON_DEPS}
	sys-libs/zlib
	virtual/pkgconfig
	dev-python/sphinx
	wayland? ( >=dev-libs/wayland-protocols-1.12 )
	clang? ( sys-devel/clang:* sys-devel/llvm:*[gold] )
	clang_build? ( clang? ( sys-devel/clang:* sys-devel/llvm:*[gold] ) )
	sanitize? ( clang? ( sys-devel/clang:* sys-devel/llvm:*[gold] ) )
	profile? ( dev-util/google-perftools )"
RDEPEND="X? ( || ( x11-apps/xrdb x11-misc/xsel ) )
	imagemagick? ( media-gfx/imagemagick )
	pillow? ( dev-python/pillow )
	media-libs/libcanberra
	dev-python/pygments"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

pkg_setup() {
	##setup a sane Clang build environment if clang_build is set
	if use clang_build; then
		filter-ldflags -Wl,-O3 -Wl,-O4
		is-ldflagq -Wl,-O1 || is-ldflagq -WL,-O2 || append-ldflags -Wl,-O2
		is-ldflagq -Wl,--as-needed || append-ldflags -Wl,--as-needed
		CC="clang"
		AR="llvm-ar"
		NM="llvm-nm"
		RANLIB="llvm-ranlib"
		tc-export CC AR NM RANLIB
		einfo
		elog "USE=clang_build detected: This package will be built with Clang."
		elog "Setting up a sane Clang compile environment."
		elog "These variables are set for this compile ONLY."
		elog "CC: ${CC} AR: ${AR} NM: ${NM} RANLIB: ${RANLIB}"
		elog "LDFLAGS: ${LDFLAGS}"
		einfo
	fi
	LIBDIR="$(get_libdir)"
	export LIBDIR
}

src_prepare() {
	default

	##fix libdir
	sed -i "/libdir =/s/'lib'/'$(get_libdir)'/" setup.py || die
	#sed -i "s#/../lib/kitty#/../$(get_libdir)/kitty#" linux-launcher.c || die
	##remove unwanted -Werror and -pedantic-errors flags if not debug build
	if use !debug; then
		sed -i -e 's/-Werror//g;s/-pedantic-errors/-pedantic/g' setup.py || die
	fi
	##substitute hard coded -O with user controlled
	user_flag="$(get-flag -O)"
	sed -i -e "s/-O3/${user_flag}/g" setup.py || die
}

python_compile() {
	##check for debug or sanitize builds. sanitize only works with clang for now.
	#call esetup.py to use correct system python. linux-package is config option
	#for linux packagers bundling. --prefix can be set to place compiled files in
	#${ED} but there is no install script.
	export XDG_CONFIG_HOME="$HOME/.config"
	if use debug; then
		einfo
		elog "USE=debug detected: **DEBUG BUILD ENABLED**"
		einfo
		esetup.py -v --debug --libdir-name "${LIBDIR}" linux-package
	elif use sanitize && use clang && tc-is-clang; then
		einfo
		elog "USE=sanitize detected: **SANITIZE BUILD ENABLED**"
		einfo
		esetup.py -v --sanitize --libdir-name "${LIBDIR}" linux-package
	elif use profile; then
		einfo
		elog "USE=profile detected: **PROFILE BUILD ENABLED**"
		einfo
		esetup.py -v --profile --libdir-name "${LIBDIR}" linux-package
	else
		esetup.py -v --libdir-name "${LIBDIR}" linux-package
	fi
}

src_install() {
	##manually install package, using --prefix doesn't play well with ebuild
	dobin linux-package/bin/*
	insinto /usr
	doins -r linux-package/{$LIBDIR,share}

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
