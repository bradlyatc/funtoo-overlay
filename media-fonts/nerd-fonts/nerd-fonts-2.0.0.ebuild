# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit font check-reqs

DESCRIPTION="Collection of fonts that are patched to include a high number of glyphs (icons)."
HOMEPAGE="https://nerdfonts.com"
SRC_URI=""

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DIRNAME=(
	3270
	AnonymousPro
	Arimo
	AurulentSansMono
	BigBlueTerminal
	BitstreamVeraSansMono
	Cousine
	DejaVuSansMono
	DroidSansMono
	FantasqueSansMono
	FiraCode
	FiraMono
	Go-Mono
	Hack
	Hasklig
	HeavyData
	Hermit
	Inconsolata
	InconsolataGo
	InconsolataLGC
	Iosevka
	Lekton
	LiberationMono
	Meslo
	Monofur
	Monoid
	Mononoki
	MPlus
	Noto
	OpenDyslexic
	Overpass
	ProFont
	ProggyClean
	Regular
	RobotoMono
	ShareTechMono
	SourceCodePro
	SpaceMono
	Terminus
	Tinos
	Ubuntu
	UbuntuMono
)

IUSE_FLAGS=(${DIRNAME[*],,})
IUSE="${IUSE_FLAGS[*]}"
REQUIRED_USE="|| ( ${IUSE_FLAGS[*]} )"

DEPEND="app-arch/unzip
	net-misc/wget"
RDEPEND="media-libs/fontconfig"

CHECKREQS_DISK_BUILD="3G"
CHECKREQS_DISK_USR="4G"

S="${WORKDIR}"
FONT_CONF=(
	${FILESDIR}/10-nerd-font-symbols.conf
)
FONT_S=${S}

pkg_pretend() {
	check-reqs_pkg_setup
}

src_unpack() {
	default
	for i in $(seq 0 $((${#IUSE_FLAGS[@]} - 1)))
	do
		if use ${IUSE_FLAGS[${i}]}; then
			wget https://github.com/ryanoasis/${PN}/releases/download/v${PV}/${DIRNAME[${i}]}.zip
			unzip ${S}/${DIRNAME[${i}]}.zip -d ${S}
		fi
	done
}

src_install() {
	declare -A font_filetypes
	local otf_file_number ttf_file_number

	otf_file_number=$(ls ${S} | grep -i otf | wc -l)
	ttf_file_number=$(ls ${S} | grep -i ttf | wc -l)

	if [[ ${otf_file_number} != 0 ]]; then
		font_filetypes[otf]=
	fi

	if [[ ${ttf_file_number} != 0 ]]; then
		font_filetypes[ttf]=
	fi

	FONT_SUFFIX="${!font_filetypes[@]}"

	font_src_install
}

pkg_postinst() {
	einfo "Installing font-patcher via an ebuild is hard, because paths are hardcoded differently"
	einfo "in .sh files. You can still get it and use it by git cloning the nerd-font project and"
	einfo "running it from the cloned directory."
	einfo "https://github.com/ryanoasis/nerd-fonts"

	elog "You might have to enable 50-user.conf and 10-nerd-font-symbols.conf by using"
	elog "eselect fontconfig"
}
