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
	apk add --no-cache --virtual .build-deps bash gcc go musl-dev ; \
	( \
		cd /usr/local/go/src; \
# set GOROOT_BOOTSTRAP + GOHOST* such that we can build Go successfully
		export GOROOT_BOOTSTRAP="$(go env GOROOT)" GOHOSTOS="$GOOS" GOHOSTARCH="$GOARCH"; \
		./make.bash; \
	); \
	\
	apk del --no-network .build-deps; \
# pre-compile the standard library, just like the official binary release tarballs do
	go install std; \
# go install: -race is only supported on linux/amd64, linux/ppc64le, linux/arm64, freebsd/amd64, netbsd/amd64, darwin/amd64 and windows/amd64
#		go install -race std; \
# remove a few intermediate / bootstrapping files the official binary release tarballs do not contain
	rm -rf \
			/usr/local/go/pkg/*/cmd \
			/usr/local/go/pkg/bootstrap \
			/usr/local/go/pkg/obj \
			/usr/local/go/pkg/tool/*/api \
			/usr/local/go/pkg/tool/*/go_bootstrap \
			/usr/local/go/src/cmd/dist/dist \
		; \
	apk del --no-network .fetch-deps; \
	go version

ENV GOPATH /go
ENV PATH $GOPATH/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
WORKDIR $GOPATH
