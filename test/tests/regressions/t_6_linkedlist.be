module t_6_linkedlist;

Void main() {
	@ctime auto ll := new LinkedList();
	ll.printList(); //! stdout:

	@ctime ll.prepend( 3 );
	ll.printList();
	print( 0 ); //! stdout: 30

	@ctime ll.prepend(10);
	ll.printList();
	print( 0 ); //! stdout: 1030

	@ctime ll.remove(3);
	ll.printList();
	print( 0 ); //! stdout: 100

	@ctime {
		delete ll;	
		ll := null;
	}
}


class LinkedList {

	@static @ctime Type T = Int;

	Void #ctor() {
		first.#ctor();
	}
	Void #dtor() {
		LinkedElement? el := first;
		while( !el.isNull ) {
			LinkedElement? nextEl := el.next;
			delete el;
			el := nextEl;
		}

		first.#dtor();
	}
	Void #ctor(LinkedList? other) {
		first.#ctor(other.first);
	}

	LinkedElement? first;

	Void prepend(T? data) {
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

	Void remove(T? data) {
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
		Void #ctor () {
			data.#ctor();
			next.#ctor();
			prev.#ctor();
		}

		Void #dtor () {
			data.#dtor();
			next.#dtor();
			prev.#dtor();
		}

		Void #ctor ( LinkedElement? other) {
			data.#ctor(other.data);
			next.#ctor(other.next);
			prev.#ctor(other.prev);
		}

		T data;

		LinkedElement? next;
		LinkedElement? prev;
	}
}
