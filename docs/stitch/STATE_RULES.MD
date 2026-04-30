# State Rules (Offline-First)

1. Render from cache first on every screen.
2. On successful API response:
   - normalize data
   - write cache
   - then refresh UI from cache-backed store
3. If offline:
   - do not clear UI
   - show cached snapshot + stale timestamp
4. Comments post:
   - optimistic insert with syncState=pending
   - on success -> synced
   - on fail -> failed + retry
5. Revalidation triggers:
   - app foreground
   - pull-to-refresh
   - open policy detail
   - open comments
   - network reconnect
6. Never block main content with full-screen loaders if cache exists.
