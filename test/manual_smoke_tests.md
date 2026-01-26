# Manual smoke tests

## Client avatar color persistence

1. Launch the app and create a client with a non-default avatar color.
2. Close the app completely and restart it.
3. Verify the client's avatar color matches the one chosen before restart.
   - Confirm the startup log includes: `Client color loaded (bootstrap): ... avatar_color=...`.

