module beast.code.data.callable.matchset;

import beast.code.data.toolkit;
import beast.code.data.callable.match;
import beast.code.data.scope_.local;
import beast.code.ast.expr.expression;
import std.range.primitives : isInputRange, ElementType;

/// Structure that handles overload matching
struct CallMatchSet {

	public:
		this( Overloadset overloadset, AST_Node ast, bool reportErrors = true, MatchLevel matchLevel = MatchLevel.fullMatch ) {
			scope_ = new LocalDataScope( );
			auto _sgd = scope_.scopeGuard;

			this.reportErrors = reportErrors;

			foreach ( overload; overloadset ) {
				if ( overload.isCallable )
					matches ~= overload.startCallMatch( ast, reportErrors && ( overloadset.length == 1 ), matchLevel );

				// If the overload is not callable, we try to overload against overload.#opCall( XXX )
				else {
					auto suboverloadset = overload.tryResolveIdentifier( Identifier.preobtained!"#call" );
					foreach ( suboverload; suboverloadset ) {
						if ( suboverload.isCallable )
							matches ~= suboverload.startCallMatch( ast, overloadset.length == 1 && suboverloadset.length == 1, matchLevel );
					}
				}
			}

			benforce( !reportErrors || matches.length != 0, E.noMatchingOverload, "No callable overloads" );
		}

	public:
		ref CallMatchSet arg( T : DataEntity )( T entity ) {
			auto _sgd = scope_.scopeGuard;

			Symbol_Type dataType = entity.dataType;
			argumentEntities ~= entity;

			foreach ( match; matches ) {
				with ( memoryManager.session )
					match.matchNextArgument( null, entity, dataType );
			}

			return this;
		}

		ref CallMatchSet arg( T : Symbol )( T sym ) {
			return arg( sym.dataEntity( MatchLevel.fullMatch ) );
		}

		ref CallMatchSet arg( T : AST_Expression )( T expr ) {
			auto _sgd = scope_.scopeGuard;

			DataEntity entity = expr.buildSemanticTree_single( false );
			Symbol_Type dataType = entity ? entity.dataType : null;
			argumentEntities ~= entity;

			foreach ( match; matches ) {
				with ( memoryManager.session )
					match.matchNextArgument( expr, entity, dataType );
			}

			return this;
		}

		ref CallMatchSet arg( R )( R args ) if ( isInputRange!R ) {
			foreach ( argv; args )
				arg( argv );

			return this;
		}

	public:
		/// Can return null when reportErrors is false
		CallableMatch finish_getMatch( ) {
			scope_.finish( );
			
			if ( matches.length == 0 )
				return null;

			// Now find best match
			CallableMatch bestMatch = matches[ 0 ];
			size_t bestMatchCount = 1;

			matches[ 0 ].finish( );

			foreach ( match; matches[ 1 .. $ ] ) {
				match.finish( );

				/*
					Let me write an example:
					a: 0 1 0 1
					b: 0 1 1 0

					Now we want a to be the new best match, because it's match level is smaller (which is better)
				*/
				if ( match.matchLevel < bestMatch.matchLevel ) {
					bestMatch = match;
					bestMatchCount = 1;
				}
				else if ( match.matchLevel == bestMatch.matchLevel )
					bestMatchCount++;
			}

			if ( bestMatch.matchLevel == MatchLevel.noMatch ) {
				if ( !reportErrors ) {
					// Do nothing
				}
				else if ( matches.length == 1 )
					berror( E.noMatchingOverload, "%s does not match arguments %s: %s".format( matches[ 0 ].sourceDataEntity.tryGetIdentificationString, argumentListIdentificationString, matches[ 0 ].errorStr ) );
				else
					berror( E.noMatchingOverload, //
							"None of the overloads match arguments %s:%s".format(  //
								argumentListIdentificationString, //
								matches.map!( x => "\n\n\t%s:\n\t\t%s".format( x.sourceDataEntity.tryGetIdentificationString, x.errorStr ) ).joiner ) //
							 );

				return null;
			}

			// Report errors do not apply on amiguous resolution (that would screw up things)
			// Report errors = false is used when trying binary operations and their reverse versions -> a.#opBinary( binXX, b ), then b.#opBinaryR( binXX, a )
			// If reportErrors would hide ambiguous resolution, then ambiguous resolution would cause trying the opBinaryR variant, which is not a correct behavior
			benforce( bestMatchCount == 1, E.ambiguousResolution, //
					"Ambiguous overload resolution for arguments %s:%s".format(  //
						argumentListIdentificationString, //
						matches.filter!( x => x.matchLevel == bestMatch.matchLevel ).map!( x => "\n\t%s (match level %s)".format( x.sourceDataEntity.tryGetIdentificationString, x.matchLevel ) ).joiner, //
						 ) );

			return bestMatch;
		}

		pragma( inline ) DataEntity finish() {
			if( auto result = finish_getMatch() )
				return result.toDataEntity();
			else
				return null;
		}

	public:
		/// List of data entities representing arguments
		/// Some of them can be null (where inferration was needed)
		DataEntity[ ] argumentEntities;

		CallableMatch[ ] matches;

		DataScope scope_;

		bool reportErrors;

	public:
		string argumentListIdentificationString( ) {
			string[ ] args;
			foreach ( arg; argumentEntities ) {
				if ( arg is null )
					args ~= "#inferred#";
				else if ( arg.isCtime )
					args ~= "%s = %s".format( arg.dataType.identificationString, arg.dataType.valueIdentificationString( arg.ctExec ) );
				else
					args ~= "%s".format( arg.dataType.identificationString );
			}

			return "( %s )".format( args.joiner( ", " ) );
		}

}
