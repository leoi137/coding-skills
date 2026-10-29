# Module: AI features

**Load when** the product sends user data to a model provider, shows model output to users, or markets "AI."

## Facts to establish (from code, then provider terms)
- Provider(s) and model(s); what is sent (prompts, records, files); whether outputs are stored; who sees outputs (only the user, or also their counterparties).
- Provider data terms: API inputs/outputs used for training? (Anthropic, OpenAI and Google API/commercial terms say no by default — confirm current terms for the provider in use and whether any opt-in was enabled.) Retention period at the provider; zero-data-retention only if contracted.
- On iOS, Apple requires explicit permission before personal data goes to a third-party AI (see `mobile-apps.md`); design the consent screen with the draft.
- Data minimization: if the payload sends more than the feature needs, put trimming it on the product-change list — it shrinks both the disclosure and the breach surface.
- Whether the company itself trains or fine-tunes on user data. If not, say so — it's a valuable, verifiable promise. If it might later, the FTC position is that you need affirmative consent for that new use; don't reserve it silently.

## Privacy policy
- Name the AI providers (or link a subprocessor list), what categories go to them, the purpose (to generate X for you), and the training/retention posture as contracted.
- Inference vs training distinction in plain words.
- Automated decisions: if model output determines anything significant about a person (credit, pricing, eligibility, hiring), the CCPA ADMT regulations and Colorado-style laws may apply — escalate; most drafting assistants don't make significant decisions.

## Terms
- Output may be inaccurate or incomplete; the user reviews and is responsible for what they send, sign or rely on; output isn't professional advice (legal, tax, financial, medical — pick the ones the product touches).
- The user owns their inputs and, as between the parties, the outputs, subject to the provider's terms; no guarantee outputs are unique or non-infringing.
- Acceptable use: don't use the AI to generate unlawful, deceptive or infringing content; incorporate the provider's usage policy by reference where its terms require it.
- Statements about what the AI does must match reality: "drafts a plan for you to review and edit," not "builds your legally binding contract."

## Marketing-claim check
The FTC's AI enforcement (Operation AI Comply, 2024 onward) targets inflated capability claims. If marketing says the AI "guarantees," "replaces a lawyer/accountant," or "ensures you get paid," flag it — the legal pages can't cure a deceptive ad.

## State AI laws (verify in `law-currency.md`)
- Companion-chatbot laws (CA SB 243, NY): apply to products designed for social/emotional companionship; a task assistant is usually outside, but if the product is conversational and could be used that way, check the definition.
- Bot disclosure: California's B.O.T. Act (Bus. & Prof. Code §17940) bars using a bot to deceive someone about its artificial identity to incentivize a sale or influence a vote. If AI writes messages sent to third parties under a user's name, the user is the sender; the product should not misrepresent.
- Utah's AI disclosure law: on-request disclosure for generative AI interactions in consumer transactions; prominent disclosure for regulated occupations.
