# Quiet List

A small, offline native iPhone to-do app. Designed for iPhone 14; requires iOS 16 or later.

**This download is the source project and build workflow, not a compiled IPA.** Run the included workflow on GitHub to produce `QuietList-unsigned.ipa`. No Apple account, certificate, or signing secret is needed for that build. The build has not been run or device-tested in the environment where this project was created (Linux, without Xcode).

## What the app does

- Add a task and tap its circle to complete it.
- Tap task text to edit; swipe left to delete.
- Completed tasks are tucked away behind a disclosure button. Open it to restore tasks or clear completed items with confirmation.
- Tasks save locally after changes and survive closing the app.
- Follows the iPhone’s light/dark appearance and text size; includes VoiceOver labels.
- No accounts, tracking, ads, network requests, badges, reminders, or subscriptions.

There is no cloud sync, export, or recovery of deleted tasks. Removing the app can remove your list. Refresh the existing installation rather than uninstalling it.

## 1. Build and download the IPA

1. Open the repository’s **Actions** tab. Enable workflows if prompted.
2. Select **Build iPhone IPA**.
3. Select **Run workflow**, choose your default branch, and confirm. A push to `main` or `master` also starts a build.
4. Wait for the build to finish successfully.
5. Open the completed run. Under **Artifacts**, download **QuietList-unsigned-IPA** while signed in to GitHub.
6. Extract the downloaded artifact ZIP. Inside is **QuietList-unsigned.ipa**.

The artifact is retained for 14 days; keep your downloaded copy or rerun the build later. **Do not rename the artifact ZIP to `.ipa`.** Extract it to obtain the actual IPA inside.

The workflow installs XcodeGen, generates an Xcode project, compiles an ARM64 iPhone app using Apple’s SDK on a GitHub macOS runner, and packages it as `Payload/QuietList.app` inside the IPA. It does not sign or distribute the app through Apple.

## 2. Sign and install on your iPhone 14

An unsigned IPA cannot be installed by simply opening it in Files or AirDropping it. It must be signed for your device.

Use your existing **AltStore Classic** or **SideStore** setup and its custom-IPA import option (usually the **+** button in **My Apps**). Select `QuietList-unsigned.ipa` and follow the tool’s signing and installation prompts. AltStore PAL is a different distribution product; these instructions refer to AltStore Classic.

If you don’t have a signing tool set up yet, follow its current official instructions first:

- AltStore Classic: https://faq.altstore.io/
- SideStore: https://docs.sidestore.io/

These tools have their own computer/pairing requirements. On iOS, you may also need to enable **Settings → Privacy & Security → Developer Mode** and trust the developer profile when prompted. Setup details vary with the iOS version and tool.

### Free Apple account limitations

Personal/free signing generally expires after **7 days**. Refresh before expiry using the sideloading tool; this is not a permanently signed app. Free-account sideloading also has active-app and App ID limits, and the sideloading helper may occupy a slot. Consult your tool’s current instructions for those limits. A paid developer membership is not required for the intended personal installation route, but signing remains subject to Apple’s restrictions.

Never put Apple credentials in this repository or in GitHub Actions. Signing happens through your chosen tool, not this workflow.

## If the build fails

Open the failed Actions step and read its error. The workflow also uploads a `build-log` artifact if the compiler step produced one. Share the error text for troubleshooting; do not share passwords, certificates, or private signing files.

Common issues:

- **No workflow listed:** ensure `.github/workflows/build-ipa.yml` is on your default branch and not nested inside another folder.
- **Project spec not found:** `project.yml` must be at the repository root.
- **No IPA to download:** wait for a successful build and open the run’s summary, not the workflow editor.
- **Signing/install error:** check the signing tool’s account, device pairing, available app slots, and refresh status. The IPA is intentionally unsigned.

## Optional: build in Xcode on a Mac

Install Xcode and XcodeGen (`brew install xcodegen`), then run `xcodegen generate` in this folder and open `QuietList.xcodeproj`.

For direct installation from Xcode, change the target’s **Code Signing Allowed** build setting to **Yes**, select your Personal Team in Signing & Capabilities, choose a unique bundle identifier, and let Xcode manage signing. Select your connected iPhone and run. The checked-in configuration disables signing only to support the cloud IPA build.

## Project contents

- `QuietList/QuietListApp.swift`: app entry point.
- `QuietList/TaskStore.swift`: task model and atomic JSON persistence in the app’s Documents directory.
- `QuietList/ContentView.swift`: task entry, completion, editing, and deletion UI.
- `QuietList/Assets.xcassets`: app icon.
- `project.yml`: XcodeGen project specification.
- `.github/workflows/build-ipa.yml`: unsigned device build and IPA packaging.

The UI is portrait-only. Tasks are ordered newest first; manual reordering, due dates, widgets, and notifications are deliberately omitted.
