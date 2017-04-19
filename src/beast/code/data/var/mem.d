module beast.code.data.var.mem;

import beast.code.data.toolkit;
import beast.code.data.var.variable;

/// User (programmer) defined variable
abstract class Symbol_MemberVariable : Symbol_Variable {

	protected:
		this( Symbol_Type parent, void delegate( ) enforceDone_memberOffsetObtaining ) {
			assert( enforceDone_memberOffsetObtaining );

			parent_ = parent;
			enforceDone_memberOffsetObtaining_ = enforceDone_memberOffsetObtaining;
			staticData_ = new Data( this, null, MatchLevel.fullMatch );
		}

	public:
		final override DeclType declarationType( ) {
			return DeclType.memberVariable;
		}

	public:
		final override DataEntity dataEntity( MatchLevel matchLevel = MatchLevel.fullMatch, DataEntity parentInstance = null ) {
			if ( parentInstance !is null || matchLevel != MatchLevel.fullMatch )
				return new Data( this, parentInstance, matchLevel );
			else
				return staticData_;
		}

		/// Offset in bytes from parent's this pointer
		final size_t parentThisOffset( ) {
			enforceDone_memberOffsetObtaining_( );
			return parentThisOffsetWIP_;
		}

		final DataEntity parent( ) {
			return parent_.dataEntity;
		}

	public:
		final override Symbol_MemberVariable isMemberVariable( ) {
			return this;
		}

	private:
		Symbol_Type parent_;
		Data staticData_;
		/// Offset of given member from this pointer
		size_t parentThisOffsetWIP_;
		void delegate( ) enforceDone_memberOffsetObtaining_;

	public:
		/// !! DON'T CALL THIS UNLESS YOU KNOW WHAT YOU'RE DOING!
		/// Sets parentThisOffset
		/// Should be called only from parent.execute_memberOffsetObtaining_ function
		void setParentThisOffsetWIP__ONLYFROMPARENTCLASS( size_t set ) {
			parentThisOffsetWIP_ = set;
		}

	private:
		final static class Data : SymbolRelatedDataEntity {

			public:
				this( Symbol_MemberVariable sym, DataEntity parentInstance, MatchLevel matchLevel ) {
					// Static variables are in global scope
					super( sym, matchLevel );
					sym_ = sym;
					parentInstance_ = parentInstance;
				}

			public:
				override Symbol_Type dataType( ) {
					return sym_.dataType;
				}

				override bool isCtime( ) {
					return parentInstance_.isCtime;
				}

				override DataEntity parent( ) {
					return parentInstance_ ? parentInstance_ : sym_.parent;
				}

				override string identificationString( ) {
					return "%s %s".format( sym_.dataType.tryGetIdentificationString, identificationString_noPrefix );
				}

			public:
				override void buildCode( CodeBuilder cb ) {
					benforce( parentInstance_ !is null, E.needThis, "Need this for %s".format( identificationString ) );

					cb.build_offset( &parentInstance_.buildCode, sym_.parentThisOffset );
				}

			private:
				Symbol_MemberVariable sym_;
				DataEntity parentInstance_;

		}

}
