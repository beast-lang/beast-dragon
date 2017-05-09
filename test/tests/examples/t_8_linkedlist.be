module t_8_linkedlist;

Void main() {
	// We create a @ctime linked list
	@ctime auto ll := new LinkedList();
	// We call the printList function at runtime (we can't print at compile time)
	ll.printList(); //! stdout:

	// Now we modify the linked list at compile-time and again print it at runtime
	@ctime ll.prepend( 3 );
	ll.printList();
	print( 0 ); //! stdout: 30

	// We do this two more times, because we can
	@ctime ll.prepend( 10 );
	ll.printList();
	print( 0 ); //! stdout: 1030

	@ctime ll.remove( 3 );
	ll.printList();
	print( 0 ); //! stdout: 100

	// Now we clean up the linked list (we could also have declared it as a local variable instead of dynamically allocated one)
	@ctime {
		delete ll;
		// The compiler currently doesn't like dangling pointers, so we set it to null
		ll := null;
	}
}

class LinkedList {

	// There are no generic classes yet, but this is a good preparation for ones - when they're implemented, one can simply move this variable to the generic parameter list
	@static @ctime Type T = Int;

	// Compiler doesn't have automatic constructor/destructor generation yet, so we have to define them manually + call all child members constructors/destructors
	Void #ctor() {
		first.#ctor();
	}

	// Compiler doesn't have automatic constructor/destructor generation yet, so we have to define them manually + call all child members constructors/destructors
	Void #dtor() {
		if( !first.isNull ) {
			LinkedElement? el := first;
			while( !el.next.isNull ) {
				el := el.next;
				delete el.prev;
			}

			delete el;
		}

		first.#dtor();
	}

	// This is a copy constructor
	Void #ctor( LinkedList? other ) {
		first.#ctor( other.first );
	}

	LinkedElement? first;

	Void prepend( T? data ) {
		LinkedElement? newFirst = new LinkedElement();
		newFirst.data = data;

		if( !first.isNull ) {
			first.prev := newFirst;
			newFirst.next := first;
		}

		first := newFirst;
	}

	Void printList() {
		LinkedElement? el := first;
		while( !el.isNull ) {
			print( el.data );
			el := el.next;
		}
	}

	Void remove( T? data ) {
		LinkedElement? el := first;
		while( !el.isNull ) {
			if( el.data == data ) {
				if( !el.prev.isNull )
					el.prev.next := el.next;
				else
					first := el.next;

				if( !el.next.isNull )
					el.next.prev := el.prev;

				delete el;
				return;
			}

			el := el.next;
		}
	}

	@static class LinkedElement {
		Void #ctor() {
			data.#ctor();
			next.#ctor();
			prev.#ctor();
		}

		Void #dtor() {
			data.#dtor();
			next.#dtor();
			prev.#dtor();
		}

		Void #ctor( LinkedElement? other ) {
			data.#ctor(other.data);
			next.#ctor(other.next);
			prev.#ctor(other.prev);
		}

		T data;
		LinkedElement? next;
		LinkedElement? prev;
	}
}
