//
//  AppDelegate.swift
//  Makestagram
//
//  Created by Benjamin Encz on 5/15/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import Parse
import FBSDKCoreKit
import ParseUI
import ParseFacebookUtilsV4


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        let configuration = ParseClientConfiguration {
            $0.applicationId = "makestagram"
            $0.server = "https://makestagram-parse-andyw.herokuapp.com/parse"
        
        }
        
        
        
        Parse.initializeWithConfiguration(configuration)
        
//        do { //What is with the do and catch? -> This is a error handling code. If it user can log in then it's great, it will proceed, if not then it will print Unable to log in
//            try PFUser.logInWithUsername("test", password: "test") //logInWithUsername is a method user to sign in the user
//        }
//        catch {
//            print("Unable to log in")
//        }
//        
//        if let currentUser = PFUser.currentUser() { //checks to see if the let currentyUser is actually a user. If it is, then it will print if not, it will print what is in the else statement
//            print ("\(currentUser.username!) logged in successfully")
//        }
//        else{
//            print ("No logged in user ;(")
//        }
        let acl = PFACL()
        acl.publicReadAccess = true
        PFACL.setDefaultACL(acl, withAccessForCurrentUser: true)
        
        // Initialize Facebook
        // Boilerplate
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        
        // check if we have logged in user
        let user = PFUser.currentUser()
        
        let startViewController: UIViewController
        
        if (user != nil) {
            // if we have a user, set the TabBarController to be the initial view controller
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            startViewController = storyboard.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
        } else {
            // If we don;t have a user, we need to present the Login View Controller, creates one using the PFLoginViewController -> Provided by parse
            // Otherwise set the LoginViewController to be the first
            let loginViewController = PFLogInViewController()
            loginViewController.fields = [.UsernameAndPassword, .LogInButton, .SignUpButton, .PasswordForgotten, .Facebook]
            loginViewController.delegate = parseLoginHelper //sets the parseLoginHelper as the delegate of the PFLoginViewController
            loginViewController.signUpController?.delegate = parseLoginHelper //ParseLoginHelper will be notified about logins and signups by the PFLoginViewControler
            // ParseLoginHelper will then forward the information to us by calling the closure that was defined when creating the ParseLoginHelper
            startViewController = loginViewController
        }
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)//Creates the UIWindow of the application; Container for all the views in the app
        self.window?.rootViewController = startViewController; // display the startViewController as the rootViewVontroller( cann be the loginViewController if user is not signed in or TabViewController if user is signed in) of the app.
        self.window?.makeKeyAndVisible()
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
//        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    //MARK: Facebook Integration
    
    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    var parseLoginHelper: ParseLoginHelper!
    
    override init() {
        super.init()
        
        parseLoginHelper = ParseLoginHelper {[unowned self] user, error in
            // Initialize the ParseLoginHelper with a callback
            if let error = error {
                // In case tehre is an error in the closure, this will call the ErrorHandling.defaultErrorHandler which will display a popip errror message
                ErrorHandling.defaultErrorHandler(error)
            } else  if let _ = user {
                // if login was successful, display the TabBarController
                // if error is not recieved but a user is recieved, then log in is sucessful.
                let storyboard = UIStoryboard(name: "Main", bundle: nil) //Load main.storyboarrd
                let tabBarController = storyboard.instantiateViewControllerWithIdentifier("TabBarController")//Create TabBarController
                // After loading the view controller, we need to present it, we can choose the main view controller of the app by setting the rootViewController proterty of AppDelegate's window
                self.window?.rootViewController!.presentViewController(tabBarController, animated:true, completion:nil)
                //as soon as the sucessful login comletes, we present the TabBarControler on the top of the login screen
            }
        }
    }
}

