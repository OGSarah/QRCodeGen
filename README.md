<div align="center">
  <img src="https://github.com/OGSarah/QRCodeGen/blob/cc4f2c58c50fd12fb13ae6fc96609b5121309dee/Screenshots/AppIcon.png" width="300" style="border: 3px solid white; border-radius: 15px; vertical-align: middle; margin-right: 20px;">
  <h1 style="display: inline-block; vertical-align: middle;">QRCodeGen - iOS app with SwiftUI</h1>
</div>

A Swift iOS QR Code Generator app made with SwiftUI that meets the ISO/IEC 18004 specification for QR codes. The app is made using Core Image.

# Brief Explanation of Technical Background of QR Codes
QR codes (Quick Response codes) are two-dimensional barcodes that store information in a grid of black and white squares. Originally developed in 1994 by Denso Wave for tracking automotive parts in manufacturing, QR codes have become ubiquitous for quickly sharing URLs, contact information, and other data through smartphone cameras. The "QR" name reflects their design goal: to be decoded at high speed.

A QR code consists of several key components:
- Finder patterns (the large squares in three corners that help scanners locate and orient the code).
- Alignment patterns (smaller patterns that assist with reading larger codes).
- Timing patterns (alternating modules that help determine the code's size).
- Data area (where the actual encoded information is stored).
- Error correction data (allowing the code to remain readable even when partially damaged or obscured).

Text Encoding Modes:
- Numeric: Digits 0 through 9.
- Alphanumeric: Decimal digits 0 through 9, as well as uppercase letters, and the symbols $, %, *, +, -, ., /,:, and space.
- Byte: Characters from the ISO-8859-1 character set. ISO-8859-1 (aka Latin-1) is a single-byte character encoding standard for representing Western European languages, including characters, digits, and symbols.
- Kanji: Double-byte characters from the Shift JIS character set. The Shift JIS character set is a character encoding standard for the Japanese language that uses a combination of one- and two-byte characters.

# Screenshots
<div align="center">
  <div style="border: 2px solid white; border-radius: 10px;">
    <img width="20%" src="https://github.com/OGSarah/QRCodeGen/blob/042368005066a21126fd0a30e44595a108d150ec/Screenshots/1_dark.png">
    <img width="20%" src="https://github.com/OGSarah/QRCodeGen/blob/042368005066a21126fd0a30e44595a108d150ec/Screenshots/1_light.png">
    <img width="20%" src="https://github.com/OGSarah/QRCodeGen/blob/042368005066a21126fd0a30e44595a108d150ec/Screenshots/2_dark.png">
    <img width="20%" src="https://github.com/OGSarah/QRCodeGen/blob/042368005066a21126fd0a30e44595a108d150ec/Screenshots/2_light.png">
  </div>
</div>

<br><br> 

<div align="center">
  <div style="border: 2px solid white; border-radius: 10px;">
    <img width="20%" src="https://github.com/OGSarah/QRCodeGen/blob/042368005066a21126fd0a30e44595a108d150ec/Screenshots/3_dark.png">
    <img width="20%" src="https://github.com/OGSarah/QRCodeGen/blob/042368005066a21126fd0a30e44595a108d150ec/Screenshots/3_light.png">
    <img width="20%" src="https://github.com/OGSarah/QRCodeGen/blob/042368005066a21126fd0a30e44595a108d150ec/Screenshots/4_dark.png">
    <img width="20%" src="https://github.com/OGSarah/QRCodeGen/blob/042368005066a21126fd0a30e44595a108d150ec/Screenshots/4_light.png">
  </div>
</div>

<br><br> 
<div align="center">
  <div style="border: 2px solid white; border-radius: 10px;">
    <img width="20%" src="https://github.com/OGSarah/QRCodeGen/blob/042368005066a21126fd0a30e44595a108d150ec/Screenshots/5_dark.png">
    <img width="20%" src="https://github.com/OGSarah/QRCodeGen/blob/042368005066a21126fd0a30e44595a108d150ec/Screenshots/5_light.png">
  </div>
</div>


# Language, Frameworks, & Tools used:
- Swift
- SwiftUI
- iOS 26
- Xcode 26
- SwiftLint
- Core Image

# Requirements

### Error Correction Level
| Error Correction Level | Error Correction Capability |
|:---|:---|
| L | Recovers 7% of data |
| M | Recovers 15% of data |
| Q | Recovers 25% of data |
| H | Recovers 30% of data |

### Smallest QR Code Version
| Error Correction Level | Numeric Mode | Alpha Numeric Mode | Byte Mode | Kanji Mode |
|:---|:---|:---|:---|:---|
| L | 187 | 114 | 78 | 48 |
| M | 149 | 90 | 62 | 38 |
| Q | 111 | 67 | 46 | 28 |
| H | 82 | 50 | 34 | 21 |

# Features

- **High-Quality QR Code Generation** – Powered by **Apple’s `CIQRCodeGenerator`** (Core Image)  
  - Automatically selects optimal version  
  - Full support for **L, M, Q, H** error correction levels  
  - Perfectly compliant with ISO/IEC 18004 standard  

- **Smart Input Handling**  
  - Paste from clipboard with one tap  
  - Clear button for instant reset  
  - Multi-line text input with vertical expansion  

- **Error Correction Picker**  
  - Segmented control with descriptive labels:  
    `Low (7%)` | `Medium (15%)` | `Quartile (25%)` | `High (30%)`  
  - Real-time resilience feedback in UI  

- **Beautiful, Scalable Output**  
  - Crisp rendering with **10× module size** + **4-module quiet zone**  
  - High-resolution `CGImage` → `UIImage` pipeline  
  - Smooth interpolation disabled for pixel-perfect QR modules  

- **Rich Interaction & Sharing**  
  - **Tap-and-hold context menu**:  
    - Copy to clipboard  
    - Save to Photos  
    - Share via `ShareLink`  
  - Toolbar actions: Paste, Clear, Share  
  - Haptic feedback on success/error  

- **Modern SwiftUI Design**  
  - `NavigationStack` + `List` with `.insetGrouped` style  
  - Glass morphism button (`.glassEffect`)  
  - Adaptive dark/light mode previews  
  - Accessibility labels & hints throughout  

- **Robust Generation Flow**  
  - Debounced input (350ms) to prevent spam  
  - Cancelable `Task` for smooth UX  
  - Error display with localized messages  
  - `ProgressView` during generation  

- **Zero External Dependencies**  
  - Uses only **Apple frameworks**: `SwiftUI`, `CoreImage`, `PhotosUI`, `UniformTypeIdentifiers`


## License
Proprietary Software

© 2025 SarahUniverse

This software and its source code are the exclusive property of SarahUniverse.
No part of this software may be reproduced, distributed, or transmitted in any form or by any means without prior written permission.
