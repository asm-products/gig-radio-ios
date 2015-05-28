//
//  EditPlaylistItemViewController.swift
//  GigRadio
//
//  Created by Michael Forrest on 28/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit

class EditPlaylistItemViewController: UITableViewController {
    var playlistItem: PlaylistItem!

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func didPressDone(sender: AnyObject) {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
