# VVdeC Library

VVDEC_VERSION := 3.0.0
VVDEC_URL := $(GITHUB)/fraunhoferhhi/vvdec/archive/v$(VVDEC_VERSION).tar.gz

ifdef GPL
ifdef GNUV3
PKGS += vvdec
endif
endif
ifeq ($(call need_pkg,"vvdec"),)
PKGS_FOUND += vvdec
endif

$(TARBALLS)/vvdec-$(VVDEC_VERSION).tar.gz:
    $(call download_pkg,$(VVDEC_URL),vvdec)

.sum-vvdec: $(TARBALLS)/vvdec-$(VVDEC_VERSION).tar.gz

vvdec: vvdec-$(VVDEC_VERSION).tar.gz .sum-vvdec
    $(UNPACK)
    $(MOVE)

.vvdec: vvdec toolchain.cmake
    cd $< && rm -f CMakeCache.txt
    cd $< && $(HOSTVARS) $(CMAKE)
    cd $< && $(CMAKEBUILD) . --target install
    touch $@
