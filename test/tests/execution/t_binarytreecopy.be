module t_binarytreecopy;

//! run
Void test() {
	BinaryTree tree;
	tree.insert( 5 );
	tree.insert( 8 );
	tree.insert( 1 );
	tree.insert( 2 );
	tree.insert( 4 );

	assert( tree.contains( 5 ) );
	assert( tree.contains( 2 ) );
	assert( !tree.contains( 9 ) );

	BinaryTree tree2 = tree;

	assert( tree2.contains( 5 ) );
	assert( tree2.contains( 2 ) );
	assert( !tree2.contains( 9 ) );

	tree.remove( 2 );
	assert( !tree.contains( 2 ) );
	assert( tree2.contains( 2 ) );

	tree.remove( 5 );
	assert( !tree.contains( 5 ) );
	assert( tree2.contains( 5 ) );
}

Void main() {
	@ctime test();
	test();
	@ctime test();
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