# DIGITAL SPORTS SCOREBOARD 

## Project Design Document 

### 1. Project Overview 

The Digital Sports Scoreboard is a portable, Bluetooth-controlled electronic scoreboard designed for indoor and outdoor sporting events. The system displays the names of two competing teams and their respective scores while allowing an operator to update game information wirelessly using a mobile application. 

The scoreboard incorporates intelligent features that improve usability and efficiency. It automatically adjusts the LCD display brightness based on the surrounding light intensity using a photoresistor (Light Dependent Resistor - LDR), ensuring the display remains visible in both bright daylight and low-light conditions. The system also includes a DFPlayer Mini audio module, enabling it to play pre-recorded audio announcements and sound effects such as game start, game end, score updates, and other event notifications. 

To enhance portability and reliability, the scoreboard operates on a rechargeable battery that supports dual charging methods. The battery can be charged using either a solar panel for outdoor operation or an AC-to-DC power adapter (charger) when mains electricity is available. This ensures uninterrupted operation in different environments. 

## 2. Project Objectives 

The project aims to: 

- Display the names of two competing teams. 

- Display and update the scores of both teams in real time. 

- Allow wireless control using a Bluetooth-enabled mobile application. 

- Play audio announcements and sound effects using a DFPlayer Mini module. 

- Automatically adjust LCD brightness using a photoresistor (LDR). 

- Recharge the internal battery using either a solar panel or an AC charger. 

- Provide both physical and mobile-app reset functionality. 

- Build a portable, low-power, and user-friendly sports scoreboard. 

## 3. Main Features 

### Wireless Bluetooth Control 

- Connects to a mobile application. 

- Updates team names and scores instantly. 

- Supports game start, game end, and reset commands. 

### Digital Display 

- Displays Team A name. 

- Displays Team B name. 

- Displays Team A score. 

- Displays Team B score. 

### Smart Brightness Control 

- Uses a photoresistor (LDR) to monitor ambient light. 

- Automatically increases LCD backlight brightness in bright environments. 

- Automatically reduces brightness in dark environments. 

- Improves visibility while reducing unnecessary power consumption. 

### Audio Announcement System 

- Uses a DFPlayer Mini module with a microSD card containing pre-recorded audio files. 

- Plays different sounds or voice announcements for: 

   - Game Start 

   - Game End 

   - Score Increase 

   - Score Decrease 

   - Other configurable notifications 

### Dual Charging System 

- Solar panel charging for outdoor use. 

- AC-to-DC charger input for indoor charging. 

- Rechargeable battery powers the scoreboard during operation. 

- Automatic charging ensures the battery remains available regardless of the power source. 

### Reset Function 

- Reset from the mobile application. 

- Physical reset button on the scoreboard. 

- Resets both scores and restores default team names. 

## 4. System Workflow 

1. The scoreboard is powered on using the rechargeable battery. 

2. The ESP32 initializes the display, Bluetooth module, DFPlayer Mini, brightness control system, and other peripherals. 

3. The mobile application connects to the scoreboard via Bluetooth. 

4. The operator enters or edits the team names. 

5. The operator starts the game using the mobile application. 

6. The DFPlayer Mini plays the game start announcement or sound. 

7. During play, the operator updates scores through the mobile application. 

8. The scoreboard updates the display instantly and plays the corresponding audio notification. 

9. The LDR continuously monitors ambient light and automatically adjusts the LCD brightness for optimal visibility. 

10. When the game ends, the operator selects “End Game,” and the DFPlayer Mini plays the end-of-game announcement or sound. 

11. The operator may reset the scoreboard using either the mobile application or the physical reset button. 

12. When battery power becomes low, the battery can be recharged using either the solar panel or an AC charger. 

## 5. Hardware Components 

- ESP32 Development Board 

- LCD Display (I²C) 

- Score Display (7-segment display or LED matrix) 

- DFPlayer Mini MP3 Module 

- MicroSD Card 

- Speaker 

- Bluetooth Communication (built into ESP32) 

- Photoresistor (LDR) 

- Fixed Resistor (for LDR voltage divider) 

- Rechargeable Lithium Battery 

- TP4056 Charging Module (or equivalent charging circuit) 

- Solar Panel 

- AC-to-DC Charging Adapter 

- Reset Push Button 

- Power Switch 

## 6. Future Improvements 

- Match countdown timer 

- Battery percentage indicator 

- Wi-Fi and Internet control 

- Match history storage 

- Multiple sports modes 

- Automatic score backup 

- Voice-controlled operation 

- Remote firmware updates 

