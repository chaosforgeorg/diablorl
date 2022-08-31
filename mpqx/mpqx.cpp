// mpqx.cpp : Defines the entry point for the console application.
//

#include <stdio.h>
#include <direct.h>
#include "../StormLib/src/StormLib.h"

void mkdirs(char *path)
{
	char *p = path;
	while (*++p) {
		if (*p == '\\') {
			*p = '\0';
			mkdir(path);
			*p = '\\';
		}
	}
}

int main(int argc, char* argv[])
{
	if (argc != 2) {
		printf("usage: mpqx {filename}\n");
	}
	HANDLE hArchive = NULL;
	if (SFileOpenArchive(argv[1],0,MPQ_FLAG_READ_ONLY,&hArchive)) {
		if (SFileAddListFile(hArchive,"listfile.txt") == ERROR_SUCCESS) {
			SFILE_FIND_DATA fd; 
			HANDLE hFind = SFileFindFirstFile(hArchive,"*.wav",&fd,NULL);
			if (hFind) {
				do {
					mkdirs(fd.cFileName);
					SFileExtractFile(hArchive,fd.cFileName,fd.cFileName);
				} while (SFileFindNextFile(hFind,&fd));
				SFileFindClose(hFind);
			}
		}
		SFileCloseArchive(hArchive);
	}
	return(0);
}

