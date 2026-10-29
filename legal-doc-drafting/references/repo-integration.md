# Repo Integration — make the output drop-in

Legal pages live in many shapes: JSX/TSX pages with inline prose, MDX/Markdown files, typed content modules rendered by a component, CMS entries, or store-listing text. The draft is only finished when it lands in the repo's existing shape and builds.

## Find the shape
1. Locate the pages: routes like `/privacy`, `/terms`, `/legal/*`; grep for "Privacy Policy" and "Terms of Service".
2. Open the page **and** whatever renders it (a layout like `LegalPage`, a content module plus `page.tsx`, an MDX loader). Note: exported names the renderer references, allowed formatting enums, how lists/tables/links are expressed, and where the "last updated" date and company facts come from (a site config, helpers like `companyInfo`).
3. Read the profile for any product-specific shape notes (e.g., `profiles/pearl-repo.md`).

## Rules
- Keep the existing format, exports and component structure. Change text, add or remove sections; don't refactor the renderer unless the draft needs a capability it lacks (and then say so).
- Pull company name, email, address and URLs from the existing config/helpers — never hardcode a second copy.
- Bump the single "last updated" source.
- Keep anchors stable where other pages or emails link to them; update in-page cross-references when numbering changes.
- Escape characters the format requires (JSX: `&apos;`, `&ldquo;` etc. — match what the file already does).
- Links to other legal pages and to the product's settings (e.g., where to delete your account) must point to routes that exist.

## After editing
Run the repo's checks (typecheck and lint at least — e.g., `npx tsc --noEmit`, `npm run lint`) and view the page on the running dev server if the project has one. If you can't run them, say so. Don't commit or deploy unless the user asked; legal pages ship through the repo's normal path.

Non-repo surfaces the draft must also update (list them in the delivery): signup and checkout notices, emails that link or quote terms, app-store privacy labels, store listing descriptions, help-center articles, marketing claims flagged as inconsistent.
