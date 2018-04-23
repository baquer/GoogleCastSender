//
//  ViewController.swift
//  GoogleCastSender
//
//  Created by Syed on 05/03/18.
//  Copyright © 2018 Syed. All rights reserved.
//

import UIKit
import GoogleCast

class SenderViewController: UIViewController, GCKDeviceScannerListener, GCKDeviceManagerDelegate,
GCKMediaControlChannelDelegate, UIActionSheetDelegate
{
    private let cancleTitle = "Cancle"
    private let disconnectTitle = "Disconnect"
    private var applicationMetaData: GCKApplicationMetadata?
    private var setectedDevice: GCKDevice?
    private var deviceScanner: GCKDeviceScanner?
    private var mediaInformation: GCKMediaInformation?
    private var deviceManager:GCKDeviceManager?
    private var mediaControlChannel: GCKMediaControlChannel?
    private lazy var buttonIdentifiedImage:UIImage =
    {
        return UIImage(named: "icon-cast-identified")
        
        }()!
    private lazy var buttonConnectedImage:UIImage =
    {
        return UIImage(named: "icon-cast-connected")
        }()!
    private lazy var receiverAPPID:String =
    {
        //Enter the APP_ID Generated On registering By GoogleCast
        return kGCKMediaDefaultReceiverApplicationID
    }()
    

    @IBOutlet weak var castButton: UIBarButtonItem!
    
    // MARK:- INIT()
    required init(coder aDecoder: NSCoder)
    {
        let filterCriteria = GCKFilterCriteria(forAvailableApplicationWithID:
            kGCKMediaDefaultReceiverApplicationID)
        deviceScanner = GCKDeviceScanner(filterCriteria:filterCriteria)
        super.init(coder: aDecoder)!
    }
    override func viewWillAppear(_ animated: Bool) {
       // GCKCastContext.sharedInstance().presentcCastInstructionViewControllerOnce()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Hide The CastButton
        navigationItem.rightBarButtonItems = []
        
        // DeviceScanner Initialized
        deviceScanner?.add(self)
        deviceScanner?.startScan()
        deviceScanner?.passiveScan = true
       
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func chooseDevice(sender:AnyObject) {
        deviceScanner?.passiveScan = false
        let friendlyName = "Casting to \(setectedDevice!.friendlyName)"
        if (setectedDevice == nil) {
            
            let alert = UIAlertController(title: "Connect to Device", message: "Connect the nearby devices", preferredStyle: UIAlertControllerStyle.actionSheet)
            
            for device in (deviceScanner?.devices)!
            {
                
                alert.addAction(UIAlertAction(title: friendlyName, style: UIAlertActionStyle.default, handler: { (alert:UIAlertAction!) in
                    print("foo")
                }))
            }
            
            
            alert.addAction(UIAlertAction(title: cancleTitle, style: UIAlertActionStyle.cancel, handler: nil))
            alert.show(self, sender: (Any).self)
        }
        else
        {
            updateStatus()
            let friendlyName = "Casting to \(setectedDevice!.friendlyName)"
            
            
            let alert = UIAlertController(title: friendlyName, message: "disConnect the nearby devices", preferredStyle: UIAlertControllerStyle.actionSheet)
            
            
            if let info = mediaInformation {
                alert.addAction(UIAlertAction(title: (info.metadata.object(forKey: kGCKMetadataKeyTitle) as! String ), style: UIAlertActionStyle.default, handler: nil))
            }
            
            alert.addAction(UIAlertAction(title: disconnectTitle, style: UIAlertActionStyle.cancel, handler: nil))
            alert.show(self, sender: (Any).self)
        }
    }
    // MARK:- Added updateStatus
    func updateStatus()
    {
        if deviceManager?.connectionState == GCKConnectionState.connected
            && mediaControlChannel?.mediaStatus != nil {
            mediaInformation = mediaControlChannel?.mediaStatus.mediaInformation
        }
    }
    func connectToDevice()
    {
        if (setectedDevice == nil)
        {
            return
        }
        let identifier = Bundle.main.bundleIdentifier
        deviceManager = GCKDeviceManager(device: setectedDevice, clientPackageName: identifier)
        deviceManager!.delegate = self
        deviceManager!.connect()
    }
    
    func deviceDisconnected()
    {
        setectedDevice = nil
        deviceManager = nil
    }
    
    func updateButtonStates()
    {
        if ((deviceScanner?.devices)!.count > 0)
        {
            // Showing The Cast Button
            
            navigationItem.rightBarButtonItems = [castButton!]
            if (deviceManager != nil && deviceManager?.connectionState == GCKConnectionState.connected) {
                
                //  Showing The Cast Button In Active Mode
                castButton!.tintColor = UIColor.blue
            } else {
                // Showing The Cast Button In InActive/Disabled Mode
                castButton!.tintColor = UIColor.gray
            }
        } else
        {
            // Not Showing Cast Button
            navigationItem.rightBarButtonItems = []
        }
    }

    @IBAction func castButtonPressed(_ sender: Any) {
        
        if (deviceManager?.connectionState != GCKConnectionState.connected) {
            if #available(iOS 8.0, *) {
                let alert = UIAlertController(title: "Not Connected",
                                              message: "Please connect the Availlable Device",
                                              preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                let alert = UIAlertView.init(title: "Not Connected",
                                             message: "Connet to the Cast Device", delegate: nil, cancelButtonTitle: "OK",
                                             otherButtonTitles: "")
                alert.show()
            }
            return
        }
        
        // MARK:- Starting Metadata
        
        // Define Media Metadata.
        let metadata = GCKMediaMetadata()
        metadata?.setString("Enter The Title", forKey: kGCKMetadataKeyTitle)
        metadata?.setString("Enter the string .",
                            forKey:kGCKMetadataKeySubtitle)
        
        let url = NSURL(string:"Enter Url of the image file ")
        metadata?.addImage(GCKImage(url: url! as URL, width: 480, height: 360))
        
        // MARK:- Starting load Media
        
        // Define Media Information.
        let mediaInformation = GCKMediaInformation(
            contentID:
            "Enter URL of thr video file",
            streamType: GCKMediaStreamType.none,
            contentType: "video/mp4",
            metadata: metadata,
            streamDuration: 0,
            mediaTracks: [],
            textTrackStyle: nil,
            customData: nil
        )
        // Cast the media
        mediaControlChannel!.loadMedia(mediaInformation, autoplay: true)
    }
    
    private func deviceDidComeOnline(device: GCKDevice!) {
        print("Device found: \(device.friendlyName)")
        updateButtonStates()
    }
    
    private func deviceDidGoOffline(device: GCKDevice!) {
        print("Device offline: \(device.friendlyName)")
        updateButtonStates()
    }
    
    
    func showError(error: NSError) {
        if #available(iOS 8.0, *) {
            let alert = UIAlertController(title: "Error",
                                          message: error.description,
                                          preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertView.init(title: "Error", message: error.description, delegate: nil,
                                         cancelButtonTitle: "OK", otherButtonTitles: "")
            alert.show()
        }
    }
    // MARK: UIActionSheetDelegate
    
    private func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        deviceScanner?.passiveScan = true
        if (buttonIndex == actionSheet.cancelButtonIndex) {
            return
        } else if (setectedDevice == nil) {
            if (buttonIndex < (deviceScanner?.devices.count)!) {
                setectedDevice = deviceScanner?.devices[buttonIndex] as? GCKDevice
                print("Selected device: \(setectedDevice!.friendlyName)")
                connectToDevice()
            }
        } else if (actionSheet.buttonTitle(at: buttonIndex) == disconnectTitle) {
            // Disconnect button.
            deviceManager!.leaveApplication()
            deviceManager!.disconnect()
            deviceDisconnected()
            updateButtonStates()
        }
    }
    
    
    
    // MARK :- Media Control Channel
    
    // MARK: GCKDeviceManagerDelegate
    
    
    
    func deviceManagerDidConnect(_ deviceManager: GCKDeviceManager!) {
        print("Connected.")
        
        updateButtonStates()
        deviceManager.launchApplication(receiverAPPID)
    }
    
    
    
    func deviceManager(_ deviceManager: GCKDeviceManager!,
                       didConnectToCastApplication
        applicationMetadata: GCKApplicationMetadata!,
                       sessionID: String!,
                       launchedApplication: Bool) {
        print("Application has launched.")
        self.mediaControlChannel = GCKMediaControlChannel()
        mediaControlChannel!.delegate = self
        deviceManager.add(mediaControlChannel)
        mediaControlChannel!.requestStatus()
    }
    
    
    private func deviceManager(deviceManager: GCKDeviceManager!,
                               didFailToConnectToApplicationWithError error: Error!) {
        print("Received notification that device failed to connect to application.")
        
        showError(error: error! as NSError)
        deviceDisconnected()
        updateButtonStates()
    }
    
    private func deviceManager(deviceManager: GCKDeviceManager!,
                               didFailToConnectWithError error: NSError!) {
        print("Received notification that device failed to connect.")
        
        showError(error: error!)
        deviceDisconnected()
        updateButtonStates()
    }
    
    private func deviceManager(deviceManager: GCKDeviceManager!,
                               didDisconnectWithError error: Error!) {
        print("Received notification that device disconnected.")
        
        if (error != nil) {
            showError(error: error! as NSError)
        }
        
        deviceDisconnected()
        updateButtonStates()
    }
    
    private func deviceManager(deviceManager: GCKDeviceManager!,
                               didReceiveApplicationMetadata metadata: GCKApplicationMetadata!) {
        applicationMetaData = metadata
    }
    

    
    
    
}

