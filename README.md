# Riccardo Di Cato — website documents

The final CV, job market paper, and pornography paper are published from the
local source paths listed below. The two papers live in the sibling folder
named `Website Files - CHANGE HERE`; the CV is published directly from its
academic master in `Job Market/CV/Academic`.

The macOS background publisher is event-driven. It remains idle until one of
the PDFs changes; it then validates the file, copies it to the website, refreshes PDF
link versions, and publishes the update to GitHub Pages. After an upload it
checks that the exact new version is visible on the public website. If GitHub
Pages times out, it requests one fresh deployment automatically and verifies
that retry. The check is bounded and never runs while the PDFs are unchanged.

The public URLs remain stable:

- CV: `https://riccardodicato.com/assets/docs/riccardo-di-cato-cv.pdf`
- Job market paper: `https://riccardodicato.com/assets/docs/DiCatoJMP.pdf`
- Pornography paper: `https://riccardodicato.com/assets/docs/CantilloDiCato_PornographyRestrictions.pdf`

The background publisher is implemented in
`scripts/publish_local_documents.sh`. Its installation template is
`scripts/com.riccardodicato.website-documents.plist`.
