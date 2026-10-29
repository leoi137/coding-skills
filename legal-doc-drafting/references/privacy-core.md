# Privacy Policy — core framework (any product)

A privacy policy has two audiences with different needs: the user, who needs to understand what happens to their information, and the enforcer (FTC, state AGs, the California Privacy Protection Agency, plaintiffs' lawyers), who will compare each sentence against what the product actually does. Write for the first, survive the second. Sector rules (GLBA, COPPA, health data, EU law) are in `modules/`; this file is the base layer every product gets.

## 1. The legal sources that shape every US policy

- **FTC Act §5 and state UDAP laws.** Any material misstatement or omission about data practices is deceptive; unreasonable data practices can be unfair. This is why accuracy beats completeness: an omitted optional detail is rarely actionable, a false "we never" is.
- **CalOPPA** (Cal. Bus. & Prof. Code §22575). Any site or app collecting personally identifiable information from California residents must post a policy that lists categories collected and third parties shared with, explains how users can review/correct data (if offered), describes how the policy is changed, states the effective date, and says how the service responds to Do Not Track signals and whether third parties track across sites. No size threshold — this applies to every product.
- **State comprehensive privacy laws** (CCPA/CPRA and the other states; see `law-currency.md` for the current list). Each has applicability thresholds. Determine coverage:
  - **California (CCPA):** for-profit doing business in CA that meets one of: annual gross revenue above the inflation-adjusted threshold (~$26.6M for 2025; verify current figure), buys/sells/shares personal information of 100,000+ consumers or households, or derives 50%+ of revenue from selling or sharing personal information.
  - **Most other states:** controls or processes data of 100,000+ residents (some 35,000–50,000 for smaller states), or a lower number combined with revenue from selling data.
  - **Texas, Nebraska:** no volume threshold; apply to anyone doing business there unless an SBA-defined small business — but even small businesses must get consent before **selling sensitive data**.
  - **A small product is often below every threshold.** Then don't promise statutory rights as if they apply by law. The defensible, user-friendly move is to offer the core rights (access, correction, deletion, opt-out of any sale/targeted ads) **voluntarily to everyone**, say so, and avoid statute-specific machinery (designated toll-free numbers, statutory response clocks, authorized-agent procedures) you are not obliged to run and might fail to honor. Add the state-specific section when a threshold is crossed or when the product deliberately sells or shares data.
- **State breach-notification laws** (all 50 states). The policy needn't describe them, but the security section must not promise anything inconsistent with them.
- **Security duties with no size threshold.** FTC §5 unfairness for unreasonable security (FTC v. Wyndham, 3d Cir. 2015); NY SHIELD Act (GBL §899-bb, reasonable safeguards for NY residents' private information); Massachusetts 201 CMR 17.00 (written information security program for anyone holding MA residents' SSNs, financial account numbers or driver's license numbers). If the product stores SSNs or account numbers, these apply regardless of company size; the obligations register should include a written security program.
- **SSN-specific statutes.** Cal. Civ. Code §1798.85, Tex. Bus. & Com. Code §501.001, NY GBL §399-ddd restrict displaying, printing and transmitting SSNs; Conn. Gen. Stat. §42-471 requires a published SSN-protection policy for anyone collecting SSNs in the course of business. Best answer: don't collect SSNs. Next best: mask, encrypt, never render on documents sent to third parties, and publish the protection statement.
- **Wiretap and pixel litigation** (CIPA §631/§638.51 "pen register" claims, VPPA for video, session-replay suits). If the product embeds third-party pixels, chat widgets or session replay, disclose them specifically and consider consent; if it embeds none, say so plainly — it's a strong statement.

## 2. Determine the company's role for each data set

- **Business / controller** for data about its own users (account, usage, billing).
- **Service provider / processor** for data a business customer puts into the product about *their* customers (e.g., a contractor's client list in an invoicing tool) when the company processes it only to provide the service. Say so: "When a [user] adds information about their own clients, we process it on the [user]'s behalf and instructions." This narrows the company's direct obligations to those people and puts notice duties on the business user — but the company still owes those people a truthful notice about anything it does directly (emails it sends them, pages it shows them, tracking on those pages).
- **Independent third parties**: payment providers, sign-in providers and other services the user connects to under their own terms. Name them and point to their policies; don't describe their practices as yours.

## 3. Required sections (the base set)

1. **Who we are and scope** — legal entity, the services covered, the user types covered (including people without accounts).
2. **Information we collect**, by user type and source: provided by you, provided by others (e.g., a user who invites you), collected automatically, received from third parties. Name sensitive categories explicitly and state what you do *not* collect only when it's true and checked.
3. **How we use information** — specific purposes tied to the data map. Include security, fraud prevention, legal compliance, service emails, and product improvement only if true. If you use aggregated/de-identified data, commit to keeping it de-identified.
4. **How we share information** — service providers (by category with named key vendors, or a linked subprocessor list), other users (what the counterpart sees), legal process, business transfers (merger/acquisition), with consent. State clearly whether you **sell** personal information or **share** it for cross-context behavioral advertising (use the statutory words; they're defined terms in CA and elsewhere).
5. **AI processing** if any — see `modules/ai-features.md`.
6. **Cookies and similar technologies** — strictly necessary vs analytics vs advertising, with names. DNT and Global Privacy Control response. If you use only necessary cookies, no banner is required in the US; say what they are.
7. **Retention** — period or criteria per category (CPRA requires it where CCPA applies; good practice everywhere). Tie to real behavior: if deletion cascades, say what remains (backups for N days, invoices kept for tax/legal reasons).
8. **Security** — describe real controls in plain words (encryption in transit, access controls, row-level security, vendor certifications if true). Never "bank-level" or "military-grade". Never "100% secure".
9. **Your choices and rights** — how to access, correct, delete, export, unsubscribe; how requests are verified; response timing you can actually meet; appeal if a state law requires it.
10. **State-specific disclosures** — only when applicable (see §1); one section listing states, not one per state. Include CA "Shine the Light" (Civ. Code §1798.83) one-liner if you don't share for third parties' direct marketing.
11. **Children** — the age the product is for; COPPA posture (see `modules/children-and-teens.md` if the product could attract under-18s).
12. **International users** — where data is processed; either the international module or a plain statement that the service is intended for the US.
13. **Changes** — how users are notified of material changes; that new uses of existing data will be consented to where required.
14. **Contact** — an address that is monitored; for CCPA-covered businesses, at least two request methods.
15. **Effective / last updated date.**

## 4. Sensitive data

Opt-in consent is required for processing sensitive data under most state laws (CA is opt-out with a "Limit" right). Typical sensitive categories: SSN and other government IDs, account login with password, financial account number with access code, precise geolocation, racial/ethnic origin, religion, health, sex life/orientation, citizenship/immigration status, genetic and biometric data, data of known children, union membership, contents of private communications (CA). If the product collects any — even optionally (e.g., a free-text "tax ID" field that some users will fill with an SSN) — disclose it, minimize it, protect it (encrypt, mask on display), and consider whether you need it at all. Several states restrict printing or publicly displaying full SSNs; anything the product renders onto documents sent to third parties deserves a product-level fix, not just a disclosure.

## 5. Opt-out signals and incentives

- **Global Privacy Control:** California and a growing set of states require honoring GPC as an opt-out of sale/sharing/targeted advertising where those laws apply. If the product does no selling, sharing or targeted advertising, say so — there is nothing for GPC to opt out of, and the statement is easy to keep true.
- **Do Not Track:** CalOPPA requires saying how you respond. No standard exists; the honest answer is usually "we don't respond to DNT signals, but we don't track you across other sites."
- **Financial incentives:** if a referral, discount or rewards program trades value for personal data, CCPA requires a notice of financial incentive with a good-faith value estimate.

## 6. Notice at collection

Where CCPA applies, notice must be given at or before collection — for web, a link to the policy at the point of collection (signup, forms, the page a non-account user acts on). In practice: link the privacy policy on every collection surface, including pages for non-account users.

## 7. Delete list (generic template clauses)

Cut anything that describes a practice the product does not have: "we may collect information from social media," "we use web beacons in emails," "we may sell to data brokers," "we use your information to deliver targeted advertising," location tracking, contests/sweepstakes, SMS, biometric login, "Privacy Shield." Each one is either a false statement or a disclosure of a practice that triggers obligations you don't meet.
