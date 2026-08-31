# Riccardo Di Cato — website documents

The website publishes the CV and job market paper automatically from the files in `document-sources`. It also republishes ordinary website edits made anywhere else in the repository.

## Update the CV

1. Open [`document-sources/riccardo-di-cato-cv.tex`](https://github.com/dicatoriccardo/rdc-preview-7f3c9a/edit/main/document-sources/riccardo-di-cato-cv.tex).
2. Edit the LaTeX directly in GitHub.
3. Click **Commit changes**.

The automation compiles the LaTeX and replaces the public CV. If the LaTeX has an error, the automation stops and the last working CV remains live.

## Update the job market paper

1. On your computer, rename the new draft exactly `DiCatoJMP.pdf`.
2. Open the [`document-sources` upload page](https://github.com/dicatoriccardo/rdc-preview-7f3c9a/upload/main/document-sources).
3. Drag in the PDF and click **Commit changes**.

The automation checks that the upload is a PDF and then replaces the public paper. If the upload is invalid, the last working website remains live.

## Check publication

Open [GitHub Actions](https://github.com/dicatoriccardo/rdc-preview-7f3c9a/actions/workflows/publish-documents.yml). A green check means publication succeeded. Updates normally appear on [riccardodicato.com](https://riccardodicato.com) within a few minutes.

The public URLs do not change:

- CV: `https://riccardodicato.com/assets/docs/riccardo-di-cato-cv.pdf`
- Job market paper: `https://riccardodicato.com/assets/docs/DiCatoJMP.pdf`
