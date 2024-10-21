# pytr: Use TradeRepublic in terminal (binary)

This repo is based on [https://github.com/pytr-org/pytr](https://github.com/pytr-org/pytr) which provides a python library to interact with the API from Trade Republic online brokerage.
___

I was looking for a way to use `pytr` but was not keen to setup a whole Python environment. Instead, I thought of using [PyInstaller](https://github.com/pyinstaller/pyinstaller) to create a self-contained binary.

I created Docker files which will build the `pytr` binary and copy it to a scratch image. This can then be exported to the host via

```shell
docker build --output=. --target=export .
```

The used base image are old on purpose: PyInstaller links against `libc` which is [forward compatible but not backward compatible](https://pyinstaller.org/en/v4.7/usage.html#making-gnu-linux-apps-forward-compatible). This should make sure the `pytr` binary runs on new and older systems.
