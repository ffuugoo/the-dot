#!/bin/zsh

# AppleScript Quick Action
#
# on run {input, parameters}
#     try
#         set command to { "~/.local/bin/dot-clean.sh" }
#
#         repeat with directoryOrFile in input
#             set end of command to quoted form of POSIX path of directoryOrFile
#         end repeat
#
#         set defaultDelimiters to AppleScript's text item delimiters
#         set AppleScript's text item delimiters to " "
#         set command to command as text
#         set AppleScript's text item delimiters to defaultDelimiters
#
#         do shell script command
#     on error message number status
#         display dialog ¬
#             "dot-clean.sh returned status code " & status & return & return & message ¬
#             with title "Failed to cleanup macOS dot-files!" ¬
#             with icon caution
#     end try
# end run

set -euo pipefail

find $@ -maxdepth 1 -type d \( -name .fseventsd -or -name .Spotlight-V100 \) -exec rm -rf {} +
find $@ -type f \( -name .DS_Store -or -name .VolumeIcon.icns -or -name ._\* \) -delete
