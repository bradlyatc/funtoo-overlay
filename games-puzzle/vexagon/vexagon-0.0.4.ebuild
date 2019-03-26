# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils gnome2-utils xdg-utils wxwidgets
WX_GTK_VER="3.0"
MY_P="${PN}-master"
S=${WORKDIR}/${MY_P}

DESCRIPTION="Complete the puzzle by matching numbered square or hexagonal tiles"
HOMEPAGE="https://vexagon.furcat.ca/"
SRC_URI="https://gitlab.com/digifuzzy/${PN}/-/archive/master/${MY_P}.tar.gz"

LICENSE="wxWinLL-3 GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="x11-libs/wxGTK:${WX_GTK_VER}"
RDEPEND="${DEPEND}"

src_prepare() {
	setup-wxwidgets
	need-wxwidgets unicode
	cmake-utils_src_prepare
}
src_configure() {
	local mycmakeargs=(
		-D_VEXREVISION_="v${PV} (Funtoo)"
	)
	cmake-utils_src_configure
}
pkg_postinst() {
	gnome2_icon_cache_update
	xdg_desktop_database_update
}
pkg_postrm() {
	gnome2_icon_cache_update
	xdg_desktop_database_update
}
