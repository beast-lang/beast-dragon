module beast.code.data.overloadset;

import beast.code.data.toolkit;
import beast.code.data.scope_.local;
import beast.code.ast.expr.parentcomma;

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
			/*Symbol_Decorator[ ] result;

		foreach( item; data ) {
			if( item.dataType !is  )
		}

		return result;*/
			return null;
			// TODO:
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
				/// TODO: Implicit cast check
				/// TODO: alias this check

				if ( item.dataType !is expectedType )
					continue;

				// TODO: Maybe better ambiguity error msg?
				benforce( result is null, E.ambiguousResolution, "Expression is ambigous: can be '%s' or '%s' (or ...)".format( result, item ) );
				result = item;
			}

			benforce( result !is null, E.noMatchingOverload, //
					data.length == 1 //
					 ? "Cannot convert '%s' to '%s'".format( data[ 0 ].identificationString, expectedType.identificationString ) //
					 : "None of the overloads are convertible to '%s'".format( expectedType.identificationString ) //
					 );

			return result;
		}

		/// Resolves a function call with this overloadset
		CallableMatch resolveCall( AST_ParentCommaExpression ast, DataScope scope_ ) {
			// TODO: Little help of expectedType?

			CallableMatch[ ] matches = data.filter!( x => x.isCallable ).map!( x => x.startCallMatch( scope_, ast ) ).array;
			benforce( matches.length > 0, E.noMatchingOverload, "No callable overloads in the %s".format( identificationString ) );

			// We have to go one argument at a time, because processing arguments can change @ctime variables
			scope subScope = new LocalDataScope( scope_ );
			foreach ( AST_Expression argExpr; ast.items ) {
				DataEntity entity = argExpr.buildSemanticTree_single( null, scope_, false );
				Symbol_Type dataType = entity ? entity.dataType : null;

				foreach ( func; matches ) {
					/// Further parsing has to be in custom session so any resolution attempt doesn't mutate local ctime variable
					with ( memoryManager.session )
						func.matchNextArgument( argExpr, entity, dataType );
				}
			}

			// Now find best match
			CallableMatch bestMatch = matches[ 0 ];
			size_t bestMatchCount = 1;

			matches[ 0 ].finish( );

			foreach ( match; matches[ 1 .. $ ] ) {
				match.finish( );

				if ( match.matchLevel > bestMatch.matchLevel ) {
					bestMatch = match;
					bestMatchCount = 1;
				}
				else if ( match.matchLevel == bestMatch.matchLevel )
					bestMatchCount++;
			}

			// TODO: error messages when matchLevel is noMatch
			benforce( bestMatch.matchLevel != CallableMatch.Level.noMatch, E.noMatchingOverload, "None of the overloads %s match given arguments".format( identificationString ) );
			benforce( bestMatchCount == 1, E.ambiguousResolution, "Ambiguous overload resolution: %s".format( matches.filter!( x => x.matchLevel == bestMatch.matchLevel ).map!( x => x.sourceDataEntity ).array.Overloadset.identificationString ) );

			return bestMatch;
		}

	public:
		string identificationString( ) {
			return "[ %s ]".format( data.map!( x => x.dataType.identificationString ).joiner( ", " ).array );
		}

	public:
		bool isEmpty( ) const {
			return data.length == 0;
		}

		bool isNotEmpty( ) const {
			return data.length > 0;
		}

	public:
		bool opCast( T : bool )( ) const {
			return data.length > 0;
		}

}
