PRODUCT := strum
VERSION := $(shell cat VERSION)
WEBSITE := acksin.com

all: build

build: deps test
	go build -ldflags "-X main.version=$(VERSION)"
	$(MAKE) website-assets

deps:
	go get -u github.com/golang/lint/golint
	go get ./...

dev-deps:
	sudo apt-get install -y inkscape 

test:
	golint ./...
	go test -cover ./...
	go tool vet **/*.go

archive:
	tar cvzf $(PRODUCT)-$(VERSION).tar.gz $(PRODUCT)

release: spell build archive
	sed -i -e "s/^VERSION=.*$\/VERSION=$(VERSION)/g" website/install.sh
	git add website/install.sh
	-git commit -m "Version $(VERSION)"
	-git tag v$(VERSION) && git push --tags
	s3cmd put --acl-public $(PRODUCT)-$(VERSION).tar.gz s3://assets.acksin.co/$(PRODUCT)/${VERSION}/$(PRODUCT)-${VERSION}.tar.gz

website-assets:
	echo "None"
	# cd website && go run logo.go > logo.svg && inkscape -z -d 150 -e autotune.png logo.svg

website:
	echo "Nothin here govn'r"

spell:
	for i in $(shell ls website/*.html); do \
		aspell check --mode=html $$i; \
	done

.PHONY: website website-dev
