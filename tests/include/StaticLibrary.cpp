#include "StaticLibrary.h"

StaticLibraryClass::StaticLibraryClass(int i)
	: i_(i)
{
}

int StaticLibraryClass::fooBar() const
{
	return 2;//printf("%d", i_);
}
