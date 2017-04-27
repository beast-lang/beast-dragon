module t_binarytree;

//! run
Void func( @ctime BinaryTree tree, Bool shouldContain ) {
	assert( ( @ctime tree.contains( 12 ) ) == shouldContain );
	tree.recursivePrint();
}

Void main() {
	@ctime BinaryTree tree;

	@ctime {
		tree.insert( 4 );
		tree.insert( 8 );
		tree.insert( 12 );
		tree.insert( 16 );
		tree.insert( 1 );

		assert( tree.contains( 12 ) );
	}

	func( tree, true ); //! stdout: 1481216

	@ctime {
		tree.remove( 12 );
	}

	func( tree, false ); //! stdout: 14816
}


class BinaryTreeNode {

	Void #ctor( Int value ) {
		this.value.#ctor( value );
		left.#ctor();
		right.#ctor();
	}
	Void #ctor( BinaryTreeNode? other ) {
		value.#ctor( other.value );

		if( other.left.isNull )
			left.#ctor();
		else
			left.#ctor( new BinaryTreeNode( other.left ) );	

		if( other.right.isNull )
			right.#ctor();
		else
			right.#ctor( new BinaryTreeNode( other.right ) );	
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
	Void #ctor( BinaryTree? other ) {
		if( other.root.isNull )
			root.#ctor();
		else
			root.#ctor( new BinaryTreeNode( other.root ) );
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