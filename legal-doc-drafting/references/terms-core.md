# Terms of Service — core framework (any product)

The Terms have three jobs: (1) form a contract that binds (see `assent-and-enforceability.md` — most failures are in the UI), (2) allocate risk sensibly, and (3) describe the product's real commercial mechanics accurately. Generic templates handle (2) passably and get (1) and (3) wrong. Your value is in (1) and (3), and in a version of (2) that a judge would actually enforce.

## 1. Section set (base)

Order matters less than grouping. A tight, accurate 15–25 section document beats a 40-section template.

1. **Agreement and parties** — who the contract is with (legal entity), what it covers, who it binds (account holders; separately, any non-account users and the narrower terms that apply to them).
2. **What the service is — and is not.** A factual description and the roles. If users transact with each other, say the company is not a party to their transactions, not an agent, not an escrow, not a payment processor (if true), not a law firm/adviser (if the product touches those areas). This section prevents more disputes than the disclaimers do.
3. **Eligibility and accounts** — age, capacity, one person per account, accurate information, account security, business use representation if the product is for businesses.
4. **Fees, billing, renewal, cancellation, refunds** — only what is live. See `modules/subscriptions.md`. If there are no fees yet, say the service is free and that you'll give notice before charging; don't publish a price and billing mechanics that don't exist.
5. **User obligations and acceptable use** — trimmed to real abuse vectors of this product (e.g., sending invoices for work not agreed, spam through the product's email, uploading malware, scraping, impersonation, unlawful content).
6. **User content and licenses** — users keep ownership; grant the company a limited license to host, process and display content *only to operate and improve the service* (narrow it; broad "perpetual, irrevocable, worldwide, for any purpose" licenses are both a trust problem and a regulatory one for AI training). Feedback license.
7. **Company IP** — the service, marks, and a limited license to use it.
8. **Third-party services** — sign-in providers, payment providers, AI providers, integrations; their terms govern their part; the company isn't responsible for them.
9. **Product-specific sections** pulled from modules (payments/marketplace, AI, communications, mobile, user content, financial).
10. **Disclaimers** — AS IS / AS AVAILABLE, conspicuous; specific disclaimers for the product's real risks (AI output accuracy, no guarantee the other party pays, no professional advice).
11. **Limitation of liability** — exclusion of indirect damages; cap (commonly the greater of fees paid in the prior 12 months or a fixed sum like $100); carve-outs required by law; state-law savings sentence. Caps must be conspicuous.
12. **Indemnity** — user indemnifies for their content, their dealings with other users, their breach and their violations of law. For B2B products, consider mutual IP-infringement indemnity.
13. **Dispute resolution** — §2 below.
14. **Governing law** — §3 below.
15. **Suspension and termination** — for breach, risk, legal requirement; what happens to data after termination (export window, deletion timeline consistent with the privacy policy); survival.
16. **Changes to the service and to the Terms** — notice mechanics per `assent-and-enforceability.md`.
17. **Notices and electronic communications** — e-delivery consent (ESIGN).
18. **General** — entire agreement, severability, no waiver, assignment (company may assign in a merger; user may not), force majeure, no agency, headings, English controls, export/sanctions (one sentence), California Civil Code §1789.3 notice for CA consumers (the provider's name, street address and telephone number, plus the Department of Consumer Affairs Complaint Assistance Unit contact; an email-only contact doesn't satisfy it), and an OFAC/sanctions eligibility representation when the product lets users transact with people anywhere in the world.
19. **Contact.**

## 2. Arbitration and class waiver

The single most consequential section, and the one most often drafted to fail.

**Decide first whether to have one.** For a small product with few users, arbitration's main benefit (blocking class actions) must be weighed against mass-arbitration exposure (thousands of individual claims each triggering company-paid filing fees) and drafting risk. Defensible choices:
- **Arbitration + class waiver** (the default for consumer products with meaningful scale or regulatory class-action exposure — privacy pixels, auto-renewal, TCPA).
- **No arbitration; court with a jury waiver where enforceable and a class waiver** — class waivers outside arbitration are generally unenforceable, so this mostly buys venue and governing law. Reasonable for B2B-only products.

**If arbitrating, draft for enforceability:**
- Mutual obligation; FAA governs; delegation clause (arbitrator decides arbitrability) except that a court decides challenges to the class waiver and mass-arbitration provisions.
- A named provider and rules (AAA Consumer Rules / AAA mass-arbitration supplementary rules, or JAMS Streamlined + mass procedures). Don't use providers or protocols courts have rejected (Heckman v. Live Nation, 9th Cir. 2024, refused New Era ADR's mass protocol).
- Company pays consumer filing fees above what a court filing would cost; hearings remote or in the consumer's county.
- **Small-claims carve-out** for either party; **IP/injunctive carve-out** narrow and mutual.
- **Pre-dispute informal resolution**: written notice with specific contents, a 30–60 day window, individual telephone/video conference. Toll limitations periods during it.
- **30-day opt-out** for new users (strongest single enforceability booster).
- **Mass-filing provisions**: batching/bellwether procedures under the provider's mass rules; keep them neutral, not punitive.
- **Class and representative waiver**, with a clear severability rule: if the class waiver is unenforceable as to a claim, that claim proceeds in court (and is stayed pending arbitration of individual claims) — avoids a total poison pill.
- **Public injunctive relief (California):** McGill v. Citibank (Cal. 2017) — a waiver of the right to seek public injunctive relief in any forum is unenforceable. Carve public injunctive relief out to court after individual arbitration.
- Caps-lock jury-trial waiver acknowledgment; a plain-language summary at the top of the Terms pointing to this section.
- Changes to this section don't apply to known disputes; users may reject a material change within 30 days.
- California CCP §1281.97–.98: if the company is the drafting party, fees must be paid within 30 days of the due date or the consumer may withdraw to court and seek sanctions — make sure the business can operationally pay.

## 3. Governing law and venue

- Choose the law of the state of incorporation or HQ deliberately; keep it the same across all documents.
- Venue for consumers: arbitration in or remote from the consumer's county; court venue for non-arbitrable matters in the company's home county *except* small claims in the consumer's county. A clause forcing all consumers to litigate in Delaware Chancery or a distant county is an unconscionability flag.
- A shortened limitations period (e.g., one year) is unenforceable in some states and for some statutory claims; include it only with "to the extent permitted by law" and accept it may not bind everywhere.
- State consumer-protection laws generally apply regardless of the choice of law; don't draft as if they don't.

## 4. Limitation of liability and disclaimers — what survives

- Conspicuous formatting (caps or bold, visually set apart). UCC §2-316 conspicuousness is the source of the convention; courts apply it broadly.
- Savings clause: "Some jurisdictions do not allow…" plus New Jersey's TCCWNA concern — NJ courts have penalized Terms that fail to say which provisions don't apply in NJ; a neutral savings clause that the limitations apply only to the extent permitted by applicable law and do not limit non-waivable rights is the usual mitigation.
- Don't disclaim liability for the company's own gross negligence, fraud, or willful misconduct; many states won't enforce that and it reads as overreach.
- Don't disclaim duties the company affirmatively promises elsewhere (e.g., "we keep your data secure" + "we are not liable for any security breach" invites a deception claim).

## 5. Delete list

Shipping, returns, sweepstakes, user forums/reviews/"Contributions" (unless UGC exists), buying agents, social-media account linking, "Purchases and Payment" lists of card brands the product doesn't accept, "Mobile Application License" for a web-only product, DMCA designated-agent text unless the agent is actually registered with the Copyright Office, "Privacy Shield," "corrections" boilerplate about pricing errors for a product with no catalog. Every surviving clause should map to something the product does.
