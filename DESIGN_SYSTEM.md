# Design System Documentation

## 🎨 Brand Identity

### Primary Color Palette
- **Primary Blue**: `#3366E6` - Main brand color
- **Primary Blue Dark**: `#264DBF` - Darker variant
- **Primary Blue Light**: `#598CF2` - Lighter variant

### Accent Colors
- **Accent Teal**: `#33B3CC` - Secondary accent
- **Accent Purple**: `#9966E6` - Tertiary accent

### Semantic Colors
- **Success**: `#33B366` - Green for completed states
- **Warning**: `#FFB333` - Orange for timers/alerts
- **Error**: `#E64D4D` - Red for errors/deletions

---

## 📐 Spacing System

```swift
xs: 4pt   // Extra small
sm: 8pt   // Small
md: 12pt  // Medium
lg: 16pt  // Large
xl: 20pt  // Extra large
xxl: 24pt // 2x large
xxxl: 32pt // 3x large
```

**Usage**: Always use `BrandSpacing` constants instead of magic numbers.

---

## 🔤 Typography

All fonts use `.rounded` design for modern, friendly appearance:

- **LargeTitle**: 34pt, Bold
- **Title**: 28pt, Bold
- **Title2**: 22pt, Semibold
- **Headline**: 17pt, Semibold
- **Body**: 17pt, Regular
- **Subheadline**: 15pt, Regular
- **Caption**: 12pt, Regular

**Usage**: Use `BrandTypography` constants.

---

## 🎯 Component Styles

### Buttons

#### Primary Button
```swift
Button("Action") { }
    .buttonStyle(PrimaryButtonStyle())
```

Features:
- Gradient background (primary blue)
- White text
- Shadow effect
- Press animation

#### Secondary Button
```swift
Button("Action") { }
    .buttonStyle(SecondaryButtonStyle())
```

Features:
- Transparent background with border
- Blue text
- Subtle shadow

---

### Cards

```swift
VStack { }
    .brandCard()
```

Features:
- Rounded corners (12pt)
- Shadow effect
- Secondary background color
- Consistent padding

---

## 🎨 Gradients

### Primary Gradient
```swift
BrandColors.primaryGradient
```
- Colors: Primary Blue → Primary Blue Light
- Direction: Top-leading to bottom-trailing

### Accent Gradient
```swift
BrandColors.accentGradient
```
- Colors: Accent Teal → Accent Purple
- Direction: Leading to trailing

---

## 📱 Shadows

Three shadow levels:

```swift
BrandShadow.small   // Subtle elevation
BrandShadow.medium  // Standard cards
BrandShadow.large   // Prominent elements
```

---

## ✅ Applied Components

### ✅ Updated
- ProgressIndicator
- DashboardView
- ProgressCard
- KeywordButton
- KeywordSelectionButton
- ValuesRankingView
- PaymentView
- VocationDirectionCard
- TaskCard
- FlowDiaryView
- DeepeningExplorationView

### 🔄 Partially Updated
- ProfileView (needs more styling)
- TaskManagementView (needs card updates)
- SettingsView (needs design system)

---

## 🎯 Usage Guidelines

### Do's ✅
- Use `BrandColors` for all colors
- Use `BrandSpacing` for all spacing
- Use `BrandTypography` for all fonts
- Use `.brandCard()` modifier for cards
- Use button styles for consistency

### Don'ts ❌
- Don't use hardcoded colors (Color.blue, Color.gray)
- Don't use magic numbers for spacing
- Don't use system fonts directly
- Don't create custom shadows (use BrandShadow)

---

## 🔄 Migration Checklist

When updating a view:
- [ ] Replace all `Color.blue` → `BrandColors.primaryBlue`
- [ ] Replace all `Color.gray` → `BrandColors.tertiaryText`
- [ ] Replace all hardcoded spacing → `BrandSpacing.*`
- [ ] Replace all `.font(.headline)` → `BrandTypography.headline`
- [ ] Add `.brandCard()` to cards
- [ ] Add shadows using `BrandShadow.*`
- [ ] Use button styles for buttons

---

## 📊 Coverage

**Current**: ~70% of views updated  
**Target**: 100% coverage

---

## 🎨 Visual Examples

### Card Example
```swift
VStack {
    Text("Title")
        .font(BrandTypography.headline)
    Text("Content")
        .font(BrandTypography.body)
}
.brandCard()
.padding(.horizontal, BrandSpacing.lg)
```

### Button Example
```swift
Button("Action") {
    // action
}
.buttonStyle(PrimaryButtonStyle())
```

---

**Last Updated**: 2026-01-18
