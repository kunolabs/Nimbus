# Audio sink restore after paused or stuck stream

## Problem

Windows can remain locked to `Steam Streaming Speakers` after a stream ends if
the audio capture path does not fully tear down. In the field report that
triggered this issue, normal output switching recovered only after restarting
the Nimbus service.

## Evidence

- A native Artemis stream ended cleanly, but Windows still resisted switching
  away from the virtual stream sink.
- Logs repeatedly showed `Resetting sink to [virtual-Stereo...] after default
  changed` and `Reinitializing audio capture` after the visible stream was gone.
- A service restart stopped the lingering capture/helper activity and restored
  normal Windows output switching.

## Likely cause

The normal restore path exists in `src/audio.cpp` and calls
`reset_default_device()` after audio capture teardown. The field report suggests
there is still a paused or stuck-stream path where capture remains alive long
enough for the Windows endpoint-change callback in
`src/platform/windows/audio.cpp` to keep reasserting the virtual sink.

Related areas to inspect:

- RTSP session pause/resume behavior in `src/stream.cpp`.
- Local WebRTC failure or startup paths that can touch capture state.
- The Windows audio endpoint callback registered by `audio_control_t::microphone`.
- Display helper pause semantics when `config_revert_on_disconnect` is disabled.

## Candidate fixes

1. Add a cheap active-session guard before the Windows endpoint callback
   reasserts the virtual sink.
2. Ensure failed or local WebRTC stream attempts release audio capture and do not
   leave the callback active.
3. Add a user-facing "Restore Audio Output" action in the tray or web UI that
   calls the existing default-device reset logic without a full service restart.
4. Add a focused regression log fixture around "last session ended, default
   device changed, callback still reasserts virtual sink".

## Current workaround

Use the tray menu's `Restore Audio Output` action in alpha builds that include
it. On older builds, restart the Nimbus service from an elevated PowerShell
window:

```powershell
Restart-Service -Name ApolloService -Force
```
