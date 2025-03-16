# VVdeC Library

VVDEC_VERSION := 3.0.0
VVDEC_URL := https://github.com/fraunhoferhhi/vvdec/archive/refs/tags/v$(VVDEC_VERSION).zip

PKGS += vvdec
DEPS_vvdec = zlib

ifeq ($(call need_pkg,"vvdec"),)
PKGS_FOUND += vvdec
endif

$(TARBALLS)/vvdec-$(VVDEC_VERSION).zip:
    $(call download_pkg,$(VVDEC_URL),vvdec)

.sum-vvdec: vvdec-$(VVDEC_VERSION).zip

vvdec: vvdec-$(VVDEC_VERSION).zip .sum-vvdec
    $(UNPACK)
    $(MOVE)

.vvdec: vvdec toolchain.cmake
    cd $< && rm -f CMakeCache.txt
    cd $< && $(HOSTVARS) $(CMAKE)
    cd $< && $(CMAKEBUILD) . --target install
    touch $@
