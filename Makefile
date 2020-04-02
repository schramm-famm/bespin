HELP_FUNC = \
    %help; \
    while(<>) { \
        if(/^([a-z0-9_-]+):.*\#\#(?:@(\w+))?\s(.*)$$/) { \
            push(@{$$help{$$2 // 'targets'}}, [$$1, $$3]); \
        } \
    }; \
    print "usage: make [target]\n\n"; \
    for ( sort keys %help ) { \
        print "$$_:\n"; \
        printf("  %-20s %s\n", $$_->[0], $$_->[1]) for @{$$help{$$_}}; \
        print "\n"; \
    }

.PHONY: help
help: 				## show options and their descriptions
	@perl -e '$(HELP_FUNC)' $(MAKEFILE_LIST)

all:  				## clean the working environment and create a certificate
all: clean cert

tmp: 				## create tmp/
	if [ -d "./tmp" ]; then rm -rf ./tmp; fi
	mkdir tmp

rsa: tmp			## generate RSA keys
	openssl genrsa -out ./tmp/id_rsa 2048
	openssl rsa -in ./tmp/id_rsa -pubout > ./tmp/id_rsa.pub

cert: rsa
	printf 'CA\nOntario\nOttawa\nschramm-famm\n\n\n\n' | openssl req -new -x509 -sha256 -key ./tmp/id_rsa \
		-out ./tmp/server.crt -days 3650

.PHONY: clean
clean: 				## remove tmp/
	rm -rf tmp
