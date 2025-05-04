# docker-xpra
Accessing X application through web. Powered by xpra and inspired by docker-novnc project.

## Why docker-xpra?
[docker-novnc](https://github.com/theasp/docker-novnc) is currently major solution for this kind of problem with [pull count over 1M+](https://hub.docker.com/r/theasp/novnc), but is [not maintained](https://github.com/theasp/docker-novnc/issues/5#issuecomment-1878737079) by repository owner, and most importantly, does not provide arm64 image.

## Features
* Native platform support for amd64 / arm64
* Health-checking feature to ensure startup order
* Seamless integration for single X application without desktop environment, powered by xpra

## Using in docker-compose
Please refer to `docker-compose.yml`.

## About image
Image is based on ubuntu 24.04 and pretty heavy with size of about ~1.5GB.
