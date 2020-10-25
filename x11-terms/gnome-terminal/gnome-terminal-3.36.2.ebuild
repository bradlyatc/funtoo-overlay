# Distributed under the terms of the GNU General Public License v2

EAPI=7
GNOME3_LA_PUNT="yes"

inherit autotools gnome3 readme.gentoo-r1

DESCRIPTION="The Gnome Terminal"
HOMEPAGE="https://wiki.gnome.org/Apps/Terminal/"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="*"

IUSE="debug +gnome-shell +nautilus"

# FIXME: automagic dependency on gtk+[X], just transitive but needs proper control
RDEPEND="
	>=dev-libs/glib-2.62.2:2[dbus]
	>=x11-libs/gtk+-3.24.12:3[X]
	>=x11-libs/vte-0.60.0
	>=dev-libs/libpcre2-10
	>=gnome-base/dconf-0.14
	>=gnome-base/gsettings-desktop-schemas-0.1.0
	sys-apps/util-linux
	gnome-shell? ( gnome-base/gnome-shell )
	nautilus? ( >=gnome-base/nautilus-3 )
"
# itstool required for help/* with non-en LINGUAS, see bug #549358
# xmllint required for glib-compile-resources, see bug #549304
DEPEND="${RDEPEND}
	app-text/yelp-tools
	dev-libs/libxml2
	>=dev-util/intltool-0.50
	sys-devel/gettext
	virtual/pkgconfig
"

DOC_CONTENTS="To get previous working directory inherited in new opened
	tab you will need to add the following line to your ~/.bashrc:\n
	. /etc/profile.d/vte.sh"

PATCHES=(
	"${FILESDIR}"/gnome-terminal-3.14.3-fix-broken-transparency-on-startup.patch
	"${FILESDIR}"/gnome-terminal-3.28.1-build-dont-treat-warnings-as-errors.patch
	"${FILESDIR}"/gnome-terminal-3.28.1-disable-function-keys.patch
	"${FILESDIR}"/gnome-terminal-3.36.2-revert-screen-take-a-ref-to-the-fd-list.patch
	"${FILESDIR}"/gnome-terminal-3.36.1.1-transparency.patch
)

src_prepare() {
	gnome3_src_prepare
}

src_configure() {
	gnome3_src_configure \
		--disable-static \
		$(use_enable debug) \
		$(use_enable gnome-shell search-provider) \
		$(use_with nautilus nautilus-extension) \
		VALAC=$(type -P true)
}

src_install() {
	DOCS="AUTHORS ChangeLog HACKING NEWS"
	gnome3_src_install
	readme.gentoo_create_doc
}

pkg_postinst() {
	gnome3_pkg_postinst
	readme.gentoo_print_elog
}
