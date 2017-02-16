module beast.code.namespace.user;

import beast.code.toolkit;
import beast.code.namespace.namespace;

/// Namespace whose symbols are generated from user (programmer) code
final class UserNamespace : Namespace {
	mixin TaskGuard!( "membersObtaining" );

public:
	this( Symbol symbol, Symbol[ ]delegate( ) obtainFunction ) {
		super( symbol );
		obtainFunction_ = obtainFunction;

		taskManager.issueJob( { enforceDone_membersObtaining( ); } );
	}

public:
	override Symbol[ ] resolveIdentifier( Identifier id ) {
		enforceDone_membersObtaining( );

		if ( auto result = id in groupedMembers_ )
			return *result;

		return null;
	}

private:
	final void execute_membersObtaining( ) {
		members_ = obtainFunction_( );
		groupedMembers_ = groupMembers( members_ );
	}

private:
	Symbol symbol_;
	Symbol[ ] members_;
	Symbol[ ][ Identifier ] groupedMembers_;
	Symbol[ ]delegate( ) obtainFunction_;

}
