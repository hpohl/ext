module ext.misc.node;

import std.algorithm;

import ext.misc.exception;


/**
 * A node in a tree of nodes.
 */
class Node(T) {
	
	/// Makes sure T derives from this.	
	invariant() {
		assert(cast(T)this !is null);
	}
	
	/**
	 * Attaches a node to this one.
	 * Throws: MiscException if the node is already attached or
	 * there is a recursive attachment.
	 */
	void attach(T n) {
		if (canFind(_children, n)) {
			throw new MiscException("Cannot attach node: Already attached.");
		}
		
		if (canFind(_parents, n)) {
			throw new MiscException("Cannot attach node: Is parent.");
		}
		
		n._parents ~= cast(T)this;
		_children ~= n;
	}
	
	/**
	 * Detaches a node from this one.
	 * Throws: MiscException if the node is not attached.
	 */
	void detach(T n) {
		if (!canFind(_children, n)) {
			throw new WAException("Cannot detach node: Not attached.");
		}
		
		copy(filter!((x) => x != this)(n._parents), n._parents);
		copy(filter!((x) => x != n)(_children), _children);
	}
	
	// Properties.
	@property nothrow pure {
		/// Returns the parents (if any) of this node.
		inout(T[]) parents() inout {
			return _parents;
		}
		
		/// Returns the children (if any) of this node.
		inout(T[]) children() inout {
			return _children;
		}
	}
	
	private {
		T[] _parents;
		T[] _children;
	}
}