# Mobile list card — design notes (M1)

Reference: `.cursor/plans/prd_roles_vs_mobile_review_e2f440d4.plan.md` (Policy list cards section).

## Hierarchy

- **One primary signal per row:** the colored **status chip** encodes workflow state.
- **Section headers** (“Needs attention”, “My Assignments”, “Approved library”) carry queue context — cards do not need a second queue marker.
- **Title** uses policy type / category via `getPolicyScreenTitle`; avoid version-only labels (`v1`) as the headline.

## Removed (anti-slop)

- **Purple 4px left stripe** (`accent="primary"`) — removed from `PolicyListCard`; it duplicated the status chip and read as generic template chrome.

## Optional affordances (implemented)

- **Muted chevron** (`chevron-forward`, ~65% opacity) on the trailing edge for tappable rows.
- White card, light border `#E4E0F2`, subtle shadow — consistent with detail meta tiles.

## Avoid

- Stripe + chip + tinted background on the same row.
- Extra “action required” color bars when the section title already says “Needs attention”.
- Bolding every meta field; keep role · department · version on one muted line.

## Stitch / 21st pass (lightweight)

- When refreshing in Stitch, compare **Refined library** list density and chip placement; port spacing into `spacing` tokens, not screenshot assets.
- Prefer **pressed state** on `Pressable` over new decorative borders for tap affordance.

## Related code

- `manageaze-mobile-app/src/components/policy/PolicyListCard.tsx`
- `manageaze-mobile-app/app/(tabs)/policies.tsx`
- `manageaze-mobile-app/app/(tabs)/assignments.tsx`
