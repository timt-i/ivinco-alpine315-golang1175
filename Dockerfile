FROM scratch
ADD alpine-minirootfs-3.15.0-x86_64.tar.gz /
ADD go1.17.5.src.tar.gz /usr/local/

ENV PATH /usr/local/go/bin:$PATH

ENV GOLANG_VERSION 1.17.5

RUN set -eux; \
    apk add --no-cache ca-certificates; \
    echo 'hosts: files dns' > /etc/nsswitch.conf; \
	apk add --no-cache --virtual .fetch-deps gnupg; \
	export GOARCH='amd64' GOOS='linux'; \
# https://github.com/golang/go/issues/38536#issuecomment-616897960
		# url='https://dl.google.com/go/go1.17.5.src.tar.gz'; \
		# sha256='3defb9a09bed042403195e872dcbc8c6fae1485963332279668ec52e80a95a2d'; \
# the precompiled binaries published by Go upstream are not compatible with Alpine, so we always build from source here 😅
	# wget -O go.tgz.asc "$url.asc"; \
	# wget -O go.tgz "$url"; \
	# echo "$sha256 *go1.17.5.src.tar.gz" | sha256sum -c -; \
	\
# https://github.com/golang/go/issues/14739#issuecomment-324767697
	# GNUPGHOME="$(mktemp -d)"; export GNUPGHOME; \
# https://www.google.com/linuxrepositories/
	# gpg --batch --keyserver keyserver.ubuntu.com --recv-keys 'EB4C 1BFD 4F04 2F6D DDCC  EC91 7721 F63B D38B 4796'; \
# let's also fetch the specific subkey of that key explicitly that we expect "go.tgz.asc" to be signed by, just to make sure we definitely have it
	# gpg --batch --keyserver keyserver.ubuntu.com --recv-keys '2F52 8D36 D67B 69ED F998  D857 78BD 6547 3CB3 BD13'; \
	# gpg --batch --verify go1.17.5.src.tar.gz.asc go1.17.5.src.tar.gz; \
	# gpgconf --kill all; \
	# rm -rf "$GNUPGHOME" go1.17.5.src.tar.gz.asc; \
	\
	# tar -C /usr/local -xzf go1.17.5.src.tar.gz; \
	# rm go1.17.5.src.tar.gz; \
	\
		apk add --no-cache --virtual .build-deps \
			bash \
			gcc \
			go \
			musl-dev \
		; \
		\
		( \
			cd /usr/local/go/src; \
# set GOROOT_BOOTSTRAP + GOHOST* such that we can build Go successfully
			export GOROOT_BOOTSTRAP="$(go env GOROOT)" GOHOSTOS="$GOOS" GOHOSTARCH="$GOARCH"; \
			./make.bash; \
		); \
		\
		apk del --no-network .build-deps; \
		\
# pre-compile the standard library, just like the official binary release tarballs do
		go install std; \
# go install: -race is only supported on linux/amd64, linux/ppc64le, linux/arm64, freebsd/amd64, netbsd/amd64, darwin/amd64 and windows/amd64
#		go install -race std; \
		\
# remove a few intermediate / bootstrapping files the official binary release tarballs do not contain
		rm -rf \
			/usr/local/go/pkg/*/cmd \
			/usr/local/go/pkg/bootstrap \
			/usr/local/go/pkg/obj \
			/usr/local/go/pkg/tool/*/api \
			/usr/local/go/pkg/tool/*/go_bootstrap \
			/usr/local/go/src/cmd/dist/dist \
		; \
	# fi; \
	\
	apk del --no-network .fetch-deps; \
	\
	go version

ENV GOPATH /go
ENV PATH $GOPATH/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
WORKDIR $GOPATH
