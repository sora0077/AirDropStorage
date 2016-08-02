//
//  FileListViewController.swift
//  AirDropStorage
//
//  Created by 林達也 on 2016/08/02.
//  Copyright © 2016年 jp.sora0077. All rights reserved.
//

import UIKit


final class FileListViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    private var files: [URL] = [] {
        didSet {
            let old = Set(oldValue)
            let new = Set(files)
            
            if old == new {
                return
            }
            
            func toIndexPaths(diff: Set<URL>, list: [URL]) -> [IndexPath] {
                return diff
                    .map { list.index(of: $0)! }
                    .map {
                        IndexPath(row: $0, section: 0)
                    }
            }
            
            let insertions = toIndexPaths(diff: new.subtracting(old), list: files)
            let deletions = toIndexPaths(diff: old.subtracting(new), list: oldValue)
            
            DispatchQueue.main.async {
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: insertions, with: .automatic)
                self.tableView.deleteRows(at: deletions, with: .automatic)
                self.tableView.endUpdates()
            }
        }
    }
    private let query = NSMetadataQuery()
    
    private let workerQueue = OperationQueue()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSFileCoordinator.addFilePresenter(self)
    
        tableView.reloadData()
        DispatchQueue.main.after(when: DispatchTime.now() + 0.5) {
            self.updateFiles()
        }
    }
    
    private func updateFiles() {
        
        guard let url = presentedItemURL else {
            files = []
            return
        }
        let properties: [String] = []
        let contents = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: properties, options: [])
        files = contents?.filter { $0.lastPathComponent != "Inbox" } ?? []
    }
}

extension FileListViewController: NSFilePresenter {
    
    var presentedItemURL: URL? {
        
        guard let directory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            return nil
        }
        return URL(fileURLWithPath: directory, isDirectory: true)
    }
    
    var presentedItemOperationQueue: OperationQueue {
        return workerQueue
    }
    
    func presentedSubitemDidChange(at url: URL) {
        updateFiles()
    }
}

extension FileListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = files[indexPath.row].lastPathComponent
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            do {
                try FileManager.default.removeItem(at: files[indexPath.row])
                files.remove(at: indexPath.row)
            } catch {
                
            }
        default:
            break
        }
    }
}

extension FileListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var isDirectory: ObjCBool = false
        let url = files[indexPath.row]
        if let path = url.path, FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory), isDirectory {
            return
        }
        
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        vc.excludedActivityTypes = [
            UIActivityTypePostToTwitter,
            UIActivityTypePostToFacebook,
            UIActivityTypePostToWeibo,
            UIActivityTypeMessage,
            UIActivityTypeMail,
            UIActivityTypePrint,
            UIActivityTypeCopyToPasteboard,
            UIActivityTypeAssignToContact,
            UIActivityTypeSaveToCameraRoll,
            UIActivityTypeAddToReadingList,
            UIActivityTypePostToFlickr,
            UIActivityTypePostToVimeo,
            UIActivityTypePostToTencentWeibo,
            UIActivityTypeOpenInIBooks
        ]
        present(vc, animated: true, completion: nil)
    }
}
