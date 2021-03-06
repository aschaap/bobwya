# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# shellcheck disable=SC2034
EAPI=7

PYTHON_COMPAT=( python3_5 python3_6 python3_7 python3_8 )

inherit llvm meson multilib-minimal pax-utils python-any-r1

MY_P="${P/_/-}"

DESCRIPTION="OpenGL-like graphic library for Linux"
HOMEPAGE="https://www.mesa3d.org/ https://mesa.freedesktop.org/
		https://mesa.freedesktop.org/"
if [[ "${PV}" == "9999" ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://gitlab.freedesktop.org/mesa/mesa.git"
	EGIT_CHECKOUT_DIR="${WORKDIR}/${MY_P}"
else
	SRC_URI="https://mesa.freedesktop.org/archive/${MY_P}.tar.xz"
	KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sparc ~x86 ~amd64-linux ~x86-linux ~sparc-solaris ~x64-solaris ~x86-solaris"
fi

LICENSE="MIT"
SLOT="0"
RESTRICT="!test? ( test )"

AMD_CARDS=( "r100" "r200" "r300" "r600" "radeon" "radeonsi" )
INTEL_CARDS=( "i915" "i965" "intel" "iris" )
VIDEO_CARDS=( "freedreno" "lima" "nouveau" "panfrost" "vc4" "virgl" "vivante" "vmware" )
VIDEO_CARDS+=( "${AMD_CARDS[@]}" )
VIDEO_CARDS+=( "${INTEL_CARDS[@]}" )
for card in "${VIDEO_CARDS[@]}"; do
	IUSE_VIDEO_CARDS+=" video_cards_${card}"
done

IUSE="${IUSE_VIDEO_CARDS}
	+X +classic d3d9 debug +dri3 +egl +gallium +gbm gles1 +gles2 +libglvnd +llvm
	lm-sensors opencl osmesa selinux test unwind vaapi valgrind vdpau vulkan vulkan-overlay
	wayland xa xvmc +zstd"

REQUIRED_USE="
	d3d9?   ( dri3 || ( video_cards_iris video_cards_r300 video_cards_r600 video_cards_radeonsi video_cards_nouveau video_cards_vmware ) )
	gles1?  ( egl )
	gles2?  ( egl )
	vulkan? ( dri3
		|| ( video_cards_i965 video_cards_iris video_cards_radeonsi )
		video_cards_radeonsi? ( llvm ) )
	vulkan-overlay? ( vulkan )
	wayland? ( egl gbm )
	video_cards_freedreno?  ( gallium )
	video_cards_intel?  ( classic )
	video_cards_i915?   ( || ( classic gallium ) )
	video_cards_i965?   ( classic )
	video_cards_iris?   ( gallium )
	video_cards_lima?   ( gallium )
	video_cards_nouveau? ( || ( classic gallium ) )
	video_cards_panfrost? ( gallium )
	video_cards_radeon? ( || ( classic gallium )
						  gallium? ( x86? ( llvm ) amd64? ( llvm ) ) )
	video_cards_r100?   ( classic )
	video_cards_r200?   ( classic )
	video_cards_r300?   ( gallium x86? ( llvm ) amd64? ( llvm ) )
	video_cards_r600?   ( gallium )
	video_cards_radeonsi?   ( gallium llvm )
	video_cards_vc4? ( gallium )
	video_cards_virgl? ( gallium )
	video_cards_vivante? ( gallium gbm )
	video_cards_vmware? ( gallium )
	xa? ( X )
	xvmc? ( X )
"

LIBDRM_DEPSTRING=">=x11-libs/libdrm-2.4.100"
# shellcheck disable=SC2124
RDEPEND="
	!app-eselect/eselect-mesa
	>=dev-libs/expat-2.1.0-r3:=[${MULTILIB_USEDEP}]
	>=sys-libs/zlib-1.2.8[${MULTILIB_USEDEP}]
	libglvnd? (
		>=media-libs/libglvnd-1.2.0-r1[${MULTILIB_USEDEP}]
		!app-eselect/eselect-opengl
	)
	!libglvnd? (
		~app-eselect/eselect-opengl-1.3.3
	)
	gallium? (
		llvm? (
			video_cards_radeonsi? (
				virtual/libelf:0=[${MULTILIB_USEDEP}]
			)
			video_cards_r600? (
				virtual/libelf:0=[${MULTILIB_USEDEP}]
			)
			video_cards_radeon? (
				virtual/libelf:0=[${MULTILIB_USEDEP}]
			)
		)
		lm-sensors? ( sys-apps/lm-sensors:=[${MULTILIB_USEDEP}] )
		opencl? (
			dev-libs/ocl-icd[khronos-headers,${MULTILIB_USEDEP}]
			dev-libs/libclc
			virtual/libelf:0=[${MULTILIB_USEDEP}]
		)
		unwind? ( sys-libs/libunwind[${MULTILIB_USEDEP}] )
		vaapi? (
			>=x11-libs/libva-1.7.3:=[${MULTILIB_USEDEP}]
		)
		vdpau? ( >=x11-libs/libvdpau-1.1:=[${MULTILIB_USEDEP}] )
		xvmc? ( >=x11-libs/libXvMC-1.0.8:=[${MULTILIB_USEDEP}] )
	)
	selinux? ( sys-libs/libselinux[${MULTILIB_USEDEP}] )
	wayland? (
		>=dev-libs/wayland-1.15.0:=[${MULTILIB_USEDEP}]
		>=dev-libs/wayland-protocols-1.8
	)
	${LIBDRM_DEPSTRING}[video_cards_freedreno?,video_cards_nouveau?,video_cards_vc4?,video_cards_vivante?,video_cards_vmware?,${MULTILIB_USEDEP}]

	video_cards_intel? (
		!video_cards_i965? ( ${LIBDRM_DEPSTRING}[video_cards_intel] )
	)
	video_cards_i915? ( ${LIBDRM_DEPSTRING}[video_cards_intel] )
	vulkan-overlay? ( dev-util/glslang:0=[${MULTILIB_USEDEP}] )
	X? (
		>=x11-libs/libX11-1.6.2:=[${MULTILIB_USEDEP}]
		>=x11-libs/libxshmfence-1.1:=[${MULTILIB_USEDEP}]
		>=x11-libs/libXdamage-1.1.4-r1:=[${MULTILIB_USEDEP}]
		>=x11-libs/libXext-1.3.2:=[${MULTILIB_USEDEP}]
		>=x11-libs/libXxf86vm-1.1.3:=[${MULTILIB_USEDEP}]
		>=x11-libs/libxcb-1.13:=[${MULTILIB_USEDEP}]
		x11-libs/libXfixes:=[${MULTILIB_USEDEP}]
	)
	zstd? ( app-arch/zstd:=[${MULTILIB_USEDEP}] )
"

# shellcheck disable=SC2068
for card in ${INTEL_CARDS[@]}; do
	[[ "${card}" == "i965" ]] && continue

	RDEPEND="${RDEPEND}
		video_cards_${card}? ( ${LIBDRM_DEPSTRING}[video_cards_intel] )
	"
done
# shellcheck disable=SC2068
for card in ${AMD_CARDS[@]}; do
	RDEPEND="${RDEPEND}
		video_cards_${card}? ( ${LIBDRM_DEPSTRING}[video_cards_radeon] )
	"
done
RDEPEND="${RDEPEND}
	video_cards_radeonsi? ( ${LIBDRM_DEPSTRING}[video_cards_amdgpu] )
"

# Please keep the LLVM dependency block separate. Since LLVM is slotted,
# we need to *really* make sure we're only using one slot.
LLVM_MAX_SLOT="10"
LLVM_DEPSTR="
	|| (
		sys-devel/llvm:10[${MULTILIB_USEDEP}]
		sys-devel/llvm:9[${MULTILIB_USEDEP}]
		sys-devel/llvm:8[${MULTILIB_USEDEP}]
		sys-devel/llvm:7[${MULTILIB_USEDEP}]
	)
	sys-devel/llvm:=[${MULTILIB_USEDEP}]
"
LLVM_DEPSTR_AMDGPU="${LLVM_DEPSTR//]/,llvm_targets_AMDGPU(-)]}"
CLANG_DEPSTR="${LLVM_DEPSTR//llvm/clang}"
CLANG_DEPSTR_AMDGPU="${CLANG_DEPSTR//]/,llvm_targets_AMDGPU(-)]}"
RDEPEND="${RDEPEND}
	gallium? (
		llvm? (
			opencl? (
				video_cards_r600? (
					${CLANG_DEPSTR_AMDGPU}
				)
				!video_cards_r600? (
					video_cards_radeonsi? (
						${CLANG_DEPSTR_AMDGPU}
					)
					!video_cards_radeonsi? (
						video_cards_radeon? (
							${CLANG_DEPSTR_AMDGPU}
						)
						!video_cards_radeon? (
							${CLANG_DEPSTR}
						)
					)
				)
			)
			!opencl? (
				video_cards_r600? (
					${LLVM_DEPSTR_AMDGPU}
				)
				!video_cards_r600? (
					video_cards_radeonsi? (
						${LLVM_DEPSTR_AMDGPU}
					)
					!video_cards_radeonsi? (
						video_cards_radeon? (
							${LLVM_DEPSTR_AMDGPU}
						)
						!video_cards_radeon? (
							${LLVM_DEPSTR}
						)
					)
				)
			)
		)
	)
"
unset {LLVM,CLANG}_DEPSTR{,_AMDGPU}

DEPEND="${RDEPEND}
	valgrind? ( dev-util/valgrind )
	X? (
		x11-libs/libXrandr[${MULTILIB_USEDEP}]
		x11-base/xorg-proto
	)
"
BDEPEND="
	${PYTHON_DEPS}
	opencl? (
		>=sys-devel/gcc-4.6
	)
	sys-devel/bison
	sys-devel/flex
	sys-devel/gettext
	virtual/pkgconfig
	$(python_gen_any_dep ">=dev-python/mako-0.8.0[\${PYTHON_USEDEP}]")
"

S="${WORKDIR}/${MY_P}"
EGIT_CHECKOUT_DIR="${S}"

QA_WX_LOAD="
x86? (
	usr/lib*/libglapi.so.0.0.0
	usr/lib*/libGLESv1_CM.so.1.1.0
	usr/lib*/libGLESv2.so.2.0.0
	usr/lib*/libGL.so.1.2.0
	usr/lib*/libOSMesa.so.8.0.0
	libglvnd? ( usr/lib/libGLX_mesa.so.0.0.0 )
)"

# driver_enable()
#	1>	 driver array (reference)
#	2>	 -- / driver USE flag (main category)
#	[3-N]> driver USE flags (subcategory)
driver_enable() {
	(($# < 3)) && die "Invalid parameter count: ${#} (3+)"
	local __driver_array_reference="${1}" driver
	declare -n driver_array=${__driver_array_reference}

	if [[ "${2}" == "--" ]] || use "${2}"; then
		driver_array+=( "${@:3}" )
	fi
}

# driver_list()
#	1>	 driver list
driver_list() {
	(($# != 1)) && die "Invalid parameter count: ${#} (1)"

	drivers="$(sort -u <<< "${1// /$'\n'}")"
	printf "%s\\n" "${drivers//$'\n'/,}"
}

llvm_check_depends() {
	local flags="${MULTILIB_USEDEP}"
	if use video_cards_r600 || use video_cards_radeon || use video_cards_radeonsi; then
		flags+=",llvm_targets_AMDGPU(-)"
	fi
	if use opencl; then
		has_version "sys-devel/clang[${flags}]" || return 1
	fi
	has_version "sys-devel/llvm[${flags}]"
}

pkg_pretend() {
	ewarn "This is an experimental version of ${CATEGORY}/${PN} designed to fix various issues"
	ewarn "when switching GL providers."
	ewarn "This package can only be used in conjuction with patched versions of:"
	ewarn " * app-select/eselect-opengl"
	ewarn " * x11-base/xorg-server"
	ewarn " * x11-drivers/nvidia-drivers"
	ewarn "from the bobwya overlay."
	if use opencl; then
		if ! use video_cards_r600 &&
			! use video_cards_radeonsi; then
			ewarn "Ignoring USE=opencl     since VIDEO_CARDS does not contain r600 or radeonsi"
		fi
	fi

	if use vaapi; then
		if ! use video_cards_r600 &&
			! use video_cards_radeonsi &&
			! use video_cards_nouveau; then
			ewarn "Ignoring USE=vaapi      since VIDEO_CARDS does not contain r600, radeonsi, or nouveau"
		fi
	fi

	if use vdpau; then
		if ! use video_cards_r300 &&
			! use video_cards_r600 &&
			! use video_cards_radeonsi &&
			! use video_cards_nouveau; then
			ewarn "Ignoring USE=vdpau      since VIDEO_CARDS does not contain r300, r600, radeonsi, or nouveau"
		fi
	fi

	if use xa; then
		if ! use video_cards_freedreno &&
			! use video_cards_nouveau &&
			! use video_cards_vmware; then
			ewarn "Ignoring USE=xa         since VIDEO_CARDS does not contain freedreno, nouveau or vmware"
		fi
	fi

	if use xvmc; then
		if ! use video_cards_r600 &&
			! use video_cards_nouveau; then
			ewarn "Ignoring USE=xvmc       since VIDEO_CARDS does not contain r600 or nouveau"
		fi
	fi

	if ! use gallium; then
		use lm-sensors && ewarn "Ignoring USE=lm-sensors since USE does not contain gallium"
		use llvm       && ewarn "Ignoring USE=llvm       since USE does not contain gallium"
		use opencl     && ewarn "Ignoring USE=opencl     since USE does not contain gallium"
		use vaapi      && ewarn "Ignoring USE=vaapi      since USE does not contain gallium"
		use vdpau      && ewarn "Ignoring USE=vdpau      since USE does not contain gallium"
		use unwind     && ewarn "Ignoring USE=unwind     since USE does not contain gallium"
		use xa         && ewarn "Ignoring USE=xa         since USE does not contain gallium"
		use xvmc       && ewarn "Ignoring USE=xvmc       since USE does not contain gallium"
	fi

	if ! use llvm; then
		use opencl     && ewarn "Ignoring USE=opencl     since USE does not contain llvm"
	fi
}

python_check_deps() {
	has_version -b ">=dev-python/mako-0.8.0[${PYTHON_USEDEP}]"
}

pkg_setup() {
	# warning message for bug 459306
	if use llvm && has_version sys-devel/llvm[!debug=]; then
		ewarn "Mismatch between debug USE flags in media-libs/mesa and sys-devel/llvm"
		ewarn "detected! This can cause problems. For details, see bug 459306."
	fi

	if use llvm; then
		llvm_pkg_setup
	fi
	python-any-r1_pkg_setup
}

multilib_src_configure() {
	local -a emesonargs=()

	if use classic; then
		# Intel code
		driver_enable DRI_DRIVERS video_cards_i915 i915
		driver_enable DRI_DRIVERS video_cards_i965 i965
		if ! use video_cards_i915 && ! use video_cards_i965; then
			driver_enable DRI_DRIVERS video_cards_intel i915 i965
		fi

		# Nouveau code
		driver_enable DRI_DRIVERS video_cards_nouveau nouveau

		# ATI code
		driver_enable DRI_DRIVERS video_cards_r100 r100
		driver_enable DRI_DRIVERS video_cards_r200 r200
		if ! use video_cards_r100 && ! use video_cards_r200; then
			driver_enable DRI_DRIVERS video_cards_radeon r100 r200
		fi
	fi

	emesonargs+=( "-Dplatforms=surfaceless$(use X && echo ",x11")$(use wayland && echo ",wayland")$(use gbm && echo ",drm")" )
	if use gallium; then
		emesonargs+=(
			"$(meson_use llvm)"
			"$(meson_use lm-sensors lmsensors)"
			"$(meson_use unwind libunwind)"
		)

		if use video_cards_iris ||
			use video_cards_r300 ||
			use video_cards_r600 ||
			use video_cards_radeonsi ||
			use video_cards_nouveau ||
			use video_cards_vmware; then
			emesonargs+=( "$(meson_use d3d9 gallium-nine)" )
		else
			emesonargs+=( "-Dgallium-nine=false" )
		fi
		if use video_cards_r600 ||
			use video_cards_radeonsi ||
			use video_cards_nouveau; then
			emesonargs+=( "$(meson_use vaapi gallium-va)" )
			use vaapi && emesonargs+=( "-Dva-libs-path=${EPREFIX}/usr/$(get_libdir)/va/drivers" )
		else
			emesonargs+=( "-Dgallium-va=false" )
		fi
		if use video_cards_r300 ||
			use video_cards_r600 ||
			use video_cards_radeonsi ||
			use video_cards_nouveau; then
			emesonargs+=( "$(meson_use vdpau gallium-vdpau)" )
		else
			emesonargs+=( "-Dgallium-vdpau=false" )
		fi
		if use video_cards_freedreno ||
			use video_cards_nouveau ||
			use video_cards_vmware; then
			emesonargs+=( "$(meson_use xa gallium-xa)" )
		else
			emesonargs+=( "-Dgallium-xa=false" )
		fi
		if use video_cards_r600 ||
			use video_cards_nouveau; then
			emesonargs+=( "$(meson_use xvmc gallium-xvmc)" )
		else
			emesonargs+=( "-Dgallium-xvmc=false" )
		fi
		if use video_cards_freedreno ||
			use video_cards_lima ||
			use video_cards_panfrost ||
			use video_cards_vc4 ||
			use video_cards_vivante; then
			driver_enable GALLIUM_DRIVERS kmsro
		fi
		driver_enable GALLIUM_DRIVERS video_cards_lima lima
		driver_enable GALLIUM_DRIVERS video_cards_panfrost panfrost
		driver_enable GALLIUM_DRIVERS video_cards_vc4 vc4
		driver_enable GALLIUM_DRIVERS video_cards_vivante etnaviv
		driver_enable GALLIUM_DRIVERS video_cards_vmware svga
		driver_enable GALLIUM_DRIVERS video_cards_nouveau nouveau

		# Only one i915 driver (classic vs gallium). Default to classic.
		if ! use classic; then
			driver_enable GALLIUM_DRIVERS video_cards_i915 i915
			if ! use video_cards_i915 && ! use video_cards_i965; then
				driver_enable GALLIUM_DRIVERS video_cards_intel i915
			fi
		fi

		driver_enable GALLIUM_DRIVERS video_cards_iris iris

		driver_enable GALLIUM_DRIVERS video_cards_r300 r300
		driver_enable GALLIUM_DRIVERS video_cards_r600 r600
		driver_enable GALLIUM_DRIVERS video_cards_radeonsi radeonsi
		if ! use video_cards_r300 && ! use video_cards_r600; then
			driver_enable GALLIUM_DRIVERS video_cards_radeon r300 r600
		fi

		driver_enable GALLIUM_DRIVERS video_cards_freedreno freedreno
		driver_enable GALLIUM_DRIVERS video_cards_virgl virgl
		emesonargs+=( "-Dgallium-opencl=$(usex opencl icd disabled)" )
	fi

	if use vulkan; then
		driver_enable VULKAN_DRIVERS video_cards_i965 intel
		driver_enable VULKAN_DRIVERS video_cards_iris intel
		driver_enable VULKAN_DRIVERS video_cards_radeonsi amd
	fi

	if use gallium; then
		driver_enable GALLIUM_DRIVERS -- swrast
		emesonargs+=( "-Dosmesa=$(usex osmesa gallium none)" )
	else
		driver_enable DRI_DRIVERS -- swrast
		emesonargs+=( "-Dosmesa=$(usex osmesa classic none)" )
	fi

	emesonargs+=(
		"$(meson_use test build-tests)"
		"-Dglx=$(usex X dri disabled)"
		"-Dshared-glapi=true"
		"$(meson_use dri3)"
		"$(meson_use egl)"
		"$(meson_use gbm)"
		"$(meson_use gles1)"
		"$(meson_use gles2)"
		"$(meson_use libglvnd glvnd)"
		"$(meson_use selinux)"
		"$(meson_use zstd)"
		"-Dvalgrind=$(usex valgrind auto false)"
		"-Ddri-drivers=$(driver_list "${DRI_DRIVERS[*]}")"
		"-Dgallium-drivers=$(driver_list "${GALLIUM_DRIVERS[*]}")"
		"-Dvulkan-drivers=$(driver_list "${VULKAN_DRIVERS[*]}")"
		"$(meson_use vulkan-overlay vulkan-overlay-layer)"
		"--buildtype" "$(usex debug debug plain)"
		"-Db_ndebug=$(usex debug false true)"
	)
	meson_src_configure
}

multilib_src_compile() {
	meson_src_compile
}

multilib_src_install() {
	meson_src_install

	if use libglvnd; then
		rm -f "${D}/usr/$(get_libdir)/pkgconfig"/{egl,gl}.pc
	else

		# Move lib{EGL*,GL*,OpenVG,OpenGL}.{la,a,so*} files from /usr/lib to /usr/lib/opengl/mesa/lib
		ebegin "(subshell): moving lib{EGL*,GL*,OpenGL}.{la,a,so*} in order to implement dynamic GL switching support"
		(
			local gl_dir
			gl_dir="/usr/$(get_libdir)/opengl/${PN}"
			dodir "${gl_dir}/lib"
			for library in "${ED%/}/usr/$(get_libdir)"/lib{EGL*,GL*,OpenGL}.{la,a,so*} ; do
				if [[ -f "${library}" || -L "${library}" ]]; then
					mv -f "${library}" "${ED%/}${gl_dir}"/lib \
						|| die "Failed to move ${library}"
				fi
			done
		)
		eend $? || die "(subshell): failed to move lib{EGL*,GL*,OpenGL}.{la,a,so*}"

	fi
}

multilib_src_install_all() {
	einstalldocs
}

multilib_src_test() {
	meson test -v -C "${BUILD_DIR}" -t 100
}

pkg_postinst() {
	if use libglvnd; then
		# Switch to the xorg implementation.
		echo
		eselect opengl set --use-old "${PN}"

	fi

	ewarn "This is an experimental version of ${CATEGORY}/${PN} designed to fix various issues"
	ewarn "when switching GL providers."
	ewarn "This package can only be used in conjuction with patched versions of:"
	ewarn " * app-select/eselect-opengl"
	ewarn " * x11-base/xorg-server"
	ewarn " * x11-drivers/nvidia-drivers"
	ewarn "from the bobwya overlay."
}
