# Adversarial Review

A drafter rereading their own work finds what they meant, not what they wrote. Before delivering, have the draft attacked by someone whose job is to make it fail. Where subagents are available, spawn one reviewer per applicable persona (or one reviewer playing all applicable personas for a small job). **Give reviewers the repo path, the draft and the live pages — not your fact ledger or your reasoning.** A reviewer handed your ledger will confirm it; a reviewer who reads the code will find what you missed.

Ask each reviewer to return findings as: quote from the draft or product → what's wrong → the evidence (file:line, statute, case) → the fix. Then you decide: fix, or reject with a reason. You make the final call; record rejected findings in the risk register if they're close calls.

## Personas (pick only those that apply)

**1. Plaintiff's class-action counsel.** Looks for: the Terms don't bind because the assent UI is weak or the user never saw them; the arbitration clause is unconscionable or has a fatal defect (no public-injunctive-relief carve-out in CA, one-sided venue, mass-arbitration provisions a court would strike); auto-renewal disclosures and consent records that don't meet the ARL; pixels, session replay or chat widgets that support a wiretap claim; SMS without proper consent; any statement in the privacy policy contradicted by the code.

**2. FTC / state-AG staff.** Looks for: deception (any claim not backed by the code: features, security controls, "never," "always," "automatic," "guaranteed"); unfairness (unreasonable security for the data held, especially SSNs and financial data); dark patterns in signup, consent and cancellation; marketing that contradicts the legal pages; AI capability claims; retroactive changes to data use without consent.

**3. The user's counterparty** (for two-sided products: the client, invitee or payer who never signed up). Asks: what did I agree to and when? Who do I complain to about abuse? Can I get my data deleted? Is this email a phishing attempt? Did anyone tell me my opening of the link was tracked?

**4. App-store reviewer** (mobile only). Account deletion in-app; privacy label vs policy vs SDKs; subscription disclosure screen; Apple-required EULA terms; age rating.

**5. The founder, six months from now.** Can we actually do every promise in this document with the current team and code (the obligations register)? Will the next feature we ship make any sentence false? Is anything here a promise we'd have to break to change pricing or vendors?

## Hard checks every reviewer runs
- Every factual sentence traces to evidence in the code or a confirmed owner statement.
- Every statute, rule or case named is real and correctly described (see the citation rule in SKILL.md).
- Every defined term is used consistently; no section references a section that doesn't exist.
- No surviving template clause describes something the product doesn't do.
