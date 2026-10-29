# Module: Mobile apps (iOS / Android)

**Load when** there is a native app, or the documents will be linked from an app-store listing.

## Store-required terms
- **Apple:** either rely on Apple's standard Licensed Application EULA or include a custom EULA meeting Apple's minimum terms: the agreement is between the user and the company, not Apple; license limited to Apple-branded devices per Usage Rules; Apple has no maintenance/support obligation; warranty failures — user may notify Apple for a refund of the purchase price, otherwise no Apple warranty obligation; the company, not Apple, handles product claims (product liability, legal/regulatory non-conformance, consumer protection, privacy); IP infringement claims are the company's responsibility; user represents they're not in an embargoed country or on a prohibited list; third-party terms compliance; **Apple and its subsidiaries are third-party beneficiaries**. Put these in an "Apple-specific terms" section that applies only to the iOS app.
- **Google Play:** no mandatory third-party-beneficiary clause, but follow the Developer Distribution Agreement and policies; the privacy policy link is mandatory for apps handling personal or sensitive data.
- **In-app account deletion**: Apple (Guideline 5.1.1(v)) and Google Play require apps that allow account creation to let users initiate deletion in-app (Google also requires a web deletion link). The privacy policy must describe it the way it actually works.
- **Third-party AI consent (Apple Guideline 5.1.2(i), since Nov 2025 — verify current text):** apps must clearly disclose where personal data is shared with third parties, *including third-party AI*, and obtain explicit permission first. A privacy-policy sentence isn't enough; the app needs a consent screen before the first call, and a way to turn it off.
- **Sign in with Apple:** account deletion must revoke the user's Apple tokens via Apple's REST API; email to "Hide My Email" relay addresses only delivers from sending domains registered with Apple. Describe deletion the way it actually works.
- **Store privacy disclosures** (Apple privacy "nutrition labels," Google Data safety form) must match the privacy policy and SDK behavior; mismatches are a store-rejection and FTC risk. Include a check in the consistency pass.
- **Subscriptions** billed by the store: see `subscriptions.md` — cancellation and refunds go through the store.

- **Age rating vs Terms:** if the Terms set a minimum age above Apple's calculated rating, override the rating to match, or the app can be rejected.
- **Custom EULA contact details:** Apple's minimum terms require the developer's name, address, phone number and email — a phone number is mandatory.

## Age and app-store accountability laws (verify in `law-currency.md`)
TX (in effect), UT, LA (delayed) app-store accountability acts impose developer duties: assign age ratings per app and per in-app purchase, use the store's age signal and parental-consent status to enforce restrictions, notify stores of significant changes, and use age data only for those purposes. If the app is 18+, the Terms and store rating should say so consistently; if minors may use it, load `children-and-teens.md`.

## SDKs
Mobile SDKs (analytics, ads, attribution, crash reporting) collect device identifiers; ATT (App Tracking Transparency) prompts are required on iOS before tracking across apps. Disclose each SDK category; if no tracking, say so and don't show an ATT prompt.
