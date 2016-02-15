//
//  TreeBuilder.swift
//  MindIt
//
//  Created by Swapnil Gaikwad on 12/02/16.
//  Copyright © 2016 ThoughtWorks Inc. All rights reserved.
//

class TreeBuilder {
    private var treeNodes : [Node] = [Node]();
    static var subTreeNodes : [Node] = [Node]();
    
    
    func buidTreeFromCollection(mindmapCollection: MindmapCollection ,rootId : String) -> [Node] {
        let root : Node? = mindmapCollection.findOne(rootId)
        
        var isCalledFirstTime: Bool = true
        
        if(root != nil) {
            treeNodes.append(root!)
            root?.setDepth(0);
        }
        
        
        let left : [String]? = root?.left
        let right : [String]? = root?.right
        
        if(root?.hasChilds() == true) {
            if(root?.getNodeState() == Config.UNDEFINED) {
                root?.setNodeState(Config.EXPANDED)
            }
            else {
                isCalledFirstTime = false
            }
        }
        else {
            if(root?.getNodeState() == Config.UNDEFINED) {
                root?.setNodeState(Config.CHILD_NODE)
            }
            else {
                isCalledFirstTime = false
            }
        }
        
        if(right != nil) {
            for rightChildId in right! {
                let rightNode = mindmapCollection.findOne(rightChildId)
                
                if(rightNode != nil) {
                    rightNode?.setDepth(1)
                    if(rightNode?.hasChilds() == true) {
                        rightNode?.setNodeState(Config.COLLAPSED)
                    }
                    else {
                        rightNode?.setNodeState(Config.CHILD_NODE)
                    }
                    treeNodes.append(rightNode!)
                }
                if(isCalledFirstTime == false && rightNode?.getNodeState() == Config.EXPANDED) {
                    traverseTree(rightNode , mindmapCollection: mindmapCollection , depth: 1)
                }
            }
        }
        
        if(left != nil) {
            for leftChildId in left! {
                let leftNode = mindmapCollection.findOne(leftChildId)
                
                if(leftNode != nil) {
                    leftNode?.setDepth(1)
                    if(leftNode?.hasChilds() == true) {
                        leftNode?.setNodeState(Config.COLLAPSED)
                    }
                    else {
                        leftNode?.setNodeState(Config.CHILD_NODE)
                    }
                    treeNodes.append(leftNode!)
                }
                if(isCalledFirstTime == false && leftNode?.getNodeState() == Config.EXPANDED) {
                    traverseTree(leftNode , mindmapCollection: mindmapCollection , depth: 1)
                }
            }
        }
        
        return treeNodes;
    }
    
    private func traverseTree(root : Node? ,mindmapCollection : MindmapCollection , depth: Int) {
        if(root != nil) {
            
            let childSubTree = root?.childSubTree
            
            for childId in childSubTree! {
                let nextChildNode = mindmapCollection.findOne(childId)
                nextChildNode?.setDepth(depth)
                if(nextChildNode?.getNodeState() == Config.EXPANDED) {
                    traverseTree(nextChildNode, mindmapCollection: mindmapCollection , depth: depth + 1)
                } 
            }
        }
    }
    
    static func getChildSubTree(root : Node? ,mindmapCollection : MindmapCollection) {
        if(root != nil) {
            let childSubTree = root?.childSubTree
            
            for childId in childSubTree! {
                let nextChildNode = mindmapCollection.findOne(childId)
                subTreeNodes.append(nextChildNode!)
                if(nextChildNode?.getNodeState() == Config.EXPANDED) {
                    getChildSubTree(nextChildNode, mindmapCollection: mindmapCollection)
                }
            }
        }
    }
}
