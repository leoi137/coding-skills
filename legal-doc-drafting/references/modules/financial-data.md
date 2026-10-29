# Module: Consumer financial data and money movement

**Load when** the product links bank/brokerage/card accounts, aggregates financial data, offers budgeting/financial insights, or moves consumer money. Not for products that merely link to a third-party payment page (that's `payments-and-marketplaces.md`).

## GLBA / Regulation P — the spine
- **Coverage:** "financial institutions" significantly engaged in financial activities for consumers (personal/household purposes). The FTC reads it broadly: an app that aggregates a consumer's account data and provides budgeting or financial insights should assume it's covered. A B2B tool that helps businesses invoice is generally not providing a consumer financial product.
- **Obligations:** initial and annual privacy notice (annual notice exception if sharing is limited to §§1016.13–.15 exceptions and the policy hasn't changed); opt-out before sharing nonpublic personal information (NPI) with non-affiliated third parties outside those exceptions; reuse limits on NPI received from others. Include the **model privacy form** ("FACTS: What does [X] do with your personal information?") as a safe harbor short form; state plainly if no opt-out is needed because the only sharing is with service providers and as permitted by law.
- **Safeguards Rule** (16 C.F.R. Part 314): written security program, qualified individual, risk assessment, MFA, encryption, vendor oversight, and FTC notification within 30 days of a security event affecting 500+ consumers' unencrypted data. The security section must describe controls that exist.

## GLBA ↔ state-law split
Most state comprehensive laws exempt GLBA-covered *data* (data-level: CA and most others) or GLBA-covered *entities* (entity-level: several states — verify per state). Draft to the data-level rule as the conservative baseline: financial NPI under GLBA; web analytics, marketing contacts and ad identifiers under state law. Show the split in a table so users and regulators can see which rights attach to which data.

## Aggregators and open banking
When users link accounts through Plaid or similar: credentials go to the aggregator/institution, not the app (verify the integration); describe the permissioned data actually requested (products enabled in the aggregator dashboard); explain disconnect and deletion. The CFPB §1033 rule is not currently enforceable (verify in `law-currency.md`); describe flows factually, don't promise §1033 rights.

## Money movement
Moving consumer funds (transfers, bill pay, debits) triggers EFTA/Regulation E (disclosures, error resolution, liability limits), state money-transmission licensing unless a licensed partner holds funds, and bank-partner program terms. Until it's live, a one-line "we don't move money; if we add it, we'll provide required disclosures first" is the right drafting.

## Investment-adjacent products
If the product discusses investments, savings strategies, or portfolios, also load `investment-adjacent.md`.
