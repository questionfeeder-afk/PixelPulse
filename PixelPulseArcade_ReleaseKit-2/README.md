# PixelPulse Arcade — publish-ready native Mac release kit

This is the **native SwiftUI** version. There is no `index.html`, JavaScript, Electron, or browser renderer.

## You do NOT need Xcode on your own Mac

The included GitHub Actions workflow builds the app on a hosted macOS machine.

### Fastest path

1. Create a new GitHub repository.
2. Upload everything in this folder to the repository.
3. Go to **Actions**.
4. Select **Build PixelPulse Arcade for macOS**.
5. Choose **Run workflow**.
6. When it finishes, download the `PixelPulse-Arcade-macOS` artifact.
7. Put the resulting `PixelPulse-Arcade-macOS.dmg` on your website.

The DMG contains:
- `PixelPulse Arcade.app`
- an `Applications` shortcut

So the user experience is:

**Download → open DMG → drag app to Applications → launch.**

## Important: Apple Gatekeeper

The workflow currently creates an **unsigned** DMG because Apple Developer signing credentials cannot be supplied by this environment.

An unsigned app may show Apple's “could not verify” warning on another Mac.

For a polished public release, the DMG should be signed with a **Developer ID Application** certificate and notarized by Apple. That requires an Apple Developer account and signing secrets in GitHub Actions. You still do not need to run Xcode yourself.

## Current app status

The app is a real native SwiftUI macOS application. The current account/friends/messages implementation is local demo state; it is not yet a production online service.

The next production step is connecting authentication, username friendships, realtime messaging, and notifications to a real backend (for example Supabase) without changing the native UI architecture.

## Architecture

- Native macOS app: SwiftUI
- Project generation in CI: XcodeGen
- CI build: GitHub Actions macOS runner
- DMG creation: hdiutil
- No HTML frontend
- No Electron
