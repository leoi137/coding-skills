# Fact Discovery — build the record before you draft

Every sentence in a privacy policy or terms that says what the product does is a representation the FTC and state AGs can enforce under "deceptive practices" law. Most published policies are wrong not because the drafter misread the law but because they described a product that doesn't exist: a template's product, last quarter's plan, or the roadmap. The cure is to build a factual record from the source of truth (the code and its configuration) before drafting a word, and to cite it.

**Source-of-truth order.** (1) Code, schema, config and infrastructure in the repo. (2) Vendor dashboards or contracts the user can confirm. (3) The user's statement. (4) The existing legal documents and marketing — these are *claims to test*, never evidence. When (4) contradicts (1), (1) wins and the contradiction goes to the top of your findings as a FALSE item.

**What counts as live.** Live means a user can reach it in production today. Code behind a disabled flag, a branch not yet merged, a price on the landing page with no billing code, and a "coming soon" button are not live. Unshipped work in the main checkout is not live either. If you can't tell whether something is deployed, say so and ask.

## The data map — what to find

Produce this table and cite `file:line` for every row. A row without evidence is a FACT-TO-VERIFY, not a fact.

| Who (user type) | Data element | Source (user, automatic, third party) | Where stored | Purpose | Shared with (vendor / other users) | Retention | Evidence |

Cover every **user type**, especially the ones without accounts: invitees, recipients of a shared link, clients of your users, people mentioned in user content. Non-account users are where both the contract (they never agreed to anything) and the privacy notice (they never saw one) usually fail.

## Where to look (adapt to the stack)

- **Dependencies:** `package.json`, `requirements.txt`, `pubspec.yaml`, `Podfile`, `build.gradle`, `go.mod`. Each SDK is a candidate vendor. Look especially for analytics (GA, PostHog, Mixpanel, Amplitude, Segment, Plausible), error tracking (Sentry, Bugsnag, Crashlytics), session replay (FullStory, LogRocket, Hotjar, Clarity — these capture keystrokes and are wiretap-litigation magnets), ads/pixels (Meta, TikTok, Google Ads, LinkedIn), auth (Supabase, Firebase, Auth0, Clerk), payments (Stripe, PayPal, RevenueCat, Paddle, Lemon Squeezy), email/SMS (Resend, SendGrid, Postmark, Twilio), AI (Anthropic, OpenAI, Google, Replicate), storage/CDN (S3, R2, Cloudflare, Vercel).
- **Environment variables and secrets config:** `.env.example`, `wrangler.jsonc`/`vercel.json`, edge-function secrets, CI config. Every external API key is a vendor that receives data.
- **Network calls:** grep for `fetch(`, SDK client constructors, and webhook handlers. The domains called are the vendor list.
- **Schema:** migrations / ORM models. Every column holding personal data belongs in the map. Flag sensitive categories (SSN or tax ID, government ID, precise location, health, biometrics, financial account numbers, children's data, contents of messages, login credentials).
- **Auth:** providers and scopes (Google OAuth scopes trigger Google's Limited Use policy and need specific disclosure). Magic-link email. Session cookies.
- **Client-side storage and tracking:** `document.cookie`, `localStorage`, `sessionStorage`, IndexedDB, third-party `<script>` tags, pixels, `navigator.sendBeacon`. A cookie banner question is answered here, not by assumption.
- **Logs:** hosting provider request logs (IP, user agent), application logs, view/open tracking (read receipts, `viewed_at`, email open pixels, link click tracking).
- **Vendor defaults that add tracking without code:** hosting/CDN dashboards that auto-inject analytics or bot-management cookies (e.g., Cloudflare Web Analytics, Vercel Analytics), email providers' open/click tracking (often on by default), auth providers' own logs (sign-in IP and user agent). The repo can't show these; list them as FACT-TO-VERIFY with the exact setting to check.
- **AI calls:** which model provider, what is sent — read the code that builds the request payload, not just the call site; context-stuffing often sends far more than the feature needs (e.g., a whole client list with addresses on every message), which is both a disclosure item and a data-minimization fix for the product-change list, whether outputs are stored, whether the provider's terms allow training on API data (most major API terms say no by default — confirm for the provider in use), zero-data-retention status, and whether AI output is shown to someone other than the user who triggered it.
- **Email and messaging:** who the sender is (your domain or the user's name), whether messages are sent on a user's behalf to third parties, marketing vs transactional, unsubscribe handling.
- **Money:** does any code hold, route, split, refund or escrow funds? Or does it only show a link or button that sends the payer to a payment provider in the payee's own account? This decides money-transmission exposure (see `modules/payments-and-marketplaces.md`).
- **Deletion and export:** is there an account-deletion path in the product, and what does it actually delete (cascades, storage objects, backups, vendor copies)? Mobile apps that support account creation must offer in-app deletion.
- **Assent surfaces:** the signup screen, checkout, any "accept" button for user-to-user agreements, and every page non-account users see. Record the exact button text and the exact notice text. See `assent-and-enforceability.md`.
- **Entity facts:** legal name, state of incorporation, address, support email. Usually in a site config file; confirm placeholders ("TODO", "Placeholders to find/replace before launch") with the user.

## Output of this step

1. The data map (above).
2. A vendor list: vendor → what it receives → role (processor/service provider, independent controller, or the user's own account at that vendor) → evidence.
3. A live-vs-planned list: every feature the existing documents or marketing mention, marked LIVE / PLANNED / NOT FOUND with evidence.
4. Assent inventory: each surface, the user type that sees it, the exact copy, and the control used.
5. Open facts: only the things the code cannot answer, phrased as specific questions.

Ask the user once, in a batch, for the open facts. Draft everything else from the record.
