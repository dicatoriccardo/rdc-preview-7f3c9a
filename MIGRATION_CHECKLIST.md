# riccardodicato.com migration checklist

The repository is currently in preview mode. Public HTML pages contain a
`noindex, nofollow, noarchive` robots directive so the GitHub preview does not
compete with the live WordPress site.

## Before cutover

- Save the WordPress.com Stats CSV exports and the separate media-library export.
- Confirm the latest website changes are pushed and the GitHub Pages preview works.
- Create or confirm a GitHub Pages deployment from the `main` branch.
- Add `riccardodicato.com` as the GitHub Pages custom domain before changing DNS.
- Record the existing WordPress DNS records so they can be restored if needed.
- Preserve all MX and TXT records. Change only records used to serve the website.

## Cutover

- Remove the preview robots meta tag from the eight canonical public pages:
  `/`, `/research/`, `/_cv/`, `/teaching_research/`, `/blog/`, `/media/`, and
  the two dated blog posts.
- Keep `noindex` on `404.html`, `/cv/`, and `/teaching-research/`.
- Confirm `robots.txt` and `sitemap.xml` are present.
- Add or confirm the repository `CNAME` file contains only `riccardodicato.com`.
- In WordPress.com DNS, replace the WordPress-managed `@` web record with these
  four GitHub Pages A records:
  - `185.199.108.153`
  - `185.199.109.153`
  - `185.199.110.153`
  - `185.199.111.153`
- Replace the wildcard `*` CNAME with an explicit `www` CNAME pointing to
  `dicatoriccardo.github.io`. Keep unrelated TXT records unchanged.
- Wait for DNS propagation and enable **Enforce HTTPS** in GitHub Pages.

## Immediately after cutover

- Verify every URL in `sitemap.xml` loads over HTTPS without an error.
- Verify both `riccardodicato.com` and `www.riccardodicato.com` resolve to one
  canonical HTTPS address.
- Confirm page source has the correct canonical URL and no preview `noindex` tag.
- Create a Google Search Console Domain property and submit `/sitemap.xml`.
- Add the chosen analytics measurement code to every public page.
- Test the contact, social, CV, research-paper, podcast, and blog links.

## After a stability period

- Keep the WordPress.com domain registration and auto-renewal active.
- Make the old WordPress.com site private after the new site has remained stable.
- Do not delete this GitHub repository: it is the production website host.
