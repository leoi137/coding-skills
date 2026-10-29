# Module: Subscriptions, trials and auto-renewal

**Load when** the product charges recurring fees, offers a free trial that converts, or the existing documents describe either. If billing isn't live, don't load it — write "the service is currently free; we'll give notice and get your agreement before charging" and flag any published price as a marketing claim to fix.

## Law that applies (check `law-currency.md` first)
- **ROSCA** (15 U.S.C. §8401–8405): for online negative-option sales, clearly disclose all material terms before collecting billing info, get express informed consent before charging, and provide simple cancellation. The FTC enforces this directly; it is the federal floor now that the 2024 click-to-cancel amendments were vacated.
- **State automatic-renewal laws**, California's being the strictest (Bus. & Prof. Code §17600 et seq., as amended by AB 2863): clear and conspicuous terms near the consent; affirmative consent to the auto-renewal specifically; acknowledgment email with terms and cancellation method; online cancellation in the same medium as signup, without obstruction (save offers allowed only within limits); notice before price changes; annual reminder for subscriptions; notice before a free trial over a certain length converts; retention of consent records. Draft to California and you satisfy most states; check NY, VT, CO, MN, VA for extra notice timing if the business has many users there.

## What the Terms section must say (only what's true)
- Price, billing period, that it renews automatically until cancelled, taxes.
- **Billing channel** decides cancellation and refunds: App Store and Google Play subscriptions are cancelled and refunded through the store, not by the company; web subscriptions through the product's billing page or the PSP's customer portal. Never say "cancel in your account" for store-billed subscriptions.
- Trial length and the conversion date; that the user won't be charged if they cancel before it ends; any reminder you send.
- When cancellation takes effect (end of current period is typical) and whether partial periods are refunded (state the policy; the law doesn't require pro-rata refunds in most states, but the policy must be applied consistently).
- Price changes: advance notice (CA requires notice before the change with cancellation instructions); continued use after the effective date.
- Failed payments and suspension.

## Product-change list (deliver with the draft)
- Consent UI at checkout: renewal terms adjacent to the pay button; separate checkbox or clear button text for auto-renewal.
- Acknowledgment email with cancellation steps.
- An online cancel path reachable in no more steps than signup.
- Reminder emails where state law requires (annual for CA; before trial conversion where the trial exceeds the state threshold).
- Store consent records (time, terms shown, price).
