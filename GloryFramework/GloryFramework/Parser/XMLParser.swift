//
//  XMLParser.swift
//  GlorySDK
//
//  Created by John Kricorian on 07/07/2021.
//

import Foundation


 public class XMLNode: NSObject {
    let tag: String
    var data: String
    let attributes: [String: String]
    var childNodes: [XMLNode]
    
    init(tag: String, data: String, attributes: [String: String], childNodes: [XMLNode]) {
        self.tag = tag
        self.data = data
        self.attributes = attributes
        self.childNodes = childNodes
    }
    
    func getAttribute(_ name: String) -> String? {
        attributes[name]
    }
    
    func getElementsByTagName(_ tag: String) -> [XMLNode] {
        var xmlNodes = [XMLNode]()
        childNodes.forEach {
            if $0.tag == tag {
                xmlNodes.append($0)
            }
            xmlNodes += $0.getElementsByTagName(tag)
        }
        return xmlNodes
    }
}

 class MicroDOM: NSObject, XMLParserDelegate {
    private let parser: XMLParser
    private var stack: [XMLNode] = []
    private var tree: XMLNode?
    var parseError: Error?
    
    init(data: Data) {
        parser = XMLParser(data: data)
        super.init()
        parser.delegate = self
    }
    
    func parse() -> XMLNode? {
        parser.parse()
        guard parser.parserError == nil else { return nil }
        return tree
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        let node = XMLNode(tag: elementName, data: "", attributes: attributeDict, childNodes: [])
        stack.append(node)
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        let lastElement = stack.removeLast()
        
        if let last = stack.last {
            last.childNodes += [lastElement]
        } else {
            tree = lastElement
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        stack.last?.data += string
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        self.parseError = parseError
    }
}
