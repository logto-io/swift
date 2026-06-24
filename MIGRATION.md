# Migrating from v1 to v2

v2 replaces the embedded WebView sign-in flow with
[`ASWebAuthenticationSession`](https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession)
on iOS. The authentication UI now runs in the system browser context, which enables
WebAuthn/passkey sign-in, follows the native-app OAuth guidance in
[RFC 8252](https://datatracker.ietf.org/doc/html/rfc8252), and shares the browser
session by default.

v2 also revamps sign-out to distinguish a complete browser sign-out from a local
credential clear, and removes the native social plugin targets that relied on the
embedded WebView flow.

## Required: review redirect URIs on iOS

In v1, the SDK handled the OAuth redirect inside the embedded WebView. In v2,
`ASWebAuthenticationSession` matches the callback through the redirect URI, so your
app must be configured to receive the URI you pass to `signInWithBrowser`.

### Custom scheme redirects

For a custom scheme such as `io.logto.app://callback`:

1. Register the scheme in your app's `Info.plist`.
2. Add the same URI to your Logto application's Redirect URIs.
3. Pass the same URI to `signInWithBrowser`.

```swift
try await logtoClient.signInWithBrowser(
    redirectUri: "io.logto.app://callback"
)
```

Custom scheme callbacks can be matched and dismissed automatically on all supported
iOS versions.

### HTTPS Universal Link redirects

You can also use an HTTPS redirect URI such as `https://example.com/callback`:

1. Add the Associated Domains capability to your app.
2. Configure `webcredentials:example.com` so `ASWebAuthenticationSession` can match
   HTTPS callbacks on iOS 17.4 and newer.
3. If the same URL should open your app outside the authentication session, also
   configure `applinks:example.com` and host a valid
   `apple-app-site-association` file.
4. Add the HTTPS URI to your Logto application's Redirect URIs.
5. Pass the same URI to `signInWithBrowser`.

On iOS 17.4 and newer, the SDK uses `ASWebAuthenticationSession`'s HTTPS callback
API so HTTPS redirects can automatically complete and dismiss the session. On older
iOS versions, the authorization request can still use the HTTPS redirect URI, but
the session may not close automatically unless your app handles the Universal Link
callback itself. Keep a custom scheme redirect as a compatibility option if you
need automatic completion on older iOS versions.

## Changed: sign-in behavior

The `signInWithBrowser(redirectUri:)` API is still the main sign-in entry point:

```swift
try await logtoClient.signInWithBrowser(
    redirectUri: "io.logto.app://callback"
)
```

The visible behavior changes because the flow now uses `ASWebAuthenticationSession`:

- iOS may show a system consent prompt before opening the browser session. The
  prompt text is controlled by the system.
- Browser cookies are shared by default, so users may get single sign-on behavior
  across the app and the system browser.
- To request an isolated browser session, set
  `prefersEphemeralWebBrowserSession: true` in `LogtoConfig`.
- The app can no longer inspect the page, inject JavaScript, or rely on WebView-only
  behavior during authentication.

## Removed: native social plugins

The native social plugin products and targets are removed:

- `LogtoSocialPlugin`
- `LogtoSocialPluginWeb`
- `LogtoSocialPluginAlipay`
- `LogtoSocialPluginWechat`

The `socialPlugins` parameter in `LogtoClient` initialization and the
`LogtoClient.handle(url:)` / notification-based plugin handoff are also removed.

Social connectors still work through the browser, like on the web. If you depend on
the native WeChat or Alipay SDK handoff, stay on the v1 line.

## Changed: sign-out API

In v1, `signOut()` cleared local credentials and tried to revoke the refresh token.
It did not end the Logto session cookie because that cookie lived inside the
embedded WebView flow.

In v2, that local-only behavior is renamed to `clearCredentials()`, and
`signOut(postLogoutRedirectUri:)` is a browser-based sign-out that also opens the
Logto end session endpoint.

### Complete sign-out with redirect

Use this when you have a Post sign-out redirect URI registered in the Logto
console. The URI can be a custom scheme or an HTTPS Universal Link. It must also be
configured for your iOS app as described above.

```swift
let error = await logtoClient.signOut(
    postLogoutRedirectUri: "io.logto.app://signed-out"
)
```

This clears local credentials, tries to revoke the refresh token, opens the Logto
end session endpoint in `ASWebAuthenticationSession`, and lets Logto navigate back
to the app through the post sign-out redirect URI.

### Complete sign-out without redirect

Use this when you want to end the Logto browser session but do not have a Post
sign-out redirect URI. The browser session stays on the Logto sign-out page and
the user returns by dismissing it manually.

```swift
let error = await logtoClient.signOut()
```

Dismissing the browser during sign-out is treated as success. Local credentials
have already been cleared before the browser opens, and token revocation has
already settled.

### Local credential clear

Use this when no UI context is available, such as a background error handler, or
when you intentionally only want to clear local state.

```swift
let error = await logtoClient.clearCredentials()
```

This is v1's `signOut()` behavior: it clears local credentials and tries to revoke
the refresh token, but it does not open the browser and does not end the Logto
session cookie. The next sign-in may silently re-enter the same account through the
browser session. Prefer browser `signOut` when the user explicitly taps a sign-out
button.

## Error and retry behavior

- `clearCredentials()` and browser `signOut` return `LogtoClientErrors.SignOut?`.
  `nil` means the local sign-out completed successfully.
- Token revocation and remote browser sign-out are best effort. If revocation fails,
  local credentials are still cleared and the revoke error is returned.
- An invalid `postLogoutRedirectUri` returns `.invalidRedirectUri` with no side
  effects. Credentials stay intact so the caller can fix the URI and retry a
  complete sign-out.
- If the browser callback URI does not match the expected post sign-out redirect
  URI, the SDK returns `.unexpectedSignOutCallback`.
- If the browser session cannot start, the SDK returns `.unableToLaunchBrowser`.

## Platform availability

Browser sign-in and browser sign-out are currently available on iOS. On non-iOS
platforms, use `clearCredentials()` for local credential clearing.

## Installing the beta

v2 is released through Git tags. For the first beta, use the prerelease tag
`v2.0.0-beta.1` when it is published. Swift Package Manager and Xcode can resolve
SemVer prerelease tags, but callers should select the prerelease explicitly instead
of relying on a normal version range to pick it automatically.
