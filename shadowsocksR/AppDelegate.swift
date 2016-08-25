//
//  AppDelegate.swift
//  shadowsocksR
//
//  Created by 称一称 on 16/8/23.
//  Copyright © 2016年 yicheng. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var mainMenu: NSMenu!
    var statusItem: NSStatusItem!

    @IBOutlet weak var runningStatusMenuItem: NSMenuItem!
    @IBOutlet weak var toggleRunningMenuItem: NSMenuItem!
    @IBOutlet weak var proxyMenuItem: NSMenuItem!
    @IBOutlet weak var autoModeMenuItem: NSMenuItem!
    @IBOutlet weak var globalModeMenuItem: NSMenuItem!
    @IBOutlet weak var manualModeMenuItem: NSMenuItem!
    @IBOutlet weak var bypasschinaModeMenuItem: NSMenuItem!

    @IBOutlet weak var serversMenuItem: NSMenuItem!
    @IBOutlet var showQRCodeMenuItem: NSMenuItem!
    @IBOutlet var scanQRCodeMenuItem: NSMenuItem!
    @IBOutlet var serversPreferencesMenuItem: NSMenuItem!

    @IBOutlet weak var lanchAtLoginMenuItem: NSMenuItem!

    var preferencesWinCtrl: PreferencesWindowController!
    var launchAtLoginController: LaunchAtLoginController = LaunchAtLoginController()



    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // 初始化菜单
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(20)
        let image = NSImage(named: "menu_icon")
        image?.template = true
        statusItem.image = image
        statusItem.menu = mainMenu

        //更新菜单状态
        updateMainMenu()
        updateServersMenu()
        updateRunningModeMenu()
        updateLaunchAtLoginMenu()

        //检测proxy_conf_helper
        ProxyConfHelper.install()

        //启动ss
        ServiceHandler.instance.sync_ss()

    }

    func applicationWillTerminate(aNotification: NSNotification) {
        inf.shared.save()
    }


    @IBAction func toggleRunning(sender: NSMenuItem) {
        inf.shared.isOn = !inf.shared.isOn
        ServiceHandler.instance.sync_ss()
        updateMainMenu()
    }


    @IBAction func selectServer(sender: NSMenuItem) {
        let index = sender.tag
        let spMgr = ServerProfileManager.instance
        let newProfile = spMgr.profiles[index]
        if newProfile.uuid != spMgr.activeProfileId {
            spMgr.setActiveProfiledId(newProfile.uuid)
            updateServersMenu()
            ServiceHandler.instance.sync_ss()
        }
    }

    @IBAction func editServerPreferences(sender: NSMenuItem) {
        if preferencesWinCtrl != nil {
            preferencesWinCtrl.close()
        }
        let ctrl = PreferencesWindowController(windowNibName: "PreferencesWindowController")
        preferencesWinCtrl = ctrl

        ctrl.showWindow(self)
        NSApp.activateIgnoringOtherApps(true)
        ctrl.window?.makeKeyAndOrderFront(self)
    }

    @IBAction func selectGFWListMode(sender: NSMenuItem) {
        inf.shared.ProxyMode = .Gfwlist
        updateRunningModeMenu()
    }

    @IBAction func selectGlobalMode(sender: NSMenuItem) {
        inf.shared.ProxyMode = .Global
        updateRunningModeMenu()
    }

    @IBAction func selectManualMode(sender: NSMenuItem) {
        inf.shared.ProxyMode = .Manual
        updateRunningModeMenu()
    }


    func updateLaunchAtLoginMenu() {
        if launchAtLoginController.launchAtLogin {
            lanchAtLoginMenuItem.state = 1
        } else {
            lanchAtLoginMenuItem.state = 0
        }
    }

    func updateRunningModeMenu() {
        let mode = inf.shared.ProxyMode

        autoModeMenuItem.state = 0
        globalModeMenuItem.state = 0
        manualModeMenuItem.state = 0
        bypasschinaModeMenuItem.state = 0

        switch mode {
        case .Gfwlist:
            proxyMenuItem.title = "Proxy - GFW List".localized
            autoModeMenuItem.state = 1
        case .Global:
            proxyMenuItem.title = "Proxy - Global".localized
            globalModeMenuItem.state = 1
        case .Bypasschina:
            proxyMenuItem.title = "Proxy - ByPassChina".localized
            bypasschinaModeMenuItem.state = 1
        case .Manual:
            proxyMenuItem.title = "Proxy - Manual".localized
            manualModeMenuItem.state = 1
        }
    }

    func updateMainMenu() {
        let isOn = inf.shared.isOn
        if isOn {
            runningStatusMenuItem.title = "ShadowsocksR: On".localized
            toggleRunningMenuItem.title = "Turn Shadowsocks Off".localized
            let image = NSImage(named: "menu_icon")
            statusItem.image = image
        } else {
            runningStatusMenuItem.title = "ShadowsocksR: Off".localized
            toggleRunningMenuItem.title = "Turn Shadowsocks On".localized
            let image = NSImage(named: "menu_icon_disabled")
            statusItem.image = image
        }
    }

    func updateServersMenu() {
        let mgr = ServerProfileManager.instance
        serversMenuItem.submenu?.removeAllItems()
        let showQRItem = showQRCodeMenuItem
        let scanQRItem = scanQRCodeMenuItem
        let preferencesItem = serversPreferencesMenuItem

        var i = 0
        for p in mgr.profiles {
            let item = NSMenuItem()
            item.tag = i
            if p.remark.isEmpty {
                item.title = "\(p.serverHost):\(p.serverPort)"
            } else {
                item.title = "\(p.remark) (\(p.serverHost):\(p.serverPort))"
            }
            if mgr.activeProfileId == p.uuid {
                item.state = 1
            }
            if !p.isValid() {
                item.enabled = false
            }
            item.action = #selector(AppDelegate.selectServer)

            serversMenuItem.submenu?.addItem(item)
            i += 1
        }
        if !mgr.profiles.isEmpty {
            serversMenuItem.submenu?.addItem(NSMenuItem.separatorItem())
        }
        serversMenuItem.submenu?.addItem(showQRItem)
        serversMenuItem.submenu?.addItem(scanQRItem)
        serversMenuItem.submenu?.addItem(NSMenuItem.separatorItem())
        serversMenuItem.submenu?.addItem(preferencesItem)
    }

}

