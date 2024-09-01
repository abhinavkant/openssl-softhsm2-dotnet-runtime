# README

```sh
docker build --no-cache -t o:2 .
docker run -ti --rm o:2 sh -l
softhsm2-util --init-token --slot 0 --label "My First Token"
pkcs11-tool --module /usr/local/lib/softhsm/libsofthsm2.so -l -t
pkcs11-tool --module /usr/local/lib/softhsm/libsofthsm2.so -M
```