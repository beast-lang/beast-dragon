module beast.code.data.overloadset;

import beast.code.data.toolkit;
import beast.code.data.decorator.decorator;
import beast.code.ast.expr.parentcomma;
import beast.code.data.callable;
import beast.code.data.scope_.local;
import beast.code.ast.expr.expression;

struct Overloadset {

	public:
		this( DataEntity[ ] data ) {
			this.data = data;
		}

		this( DataEntity entity ) {
			data = [ entity ];
		}

	public:
		DataEntity[ ] data;
		alias data this;

	public:
		/// Returns list of decorators in the overloadset
		Symbol_Decorator[ ] filter_decoratorsOnly( ) {
			import std.array : appender;

			auto result = appender!( Symbol_Decorator[ ] );
			foreach ( item; data ) {
				if ( auto deco = item.isDecorator )
					result ~= deco;
			}

			return result.data;
		}

	public:
		/// Returns single entry from the overloadset
		/// If the overloadset is empty, throws noMatchingOverload error, if it contains multiple items, throws ambiguousResolution error
		DataEntity single( ) {
			benforce( data.length < 2, E.ambiguousResolution, "Expression is ambigous: can be '%s' or '%s' (or possibly more)".format( data[ 0 ], data[ 1 ] ) );
			benforce( data.length > 0, E.noMatchingOverload, "Empty overloadset (more explaining message should have been shown, this would probably deserve a bug report)" );
			return data[ 0 ];
		}

		/// Returns single entry from the overloadset that is of expected type or implicitly converible to to it
		/// Throws error if no matching overload is found (or the result is ambiguous)
		/// The expectedType can be null, in that case, the "single"" function is called
		DataEntity single_expectType( Symbol_Type expectedType ) {
			if ( !expectedType )
				return this.single( );

			benforce( data.length > 0, E.noMatchingOverload, "Empty overloadset (more explaining message should have been shown, this would probably deserve a bug report)" );

			DataEntity result;

			foreach ( item; data ) {
				item = item.tryCast( expectedType );

				if ( !item )
					continue;

				// TODO: Maybe better ambiguity error msg?
				benforce( result is null, E.ambiguousResolution, "Expression is ambigous: can be '%s' or '%s' (or ...)".format( result, item ) );
				result = item;
			}

			benforce( result !is null, E.noMatchingOverload, //
					data.length == 1 //
					 ? "Cannot convert '%s' to '%s'".format( data[ 0 ].identificationString, expectedType.identificationString ) //
					 : "None of overloads is convertible to '%s'".format( expectedType.identificationString ) //
					 );

			assert( result.dataType is expectedType );
			return result;
		}

	public:
		/// Resolves call with given arguments (can either be AST_Expression or DataEntity or ranges of both)
		DataEntity resolveCall( Args... )( AST_Node ast, bool reportErrors, Args args ) {
			CallMatchSet match = CallMatchSet( this, ast, reportErrors );

			foreach ( arg; args )
				match.arg( arg );

			return match.finish( );
		}

	public:
		string identificationString( ) {
			return "[ %s ]".format( data.map!( x => x.dataType.identificationString ).joiner( ", " ).array );
		}

	public:
		bool isEmpty( ) const {
			return data.length == 0;
		}

	public:
		bool opCast( T : bool )( ) const {
			return data.length > 0;
		}

}
