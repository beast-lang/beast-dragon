#define PRIMITIVE_VAL( var, type ) ( *( ( type* )( var ) ) )
#include <stdint.h>

// TYPES

// module core
typedef unsigned char _tku3kv2__Type[ 4 ];
typedef unsigned char _9d712o__Bool[ 1 ];
typedef void _uvto8c3__Void;
typedef unsigned char _o5vpd31__Int[ 4 ];
typedef unsigned char _fi3f933__Operator[ 4 ];
typedef unsigned char _2lthhf___Ctor[ 4 ];

// module t_localvarusage

// MEMORY BLOCKS

unsigned char __s17_true[1] = { 1 };
unsigned char __s18_false[1] = { 0 };

// DECLARATIONS

// module core

// module t_localvarusage
void _0dlg221__foo1( _9d712o__Bool *_2s5g563__x );
void _0a1cku3__foo2( _9d712o__Bool *_2s5g563__x, _9d712o__Bool *_2s5g563__y );
void _079pvd3__main( );

//DEFINITIONS

// module core

// module t_localvarusage
void _0dlg221__foo1( _9d712o__Bool *_2s5g563__x ) {
}

void _0a1cku3__foo2( _9d712o__Bool *_2s5g563__x, _9d712o__Bool *_2s5g563__y ) {
	{
		_9d712o__Bool _98jpcm__tmp;
		{
			*( (bool*) &_98jpcm__tmp ) = *( (bool*) _2s5g563__x );
		}
		_0dlg221__foo1( &_98jpcm__tmp );
		// #dtor _98jpcm__tmp
	}
	{
		_9d712o__Bool _9fbrcm__tmp;
		{
			*( (bool*) &_9fbrcm__tmp ) = *( (bool*) _2s5g563__y );
		}
		_0dlg221__foo1( &_9fbrcm__tmp );
		// #dtor _9fbrcm__tmp
	}
}

void _079pvd3__main( ) {
	{
		_9d712o__Bool _90o3o5__tmp;
		{
			*( (bool*) &_90o3o5__tmp ) = *( (bool*) &__s17_true );
		}
		_9d712o__Bool _q535o5__tmp;
		{
			*( (bool*) &_q535o5__tmp ) = *( (bool*) &__s18_false );
		}
		_0a1cku3__foo2( &_90o3o5__tmp, &_q535o5__tmp );
		// #dtor _90o3o5__tmp
		// #dtor _q535o5__tmp
	}
}

void main() {}