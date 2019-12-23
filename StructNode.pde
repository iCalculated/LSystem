// The original node did not cut it, so this is a proper tree implementation with children and parents. 
// The data stored is still just a node. 
class StructNode {
    Node data;
    StructNode parent;
    ArrayList<StructNode> children;

    StructNode(Node data) {
        this.data = data;
        this.children = new ArrayList<StructNode>();
    }

    StructNode addChild(Node childData) {
        StructNode childNode = new StructNode(childData);
        childNode.parent = this;
        this.children.add(childNode);
        return childNode;
    }

    int countBranches() {
        return children.size();
    }

    String toString() {
        String ret = data.toString() + ", parent: " + (parent != null  ? parent.data.toString() : "null") + ", children: ";
        for(StructNode child : children) {
            ret += "\n" + child.toString(1);
        }
        return ret;
    }

    // ugly function but it pretty-prints (sub)trees
    String toString(int depth) {
        String ret = data.toString() + ", parent: " + (parent != null  ? parent.data.toString() : "null") + ", children: " + countBranches();
        for(StructNode child : children) {
            ret += "\n";
            for(int i = 0; i < depth; i++) {
                ret += " ";
            }
            ret += child.toString(depth+1);
        }
        return ret;

    }


}