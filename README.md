# Riccardo Di Cato — website documents

The final CV and job market paper are published from the sibling folder named
`Website Files - CHANGE HERE`.

The macOS background publisher is event-driven. It remains idle until either
PDF changes; it then validates the file, copies it to the website, refreshes PDF
link versions, and publishes the update to GitHub Pages.

The public URLs remain stable:

- CV: `https://riccardodicato.com/assets/docs/riccardo-di-cato-cv.pdf`
- Job market paper: `https://riccardodicato.com/assets/docs/DiCatoJMP.pdf`

The background publisher is implemented in
`scripts/publish_local_documents.sh`. Its installation template is
`scripts/com.riccardodicato.website-documents.plist`.
