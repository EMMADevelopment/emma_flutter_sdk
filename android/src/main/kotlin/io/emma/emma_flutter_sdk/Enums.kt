package io.emma.emma_flutter_sdk

enum class PermissionStatus {
    Granted,
    Denied,
    ShouldPermissionRationale,
    Unsupported,
}

enum class InAppAction {
    Click,
    Impression,
    DismissedClick
}
