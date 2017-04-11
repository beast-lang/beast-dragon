module beast.code.ast.decl.variable;

import beast.code.ast.decl.toolkit;
import beast.code.ast.identifier;
import beast.code.data.scope_.root;
import beast.code.data.var.usrstc;
import beast.code.data.var.usrlcl;
import beast.backend.ctime.codebuilder;
import beast.code.data.var.usrmem;

final class AST_VariableDeclaration : AST_Declaration {

	public:
		static bool canParse( ) {
			assert( 0 );
		}

		/// Continues parsing after "@deco Type name" part ( "= value;", ":= value;" or ";" can follow )
		static AST_VariableDeclaration parse( CodeLocationGuard _gd, AST_DecorationList decorationList, AST_Expression dataType, AST_Identifier identifier ) {
			AST_VariableDeclaration result = new AST_VariableDeclaration;
			result.decorationList = decorationList;
			result.dataType = dataType;
			result.identifier = identifier;

			if ( currentToken.matchAndNext( Token.Operator.assign ) ) {
				result.value = AST_Expression.parse( );
			}
			else if ( currentToken.matchAndNext( Token.Operator.colonAssign ) ) {
				result.valueColonAssign = true;
				result.value = AST_Expression.parse( );
			}
			else
				currentToken.expect( Token.Special.semicolon, "default value or ';'" );

			currentToken.expectAndNext( Token.Special.semicolon );

			result.codeLocation = _gd.get( );
			return result;
		}

	public:
		override void executeDeclarations( DeclarationEnvironment env, void delegate( Symbol ) sink ) {
			const auto __gd = ErrorGuard( codeLocation );

			VariableDeclarationData declData = new VariableDeclarationData( env );
			DecorationList decorationList = new DecorationList( decorationList, env.staticMembersParent );

			// Apply possible decorators in the variableDeclarationModifier context
			decorationList.apply_variableDeclarationModifier( declData );

			if ( declData.isStatic ) {
				// No buildConstructor - that is handled in the Symbol_UserStaticVariable.memoryAllocation
				sink( new Symbol_UserStaticVariable( this, decorationList, declData ) );
			}
			else {
				benforce( env.parentType !is null, E.memVarOutsideClass, "Cannot declare nonstatic variables outside classes" );
				benforce( env.parentType.declarationType == Symbol.DeclType.staticClass || env.parentType.declarationType == Symbol.DeclType.memberClass, E.memVarOutsideClass, "Cannot declare nonstatic variables outside classes" );

				sink( new Symbol_UserMemberVariable( this, decorationList, declData ) );
			}
		}

		override void buildStatementCode( DeclarationEnvironment env, CodeBuilder cb ) {
			const auto __gd = ErrorGuard( codeLocation );
			assert( currentScope );

			VariableDeclarationData declData = new VariableDeclarationData( env );
			DecorationList decorations = new DecorationList( decorationList, env.staticMembersParent );

			// Apply possible decorators in the variableDeclarationModifier context
			decorations.apply_variableDeclarationModifier( declData );

			if ( declData.isStatic ) {
				// No buildConstructor for static variables - that is handled in the Symbol_UserStaticVariable.memoryAllocation
				if ( env.staticMemberMerger && env.staticMemberMerger.isFinished( ) )
					currentScope.addEntity( env.staticMemberMerger.getRecord( this ) );

				else {
					Symbol_UserStaticVariable var = new Symbol_UserStaticVariable( this, decorations, declData );
					currentScope.addEntity( var );

					if ( env.staticMemberMerger )
						env.staticMemberMerger.addRecord( this, var );
				}
			}
			else {
				assert( !env.parentType );

				DataEntity valueEntity;
				DataEntity_UserLocalVariable var;

				if ( dataType.isAutoExpression ) {
					benforce( value !is null, E.missingInitValue, "Variable '%s.%s' definition needs implicit value for type deduction".format( currentScope.identificationString, identifier.str ) );

					valueEntity = value.buildSemanticTree_single;
					var = new DataEntity_UserLocalVariable( identifier, valueEntity.dataType, decorations, declData );
				}
				else {
					var = new DataEntity_UserLocalVariable( this, decorations, declData );

					if ( value )
						valueEntity = value.buildSemanticTree_singleInfer( var.dataType );
				}

				cb.build_localVariableDefinition( var );
				buildConstructor( var, valueEntity, declData.isCtime ? scoped!CodeBuilder_Ctime : cb );
				currentScope.addLocalVariable( var );
			}
		}

	public:
		AST_DecorationList decorationList;
		AST_Expression dataType;
		AST_Identifier identifier;
		AST_Expression value;
		/// True if variable was declarated using "@deco Type name := value"
		bool valueColonAssign;

	protected:
		override SubnodesRange _subnodes( ) {
			// Decoration list can be inherited from decoration block or something, in that case we should not consider it a subnodes
			return nodeRange( dataType, identifier, value, decorationList.codeLocation.isInside( codeLocation ) ? decorationList : null );
		}

	public:
		void buildConstructor( DataEntity entity, DataEntity valueEntity, CodeBuilder cb ) {
			cb.build_scope( ( cb ) {
				auto match = entity.expectResolveIdentifier( ID!"#ctor" ).CallMatchSet( this, true );

				if ( valueEntity ) {
					// colonAssign calls #ctor( #Ctor.refAssign, value );
					if ( valueColonAssign )
						match.arg( coreLibrary.enum_.xxctor.refAssign );

					match.arg( valueEntity );
				}

				match.finish( ).buildCode( cb );
			} );
		}

		pragma( inline ) void buildConstructor( DataEntity entity, CodeBuilder cb ) {
			buildConstructor( entity, value ? value.buildSemanticTree_singleInfer( entity.dataType ) : null, cb );
		}

}

final class VariableDeclarationData {

	public:
		this( DeclarationEnvironment env ) {
			this.env = env;

			isCtime = env.isCtime;
			isStatic = env.isStatic;
		}

	public:
		DeclarationEnvironment env;

	public:
		bool isCtime;
		bool isStatic;

}
