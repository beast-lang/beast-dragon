module beast.code.data.entitycontainer.namespace.user;

import beast.code.toolkit;
import beast.code.data.entitycontainer.namespace.namespace;

/// Namespace whose symbols are generated from user (programmer) code
final class UserNamespace : Namespace {
	mixin TaskGuard!( "membersObtaining" );

public:
	alias ObtainFunction = Symbol[ ]delegate( );

public:
	this( Symbol symbol, ObtainFunction obtainFunction, InstanceTransformer instanceTransformer = defaultInstanceTransformer ) {
		super( symbol, instanceTransformer );
		obtainFunction_ = obtainFunction;

		taskManager.issueJob( { enforceDone_membersObtaining( ); } );
	}

public:
	override Overloadset resolveIdentifier( Identifier id, DataEntity instance ) {
		enforceDone_membersObtaining( );
		return super.resolveIdentifier( id, instance );
	}

private:
	final void execute_membersObtaining( ) {
		initialize( obtainFunction_( ) );
	}

private:
	ObtainFunction obtainFunction_;

}
