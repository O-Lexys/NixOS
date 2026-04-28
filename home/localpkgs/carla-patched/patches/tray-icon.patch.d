diff --git a/source/frontend/carla_host.py b/source/frontend/carla_host.py
index dc73ea4f5..a6954029f 100644
--- a/source/frontend/carla_host.py
+++ b/source/frontend/carla_host.py
@@ -54,6 +54,8 @@ if qt_config == 5:
         QListWidgetItem,
         QGraphicsView,
         QMainWindow,
+        QSystemTrayIcon,
+        QMenu,
     )
 
 elif qt_config == 6:
@@ -86,6 +88,8 @@ elif qt_config == 6:
         QListWidgetItem,
         QGraphicsView,
         QMainWindow,
+        QSystemTrayIcon,
+        QMenu,
     )
 
 # ------------------------------------------------------------------------------------------------------------
@@ -182,6 +186,12 @@ class HostWindow(QMainWindow):
         self.ui = ui_carla_host.Ui_CarlaHostW()
         self.ui.setupUi(self)
         gCarla.gui = self
+        
+        self.fSystemTray = None
+        self.fStartInTray = False
+        self.fMinimizeToTray = True
+        if not (self.host.isControl or self.host.isPlugin):
+            self.setupSystemTray()
 
         if False:
             # kdevelop likes this :)
@@ -710,7 +720,22 @@ class HostWindow(QMainWindow):
             self.ui.act_file_quit.setText(self.tr("Hide"))
             QApplication.instance().setQuitOnLastWindowClosed(False)
         else:
-            self.show()
+            if self.fSystemTray is not None:
+                QApplication.instance().setQuitOnLastWindowClosed(False)
+            # Check if should start in tray
+            if self.fStartInTray and self.fSystemTray is not None:
+                # Don't show window, just show tray notification
+                self.fSystemTray.showMessage(
+                    "Carla",
+                    "Carla has started in the system tray.\nDouble-click the tray icon to show the window.",
+                    QSystemTrayIcon.Information,
+                    3000
+                    )
+                self.fShowHideAction.setText("Show Carla")
+            else:
+                self.show()
+                if self.fSystemTray is not None:
+                    self.fShowHideAction.setText("Hide Carla")
 
     # --------------------------------------------------------------------------------------------------------
     # Setup
@@ -1152,6 +1177,7 @@ class HostWindow(QMainWindow):
         self.ui.text_logs.appendPlainText("  Driver name:  %s" % driverName)
         self.ui.text_logs.appendPlainText("  Sample rate:  %i" % int(sampleRate))
         self.ui.text_logs.appendPlainText("  Process mode: %s" % processMode2Str(processMode))
+        self.updateSystemTrayTooltip()
 
     @pyqtSlot()
     def slot_handleEngineStoppedCallback(self):
@@ -1178,6 +1204,7 @@ class HostWindow(QMainWindow):
         if self.host.isPlugin or not self.fSessionManagerName:
             self.ui.act_file_open.setEnabled(False)
             self.ui.act_file_save_as.setEnabled(False)
+        self.updateSystemTrayTooltip()
 
     @pyqtSlot(int, str)
     def slot_handleTransportModeChangedCallback(self, transportMode, transportExtra):
@@ -1535,6 +1562,7 @@ class HostWindow(QMainWindow):
 
         if pluginType == PLUGIN_LV2:
             self.fHasLoadedLv2Plugins = True
+        self.updateSystemTrayTooltip()
 
     @pyqtSlot(int)
     def slot_handlePluginRemovedCallback(self, pluginId):
@@ -1570,6 +1598,7 @@ class HostWindow(QMainWindow):
             pitem.setPluginId(i)
 
         self.ui.act_plugin_remove_all.setEnabled(True)
+        self.updateSystemTrayTooltip()
 
     # --------------------------------------------------------------------------------------------------------
     # Canvas
@@ -1649,6 +1678,75 @@ class HostWindow(QMainWindow):
             self.ui.graphicsView.setViewportUpdateMode(QGraphicsView.FullViewportUpdate)
         else:
             self.ui.graphicsView.setViewportUpdateMode(QGraphicsView.MinimalViewportUpdate)
+    
+    def updateSystemTrayTooltip(self):
+        """Update system tray tooltip with current status"""
+        if self.fSystemTray is None:
+            return
+        status_parts = ["Carla"]
+        if self.host.is_engine_running():
+            status_parts.append("● Engine Running")
+        else:
+            status_parts.append("○ Engine Stopped")
+        if self.fPluginCount > 0:
+            status_parts.append(f"{self.fPluginCount} plugin(s)")
+        self.fSystemTray.setToolTip("\n".join(status_parts))
+    def setupSystemTray(self):
+        """Set up the system tray icon and menu"""
+        if not QSystemTrayIcon.isSystemTrayAvailable():
+            print("System tray is not available on this system")
+            return
+        self.fSystemTray = QSystemTrayIcon(self)
+        icon = QIcon(":/scalable/carla.svg")
+        if icon.isNull():
+            icon = self.windowIcon()
+        if icon.isNull():
+            icon = QApplication.instance().windowIcon()
+        self.fSystemTray.setIcon(icon)
+        # Set initial tooltip
+        self.fSystemTray.setToolTip("Carla")
+        # Create context menu
+        trayMenu = QMenu(self)
+        # Add show/hide action
+        self.fShowHideAction = QAction("Show Carla", self)
+        self.fShowHideAction.triggered.connect(self.slot_toggleWindowVisibility)
+        trayMenu.addAction(self.fShowHideAction)
+        trayMenu.addSeparator()
+        if not self.host.isPlugin:
+            transportMenu = trayMenu.addMenu("Transport")
+            transportMenu.addAction(self.ui.b_transport_play.defaultAction() if hasattr(self.ui.b_transport_play, 'defaultAction') else QAction("Play", self))
+            transportMenu.addAction(self.ui.b_transport_stop.defaultAction() if hasattr(self.ui.b_transport_stop, 'defaultAction') else QAction("Stop", self))
+            # Create play/pause action manually since button might not have default action
+            playAction = QAction("Play/Pause", self)
+            playAction.triggered.connect(self.slot_transportPlayPause)
+            transportMenu.addAction(playAction)
+            stopAction = QAction("Stop", self)
+            stopAction.triggered.connect(self.slot_transportStop)
+            transportMenu.addAction(stopAction)
+            trayMenu.addSeparator()
+        # Engine controls
+        if not self.host.isPlugin:
+            engineMenu = trayMenu.addMenu("Engine")
+            engineMenu.addAction(self.ui.act_engine_start)
+            engineMenu.addAction(self.ui.act_engine_stop)
+            trayMenu.addSeparator()
+        # Plugin actions
+        pluginMenu = trayMenu.addMenu("Plugins")
+        pluginMenu.addAction(self.ui.act_plugin_add)
+        pluginMenu.addAction(self.ui.act_plugin_remove_all)
+        trayMenu.addSeparator()
+        # Settings
+        trayMenu.addAction(self.ui.act_settings_configure)
+        trayMenu.addSeparator()
+        # Quit action
+        quitAction = QAction("Quit Carla", self)
+        quitAction.triggered.connect(self.slot_fileQuit)
+        trayMenu.addAction(quitAction)
+        self.fSystemTray.setContextMenu(trayMenu)
+        # Connect double-click to show/hide
+        self.fSystemTray.activated.connect(self.slot_systemTrayActivated)
+        # Show the tray icon
+        self.fSystemTray.show()
 
     def updateCanvasInitialPos(self):
         x = self.ui.graphicsView.horizontalScrollBar().value() + self.width()/4
@@ -1686,6 +1784,50 @@ class HostWindow(QMainWindow):
     @pyqtSlot()
     def slot_canvasArrange(self):
         patchcanvas.arrange()
+    
+    @pyqtSlot()
+    def slot_toggleWindowVisibility(self):
+        """Toggle main window visibility"""
+        if self.isVisible() and not self.isMinimized():
+            self.hide()
+            if self.fSystemTray is not None:
+                self.fShowHideAction.setText("Show Carla")
+                if not self.fStartInTray:  # Only show message if not starting in tray
+                    self.fSystemTray.showMessage(
+                        "Carla",
+                        "Carla is still running in the system tray",
+                        QSystemTrayIcon.Information,
+                        2000
+                    )
+        else:
+            self.show()
+            self.setWindowState(self.windowState() & ~Qt.WindowMinimized | Qt.WindowActive)
+            self.activateWindow()
+            self.raise_()
+            if self.fSystemTray is not None:
+                self.fShowHideAction.setText("Hide Carla")
+
+    @pyqtSlot(QSystemTrayIcon.ActivationReason)
+    def slot_systemTrayActivated(self, reason):
+        """Handle system tray icon activation"""
+        if reason == QSystemTrayIcon.DoubleClick:
+            self.slot_toggleWindowVisibility()
+        elif reason == QSystemTrayIcon.Trigger:
+            # Single click behavior (Linux/Windows)
+            self.slot_toggleWindowVisibility()
+        elif reason == QSystemTrayIcon.MiddleClick:
+            # Middle click - show a status message
+            if self.fSystemTray is not None:
+                status = "Engine running" if self.host.is_engine_running() else "Engine stopped"
+                plugins = f"{self.fPluginCount} plugin(s) loaded"
+                self.fSystemTray.showMessage("Carla Status", f"{status}\n{plugins}", QSystemTrayIcon.Information, 2000)
+
+
+    @pyqtSlot()
+    def slot_fileQuit(self):
+        """Quit application"""
+        self.fCustomStopAction = self.CUSTOM_ACTION_APP_CLOSE
+        self.close()
 
     @pyqtSlot()
     def slot_canvasRefresh(self):
@@ -2007,6 +2149,9 @@ class HostWindow(QMainWindow):
             if not geometry.isNull():
                 self.restoreGeometry(geometry)
 
+            self.fStartInTray = settings.value("StartInTray", True, bool)
+            self.fMinimizeToTray = settings.value("MinimizeToTray", True, bool)
+
             showToolbar = settings.value("ShowToolbar", True, bool)
             self.ui.act_settings_show_toolbar.setChecked(showToolbar)
             self.ui.toolBar.blockSignals(True)
@@ -3067,11 +3212,32 @@ class HostWindow(QMainWindow):
                 return
 
         QMainWindow.closeEvent(self, event)
+        
+        if self.fSystemTray is not None:
+            self.fSystemTray.hide()
+            self.fSystemTray = None
 
         # if we reach this point, fully close ourselves
         gCarla.gui = None
         QApplication.instance().quit()
 
+
+def updateSystemTrayTooltip(self):
+    """Update system tray tooltip with current status"""
+    if self.fSystemTray is None:
+        return
+    status_parts = ["Carla"]
+    
+    if self.host.is_engine_running():
+        status_parts.append("● Engine Running")
+    else:
+        status_parts.append("○ Engine Stopped")
+    
+    if self.fPluginCount > 0:
+        status_parts.append(f"{self.fPluginCount} plugin(s)")
+    
+    self.fSystemTray.setToolTip("\n".join(status_parts))
+
 # ------------------------------------------------------------------------------------------------
 # Canvas callback
 
diff --git a/source/frontend/carla_shared.py b/source/frontend/carla_shared.py
index aae07a0d0..278c21bb6 100644
--- a/source/frontend/carla_shared.py
+++ b/source/frontend/carla_shared.py
@@ -181,6 +181,7 @@ CANVAS_EYECANDY_SMALL     = 1
 # ------------------------------------------------------------------------------------------------------------
 # Carla Settings keys
 
+CARLA_KEY_MAIN_START_IN_TRAY    = "Main/StartInTray"
 CARLA_KEY_MAIN_PROJECT_FOLDER   = "Main/ProjectFolder"   # str
 CARLA_KEY_MAIN_USE_PRO_THEME    = "Main/UseProTheme"     # bool
 CARLA_KEY_MAIN_PRO_THEME_COLOR  = "Main/ProThemeColor"   # str
@@ -264,6 +265,7 @@ CARLA_KEY_CUSTOM_PAINTING = "UseCustomPainting" # bool
 # Carla Settings defaults
 
 # Main
+CARLA_DEFAULT_START_IN_TRAY         = True
 CARLA_DEFAULT_MAIN_PROJECT_FOLDER   = HOME
 CARLA_DEFAULT_MAIN_USE_PRO_THEME    = True
 CARLA_DEFAULT_MAIN_PRO_THEME_COLOR  = "Black"
