---

designSystem:
  name: "ManagEaze Unified Interface"
  style: "Governance SaaS, clean enterprise surfaces with purple-led accent system"
  platforms:
    - "web"
    - "mobile-web"
    - "native-mobile"
  colorMode:
    supported:
      - "light"
      - "dark"
    default: "light"

tokens:
  color:
    brand:
      primary:
        50: "#C7C0FF"
        100: "#A599FA"
        200: "#8471EF"
        300: "#644AE4"
        400: "#4523C8"
      sidebarPrimaryLight: "#6E4CF5"
      sidebarPrimaryDark: "#6140E1"
    neutral:
      50: "#FFFFFF"
      100: "#E6E6E6"
      200: "#B3B4B4"
      300: "#999B9B"
      400: "#808282"
      500: "#666968"
      600: "#4D504F"
      700: "#333736"
      800: "#1A1E1D"
      900: "#000504"
    semantic:
      success:
        50: "#EFFFE6"
        300: "#81FF33"
        400: "#61FF00"
      warning:
        50: "#FFE7E6"
        100: "#FF9F99"
        200: "#FF6F66"
        300: "#FF271A"
        400: "#FF0F00"
      info:
        100: "#B3DAFF"
        200: "#80C2FF"
        300: "#339DFF"
        400: "#0085FF"
      missing:
        50: "#FFF6E6"
        100: "#FFE5B3"
        200: "#FFCB66"
        300: "#FFB933"
        400: "#FFA800"
    chart:
      light:
        c1: "#E2795A"
        c2: "#2A9B8A"
        c3: "#264754"
        c4: "#E9C466"
        c5: "#F3A25A"
      dark:
        c1: "#3B82F6"
        c2: "#34C48F"
        c3: "#FB923C"
        c4: "#B06BEB"
        c5: "#EC4899"
    surface:
      light:
        background: "#FAFAFA"
        card: "#FFFFFF"
        popover: "#FFFFFF"
        sidebar: "#FFFFFF"
        border: "#E5E7EB"
        input: "#E5E7EB"
      dark:
        background: "#121217"
        card: "#1F1F23"
        popover: "#1F1F23"
        sidebar: "#1F1F23"
        border: "#34343A"
        input: "#34343A"
    text:
      light:
        primary: "#000504"
        secondary: "#999B9B"
        muted: "#6B7280"
      dark:
        primary: "#F2F2F2"
        secondary: "#999B9B"
        muted: "#A3A3A3"
    focus:
      ringLight: "#111827"
      ringDark: "#6140E1"
      aiInputFocus: "#9333EA"

  typography:
    families:
      primary: "DM Sans, Roboto Flex, -apple-system, BlinkMacSystemFont, Segoe UI, sans-serif"
      mono: "IBM Plex Mono, SFMono-Regular, Menlo, Monaco, Consolas, monospace"
    weight:
      regular: 400
      medium: 500
      semibold: 600
      bold: 700
    scale:
      h1:
        size: "30px"
        lineHeight: "38px"
        weight: 700
      h2:
        size: "24px"
        lineHeight: "32px"
        weight: 600
      h3:
        size: "20px"
        lineHeight: "28px"
        weight: 600
      h4:
        size: "18px"
        lineHeight: "26px"
        weight: 600
      body:
        size: "14px"
        lineHeight: "22px"
        weight: 400
      small:
        size: "12px"
        lineHeight: "18px"
        weight: 400
      caption:
        size: "11px"
        lineHeight: "16px"
        weight: 400
    letterSpacing:
      normal: "0em"

  spacing:
    baseUnit: 4
    compactUnit: 4.48
    scale:
      1: "4px"
      2: "8px"
      3: "12px"
      4: "16px"
      5: "20px"
      6: "24px"
      8: "32px"
      10: "40px"
      12: "48px"
      16: "64px"
    container:
      paddingInline: "32px"
      maxWidth: "1400px"

  radius:
    base: "10.4px"
    sm: "6.4px"
    md: "8.4px"
    lg: "10.4px"
    xl: "16px"
    pill: "9999px"

  shadow:
    light:
      2xs: "0.5px 1px 5.5px 0px rgba(0, 0, 0, 0.07)"
      xs: "0.5px 1px 5.5px 0px rgba(0, 0, 0, 0.07)"
      sm: "0.5px 1px 5.5px 0px rgba(0, 0, 0, 0.14), 0.5px 1px 2px -1px rgba(0, 0, 0, 0.14)"
      md: "0.5px 1px 5.5px 0px rgba(0, 0, 0, 0.14), 0.5px 2px 4px -1px rgba(0, 0, 0, 0.14)"
      lg: "0.5px 1px 5.5px 0px rgba(0, 0, 0, 0.14), 0.5px 4px 6px -1px rgba(0, 0, 0, 0.14)"
      xl: "0.5px 1px 5.5px 0px rgba(0, 0, 0, 0.14), 0.5px 8px 10px -1px rgba(0, 0, 0, 0.14)"
      2xl: "0.5px 1px 5.5px 0px rgba(0, 0, 0, 0.35)"
    dark:
      sm: "0 1px 3px 0 rgba(0, 0, 0, 0.40), 0 1px 2px -1px rgba(0, 0, 0, 0.40)"
      md: "0 4px 6px -1px rgba(0, 0, 0, 0.40), 0 2px 4px -2px rgba(0, 0, 0, 0.40)"
      lg: "0 10px 15px -3px rgba(0, 0, 0, 0.40), 0 4px 6px -4px rgba(0, 0, 0, 0.40)"
      xl: "0 20px 25px -5px rgba(0, 0, 0, 0.40), 0 8px 10px -6px rgba(0, 0, 0, 0.40)"

  motion:
    durations:
      fast: "120ms"
      normal: "200ms"
      moderate: "300ms"
      slow: "500ms"
      shimmer: "2000ms"
    easing:
      standard: "ease"
      emphasized: "cubic-bezier(0.2, 0.0, 0, 1.0)"
      inOut: "ease-in-out"
      out: "ease-out"
    patterns:
      accordionOpen: "height 200ms ease-out"
      accordionClose: "height 200ms ease-out"
      shimmerSweep: "translateX(-100%) -> translateX(100%) over 2000ms infinite"

  breakpoints:
    xs: "0px"
    sm: "600px"
    md: "960px"
    lg: "1280px"
    xl: "1920px"
contentMax: "1400px"

---

# Design Intent

## Visual Atmosphere

ManagEaze should feel structured, policy-heavy, and trustworthy without looking cold. The visual language is clean enterprise with a purple command accent, generous whitespace, and restrained elevation. Surfaces stay mostly neutral so status colors and workflow actions are easy to scan.

## Color Philosophy

The interface is anchored by deep neutrals and a vibrant violet primary. Success and warning states are intentionally high-contrast for governance workflows where missed cues create risk. Sidebars and selected states use lighter purple tints to preserve continuity without creating visual noise.

## Typography Character

Body text is compact and practical (14px default), tuned for dense tables, policy metadata, and side panels. Headings are semibold to bold with short line heights for hierarchy clarity. Monospace is reserved for technical or machine-like text fragments.

## Layout Principles

- Keep primary content in card-like surfaces with clear section boundaries.
- Prefer predictable vertical rhythm and 8/16/24 spacing clusters.
- Use the left rail as the operational anchor and avoid overloading top navigation.
- Keep reading widths controlled in long-form policy content.

## Component Styling Rules

- **Buttons:** solid primary for main actions; subtle neutrals for secondary actions; destructive actions in warning-red family.
- **Cards and panels:** rounded corners with soft layered shadow; avoid hard outlines unless showing focus/error.
- **Inputs:** neutral border, clear focus ring, no noisy glow; preserve compact density.
- **Status chips/tags:** color-coded, concise labels, consistent shape and padding.

## Interaction Behavior

- Motion should be functional and quick, mostly in 120-300ms ranges.
- Expand/collapse transitions are smooth and understated.
- Loading shimmer should indicate progress without distraction.
- Focus states must be explicit across keyboard and touch workflows.

## Accessibility and Readability

- Maintain strong text-to-surface contrast in both light and dark themes.
- Do not rely on color alone for state communication; pair with iconography or labels.
- Preserve legible line-height for policy paragraphs and comments.
- Support RTL content gracefully in rich text and comment views.

## Responsive Adaptation Guidance

On mobile and narrow web widths, preserve hierarchy over parity: keep policy context visible, move secondary actions into sheets or segmented panels, and make comments a deliberate subflow (bottom sheet or dedicated route) rather than dense side-by-side desktop composition.

## Expo React Native Web Variant

Use this variant when generating screens/components specifically for Expo React Native Web. Token names are optimized for direct theme object usage (e.g., `theme.colors.bg`, `theme.spacing.md`, `theme.radius.lg`).

```yaml
expoRnwVariant:
  themeObject:
    colors:
      bg: "#FAFAFA"
      bgDark: "#121217"
      surface: "#FFFFFF"
      surfaceDark: "#1F1F23"
      text: "#000504"
      textDark: "#F2F2F2"
      textMuted: "#999B9B"
      border: "#E5E7EB"
      borderDark: "#34343A"
      primary: "#644AE4"
      primaryPressed: "#4523C8"
      primarySoft: "#C7C0FF"
      success: "#61FF00"
      warning: "#FF271A"
      info: "#339DFF"
      focus: "#9333EA"
      overlay: "rgba(0, 5, 4, 0.56)"

    typography:
      fontFamilySans: "DM Sans"
      fontFamilyMono: "IBM Plex Mono"
      size:
        xs: 11
        sm: 12
        md: 14
        lg: 18
        xl: 24
        xxl: 30
      lineHeight:
        xs: 16
        sm: 18
        md: 22
        lg: 26
        xl: 32
        xxl: 38
      weight:
        regular: "400"
        medium: "500"
        semibold: "600"
        bold: "700"

    spacing:
      xxs: 4
      xs: 8
      sm: 12
      md: 16
      lg: 24
      xl: 32
      xxl: 48
      screenPad: 16
      sectionGap: 24

    radius:
      sm: 6
      md: 8
      lg: 10
      xl: 16
      pill: 999

    shadow:
      card:
        shadowColor: "#000000"
        shadowOpacity: 0.14
        shadowRadius: 5.5
        shadowOffset:
          width: 0.5
          height: 1
        elevation: 3
      modal:
        shadowColor: "#000000"
        shadowOpacity: 0.35
        shadowRadius: 10
        shadowOffset:
          width: 0.5
          height: 8
        elevation: 8

    motion:
      fastMs: 120
      normalMs: 200
      moderateMs: 300
      slowMs: 500
      shimmerMs: 2000

    breakpoints:
      phone: 0
      tablet: 768
      desktop: 1280
      wide: 1440

  componentGuidance:
    button:
      primary:
        bg: "colors.primary"
        text: "#FFFFFF"
        radius: "radius.md"
        minHeight: 44
      secondary:
        bg: "colors.surface"
        text: "colors.text"
        borderColor: "colors.border"
        borderWidth: 1
    card:
      bg: "colors.surface"
      radius: "radius.lg"
      padding: "spacing.md"
      shadow: "shadow.card"
    input:
      bg: "colors.surface"
      text: "colors.text"
      borderColor: "colors.border"
      radius: "radius.md"
      minHeight: 44
      focusRingColor: "colors.focus"
    bottomSheet:
      bg: "colors.surface"
      radiusTopLeft: "radius.xl"
      radiusTopRight: "radius.xl"
      dragHandleColor: "colors.textMuted"
      overlayColor: "colors.overlay"

  screenPatterns:
    loginSignup:
      layout: "Centered form card on web; full-height stacked form on mobile."
      maxWidth: 420
    policyLibrary:
      layout: "Single-column list on mobile, two-pane support on tablet+."
      itemDensity: "compact"
    policyDetail:
      layout: "Header + metadata + content blocks; comments entry via CTA."
    comments:
      entryMode: "Bottom sheet on phone, side panel on tablet/web."
      composerSticky: true
      threadOrder: "newest-last"
```

### Expo RNW Notes

- Prefer RN primitives (`View`, `Text`, `Pressable`, `TextInput`, `FlatList`) and map these tokens into a single `theme.ts`.
- Keep spacing and font sizing numeric for native compatibility.
- Use bottom-sheet comments on mobile as the default interaction model for policy detail.
- Keep API latency and offline behavior transparent with subtle stale-data labels, not blocking modals.

