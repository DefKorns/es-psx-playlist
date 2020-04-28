DEPENDANT=0

PKG_PRETTY_NAME := Emulationstation: PSX Playlist
PKG_NAME := es-psx-playlist
VERSION := 1.2.3
PKG_CREATOR := DefKorns
MAINTAINER := DefKorns <defkorns@gmail.com>
PLATFORM := SONYPSC
ARCHITECTURE := armhf
ifeq ($(DEPENDANT), 1)
	DEPENDS :=
endif

PKG_TARGET := $(PKG_NAME)_$(PLATFORM)

all : $(PKG_TARGET).mod

$(PKG_TARGET).mod:
	mkdir -p $(PKG_TARGET)/DEBIAN
	cp -rf mod/* $(PKG_TARGET)/
	printf "%s\n" \
		"Package: $(PKG_NAME)" \
		"Version: $(VERSION)" \
		"Architecture: $(ARCHITECTURE)" \
		"Depends: $(DEPENDS)" \
		"Maintainer: $(MAINTAINER)" \
		"Description: $(PKG_PRETTY_NAME)" > $(PKG_TARGET)/DEBIAN/control
	cat mod_description.txt >> $(PKG_TARGET)/DEBIAN/control
	echo "Author: $(PKG_CREATOR)" >> $(PKG_TARGET)/DEBIAN/control
	echo "Platform: $(PLATFORM) $(ARCHITECTURE)" >> $(PKG_TARGET)/DEBIAN/control
	echo "Built: $(shell date)" >> $(PKG_TARGET)/DEBIAN/control
	cp -rf preinst $(PKG_TARGET)/DEBIAN/preinst
	cp -rf postinst $(PKG_TARGET)/DEBIAN/postinst
	cp -rf postrm $(PKG_TARGET)/DEBIAN/postrm
	chmod 755 $(PKG_TARGET)/DEBIAN
	chmod 755 $(PKG_TARGET)/DEBIAN/preinst
	chmod 755 $(PKG_TARGET)/DEBIAN/postinst
	chmod 755 $(PKG_TARGET)/DEBIAN/postrm
	dpkg-deb -v --build $(PKG_TARGET)
	mv $(PKG_TARGET).deb $(PKG_TARGET).mod

	rm -r $(PKG_TARGET)/
	touch $(PKG_TARGET).mod

clean:
	-rm -rf $(PKG_TARGET)/ $(PKG_TARGET).mod

.PHONY: clean