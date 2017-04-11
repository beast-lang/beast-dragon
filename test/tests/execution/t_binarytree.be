module t_binarytree;

class BinaryTreeNode {

	Void #ctor( Int value ) {
		this.value.#ctor( value );
		left.#ctor();
		right.#ctor();
	}
	Void #dtor() {
		value.#dtor();
		left.#dtor();
		right.#dtor();
	}

	Void recursivePrint() {
		if( !left.isNull )
			left.recursivePrint();
		
		print( value );

		if( !right.isNull )
			right.recursivePrint();
	}

	Int value;
	BinaryTreeNode? left;
	BinaryTreeNode? right;
}

class BinaryTree {

	Void #ctor() {
		root.#ctor( null );
	}
	Void #dtor() {
		root.#dtor();
	}

	Void insert( Int value ) {
		BinaryTreeNode? node := root;
		Pointer nodePtr = root.#addr;

		while( !node.isNull ) {
			if( value > node.value )
				nodePtr = node.right.#addr;
			else
				nodePtr = node.left.#addr;

			node := nodePtr.data( BinaryTreeNode? );
		}

		nodePtr.data( BinaryTreeNode? ) := new BinaryTreeNode( value );
	}

	Bool contains( Int value ) {
		BinaryTreeNode? node := root;
		while( !node.isNull ) {
			if( value == node.value )
				return true;
			else if( value > node.value )
				node := node.right;
			else
				node := node.left;
		}

		return false;
	}

	Bool remove( Int value ) {
		BinaryTreeNode? node := root;
		Pointer nodePtr = root.#addr;

		while( !node.isNull ) {
			if( value == node.value ) {
				if( node.left.isNull ) {
					nodePtr.data( BinaryTreeNode? ) := node.right;
					delete node;
				}
				else if( node.right.isNull ) {
					nodePtr.data( BinaryTreeNode? ) := node.left;
					delete node;
				}
				else {
					BinaryTreeNode? substNode := node.left;
					Pointer substNodePtr = node.left.#addr;

					while( !substNode.right.isNull ) {
						substNodePtr = substNode.right.#addr;
						substNode := substNode.right;
					}

					node.value = substNode.value;
					substNodePtr.data( BinaryTreeNode? ) := substNode.left;
					delete substNode;
				}

				return true;
			}
			else if( value > node.value )
				nodePtr = node.right.#addr;
			else
				nodePtr = node.left.#addr;

			node := nodePtr.data( BinaryTreeNode? );
		}

		return false;
	}

	Void recursivePrint() {
		if( !root.isNull )
			root.recursivePrint();
	}

	BinaryTreeNode? root;

}

Bool test( Bool print ) {
	BinaryTree tree;

	tree.insert( 1 );
	tree.insert( 2 );
	tree.insert( 1 );
	tree.insert( 10 );

	assert( tree.contains( 1 ) );
	assert( !tree.contains( 3 ) );

	if( print )
		tree.recursivePrint(); //! stdout: 11210

	tree.remove( 1 );

	assert( tree.contains( 1 ) );
	
	if( print )
		tree.recursivePrint(); //! stdout: 1210

	tree.remove( 1 );
	tree.remove( 2 );

	assert( !tree.contains( 1 ) );
	assert( !tree.contains( 2 ) );

	if( print )
		tree.recursivePrint(); //! stdout: 10

	tree.remove( 10 );

	assert( !tree.contains( 1 ) );
	assert( !tree.contains( 2 ) );
	assert( !tree.contains( 10 ) );

	if( print )
		tree.recursivePrint(); //! stdout: 

	return true;
}

@ctime auto ctTest = test( false );

Void main() {
	test( true );
}