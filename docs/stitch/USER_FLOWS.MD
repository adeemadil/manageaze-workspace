# User Flows

## Auth Flow

Login -> token returned -> save securely -> fetch user context -> route to Policy Library.

## Policy Browse Flow

Open app -> show cached library instantly -> background sync -> update list non-disruptively.

## Policy Detail + Comments Flow

Tap policy card -> show cached detail -> background sync -> tap "Comments" -> open comments panel/sheet -> post comment optimistic -> reconcile with server response.

## Offline/Reconnect Flow

If offline:

- Continue showing cached library/detail/comments.
- Queue comment submissions.
On reconnect:
- Auto-sync queued writes first.
- Revalidate list/detail/comments.
- Show subtle "updated just now" confirmation.