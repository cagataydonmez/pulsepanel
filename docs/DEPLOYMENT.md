# PulsePanel Deployment

Use the root script:

```bash
./install_local.sh devices
./install_local.sh mac
./install_local.sh iphone
./install_local.sh both
./install_local.sh testflight
```

## Local Mac

`./install_local.sh mac` builds `PulsePanelMac.app`, copies it to `~/Applications`, and launches it.

## iPhone Wi-Fi Install

Prerequisites:

- Pair the iPhone once in Xcode.
- Enable wireless/network debugging in Xcode Devices and Simulators.
- Keep Mac and iPhone on the same Wi-Fi network.
- Keep the iPhone unlocked during install.

Then run:

```bash
./install_local.sh iphone
```

If multiple iPhones are visible, the script prompts for a device. To skip the prompt:

```bash
DEVICE_ID="Cgty iPhone" ./install_local.sh iphone
```

## Mac + iPhone

```bash
./install_local.sh both
```

This launches the Mac menu bar companion first, then installs and launches the iPhone app.

## TestFlight

Prerequisites:

- App Store Connect app record for `com.cagataydonmez.pulsepanel`.
- Apple Distribution certificate installed in Keychain.
- App Store Connect API key at `~/.appstoreconnect/private_keys/AuthKey_${ASC_KEY_ID}.p8`.

Run:

```bash
export ASC_KEY_ID=XXXXXXXXXX
export ASC_ISSUER_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
export ASC_KEY_PATH="$HOME/.appstoreconnect/private_keys/AuthKey_${ASC_KEY_ID}.p8"
export TESTFLIGHT_CONFIRM=1
./install_local.sh testflight
```

The script archives the iOS app, exports an IPA with `method=app-store-connect`, and uploads with `xcrun altool`.

If export fails with `Cloud signing permission error` or `No profiles for 'com.cagataydonmez.pulsepanel' were found`, fix signing in Apple Developer/App Store Connect first:

- Confirm the App Store Connect API key has permission to manage cloud signing/profiles for team `4P293R4B47`.
- Confirm the bundle ID `com.cagataydonmez.pulsepanel` exists and is assigned to the App Store Connect app record.
- Create or refresh an App Store distribution provisioning profile for that bundle ID, or sign in to the team account in Xcode and rerun with `-allowProvisioningUpdates`.
