# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME2_LA_PUNT="yes"
PYTHON_COMPAT=( python2_7 python3_{5,6,7} )

inherit gnome2 flag-o-matic python-r1

DESCRIPTION="The GNOME Spreadsheet"
HOMEPAGE="http://www.gnumeric.org/"
LICENSE="GPL-2"

SLOT="0"
KEYWORDS="*"

IUSE="+introspection libgda perl python"
# python-loader plugin is python2.7 only
REQUIRED_USE="python? ( $(python_gen_useflags -2) )"

# Missing gnome-extra/libgnomedb required version in tree
# but its upstream is dead and will be dropped soon.

# lots of missing files, also fails tests due to 80-bit long story
# upstream bug #721556
RESTRICT="test"

RDEPEND="
	app-arch/bzip2
	sys-libs/zlib
	>=dev-libs/glib-2.62.3:2
	>=gnome-extra/libgsf-1.14.46:=
	>=x11-libs/goffice-0.10.42:0.10
	>=dev-libs/libxml2-2.9.9:2
	>=x11-libs/pango-1.44.7:=

	>=x11-libs/gtk+-3.24.12:3
	x11-libs/cairo:=[svg]

	introspection? ( >=dev-libs/gobject-introspection-1.62.0:= )
	perl? ( dev-lang/perl:= )
	python? ( ${PYTHON_DEPS}
		>=dev-python/pygobject-3.34:3[${PYTHON_USEDEP}] )
	libgda? ( gnome-extra/libgda:5[gtk] )
"
DEPEND="${RDEPEND}
	app-text/docbook-xml-dtd:4.5
	app-text/yelp-tools
	dev-util/gtk-doc-am
	>=dev-util/intltool-0.51.0
	virtual/pkgconfig
"

src_prepare() {
	# Manage gi overrides ourselves
	sed '/SUBDIRS/ s/introspection//' -i Makefile.{am,in} || die
	gnome2_src_prepare
}

src_configure() {
	if use python ; then
		python_setup 'python2*'
	fi
	gnome2_src_configure \
		--disable-static \
		--with-zlib \
		$(use_with libgda gda) \
		$(use_enable introspection) \
		$(use_with perl) \
		$(use_with python)
}

src_install() {
	gnome2_src_install
	python_moduleinto gi.overrides
	python_foreach_impl python_domodule introspection/gi/overrides/Gnm.py
}
