module t_binarytreemirroring;

Void main() {
	@ctime BinaryTree tree;
	tree.recursivePrint(); //! stdout:

	@ctime {
		tree.insert( 1 );
		tree.insert( 5 );
		tree.insert( -1 );
	}

	tree.recursivePrint(); //! stdout: -115

	print( tree.contains( 6 ) ); //! stdout: 0
	print( @ctime tree.contains( 5 ) ); //! stdout: 1
}

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