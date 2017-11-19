#include "DynamicLibrary.h"

DynamicLibraryClass::DynamicLibraryClass(int i)
	: i_(i)
{
}

int DynamicLibraryClass::fooBar() const
{
	return 1;//printf("%d", i_);
}
