# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit gnome2-utils


MY_P="Arc-Menu-v${PV}-Stable-ff12b62d9ed4f1ae2ce7ad5aa743f69fec18811e"
DESCRIPTION="Arc Menu is a Gnome shell extension designed to replace the standard menu found in Gnome 3"
HOMEPAGE="https://gitlab.com/LinxGem33/Arc-Menu"
SRC_URI="https://gitlab.com/LinxGem33/Arc-Menu/-/archive/v${PV}-Stable/${PN}-v${PV}-Stable.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

COMMON_DEPEND="dev-libs/glib:2"
RDEPEND="${COMMON_DEPEND}
	app-eselect/eselect-gnome-shell-extensions
	>=gnome-base/gnome-shell-3.18.0
"
DEPEND="${COMMON_DEPEND}"
BDEPEND="
	dev-util/intltool
	sys-devel/gettext
"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	default
	# Set correct version
	export VERSION="${PV}"

	# Don't install README and COPYING in unwanted locations
	sed -i -e 's/COPYING//g' -e 's/AUTHORS//g' Makefile || die
}

pkg_preinst() {
	gnome2_schemas_savelist
}

pkg_postinst() {
	gnome2_schemas_update
	ebegin "Updating list of installed extensions"
	eselect gnome-shell-extensions update
	eend $?
}

pkg_postrm() {
	gnome2_schemas_update
}
