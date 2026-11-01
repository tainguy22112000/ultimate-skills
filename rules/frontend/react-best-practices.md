---
paths:
  - "**/*.{tsx,jsx}"
---

# React Rules (Strict – Production Quality)

> These rules apply to **all React / Next.js / TypeScript code** generated or modified by Claude.
> Goal: **clean, maintainable, testable, and production-ready React code**.

---

## 1. Core React Principles (MANDATORY)

### ❌ Forbidden

- Giant components (>200 lines)
- Mixing **business logic**, **UI**, and **side effects** in the same file
- Multiple responsibilities inside one component
- Inline utility functions inside components (unless trivial)
- Anonymous callbacks with complex logic
- Copy-pasted logic across components
- “God Contexts” with too many responsibilities
- Re-implementing utilities that already exist in the codebase

### ✅ Required

- Single Responsibility Principle (SRP)
- Composition over configuration
- Hooks for logic, components for rendering
- Predictable data flow (top-down)
- Stable references (`useCallback`, `useMemo`) where needed
- Explicit naming over clever naming

---

## 2. File & Folder Structure Rules

### 📁 Component Structure

```txt
ComponentName/
├── ComponentName.tsx          # public API only
├── ComponentName.context.tsx  # context + provider
├── ComponentName.hooks.ts     # logic hooks only
├── ComponentName.types.ts     # shared types
├── ComponentName.utils.ts     # pure helpers
├── components/
│   ├── SubComponentA.tsx
│   ├── SubComponentB.tsx
│   └── index.ts
```

### Rules

- **1 component = 1 file**
- Context **never** lives in the same file as UI
- Utilities **never** live inside React files
- Hooks **never** return JSX

---

## 3. Component Rules

### Every component MUST:

- Be under **150 lines**
- Have **one clear responsibility**
- Receive data via props or hooks only
- Never mutate external state directly

### ❌ Bad

```tsx
const Component = () => {
  const helper = () => { /* complex logic */ }
  useEffect(() => { /* business logic */ })
  return (...)
}
```

### ✅ Good

```tsx
export function Component() {
  const state = useComponentState()
  return <ComponentView {...state} />
}
```

---

## 4. Hooks Rules (VERY IMPORTANT)

### Custom Hooks MUST:

- Start with `use`
- Encapsulate **all logic**
- Never access DOM directly unless unavoidable
- Never depend on UI libraries
- Return a **minimal surface API**

### ❌ Bad

```ts
useEffect(() => {
  if (mode === 'gallery') {
    // core logic
  }
}, [mode])
```

### ✅ Good

```ts
const { items, addItems, removeItem } = useDropzoneItems()
```

---

## 5. Context Rules

### Context is ONLY allowed for:

- Cross-tree shared state
- Stable, well-defined APIs

### Context MUST NOT:

- Contain heavy logic
- Contain async code
- Replace local state unnecessarily

### Required Pattern

```tsx
export const ComponentContext = createContext<TState | null>(null)

export function useComponentContext() {
  const ctx = useContext(ComponentContext)
  if (!ctx) throw new Error('useComponentContext must be used within Provider')
  return ctx
}
```

---

## 6. State Management Rules

### ❌ Forbidden

- Duplicated state
- Derived state stored in `useState`
- Mutating arrays or objects
- Side effects inside render

### ✅ Required

- Derived values via `useMemo`
- State transitions via small functions
- Immutable updates only

---

## 7. Side Effects Rules (`useEffect`)

### `useEffect` is ONLY for:

- Syncing with external systems
- Subscriptions / listeners
- I/O side effects

### ❌ Forbidden

- Core logic
- State orchestration
- Business rules

### ✅ Pattern

```ts
useEffect(() => {
  syncFromProps(value)
}, [value])
```

---

## 8. Utilities Rules

### Utilities MUST:

- Be pure functions
- Live outside React
- Have no side effects
- Be reusable and testable

### ❌ Bad

```ts
const normalize = () => {
  setState(...)
}
```

### ✅ Good

```ts
export function normalizeItem(input: File | string): TItem
```

---

## 9. TypeScript Rules (Strict)

### Required

- Explicit return types for public functions
- No `any`
- No inline complex types
- Centralized types file

### Naming Conventions

- `I` prefix for interfaces
- `T` prefix for types / unions
- Enums avoided unless strictly necessary

---

## 10. Performance Rules

### Required

- Revoke `URL.createObjectURL` when no longer needed
- Stable drag-and-drop handlers
- Memoize expensive computations
- No inline object literals in JSX props

---

## 11. Accessibility Rules

### Required

- All buttons have accessible labels
- Keyboard support for drag-and-drop
- No click-only interactions

---

## 12. Claude-Specific Instructions (MANDATORY)

When generating or modifying code, Claude MUST:

1. **Refactor before adding features**
2. **Split files automatically**
3. **Extract hooks aggressively**
4. **Delete unused code**
5. **Ask before adding new dependencies**
6. **Prefer existing utilities**
7. **Never generate all-in-one components**
8. **Never generate files >150 lines**

---

## 13. Dropzone-Specific Rules

Claude MUST:

- Separate **Thumbnail** and **Gallery** modes into different components
- Extract logic into:

  - `useDropzoneItems`
  - `useDropzoneDnD`
  - `useDropzoneCrop`

- Never mix `react-dropzone` logic with UI rendering
- Treat `onChange` as the single source of truth

---

## 14. Mandatory Refactor Triggers

Claude MUST stop and refactor if:

- A file exceeds **200 lines**
- A component handles more than **2 responsibilities**
- A context exposes more than **5 fields**
- More than **2 useEffect hooks** exist in one component

---

## 15. Prompt Header (REQUIRED)

Add this to the top of every Claude prompt:

```txt
You MUST follow the React Rules.
If existing code violates the rules, refactor first.
Do not generate monolithic components.
Favor hooks, composition, and clarity.
```

---

✅ **These rules are mandatory and non-negotiable.**

If code violates these rules, Cursor must **refactor before proceeding**.
