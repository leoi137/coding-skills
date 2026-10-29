# Profile: Pearl

Owner decisions and pointers. Re-derive every product fact from the code on each job.

## Entity
- Pearl Tech Inc., Delaware corporation, 701 Brazos St, Austin, Texas. Support: pearl@pearltech.xyz.
- Single source in the waitlist repo: `lib/companyInfo.ts` (`getCompanyName`, `getCompanyAddress`, `getCompanyEmail`, `COMPANY_INFO.jurisdiction = "Delaware"`).

## Owner decisions
- Governing law: Delaware or Texas (choose deliberately; keep consistent across all four documents). Texas TDPSA applies (no volume threshold; Austin HQ).
- Disputes: arbitration + class waiver with 30-day opt-out and small-claims carve-out.
- Minimum age 18; United States only.
- Product posture: a **personalized financial coaching, education and organization tool** — never an adviser, wealth manager or "CFO" without the colloquial-reference disclaimer. Load `references/modules/investment-adjacent.md` and hand every finished draft to `pre-sec-ria-review`.

## Canonical product statement
`Pearl/lib/ui/widgets/legal_disclosure_content.dart` (live iOS app onboarding disclosure). Every document's product description conforms to it.

## Repo
- Waitlist site: `Pearl-Waitlist/pearl_waitlist` — legal pages are typed `*Content.ts` modules; shapes differ per document. Read `profiles/pearl-repo.md` before editing any of them.
- App: `Pearl/` (Flutter). If the app embeds its own legal copies rather than linking the hosted pages, flag that they need a parallel update.
- Build: `npm run build` or `npx tsc --noEmit`. Stop at "ready to build/deploy"; the owner publishes.

## Modules that usually apply
financial-data (Plaid account linking), investment-adjacent, ai-features (OpenAI and Anthropic receive portions of financial data), subscriptions (App Store via RevenueCat; web via Stripe), mobile-apps (iOS), communications (daily push + email).

## Last audit (2026-05) — leads to re-verify, not facts
- iOS app live and paid: $14.99/mo or $119.99/yr, 7-day trial on yearly only.
- App is read-only on money ("you take every action yourself"); no money movement.
- Waitlist Terms/Privacy described Pearl as an "AI Wealth Manager… that automates your finances" — hold-out language contradicting the disclosure; privacy described data flows as "read-only someday" while the app collects today.
- Cookie Policy shape unconfirmed — read `cookies/cookiesContent.ts` before editing.
