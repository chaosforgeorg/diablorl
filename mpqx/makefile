#####################################################################
#
# Makefile for compiling mpqx with MINGW
#
#####################################################################

PATH   = C:\MINGW\bin
CPP    = g++
CC     = gcc
CFLAGS = -Wall
DFLAGS = -D_7ZIP_ST

all: mpqx.exe

mpqx.exe: mpqx.o ../StormLib/StormLib.lib
	$(CPP) $(CFLAGS) $(DFLAGS) -o mpqx.exe mpqx.o StormLib.dll  

mpqx.o: %.o: %.cpp
	$(CC) -o $@ $(CFLAGS) $(DFLAGS) -c $<

