#include <iostream>
template<unsigned n>
struct Factorial
{
	enum{
		value = n * Factorial<n-1>::value
	};
};
template<>
struct Factorial<0>
{
	enum{
		value = 1;
	};
};

int main()
{
	std::cout<< Factorial<5>::value;
	std::cout<< Factorial<10>::value<<endl;
	return 0;
}
