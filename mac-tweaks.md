# Mac tweaks

## 🧭 System Animation & UI Performance Tweaks

```
# Speed up window resize animation
defaults write NSGlobalDomain NSWindowResizeTime -float 0.1

# Make Dock show/hide faster
defaults write com.apple.dock autohide-time-modifier -float 0.1

# Disable Mission Control animation delay
defaults write com.apple.dock expose-animation-duration -float 0

# Make Dock show instantly when hidden
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.2

# Dock icon size
defaults write com.apple.dock tilesize -int 51

# Magnified icon size when hovering
defaults write com.apple.dock largesize -float 67.84

# Use “scale” instead of “genie” for window minimize animation
defaults write com.apple.dock mineffect -string "scale"

# Don’t show minimized windows separately on the right of the Dock
defaults write com.apple.dock minimize-to-application -bool true
```

## 🚀 Finder & Desktop Behavior

```
# Show all file extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Warn when changing file extensions
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool true

# Warn before deleting items from iCloud Drive
defaults write com.apple.finder FXEnableRemoveFromICloudDriveWarning -bool true

# Warn before emptying Trash
defaults write com.apple.finder WarnOnEmptyTrash -bool true

# Auto-delete items in Trash after 30 days
defaults write com.apple.finder FXRemoveOldTrashItems -bool true

# Show folders first when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# Default search scope: current folder
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Default Finder view: List
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Icon size in Finder views (64 px)
defaults write com.apple.finder IconViewSettings -dict IconSize -integer 64

# Sort items by name
defaults write com.apple.finder FXArrangeGroupViewBy -string "Name"

# Remove existing .DS_Store files
sudo find ~/ -name ".DS_Store" -delete

# Don’t create .DS_Store files on network drives
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool TRUE
```

## 🧠 Input & Keyboard Behavior

```
# Faster key repeat
defaults write -g KeyRepeat -int 2
defaults write -g InitialKeyRepeat -int 25

# Use F1–F12 as standard function keys by default
defaults write -g com.apple.keyboard.fnState -bool true
```

## 🖱️ Mouse & Dock Interaction

```
# Disable natural scrolling (for external mice)
defaults write -g com.apple.swipescrolldirection -bool false

# Faster “spring-loading” delay when dragging files over Dock icons
defaults write NSGlobalDomain com.apple.springing.delay -float 0

# Enable automatic opening of folders when hovering files
defaults write NSGlobalDomain com.apple.springing.enabled -bool true
```

## 🌐 Privacy & Telemetry Disablement

```
# Disable Apple analytics and diagnostics
defaults write com.apple.SubmitDiagInfo AutoSubmit -bool false
defaults write com.apple.SubmitDiagInfo AllowApplePersonalizedAds -bool false

# Disable ad tracking
defaults write com.apple.AdLib allowApplePersonalizedAdvertising -bool false

# Disable location services
defaults write com.apple.locationd LocationServicesEnabled -int 0
defaults write com.apple.locationd LocationServicesEnabledInSetup -int 0

# Disable Safari analytics and suggestions
defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true
defaults write com.apple.Safari UniversalSearchEnabled -bool false
defaults write com.apple.Safari SuppressSearchSuggestions -bool true

# Disable Spotlight suggestions
defaults write com.apple.Spotlight SuggestionsEnabled -bool false

# Disable Siri analytics and data collection
defaults write com.apple.assistant.support UserEnabled -bool false
sudo defaults write com.apple.assistant.support "Assistant Enabled" -bool false
defaults write com.apple.Siri UserHasDeclinedEnable -bool true
sudo defaults write com.apple.analyticsd AutoSubmit -bool false
sudo defaults write com.apple.analyticsd AutoSubmitVersion -int 0
sudo launchctl disable system/com.apple.analyticsd

# Disable iCloud analytics
defaults write com.apple.iCloud EnableAnalytics -bool false

# Disable usage reporting for Maps, Health, Messages, Photos
defaults write com.apple.Maps UserSelectedAnonymousUsageOptIn -bool false
defaults write com.apple.Health UserSelectedAnonymousUsageOptIn -bool false
defaults write com.apple.imessage UserSelectedAnonymousUsageOptIn -bool false
defaults write com.apple.Photos UserSelectedAnonymousUsageOptIn -bool false
```

## ✏️ TextEdit Defaults (Useful for Dev Notes)

```
# Plain text mode by default
defaults write com.apple.TextEdit RichText -int 0

# Default window size
defaults write com.apple.TextEdit WidthInChars -int 140
defaults write com.apple.TextEdit HeightInChars -int 40

# Spellcheck and smart features
defaults write com.apple.TextEdit CheckSpellingWhileTyping -bool true
defaults write com.apple.TextEdit SmartQuotes -bool true
defaults write com.apple.TextEdit SmartDashes -bool true
defaults write com.apple.TextEdit ShowRuler -bool true
```

## 🧩 Safari Developer Menu

```
# Enable Develop menu (Cmd + Opt + I for Web Inspector)
defaults write com.apple.Safari IncludeDevelopMenu -bool true
```

## 🔄 Apply and Restart

```
# Restart relevant daemons to apply settings
killall cfprefsd && killall locationd && killall SystemUIServer && killall Finder && killall Dock && killall TextEdit && killall Safari

# Reboot (3-second delay)
sleep 3
sudo reboot
```
