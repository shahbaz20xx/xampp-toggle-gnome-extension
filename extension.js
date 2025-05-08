/* extension.js
 * XAMPP Toggle extension for GNOME
 */

'use strict';

import Gio from 'gi://Gio';
import GLib from 'gi://GLib';
import GObject from 'gi://GObject';

import { Extension } from 'resource:///org/gnome/shell/extensions/extension.js';
import * as QuickSettings from 'resource:///org/gnome/shell/ui/quickSettings.js';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';

// XAMPP Feature class for the Quick Settings toggle
const XamppFeature = GObject.registerClass(
    class XamppFeature extends QuickSettings.QuickToggle {
        _init() {
            super._init({
                title: 'XAMPP Server',
                iconName: 'network-server-symbolic',
                toggleMode: true,
            });

            // Set initial state based on XAMPP status
            this.checked = this._isXamppRunning();

            // Connect the toggle state change event
            this.connect('clicked', () => {
                this._toggleXampp();
            });
        }

        _isXamppRunning() {
            try {
                let [success, stdout] = GLib.spawn_command_line_sync('pidof httpd');
                return stdout.length > 0; // XAMPP is running if httpd process exists
            } catch (e) {
                logError(e, 'XAMPP Toggle: Failed to check XAMPP status');
                return false;
            }
        }

        _toggleXampp() {
            let command = this.checked
                ? 'sudo /opt/lampp/lampp start'
                : 'sudo /opt/lampp/lampp stop';
            this._runCommand(command);
        }

        _runCommand(command) {
            try {
                let [, argv] = GLib.shell_parse_argv(command);
                let proc = Gio.Subprocess.new(
                    argv,
                    Gio.SubprocessFlags.STDOUT_PIPE | Gio.SubprocessFlags.STDERR_PIPE
                );

                proc.communicate_utf8_async(null, null, (proc, res) => {
                    try {
                        let [, stdout, stderr] = proc.communicate_utf8_finish(res);
                        if (proc.get_exit_status() !== 0) {
                            log(`XAMPP Toggle: Error executing command: ${stderr}`);
                            // Sync toggle with actual state
                            this.checked = this._isXamppRunning();
                        } else {
                            // Sync toggle with actual state
                            this.checked = this._isXamppRunning();
                        }
                    } catch (e) {
                        logError(e, 'XAMPP Toggle');
                        this.checked = this._isXamppRunning();
                    }
                });
            } catch (e) {
                logError(e, 'XAMPP Toggle');
                this.checked = this._isXamppRunning();
            }
        }
    }
);

// System Indicator for Quick Settings
export const Indicator = GObject.registerClass(
    class Indicator extends QuickSettings.SystemIndicator {
        _init() {
            super._init();

            // Create the indicator icon
            this._indicator = this._addIndicator();
            this._indicator.icon_name = 'network-server-symbolic';

            // Create the XAMPP toggle
            this._feature = new XamppFeature();

            // Add the toggle to Quick Settings items
            this.quickSettingsItems.push(this._feature);

            // Connect the toggle's state to the indicator icon
            this._feature.connect('notify::checked', () => {
                this._indicator.visible = this._feature.checked;
            });

            // Initial visibility of the indicator
            this._indicator.visible = this._feature.checked;
        }

        destroy() {
            // Clean up
            this.quickSettingsItems.forEach(item => item.destroy());
            super.destroy();
        }
    }
);

export default class XamppToggleExtension extends Extension {
    enable() {
        // Create the indicator
        this._indicator = new Indicator();

        // Add the indicator to Quick Settings
        Main.panel.statusArea.quickSettings.addExternalIndicator(this._indicator);
    }

    disable() {
        // Remove and clean up
        if (this._indicator) {
            this._indicator.destroy();
            this._indicator = null;
        }
    }
}