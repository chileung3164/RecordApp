#!/bin/bash

# Generate UUIDs for the new files
SESSION_STORAGE_FILE_UUID="93NEW0142C000014008E5409"
SESSION_STORAGE_BUILD_UUID="93NEW0152C000015008E5409"

SESSION_HISTORY_FILE_UUID="93NEW0162C000016008E5409"
SESSION_HISTORY_BUILD_UUID="93NEW0172C000017008E5409"

SESSION_DETAIL_FILE_UUID="93NEW0182C000018008E5409"
SESSION_DETAIL_BUILD_UUID="93NEW0192C000019008E5409"

PROJECT_FILE="ResApp.xcodeproj/project.pbxproj"

# Backup the original project file
cp "$PROJECT_FILE" "$PROJECT_FILE.backup"

# Add PBXBuildFile entries (after line with 92NEW0132C000013008E5409)
sed -i '' '/92NEW0132C000013008E5409.*Constants\.swift in Sources/a\
		93NEW0152C000015008E5409 /* SessionStorageService.swift in Sources */ = {isa = PBXBuildFile; fileRef = 93NEW0142C000014008E5409 /* SessionStorageService.swift */; };\
		93NEW0172C000017008E5409 /* SessionHistoryView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 93NEW0162C000016008E5409 /* SessionHistoryView.swift */; };\
		93NEW0192C000019008E5409 /* SessionDetailView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 93NEW0182C000018008E5409 /* SessionDetailView.swift */; };
' "$PROJECT_FILE"

# Add PBXFileReference entries (after line with 92NEW0131C000013008E5409)
sed -i '' '/92NEW0131C000013008E5409.*Constants\.swift/a\
		93NEW0142C000014008E5409 /* SessionStorageService.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = Services/SessionStorageService.swift; sourceTree = "<group>"; };\
		93NEW0162C000016008E5409 /* SessionHistoryView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = Views/Components/SessionHistoryView.swift; sourceTree = "<group>"; };\
		93NEW0182C000018008E5409 /* SessionDetailView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = Views/Components/SessionDetailView.swift; sourceTree = "<group>"; };
' "$PROJECT_FILE"

# Add SessionStorageService.swift to Services group (after TimerService.swift)
sed -i '' '/92NEW0041C000004008E5409.*TimerService\.swift/a\
				93NEW0142C000014008E5409 /* SessionStorageService.swift */,
' "$PROJECT_FILE"

# Add SessionHistoryView.swift and SessionDetailView.swift to Components group (after ButtonStyles.swift)
sed -i '' '/92NEW0111C000011008E5409.*ButtonStyles\.swift/a\
				93NEW0162C000016008E5409 /* SessionHistoryView.swift */,\
				93NEW0182C000018008E5409 /* SessionDetailView.swift */,
' "$PROJECT_FILE"

# Add to Sources build phase (after Constants.swift in Sources)
sed -i '' '/92NEW0132C000013008E5409.*Constants\.swift in Sources/a\
				93NEW0152C000015008E5409 /* SessionStorageService.swift in Sources */,\
				93NEW0172C000017008E5409 /* SessionHistoryView.swift in Sources */,\
				93NEW0192C000019008E5409 /* SessionDetailView.swift in Sources */,
' "$PROJECT_FILE"

echo "Successfully added files to Xcode project!"
echo "Original project file backed up as: $PROJECT_FILE.backup" 