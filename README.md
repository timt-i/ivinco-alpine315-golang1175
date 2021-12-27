# ivinco-alpine315-golang1175

links: 

It is used Alpine OS from official site - https://alpinelinux.org/downloads/ for docker image.
We need only archive with root-filesystem (original is located on https://dl-cdn.alpinelinux.org/alpine/v3.15/releases/x86_64/alpine-minirootfs-3.15.0-x86_64.tar.gz).

For build Golang  it is used Git repo of the Docker "Official Image" for golang (https://github.com/docker-library/golang)

And the precompiled binaries published by Go upstream are not compatible with Alpine, so we always build from source (https://dl.google.com/go/go1.17.5.src.tar.gz) in this image.
