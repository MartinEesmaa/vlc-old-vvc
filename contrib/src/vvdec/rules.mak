# VVdeC Library

VVDEC_VERSION := 3.0.0
VVDEC_URL := $(GITHUB)/fraunhoferhhi/vvdec/archive/v$(VVDEC_VERSION).tar.gz

PKGS += vvdec
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
	cd $< && $(HOSTVARS) $(CMAKE) -DVVDEC_ENABLE_LINK_TIME_OPT=OFF
	cd $< && $(CMAKEBUILD) . --target install
	touch $@