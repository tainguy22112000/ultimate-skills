---
paths:
  - "**/*.{ts,tsx}"
---

# TypeScript Rules (Strict – Safe, Explicit, Scalable)

> These rules apply to **all TypeScript code** generated or modified by Claude.
> Goal: **maximum type safety, clarity, maintainability, and long‑term scalability**.

---

## 1. Core TypeScript Philosophy (MANDATORY)

### Principles

- TypeScript exists to **prevent bugs**, not silence errors
- Types are part of the **API design**
- Prefer **explicitness over inference** at module boundaries

### ❌ Forbidden

- Using TypeScript as “typed JavaScript” only
- Ignoring type errors
- Overusing `any`
- Using types just to satisfy the compiler

---

## 2. Strict Compiler Settings (REQUIRED)

Claude MUST assume the following:

```json
{
  "strict": true,
  "noImplicitAny": true,
  "strictNullChecks": true,
  "noUncheckedIndexedAccess": true,
  "exactOptionalPropertyTypes": true
}
```

If code violates these settings, Claude MUST refactor.

---

## 3. `any`, `unknown`, and `never`

### ❌ Forbidden

```ts
const data: any = response
```

### ✅ Required

```ts
const data: unknown = response
```

### Rules

- `any` is **forbidden** unless explicitly approved
- `unknown` MUST be narrowed before use
- `never` MUST be used for exhaustive checks

```ts
function assertNever(x: never): never {
  throw new Error(`Unexpected value: ${x}`)
}
```

---

## 4. Type vs Interface Rules

### Preferred Usage

- `interface` → object shapes, public APIs
- `type` → unions, primitives, tuples

### Naming Conventions (STRICT)

- `IUser`, `IDropzoneItem` → interfaces
- `TStatus`, `TMode` → types / unions

### ❌ Bad

```ts
type User = { name: string }
```

### ✅ Good

```ts
interface IUser {
  name: string
}
```

---

## 5. Function Typing Rules

### Required

- Explicit return types for all public functions
- Generic constraints must be explicit

### ❌ Bad

```ts
export function parse(data) {
  return JSON.parse(data)
}
```

### ✅ Good

```ts
export function parse<T>(data: string): T {
  return JSON.parse(data) as T
}
```

---

## 6. Narrowing & Guards (CRITICAL)

### Use Type Guards

```ts
function isFile(value: unknown): value is File {
  return value instanceof File
}
```

### Avoid Type Assertions

❌ Bad

```ts
value as IUser
```

✅ Good

```ts
if (isUser(value)) {
  value.name
}
```

---

## 7. Union & Discriminated Union Rules

### Always Prefer Discriminated Unions

```ts
type TAction = { type: 'add'; payload: number } | { type: 'remove'; payload: string }
```

### Exhaustive Handling Required

```ts
switch (action.type) {
  case 'add':
    return
  case 'remove':
    return
  default:
    assertNever(action)
}
```

---

## 8. Optional Properties & Nullability

### ❌ Forbidden

```ts
user.name!
```

### ✅ Required

```ts
if (!user.name) return
```

Rules:

- Avoid non‑null assertions (`!`)
- Optional ≠ nullable
- Handle `undefined` explicitly

---

## 9. Generics Best Practices

### Rules

- Avoid over‑generic abstractions
- Limit generics to **1–2 parameters**
- Prefer concrete types at call sites

### ❌ Bad

```ts
function fn<T, U, V>(a: T, b: U): V {}
```

### ✅ Good

```ts
function mapItems<T>(items: T[]): T[] {}
```

---

## 10. Enums (Use Sparingly)

### ❌ Avoid

```ts
enum Status {
  Active,
  Inactive
}
```

### ✅ Prefer

```ts
type TStatus = 'active' | 'inactive'
```

Use `enum` only when interoperability requires it.

---

## 11. Type Inference Rules

### Let TS infer locally

```ts
const count = 0
```

### Be explicit at boundaries

```ts
export function getUser(): IUser {}
```

---

## 12. Utility Types Rules

### Allowed

- `Partial`
- `Pick`
- `Omit`
- `Readonly`

### ❌ Forbidden

- Deep utility chains
- Hard‑to‑read mapped types without documentation

---

## 13. Error Handling & Types

### Always Type Errors

```ts
catch (err: unknown) {
  if (err instanceof Error) {
    log(err.message)
  }
}
```

Never assume error shapes.

---

## 14. Code Size & Complexity Limits

Claude MUST stop and refactor if:

- A type definition exceeds **50 lines**
- A generic becomes hard to explain in one sentence
- A file mixes types and implementation logic

---

## 15. Cursor‑Specific Instructions (MANDATORY)

When generating or modifying TypeScript code, Claude MUST:

1. Fix types before adding logic
2. Refactor unsafe typings immediately
3. Prefer narrowing over assertions
4. Never introduce `any`
5. Keep types close to domain concepts

---

## 16. Mandatory Prompt Header

Add this to the top of every Claude prompt:

```txt
You MUST follow the TypeScript Rules.
Fix types first if violations exist.
Avoid any and unsafe assertions.
Prefer explicit, domain‑driven types.
```

---

✅ **These rules are strict and non‑negotiable.**

If code violates these rules, Cursor must **refactor before proceeding**.
