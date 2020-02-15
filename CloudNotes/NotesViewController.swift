//
//  NotesViewController.swift
//  CloudNotes
//
//  Created by Peter Hedlund on 2/8/20.
//  Copyright © 2020 Peter Hedlund. All rights reserved.
//

import Cocoa

class NotesViewController: NSViewController {

    @IBOutlet var topView: NSView!
    @IBOutlet var notesView: NSTableView!

    var editorViewController: EditorViewController?
    var selectedNote: CDNote?

    var notes: [CDNote]? {
        didSet {
            editorViewController?.note = nil
            notesView.reloadData()
        }
    }

    private var observers = [NSObjectProtocol]()

    deinit {
        for observer in observers {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topView.wantsLayer = true
        let border: CALayer = CALayer()
        border.autoresizingMask = .layerWidthSizable;
        border.frame = CGRect(x: 0,
                              y: 1,
                              width: topView.frame.width,
                              height: 1)
        border.backgroundColor = NSColor.gridColor.cgColor
        topView.layer?.addSublayer(border)
        
        observers.append(NotificationCenter.default.addObserver(forName: .editorUpdatedNote, object: nil, queue: .main, using: { [weak self] _ in
            DispatchQueue.main.async {
                if let row = self?.notesView.selectedRow {
                    self?.notesView.reloadData(forRowIndexes: IndexSet(integer: row), columnIndexes: IndexSet(integer: 0))
                }
            }
        }))
    }
    
}

extension NotesViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let note = notes?[row] else {
            return nil
        }
        
        if let noteView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "NoteCell"), owner: self) as? NoteCellView {
            noteView.contentLabel.stringValue = note.content
            noteView.modifiedLabel.stringValue = ModifiedValueTransformer().transformedValue(note.modified) as? String ?? ""
            return noteView
        }
        return nil        
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 96.0
    }

    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return NoteTableRowView(frame: .zero)
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        let selectedRow = notesView.selectedRow
        guard let note = notes?[selectedRow] else {
            return
        }
        selectedNote = note
        editorViewController?.note = note
    }

}

extension NotesViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if let notes = notes {
            return notes.count
        }
        return 0
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard let note = notes?[row] else {
            return nil
        }
        return note
    }
    
}
