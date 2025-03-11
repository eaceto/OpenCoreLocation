import Foundation

/// Represents the physical orientation of a device.
/// [Apple Documentation](https://developer.apple.com/documentation/corelocation/cldeviceorientation)
public enum CLDeviceOrientation: String, CustomDebugStringConvertible, CustomStringConvertible {
    /// The device's orientation is unknown.
    case unknown = "Unknown"
    /// The device is in portrait mode, with the device held upright and the home button at the bottom.
    case portrait = "Portrait"
    /// The device is in portrait mode, but upside down.
    case portraitUpsideDown = "Portrait Upside Down"
    /// The device is in landscape mode, with the device held upright and the home button on the right side.
    case landscapeLeft = "Landscape Left"
    /// The device is in landscape mode, with the device held upright and the home button on the left side.
    case landscapeRight = "Landscape Right"
    /// The device is laid flat, with the screen facing upwards.
    case faceUp = "Face Up"
    /// The device is laid flat, with the screen facing downwards.
    case faceDown = "Face Down"

    // MARK: - CustomStringConvertible
    /// A user-friendly description of the device orientation.
    public var description: String {
        return rawValue
    }

    // MARK: - CustomDebugStringConvertible
    /// A debug-friendly description of the device orientation.
    public var debugDescription: String {
        return "CLDeviceOrientation(\(rawValue))"
    }
}
