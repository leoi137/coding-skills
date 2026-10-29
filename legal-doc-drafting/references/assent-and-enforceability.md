# Assent and Enforceability — the contract lives in the UI

A perfectly drafted Terms of Service binds nobody if the product never obtained agreement to it. Courts decide enforceability from screenshots of the signup and checkout screens, not from the Terms text. So every Terms job includes an audit of the flows that are supposed to form the contract, and the deliverable includes UI/copy changes where those flows are weak.

## The doctrine in one page

Online contracts form when the user had **reasonably conspicuous notice** of the terms and **unambiguously manifested assent** to them (Meyer v. Uber, 2d Cir. 2017; Berman v. Freedom Financial Network, 9th Cir. 2022). Four patterns, strongest to weakest:

1. **Clickwrap** — an unchecked checkbox or a button that says "I agree to the Terms" next to linked terms. Reliably enforced.
2. **Sign-in wrap / sign-up wrap** — "By [doing X], you agree to the Terms" near the button that does X. Enforced only when the notice is conspicuous (size, contrast, proximity to the button, links that look like links) **and** the action the user takes is the one named in the notice. 9th Cir. struck such flows in Berman (tiny grey text, links not styled as links) and Chabolla v. ClassPass (2025: notice text spread across screens, button labelled "Continue" while the notice referenced a different action). Light grey 12px text under a card is the classic losing fact pattern.
3. **Browsewrap** — a footer link and nothing else. Generally unenforceable against consumers.
4. **Nothing** — users who never saw the terms (e.g., recipients of a shared link). Not bound.

**Practical specification (draft this into the product-change list):**
- The notice sits directly above or beside the action button, in body-size text with normal contrast, with "Terms" and "Privacy Policy" as visibly styled links.
- The notice names the exact button: if the button says "Continue with Google," the notice says "By selecting Continue with Google, you agree to the Terms…"; if there are several sign-in buttons, say "By continuing" only when every button reads "Continue…".
- Prefer an explicit checkbox for anything involving payment, auto-renewal, arbitration-heavy products, or a user base likely to sue (consumer, high volume).
- Record assent: user id, timestamp, terms version, the surface. A versioned record is what lets you prove which terms a user agreed to.
- Privacy policies are notices, not contracts — linking them is about notice at collection, not assent. Don't write "you agree to our Privacy Policy" as if consent to a privacy policy were needed or meaningful; say "see our Privacy Policy for how we handle your information."

## Users who never sign up

Invitees, payers, recipients of shared links, clients of your users. They are often the people most likely to have a dispute. Options, in order of preference:
1. A short notice on the page they act on, next to the action ("By paying / accepting / replying you agree to the Terms of Use"), with a link to terms written for them (a short "Recipient Terms" section or separate page). Their obligations should be modest: lawful use, no abuse, the platform is not a party to their deal, disclaimers, limitation of liability, dispute clause.
2. At minimum, a footer link to Terms and Privacy on every page they see. This gives them **privacy notice** (required regardless) even if it doesn't bind them contractually.
Never draft Terms that assume non-account users accepted them when the product never asked.

## Changes to the Terms

- Unilateral changes bind existing users only with notice and an opportunity to reject (stop using). Notify by email or in-product for material changes, state the effective date, and give a reasonable lead time (commonly 14–30 days) for adverse changes. Continued use after the effective date is the acceptance mechanism.
- Changes to the **arbitration clause** should not apply to disputes the company already knew about (courts treat retroactive changes as illusory); say so.
- Keep prior versions available (a changelog or archive URL) — it is the evidence trail. Posting revised terms on the site without notice doesn't bind existing users (Douglas v. U.S. District Court, 9th Cir. 2007); you need to show which version each user accepted, so the product should store `terms_version` and `accepted_at` per user. If it doesn't, put that on the product-change list.
- A change in how personal data is used (especially using existing data for a new purpose like AI training) needs affirmative consent, not a quiet policy update (FTC guidance, Feb 2024).

## Capacity and age

- State a minimum age that matches the product and app-store rating. 18+ for anything involving contracts with money, financial data, or adult content. 13+ is the floor below which COPPA applies; 13–17 users require attention to state minor-protection laws and should usually be excluded unless the product is built for them.
- A minor can disaffirm most contracts; an 18+ requirement is both a legal and a risk-reduction choice.

## Electronic records and signatures

- ESIGN (15 U.S.C. §7001) and UETA make electronic signatures and records valid. For **consumer** disclosures that a law requires "in writing," ESIGN §101(c) requires the consumer's affirmative consent to electronic delivery, after specific disclosures (right to paper, how to withdraw, hardware/software requirements). Most apps satisfy this with an e-delivery consent in the Terms plus assent at signup; products that deliver legally required notices (e.g., financial disclosures) should do the full §101(c) consent.
- When the product lets **two users sign a contract with each other** (proposals, SOWs, milestone plans), the product is the signing platform, not a party. Capture an audit trail (signer identity method, timestamp, IP, document hash), present the exact document before signature, and give both parties a copy. Only promise the audit-trail elements the product actually records.

## Enforceability boosters (drafting side)

- Mutuality, a small-claims carve-out, a 30-day arbitration opt-out, consumer-friendly venue and fee terms, and a clear severability rule do more for enforceability than aggressive language does.
- Avoid one-sided terms that invite unconscionability findings (e.g., company may sue in court but user must arbitrate; caps of $0; waiving non-waivable statutory rights).
- Keep the Terms readable; courts and regulators weigh whether a reasonable user could understand what they agreed to.
