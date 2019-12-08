# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="libco is a cross-platform, permissively licensed implementation of cooperative-multithreading"
HOMEPAGE="https://github.com/byuu/higan/tree/master/libco"
SRC_URI="https://github.com/canonical/libco/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="ISC"
SLOT="0"
KEYWORDS="amd64 x86"

DEPEND="app-arch/unzip"

src_prepare() {
	default
	sed -i 's/LIBDIR ?= lib/LIBDIR ?= lib64/' Makefile
}
