# Module: Payments, invoicing and two-sided products

**Load when** users pay each other through or alongside the product (marketplaces, invoicing, booking, freelancing, tipping, creator payouts), or the product helps two users form an agreement with each other.

## 1. Classify the money flow — this decides the regulatory exposure

| Pattern | Who touches funds | Exposure |
|---|---|---|
| **Link-out** — product shows the payee's own PayPal.me / Venmo / bank details; payer pays outside the product | Nobody but the payer, the payee and their provider | Lowest. Not money transmission. The product is software. |
| **Payee's own merchant account** — Stripe Standard/Express connected accounts where funds settle to the payee's Stripe balance; the platform may take an application fee | The PSP | Low, if the platform never holds funds and the PSP is the regulated party. Follow the PSP's platform terms (they require you to pass through their services agreement and disclose their role). |
| **Platform collects, then pays out** — funds land in the company's account first | The company | Money transmission under state laws (licenses in ~49 states) unless an exemption applies: **agent of the payee** (payment to the agent discharges the payer's debt — must be in a written agreement with the payee and recognized in that state) or a licensed PSP model (Stripe Connect with destination/separate charges keeps funds with Stripe). Don't draft this pattern without the user confirming the structure. |
| **Escrow / holding funds until approval** | The company or a licensed escrow | Escrow licensing in some states (e.g., California Escrow Law). Never use the word "escrow" unless a licensed escrow agent is involved. |

Federal overlay: FinCEN treats a person that accepts and transmits funds as a money transmitter (an MSB) unless an exemption applies, such as the payment-processor exemption at 31 C.F.R. §1010.100(ff)(5)(ii)(B) (facilitating purchases of goods or services through clearing and settlement systems under an agreement with the seller). State agent-of-payee exemptions vary by state and are not universal; map them per state before relying on one.

If the platform ever **pulls** money from a payer on a schedule (card on file, ACH debits), the payer's authorization is a Regulation E §1005.10(b) recurring-debit authorization for consumer accounts (signed or similarly authenticated, with a copy to the payer) and, for ACH, a Nacha WEB-debit authorization. Whoever obtains it is exposed — draft it so the payee obtains it through a licensed processor, never so the company "charges on the payee's behalf," which is how a regulator finds the company is the transmitter.

**Drafting consequences:** describe the flow the code implements. For link-out products, state that payments happen directly between the users through the payee's own payment account; the company does not receive, hold, transmit, or refund funds, does not process payments, and cannot reverse them; confirmation of payment in the product is a record the payee makes, not a verification.

## 2. Platform-not-party

The users' deal is between them. The Terms should say:
- The company is not a party to agreements between users, does not guarantee performance or payment, is not an agent of either side, and doesn't verify identity, licenses, or quality unless it actually does.
- The company does not resolve disputes between users (or, if it offers a review/fix-request flow, that the flow is a communication tool and the decision rests with the users).
- Users are responsible for their own taxes, invoices' legal sufficiency, licenses, and compliance with laws applicable to their business.
- Release of claims against the company arising from user-to-user disputes (California users: include the Civil Code §1542 waiver language, which is otherwise not effective as to unknown claims).

## 3. Contracts formed between users on the platform

If the product drafts, presents or records agreements between users (proposals, SOWs, milestone plans):
- **Not legal advice / not a law firm.** Templates and AI-drafted terms are tools; the users decide their terms. Online document services have been sued for unauthorized practice (Janson v. LegalZoom, W.D. Mo. 2011 — the court found that software filling in legal documents from a user's answers, beyond selling blank forms, could be the unauthorized practice of law; the case settled), and the FTC's 2024–25 DoNotPay order bars claiming an AI is a substitute for a lawyer without evidence. Products that draft bespoke legal terms for users from their facts sit closer to the unauthorized-practice-of-law line; the mitigants are that the user supplies and approves every term, the product offers forms rather than individualized legal judgment, and the disclaimer is prominent where drafting happens (Texas Gov't Code §81.101(c) expressly excludes software products that clearly and conspicuously state they are not a substitute for an attorney; other states have no such safe harbor).
- **E-signature mechanics** (see `assent-and-enforceability.md`): show the full document before acceptance; record only what you say you record; give both parties a copy or a durable link.
- **Immutability claims** ("once issued, an invoice can't change") are representations — make sure the database actually enforces them before stating them.

## 4. Invoicing specifics

- The invoice is the payee's document issued through the product; the company is not the seller or the creditor.
- Tax identification numbers: if the product prints them on documents sent to third parties, warn users not to enter an SSN when they have an EIN, mask or omit by default, and disclose collection as sensitive data in the privacy policy. Several states (e.g., CA Civ. Code §1798.85) restrict publicly displaying or printing SSNs on materials sent by mail; sending an SSN on an invoice to a client is the user's choice, but the product shouldn't nudge it.
- Late fees, interest and collection language on invoices are the payee's terms; the product should not insert them by default.
- Payment confirmation by the payee or a "mark as paid" by the payer creates records, not verified facts.

## 5. Communications sent on a user's behalf

When the product emails a user's customer (invoices, reminders, notices): identify the sender honestly ("Jane Doe via Kept"), set reply-to to the user, include the company's physical address only where CAN-SPAM requires it (transactional/relationship emails are exempt from most CAN-SPAM requirements but must not be deceptive), and make the Terms put responsibility for recipient consent and lawful content on the user. Prohibit using the product to send invoices for work not agreed, harassment, or bulk unsolicited messages. See `communications.md`.

## 6. Payment-provider pass-through

- **Stripe Connect:** platforms must include Stripe's Connected Account Agreement acceptance language for connected accounts ("Payment processing services for [users] on [platform] are provided by Stripe and are subject to the Stripe Connected Account Agreement…") and obtain the user's agreement. Only include when Connect is live.
- **PayPal:** a link-out to PayPal.me requires no pass-through; say users are subject to PayPal's terms for their PayPal accounts. If the product integrates PayPal APIs (Commerce Platform, Payouts), follow PayPal's partner requirements.
- **Chargebacks and refunds** belong to the payee and their PSP; the company does not process them.

## 7. Prohibited businesses

PSPs prohibit certain business types (Stripe's Restricted Businesses list). If the product connects payees to a PSP, mirror the core prohibitions in acceptable use so the company can terminate accounts that would jeopardize its PSP relationship.
