# Checkpoint

A quick and dirty macOS app built using Swift and SwiftUI that helps you
track your work and maintain productivity through logging your work at
set intervals.

## macOS 26

1. Download the latest release [v2.0.0](https://github.com/damiensedgwick/Checkpoint/releases/tag/v2.0.0)
2. Drag the Checkpoint app into your applications folder
3. Open up Checkpoint and start logging your work

<img width="3024" height="1964" alt="Screenshot 2025-07-30 at 11 50 49" src="https://github.com/user-attachments/assets/ccaadaf0-975b-46ac-a211-c382b86cd664" />

## macOS Sequoia (15)

1. Download the last release to support this version [v1.1.0](https://github.com/damiensedgwick/Checkpoint/releases/tag/v1.1.0)
2. Drag the Checkpoint app into your applications folder
3. Open up Checkpoint and start logging your work

<img width="3024" height="1964" alt="Screenshot 2025-07-30 at 11 50 49" src="https://github.com/user-attachments/assets/f7d3642e-7d0f-425e-81f0-359286a6fe81" />

## Development

In the project root, from your terminal, run:

```sh
cp Config.xcconfig.template Config.xcconfig
```

Then add your development team ID after `DEVELOPMENT_TEAM =`. Your ID can be found
in your Apple Developer portal under Membership Details.

## Release Process (mental notes for me)

1. Archive the project from within Xcode
2. Distrubute App > Direct Distribution
3. Once processed, export Notarized app
4. Create new release on GitHub and upload binary

## License

This project is open source and available under the MIT License.
