## SPDX-License-Identifier: MIT OR Apache-2.0
##
## Copyright (c) 2019-2025 Darren Dai <Darren_Serious@hotmail.com>

# Reference followed: https://www.docker.com/blog/getting-started-with-docker-for-arm-on-linux

TAG := 2025.01

default: build_local

build_local:
	docker build                                           \
	    --network=host                                     \
	    --platform linux/amd64                             \
	    --tag rootfs:$(TAG)              \
	    --file Dockerfile.ubun22 .

run:
	docker run -it --network host \
	--name osdev-utils  \
	--privileged --rm \
	-v /Users:/Users \
	-w $(PWD)/.. \
	rootfs:$(TAG) /bin/bash
