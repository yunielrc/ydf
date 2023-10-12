# Changelog

## [0.3.1](https://github.com/yunielrc/ydf/compare/v0.3.0...v0.3.1) (2023-10-12)


### Bug Fixes

* **package-command:** add return keywork right before exit code ([455648b](https://github.com/yunielrc/ydf/commit/455648b3ace6c69b657c6f110cd88dd9ece54390))

## [0.3.0](https://github.com/yunielrc/ydf/compare/v0.2.0...v0.3.0) (2023-09-28)


### Features

* **package:** add a command to list packages ([02ace92](https://github.com/yunielrc/ydf/commit/02ace92dadd4cd6c733ab6eef0f4a9619cd88fba)), closes [#5](https://github.com/yunielrc/ydf/issues/5)
* **package:** add a command to list selections ([c6c9907](https://github.com/yunielrc/ydf/commit/c6c99077bd09ff22fb0dc0020fa02c53ebdf2668)), closes [#6](https://github.com/yunielrc/ydf/issues/6)

## 0.2.0 (2023-09-27)


### Features

* **package-service:** make envsubst variables availables in scripts instructions ([32e89c2](https://github.com/yunielrc/ydf/commit/32e89c228e27f819a839ba45e345cdf916f5a2be))
* **package-service:** print output for all instrucions ([843b8f4](https://github.com/yunielrc/ydf/commit/843b8f408d44fddbef407208c4e8ab3b27f8b589))
* **package:** add a command to install a package ([da8fa28](https://github.com/yunielrc/ydf/commit/da8fa2812294335145fcd8d74d57a12359e6b42e))
* **package:** add an instruction homecp to copy files recursively to ~/ ([68edd3c](https://github.com/yunielrc/ydf/commit/68edd3cb9ae3232fd9f906d790df5768d6c4b29e))
* **package:** add an instruction homeln to create files symlinks on home ([ed4a268](https://github.com/yunielrc/ydf/commit/ed4a2684c579d0afe3e09be262fc422d7b81adad))
* **package:** add an instruction homelnr to create directories and make files symlinks on ~/ ([3c9043c](https://github.com/yunielrc/ydf/commit/3c9043cbc77d417756d540b94f7c29516838a5e1))
* **package:** add an instruction rootcp to copy files recursively to / ([1d38e92](https://github.com/yunielrc/ydf/commit/1d38e92eea665f7043369abe7963d506fbf26658))
* **package:** add an instruction to install [@snap](https://github.com/snap) apps ([d0eda52](https://github.com/yunielrc/ydf/commit/d0eda52c03a974043e43d4cbc9be0885899750c4))
* **package:** add an instruction to install a ydof plugin ([e2baaa0](https://github.com/yunielrc/ydf/commit/e2baaa0c9c4a9855f26a49ebcb8f7201c906f7b5))
* **package:** add an instruction to install flatpak apps ([b94a556](https://github.com/yunielrc/ydf/commit/b94a55639bcbb01e4d34e5cde8579c9dbc499afd))
* **package:** add an instruction to run docker-compose.yml ([a93a2ba](https://github.com/yunielrc/ydf/commit/a93a2ba066f974e6afc1033939c7eabb9e3a01d0))
* **package:** add an option to set a default directory for packages ([d1a6fb5](https://github.com/yunielrc/ydf/commit/d1a6fb521355c6dd787bcf83dd1834672a96efbb))
* **package:** add instr homecps to copy files to ~/ with envvar substitution ([4f89db9](https://github.com/yunielrc/ydf/commit/4f89db9bfc364ac712f16b16b0d81eefbda9d798))
* **package:** add instruction [@apt](https://github.com/apt), [@apt-get](https://github.com/apt-get) to install ubuntu packages ([7186c5a](https://github.com/yunielrc/ydf/commit/7186c5a59c549b8bf8f2e1f5aec91a573752dfea))
* **package:** add instruction dconf.ini to configure gnome desktop apps ([f671b8a](https://github.com/yunielrc/ydf/commit/f671b8a88e364fd732d5d6f9ba66b6b525d4523a))
* **package:** add instruction homecat to cat files recursively to ~/ ([7a2850e](https://github.com/yunielrc/ydf/commit/7a2850e019baa50386570d40fd86a26cce0f4eb6))
* **package:** add instruction homecat to cat files recursively to ~/ With envar substitution ([b27e923](https://github.com/yunielrc/ydf/commit/b27e923faa4bce465943288b1afe68a04ab8b111))
* **package:** add instruction install ([3b374df](https://github.com/yunielrc/ydf/commit/3b374df3e63a9be0c04e82fd152a5874ea2547a3))
* **package:** add instruction pacman to install apps for manjaro ([e29623b](https://github.com/yunielrc/ydf/commit/e29623b1a66474554c11c8ad698db3325ae44120))
* **package:** add instruction postinstall ([9cb6f27](https://github.com/yunielrc/ydf/commit/9cb6f27a98d8d483d155db365adafb62fa9abacc))
* **package:** add instruction rootcat to cat files recursively to / ([63dad11](https://github.com/yunielrc/ydf/commit/63dad11432bb80195d62ee54076599d8b37d69b4))
* **package:** add instruction rootcps to copy to / with envar substitution ([8ee935a](https://github.com/yunielrc/ydf/commit/8ee935aeae7af6741cd2592b212c92ba5a605e5e))
* **package:** add instruction to add a yzsh theme ([a5ae0bf](https://github.com/yunielrc/ydf/commit/a5ae0bf4ed6c61f43edb6776c3b0ac8974e1b2b7))
* **package:** add instruction yay for manjaro ([92243b6](https://github.com/yunielrc/ydf/commit/92243b651c7b96ecf094a7ade8bc08af86b4321d))
* **package:** install multiple packages ([50f6a1d](https://github.com/yunielrc/ydf/commit/50f6a1dd3d9b016595376f072bd395eca52a8bd7))
* **package:** install packages from a packages selection file ([14b7ac5](https://github.com/yunielrc/ydf/commit/14b7ac57f8d38a5e21f151672dc4d51e00aea921))


### Bug Fixes

* **install:** solve the problem of overwriting .gitignore ([fc58248](https://github.com/yunielrc/ydf/commit/fc58248fd58c8b27b205005fa002e8d8e70c9ff0))
* **package-service:** show error during cat operation when dest file doesn't exist ([1bbd87a](https://github.com/yunielrc/ydf/commit/1bbd87a222a0a4fc2f9de1d1a9f412c4264f5eed))
* **package-service:** solve problem when installing multiple packages from a @&lt;package_manager&gt; file ([ee01c77](https://github.com/yunielrc/ydf/commit/ee01c773e82e757e37a130d7c03f3ee2774c83de))
* **package-service:** solve sudo problem when installing yay packages ([6d0d1ea](https://github.com/yunielrc/ydf/commit/6d0d1eae6beba7a8f4f4d2ccbd9d1f8443051bc3))
* **package:** execute instruction only if file type match ([778a315](https://github.com/yunielrc/ydf/commit/778a31558089e6dbf8ed8dfd61fc1b4cbb2c4526))
* **ydf:** create a default envarsub file to avoid unbound variable ([5a88fce](https://github.com/yunielrc/ydf/commit/5a88fce4ecc0e8a2eb5eab6ae46a2e1cf9a62740))
* **ydf:** set a default value for OS variable ([6f63f34](https://github.com/yunielrc/ydf/commit/6f63f34885f963ea12753f18793d4cd4040a53c7))


### Performance Improvements

* **package:** add tests/fixtures/0empty directory ([22312a9](https://github.com/yunielrc/ydf/commit/22312a940436e4633d03c1a094ff412d972d0598))


### Miscellaneous Chores

* **release:** release 0.2.0 ([f51bd3b](https://github.com/yunielrc/ydf/commit/f51bd3be7ff725d41b77eb74f7f96622ad774176))
