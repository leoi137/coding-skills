# Profile: Kept

Owner decisions and pointers. Re-derive every product fact from the code on each job.

## Entity
- Pearl Tech Inc. (Delaware corporation per `profiles/pearl.md`; HQ Austin, Texas — confirm). Brand "Kept", live at https://pearltech.xyz.
- Single source in the repo: `src/lib/site.ts` (`legalName`, `supportEmail`, `legalLastUpdated`, `monthlyPrice`). The file is marked "Placeholders to find/replace before launch" — confirm values with the owner.
- No street address or phone on the legal pages yet; needed for Cal. Civ. Code §1789.3.

## Owner decisions (to confirm — the current pages chose these, possibly by template default)
- Governing law: current Terms say **California** (`src/app/terms/page.tsx` §17). The company is Delaware/Texas; California law brings McGill public-injunctive-relief and CA consumer law to every user. Recommended: Texas or Delaware, with consumer-venue protections. **Ask.**
- Disputes: current Terms use arbitration with an informal-resolution step (§16). Users are businesses and sole proprietors; decide whether to keep arbitration or use courts with a class waiver dropped. **Ask.**
- Minimum age 18; US-first, but Clients may be anywhere (needs a sanctions line).

## Repo
- `~/Desktop/Resources/Kept` — Next.js on Cloudflare Workers, Supabase. Read `AGENTS.md` first: shared checkout (prefer a worktree), one dev server on localhost:3001, frontend ships only by merging to `main`, commits are plain imperative English with no AI attribution, and the docs map says what docs to update.
- Legal pages: `src/app/privacy/page.tsx`, `src/app/terms/page.tsx` — inline JSX rendered through `src/components/legal-page.tsx`; date from `site.legalLastUpdated`.
- Checks: `npm run lint`, `npx tsc --noEmit`.
- Business rules live in SQL (`supabase/migrations/`); the client-facing contract is `docs/client-page.md`; behavior docs are in `docs/`. Open gaps are in `BACKLOG.md` (e.g., KEPT-2 is the review-window mismatch in the Terms).

## User types and roles
- **Contractor** (account holder; business user). Kept is controller for their account data.
- **Client** (no account; acts through `/i/<token>` and emails). Kept processes Client data on the Contractor's behalf for the invoice, but directly controls what it does itself on the Client page (view tracking, logs) and in emails it sends.

## Modules that usually apply
- payments-and-marketplaces — the client pays the contractor via the contractor's PayPal.me; Kept never touches funds.
- ai-features — `supabase/functions/draft-plan`, `draft-proof` call Claude.
- communications — Kept emails Clients on Contractors' behalf (Resend).
- user-content — Contractors upload proof files Clients can view.
- subscriptions — only if billing code exists (none found at last audit).

## Last audit (2026-10-28) — leads to re-verify, not facts
- Legal pages and landing page describe features with no code: Stripe card/ACH and automatic payments, a $19.99/mo subscription, typed-name acceptance with IP and hash, a review window with deemed approval, contract generation (Terms §§3, 5, 6, 9; Privacy §2; `src/app/page.tsx` "charged automatically" copy and price).
- Client page `src/app/i/[token]/client-page.tsx` has no Terms/Privacy link; Terms intro claims to bind anyone who "accepts a plan or pays through the Services".
- Contractor assent is a sign-in wrap in small grey text below two buttons (`src/app/login/page.tsx:30-40`); no stored terms version.
- Free-text `profiles.tax_id` printed on every invoice PDF (`supabase/functions/_shared/invoice-pdf.ts:121`); Privacy invites SSNs as tax IDs.
- `invoices.viewed_at` view tracking not disclosed.
- Privacy lists PayPal/Stripe as service providers; Kept shares nothing with them under the link-out model.
- Privacy promises deletion within 30 days of request; no account-deletion path found, issued invoices can't be deleted, proof files aren't cleaned up (KEPT-8).
- Plan chat sends Anthropic the name, email and address of up to 200 clients with each message (`src/app/app/data.ts:120-127`, `supabase/functions/draft-plan`) — disclosure and minimization item.
- Vendor settings to check: Cloudflare Web Analytics auto-injection, Resend open/click tracking, prod Supabase region.
- Landing page, `layout.tsx` description and social-card alt text promise automatic charging, saved cards, a review window and a price.
- Open signup + emailing arbitrary addresses an invoice with a payment link = phishing vector; add abuse reporting to Client emails and pages.
