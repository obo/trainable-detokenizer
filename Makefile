all:
	# Getting prerequisities
	make nametag

nametag:
	git clone https://github.com/ufal/nametag.git $@
	cd $@ \
	&& git submodule init && git pull && git submodule update \
	&& cd src && make
