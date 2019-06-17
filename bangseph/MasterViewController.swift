/*
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import Speech
import Firebase
import Foundation
import SwiftyJSON

class MasterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    var transtext: String?
    @IBOutlet weak var transcribeButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "ko-KR"))!
    
    private var speechRecognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var speechRecognitionTask: SFSpeechRecognitionTask?
    
    private let audioEngine = AVAudioEngine()
    
    @IBAction func LogOut(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            dismiss(animated: true,completion: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
    }
    
    @IBAction func startTranscribing(_ sender: Any) {
        
        transcribeButton.isHidden = true
        stopButton.isEnabled = true
        try! startSession()
    }
    
    @IBAction func stopTranscribing(_ sender: Any) {
        stopButton.isHidden = true
        if audioEngine.isRunning {
            audioEngine.stop()
            speechRecognitionRequest?.endAudio()
            transcribeButton.isEnabled = true
            stopButton.isEnabled = false
        }
        print(self.transtext!)
        searchFooter.label.text = self.transtext!
        
    }
    
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchFooter: SearchFooter!
    
    var detailViewController: DetailViewController? = nil
    // 사용자가 검색중인 사탕을 보유
    var filteredCandies = [Candy]()
    var candies = [Candy]()
    let searchController = UISearchController(searchResultsController: nil)
    // MARK: - View Setup
    // MARK: - Private instance methods
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredCandies = candies.filter({( candy : Candy) -> Bool in
            let doesCategoryMatch = (scope == "All") || (candy.category == "\(scope)호선")
            
            if searchBarIsEmpty() {
                return doesCategoryMatch
            } else {
                return doesCategoryMatch && candy.name.lowercased().contains(searchText.lowercased())
            }
        })
        tableView.reloadData()
    }
    
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let json = readJSONFromFile(fileName: "서울시 역코드로 지하철역 위치 조회")
        let jsonArray = json["DATA"] as? [[String: Any]]
       
        authorizeSR()
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Station"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        // Setup the Scope Bar
    
        searchController.searchBar.scopeButtonTitles = ["All","1", "2", "3","4","5","6","7","8","9"]
        searchController.searchBar.delegate = self
        
        for jsonArrayIndex in jsonArray! {
            candies.append(Candy(category: "\(jsonArrayIndex["line_num"] as! String)호선", name: jsonArrayIndex["station_nm"] as! String, latitude: jsonArrayIndex["xpoint_wgs"] as! String, longitude: jsonArrayIndex["ypoint_wgs"] as! String, addr: jsonArrayIndex["cyber_st_code"] as! String))
        
        }
        
        
        if let splitViewController = splitViewController {
            let controllers = splitViewController.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if splitViewController!.isCollapsed {
            if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
                self.tableView.deselectRow(at: selectionIndexPath, animated: animated)
            }
        }
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredCandies.count
        }
        
        return candies.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let candy: Candy
        if isFiltering() {
            candy = filteredCandies[indexPath.row]
        } else {
            candy = candies[indexPath.row]
        }
        cell.textLabel!.text = candy.name
        cell.detailTextLabel!.text = candy.category
        return cell
    }
    
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                //        let candy = candies[indexPath.row]
                let candy: Candy
                if isFiltering() {
                    candy = filteredCandies[indexPath.row]
                } else {
                    candy = candies[indexPath.row]
                }
                
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailCandy = candy
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    func authorizeSR() {
        SFSpeechRecognizer.requestAuthorization{
            authStaus in OperationQueue.main.addOperation {
                switch authStaus {
                case .authorized:
                    self.transcribeButton.isEnabled = true
                    
                case .denied:
                    self.transcribeButton.isEnabled = false
                    self.transcribeButton.setTitle("Speech recognition access denied by user", for: .disabled)
                case .restricted:
                    self.transcribeButton.isEnabled = false
                    self.transcribeButton.setTitle("Speech recognition restricted on device", for: .disabled)
                case .notDetermined:
                    self.transcribeButton.isEnabled = false
                    self.transcribeButton.setTitle("Speech recognition not authorized", for: .disabled)
                }
            }
        }
    }
    
    func startSession() throws {
        if let recognitionTask = speechRecognitionTask {
            recognitionTask.cancel()
            self.speechRecognitionTask = nil
        }
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSession.Category.record)
        
        speechRecognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = speechRecognitionRequest else {
            fatalError("SFSpeechAudioBufferRecognitionRequest object creation failed")
        }
        
        let inputNode = audioEngine.inputNode
        recognitionRequest.shouldReportPartialResults = true
        
        speechRecognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) {
            result, error in
            
            var finished = false
            if let result = result {
            
                self.transtext = result.bestTranscription.formattedString
                
                finished = result.isFinal
            }
            
            if error != nil || finished {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.speechRecognitionRequest = nil
                self.speechRecognitionTask = nil
                self.transcribeButton.isEnabled = true
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            
            self.speechRecognitionRequest?.append(buffer)
        }
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    func readJSONFromFile(fileName: String) -> [String : Any]
    {
        var json: Any?
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            do {
                let fileUrl = URL(fileURLWithPath: path)
                // Getting data from JSON file using the file URL
                let data = try Data(contentsOf: fileUrl, options: .mappedIfSafe)
                json = try? JSONSerialization.jsonObject(with: data, options: []) as! [String : Any]
            } catch {
                // Handle error here
            }
        }
        return json as! [String : Any]
    }
    
}

extension MasterViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
        
    }
    
}

extension MasterViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
        
    }
}
