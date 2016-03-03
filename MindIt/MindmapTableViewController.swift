
import UIKit
import SwiftDDP
class MindmapTableViewController: UITableViewController , PresenterDelegate {
    
    //MARK:Properties
    var loader: Loader!
    var activityIndicator : UIActivityIndicatorView!
    var strLabel : UILabel!
    
    var presenter: TableViewPresenter!
    var mindmapId: String!
    
    private var isFullyDisappeared : Bool = true
    
    //MARK : Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter =  TableViewPresenter(viewDelegate: self, meteorTracker: MeteorTracker.getInstance())
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if(isFullyDisappeared == true) {
            isFullyDisappeared = false
            showProgressBar()
            presenter.connectToServer(mindmapId)
        }
        else {
            self.reloadTableView()
        }
    }
    
    
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        isFullyDisappeared = true
        presenter.unsubscribe()
    }
    
    func reloadTableView() {
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.getNodeCount();
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "NodeViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! NodeViewCell
        
        let node : Node? = presenter.getNodeAt(indexPath.row)
        
        if(node == nil) {
            cell.nodeDataLabel.text = Config.NETWORK_ERROR
        }
        else {
            cell.setData(node!, presenter: presenter)
        }
        return cell
    }
    
    func didConnectSuccessfully() {
        stopProgressBar()
        self.reloadTableView()
    }
    
    func didFailToConnectWithError(error: String) {
        stopProgressBar()
        switch(error) {
        case Config.NETWORK_ERROR  :
            print("Error in Network")
            giveAlert(Config.NETWORK_ERROR);
            break
            
        case Config.INVALID_MINDMAP:
            print("Invalid mindmap")
            giveAlert(Config.INVALID_MINDMAP)
            break
            
        default:
            giveAlert(Config.UNKNOWN_ERROR)
        }
    }
    
    private func showProgressBar() {
        dispatch_async(dispatch_get_main_queue(), {
            self.loader = NSBundle.mainBundle().loadNibNamed("Loader", owner: self, options: nil).first as! Loader
            self.loader.show("Loading Mindmap...")
        })
    }
    
    private func stopProgressBar() {
        dispatch_async(dispatch_get_main_queue()) {
            self.loader.hide()
        }
    }
    
    func updateChanges() {
            self.reloadTableView()
    }
    
    func giveAlert(errorMessage : String) {
        let refreshAlert : UIAlertController = UIAlertController(title: "", message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
        let meteorTracker : MeteorTracker = MeteorTracker.getInstance()
        meteorTracker.subscriptionSuccess = false
        meteorTracker.unsubscribe()
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
            self.navigationController?.popToRootViewControllerAnimated(false)
        }))
        
        presentViewController(refreshAlert, animated: true, completion: nil)
    }
    
}
