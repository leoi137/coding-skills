# Repository Integration — the `*Content.ts` data-shape contract

In the Pearl waitlist app (`Pearl-Waitlist/pearl_waitlist`), legal pages are **typed data modules** consumed by React Server Component renderers. Each document is a pair:

```
app/<doc>/<doc>Content.ts   ← the content (what you edit)
app/<doc>/page.tsx          ← the renderer (read it; rarely edit it)
```

Documents: `terms/`, `privacy/`, `cookies/`, `disclosure/`. **The shapes are NOT identical across documents.** Always open both the `Content.ts` and the `page.tsx` for the specific document before editing — the renderer hard-references the module's exported names and field structure, so an out-of-shape edit either fails to typecheck or silently fails to render.

Golden rules:
1. Match the existing exported shape exactly. Don't rename exports or change `TERMS_INTRO`/`PRIVACY_INTRO` field names — `page.tsx` references them individually.
2. Use the `() => string` **function form** for any `content` that interpolates a `companyInfo` helper; use a plain string otherwise. Both are valid (`string | (() => string)`).
3. The Table of Contents and `CONTACT_INFO` derive automatically — never hand-maintain the TOC.
4. **Bump `*_METADATA.lastUpdated`** to the current date on every substantive change.
5. Multi-paragraph string content uses `\n\n`; the renderers handle line breaks (terms' default branch uses `whitespace-pre-line`).

---

## The shared `companyInfo` helpers (`lib/companyInfo.ts`)

```ts
import {
  getCompanyName,     // () => "Pearl Tech Inc."
  getCompanyAddress,  // () => "701 Brazos St, Austin, Texas USA"
  getCompanyEmail,    // () => "pearl@pearltech.xyz"
  getCompanyEmailLink,// () => "mailto:pearl@pearltech.xyz"
  COMPANY_INFO,       // { name, address, email, website: "https://joinpearlai.com", jurisdiction: "Delaware" }
  getCurrentYear, getCopyrightText,
} from "@/lib/companyInfo";
```

Always reference the company via these helpers, never hardcode "Pearl Tech Inc." or the address. If a fact changes, it changes in one place. Note the **two relevant jurisdictions**: incorporation = Delaware (`COMPANY_INFO.jurisdiction`), HQ = Austin, Texas (in the address). Governing-law and Texas-TDPSA drafting choices flow from these.

---

## Terms shape (`terms/termsContent.ts`)

```ts
export const TERMS_METADATA = { title: string, lastUpdated: string };

export const TERMS_INTRO = {
  agreementHeading: string,
  companyIntro: () => string,
  servicesDescription: () => string,
  productDescription: string,        // ← the product description; fix hold-out language HERE
  contactInfo: () => string,
  legalAgreement: () => string,
  changeNotification: () => string,
  ageRequirement: string,
  printRecommendation: string,
};
// NOTE: page.tsx renders each TERMS_INTRO field individually. To add/remove an
// intro field you must also edit terms/page.tsx. Changing the *text* of an existing
// field is safe and needs no page.tsx change.

export interface TermsSection {
  id: string;                        // "section1", "section2", ... (used as anchor)
  title: string;                     // "1. OUR SERVICES"
  content: string | (() => string);
  subsections?: { [heading: string]: string | (() => string) };  // ← OBJECT MAP
  listItems?: string[];
  specialFormatting?: "bullet-list" | "contact-info" | "subsections" | "payment-methods";
}

export const TERMS_SECTIONS: { [key: string]: TermsSection } = { section1: {...}, ... };
export const TERMS_TABLE_OF_CONTENTS = Object.values(TERMS_SECTIONS).map(s => ({ id: s.id, title: s.title }));
export const CONTACT_INFO = { companyName: () => ..., address: () => ..., email: () => ..., website: () => ... };
```

- **`subsections` is an OBJECT** `{ "Heading": value }`. The renderer iterates entries; use `specialFormatting: "subsections"`.
- `specialFormatting: "bullet-list"` renders `listItems` as a `<ul>` after `content`.
- `specialFormatting: "payment-methods"` renders `listItems` as accepted payment methods.
- `specialFormatting: "contact-info"` renders the `CONTACT_INFO` block.
- Default (no `specialFormatting`): `content` rendered with `whitespace-pre-line` (so `\n\n` = paragraph breaks).

---

## Privacy shape (`privacy/privacyContent.ts`) — different from Terms

```ts
export const PRIVACY_METADATA = { title: string, lastUpdated: string };

export const PRIVACY_INTRO = {
  description: () => string,
  contactLine: () => string,
  glbaNotice: string,    // ← rendered in a dedicated highlighted box by page.tsx
};

export interface PrivacySection {
  id: string;
  title: string;
  content?: string | (() => string);
  subsections?: Array<{ title: string; content: string | (() => string); listItems?: string[] }>; // ← ARRAY of objects
  listItems?: string[];
  tableData?: { headers: string[]; rows: string[][] };
  specialFormatting?: "table" | "contact-info" | "note-box";
}

export const PRIVACY_SECTIONS: { [key: string]: PrivacySection } = { section1: {...}, ... };
export const PRIVACY_TABLE_OF_CONTENTS = Object.values(PRIVACY_SECTIONS).map(s => ({ id: s.id, title: s.title }));

export const GLBA_NOTICE = {   // ← rendered as a model-notice block at the bottom of the page
  title: string, facts: () => string, why: string, how: string, toLimit: () => string, questions: () => string,
};
export const CONTACT_INFO = { companyName, address, email, website };  // same shape as Terms
```

- **`subsections` is an ARRAY** of `{ title, content, listItems? }` — opposite of Terms. Do not use an object map here.
- `tableData` renders an HTML table (used for the retention table) — use `specialFormatting: "table"`.
- `specialFormatting: "contact-info"` renders the `CONTACT_INFO` block.
- **`specialFormatting: "note-box"` is NOT specially handled by the current `privacy/page.tsx`** — a section marked `note-box` renders via the normal `content` paragraph branch. So `note-box` is presently a no-op label. If you want a visually distinct callout box, either (a) add a `note-box` branch to `privacy/page.tsx`, or (b) just rely on the normal paragraph. Don't assume a box appears.
- `PRIVACY_INTRO.glbaNotice` and the whole `GLBA_NOTICE` object are **fixed structural elements** the page renders in special positions. Keep both present and populated.

---

## Disclosure shape (`disclosure/disclosureContent.ts`)

```ts
export const DISCLOSURE_METADATA = { title, subtitle, lastUpdated };
export const DISCLOSURE_INTRO = { description: () => string, warning: string };
export interface DisclosureSection { id; title; content: string | (() => string); listItems?: string[]; specialFormatting?: "contact-info" | "warning-box"; }
export const DISCLOSURE_SECTIONS = { ... };
export const DISCLOSURE_TABLE_OF_CONTENTS = Object.values(...).map(...);
export const DISCLOSURE_WARNINGS = { mainWarning, waitlistNotice, investmentRisk, noAdvice };
```

This is the document `pre-sec-ria-review` produced; it's the canonical securities-posture reference. The Terms/Privacy product description must agree with it.

## Cookie Policy (`cookies/cookiesContent.ts`)

Read `cookies/cookiesContent.ts` and `cookies/page.tsx` before editing — confirm its exact exported shape (it follows the same family pattern but verify field names and `specialFormatting` enum). The Cookie Policy must stay consistent with the Privacy Policy's §"Cookies/SDKs/Tracking" and GPC/DNT posture.

---

## After editing

The change should typecheck and build:

```bash
cd Pearl-Waitlist/pearl_waitlist && npm run build   # or: npx tsc --noEmit
```

If you can't run it in this session, say so and tell the user to run it. Per the user's deploy hand-off preference, **make the code changes and stop at "ready to build/deploy" — don't deploy.** A static export lands in `out/`; the user controls publishing.

## Cross-repo note

The Flutter app (`Pearl/`) may have its own terms/privacy surfaces shown in-app or linked. The user scoped this work to the **waitlist** `/terms` and `/privacy`. If the in-app legal links point to the same hosted pages, upgrading the waitlist pages covers both; if the app embeds its own copies, flag that they need a parallel update — don't silently leave them inconsistent.
