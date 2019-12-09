# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit autotools

DESCRIPTION="C implementation of the Raft consensus protocol"
HOMEPAGE="https://github.com/canonical/raft"
SRC_URI="https://github.com/canonical/raft/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-3-with-linking-exception"
SLOT="0"
KEYWORDS=""

IUSE="btrfs debug example sanitize zfs"
DEPEND=">=dev-libs/libuv-1.8.0
	btrfs? ( sys-fs/btrfs-progs )
	zfs? ( >=sys-fs/zfs-0.8.0 )
"
DOCS=( "README.md" )

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	econf \
	$(use_enable debug) \
	$(use_enable example) \
	$(use_enable sanitize)
}
