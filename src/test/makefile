CC		:= bin/clang
CXX		:= bin/clang++

CFLAGS		:= -flto=thin -fvisibility=hidden
CFLAGS_V2	:= -march=x86-64-v2
CFLAGS_V3	:= -march=x86-64-v3 -mavx2

CFLAGS_MINGW	:= --target=x86_64-w64-mingw32 -fms-compatibility-version=19.40 --sysroot=sys/mingw

CXXFLAGS	:= -fno-exceptions -fno-rtti -static-libstdc++

SYS_LINUX_V2	:= -cxx-isystem sys/linux/x86-64-v2/include/c++/v1 -Lsys/linux/x86-64-v2/lib
SYS_LINUX_V3	:= -cxx-isystem sys/linux/x86-64-v3/include/c++/v1 -Lsys/linux/x86-64-v3/lib

SYS_MINGW_V2	:= -cxx-isystem sys/mingw/x86-64-v2/include/c++/v1 -Lsys/mingw/x86-64-v2/lib
SYS_MINGW_V3	:= -cxx-isystem sys/mingw/x86-64-v3/include/c++/v1 -Lsys/mingw/x86-64-v3/lib

all: build/test/main build/test/main-v2 build/test/main-v3 build/test/main.exe build/test/main-v2.exe build/test/main-v3.exe

build/test/main: src/test/main.c build/test
	$(CC) -std=c23 -Os $(CFLAGS) $(CFLAGS_V2) -o $@ $<

build/test/main.exe: src/test/main.c build/test
	$(CC) -std=c23 -Os $(CFLAGS) $(CFLAGS_V2) -mwindows -municode $(CFLAGS_MINGW) -lpathcch -lole32 -luuid -o $@ $<

build/test/main-v2: src/test/main.cpp build/test
	$(CXX) -std=c++26 -O3 $(CFLAGS) $(CFLAGS_V2) $(CXXFLAGS) $(SYS_LINUX_V2) -o $@ $<

build/test/main-v3: src/test/main.cpp build/test
	$(CXX) -std=c++26 -O3 $(CFLAGS) $(CFLAGS_V3) $(CXXFLAGS) $(SYS_LINUX_V3) -o $@ $<

build/test/main-v2.exe: src/test/main.cpp build/test
	$(CXX) -std=c++26 -O3 $(CFLAGS) $(CFLAGS_V2) $(CXXFLAGS) $(CFLAGS_MINGW) $(SYS_MINGW_V2) -o $@ $<

build/test/main-v3.exe: src/test/main.cpp build/test
	$(CXX) -std=c++26 -O3 $(CFLAGS) $(CFLAGS_V3) $(CXXFLAGS) $(CFLAGS_MINGW) $(SYS_MINGW_V3) -o $@ $<

build/test:
	mkdir -p $@

run-linux: build/test/main build/test/main-v2 build/test/main-v3
	$<
	$< -v2

run-mingw: build/test/main.exe build/test/main-v2.exe build/test/main-v3.exe
	WINEDEBUG="-all" WINE_DISABLE_KERNEL_WRITEWATCH=1 wine64 $<
	cat ~/.wine/drive_c/users/steamuser/AppData/Local/Ace/test/main.log
	WINEDEBUG="-all" WINE_DISABLE_KERNEL_WRITEWATCH=1 wine64 $< -v2
	cat ~/.wine/drive_c/users/steamuser/AppData/Local/Ace/test/main.log

run: run-linux run-mingw

clean:
	rm -rf build/test

.PHONY: all run-linux run-mingw run clean
