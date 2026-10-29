# Module: Investment-adjacent products — hard constraints inherited from `pre-sec-ria-review`

**Load when** the product discusses investing, portfolios, securities, retirement allocation, or describes itself with adviser-like words (advisor, wealth manager, CFO, planner), and the company is not a registered investment adviser. For these products, finish every job by handing the draft to `pre-sec-ria-review`. For any other product, this module and that hand-off don't apply.

The text below was written for Pearl, the first such product; Pearl's facts now live in `profiles/pearl.md`. For a different investment-adjacent product, apply the same rules with that product's canonical disclosure in place of Pearl's.

This skill drafts. The sibling skill `pre-sec-ria-review` adjudicates the securities line. You do **not** re-derive that line — you treat its conclusions as **hard drafting constraints** and you hand finished drafts back to it for sign-off. This file is the operating contract between the two skills.

---

## Canonical source of truth — read this before describing the product

The authoritative statement of what Pearl is and is not lives in the **live iOS app's onboarding disclosure**:

> `Pearl/lib/ui/widgets/legal_disclosure_content.dart`

This is the gold-standard, compliance-reviewed product description. **Conform every other document's product description to it.** It establishes the true product:

- Pearl is a **"personalized financial coaching, education, and organization tool"** — not a wealth manager, not an adviser.
- It serves the **United States** and, with permission, **reads bank/transaction/balance/goal data via Plaid**, runs it through **third-party AI (OpenAI, Anthropic)**, and sends **daily/near-daily notifications** referencing the user's finances.
- It **never** recommends specific securities, tells the user to buy/sell/hold/rebalance/allocate, suggests portfolio composition, moves money, or acts as a fiduciary. The user takes every action themselves on their own accounts.

When any other document disagrees with this disclosure on the coaching framing, the disclosure wins and the other document gets rewritten to match.

## The posture you are drafting into — "pre-registration" ≠ "pre-launch"

This is the conceptual trap. There are two independent axes:

- **Product axis: the app is LIVE.** Real users, real money ($14.99/mo or $119.99/yr — 7-day trial on yearly only; iOS via App Store/RevenueCat, web via Stripe), real financial-data collection. Privacy and Terms must describe present-tense data flows.
- **Adviser axis: the company is PRE-REGISTRATION.** It has deliberately stayed on the coaching side of the line and is not (yet) a registered investment adviser.

Do not let "pre-registration" leak into "pre-launch" framing. The waitlist *site's* Disclosure says "no live services / waitlist," which is correct **for the marketing site** but **wrong for the app** — the app is operating. Until RIA registration is effective, on the adviser axis:

- The company may **educate, coach, organize, contextualize, and behaviorally nudge** about the user's financial life.
- It may **not advise** on the value of securities or the advisability of buying/selling specific securities, and **may not hold itself out** as doing so (Advisers Act §202(a)(11) and the §208 hold-out prohibition).
- It does **not** make investment decisions for or with the user, does not manage assets, does not execute transactions.

Every legal document must be consistent with both axes: live product, coaching-only posture.

---

## The hold-out blocklist — never draft these (pre-registration)

These words/phrases in product descriptions, section text, or defined terms are **§208 hold-out evidence** even when surrounding sentences are compliant. Flag and rewrite every instance:

- "Investment adviser / advisor / advisory" (describing the company or product)
- "Wealth manager," "wealth management," "portfolio manager," "money manager"
- "CFO," "personal CFO," "AI CFO"
- "Investment counsel," "investment guidance," "financial advisor in your pocket"
- "We automate / manage / optimize your investments (or portfolio)"
- "We tell you what to buy/sell," "for-you picks," "recommended ETFs/funds," "model portfolios"
- Any phrasing implying the app makes or executes investment decisions for/with the user

**Permissible self-descriptions** (coaching side): money coach, financial coach, spending/savings coach, financial education, budgeting and goal-tracking tool, financial habit tracker, "automates your finances" **only** in the budgeting/cash-flow sense and **never** implying investment management. When in doubt, describe behavior and organization, not investment action.

### The colloquial-reference disclaimer technique (how "CFO" can survive)

There is a legitimate way to accommodate marketing language the founder likes (e.g., "your CFO in your phone") without conceding a hold-out: **expressly disclaim that the colloquialism creates any advisory relationship.** The live app disclosure does exactly this, and it is the model to reuse:

> "No description of Pearl — including any colloquial reference to a 'CFO,' 'advisor,' 'planner,' 'wealth manager,' or similar role — creates any advisory, fiduciary, brokerage, accounting, legal, or tax-professional relationship between you and Pearl Tech."

Two precise boundaries on this technique:
1. **In the legal documents**, this disclaimer is the right tool — include a version of it in the Terms' financial-disclaimer section and the Disclosure so the documents stay internally consistent even if users or marketing use the word "CFO."
2. **It does NOT license aggressive hold-out in *marketing*.** A disclaimer buried in the ToS does not cure a landing page headline that holds the company out as a "wealth manager who manages your money." Whether marketing copy itself crosses the §208 hold-out line is **`pre-sec-ria-review`'s** call — route the marketing use there. (This reconciles the user's saved "CFO in your phone" preference with the blocklist: the term can appear, *defused by an express disclaimer and kept on the coaching side* — it is not a free pass for advisory positioning.)

> **Live Pearl issue this addresses.** The waitlist Terms and Privacy currently describe Pearl as an "AI Wealth Manager / AI-powered wealth management platform that automates your finances." That is hold-out language, it contradicts both the app disclosure and the site Disclosure, and it is the opposite of the carefully-drafted "coaching, education, and organization tool" framing in `legal_disclosure_content.dart`. On any upgrade, **rewrite the product description to match the app disclosure** and make every document (app disclosure, site Disclosure, Terms, Privacy, Cookie) tell one story. This is mandatory, not optional.

---

## The live-vs-planned framing rule

The documents must not describe roadmap capabilities as if they are live, and must not describe live data flows as if they are hypothetical. Two failure modes, both real:

1. **Overstating capability** → securities hold-out + FTC §5. Saying the app "manages your money" or "manages your investments" when it only coaches/organizes is both a hold-out and a deceptive claim.
2. **Understating live data collection** → privacy under-disclosure. The app links bank accounts via **Plaid** and pulls transactions **today**, and sends portions of that data to OpenAI/Anthropic. The Privacy Policy must disclose all of this as a **present** practice, not a "future feature" or "read-only someday." (The current waitlist privacy's "read-only today" framing is wrong.)

**Establish the true live state as a threshold fact** (see SKILL.md Step 1) and write every tense to it. Use the just-in-time-notice mechanism for genuinely future features: "If and when we add [transfers / investment advisory services], we will register as required, provide just-in-time notice, obtain any required consents, and update these Terms and our Privacy Policy."

---

## Mandatory reps the documents must carry (pre-registration)

These must appear (in the Terms' financial/AI disclaimer section, the Disclosure, and reflected in the Privacy Policy's future-features section), and must stay mutually consistent:

- The company is **not currently registered** as an investment adviser or broker-dealer with the SEC or any state, and does not currently provide investment advisory or brokerage services.
- Content is **informational/educational**, not personalized investment, legal, tax, or accounting advice.
- **No fiduciary or advisory relationship** is created by using the app or joining the waitlist (pre-registration).
- Any AI-generated insights are **assistive**, based on algorithms/historical data, and **do not guarantee outcomes**; the user is responsible for their own financial decisions.
- Investing involves risk including loss of principal; past performance ≠ future results (wherever any illustrative figures appear).
- Any advisory features will be enabled **only after** required registration and subject to additional terms/disclosures at that time.

---

## What stays with `pre-sec-ria-review` (don't duplicate it here)

- Sentence-by-sentence review of **chat outputs and notifications** for the advice line.
- System-prompt guardrails for the LLM backend.
- Marketing/landing-page/deck/FAQ advice-line and anti-fraud review.
- The SHIP / SHIP WITH EDITS / DO NOT SHIP verdict.

You draft the legal documents; that skill clears the securities risk in them and in everything else.

---

## The hand-off

End every drafting job with an explicit hand-off:

> "Drafting complete. Run this through `pre-sec-ria-review` for the §202(a)(11) / §208 sign-off before publishing. I proactively neutralized the following hold-out items: [list]. Outstanding FACT-TO-VERIFY items: [list]."

If a drafting choice depends on a securities-line call you are unsure of (e.g., whether a particular "future advisory" hook reads as a present hold-out), say so and route it to `pre-sec-ria-review` rather than guessing.
