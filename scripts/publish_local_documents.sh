#!/bin/zsh

set -u

SCRIPT_DIR=${0:A:h}
REPO_DIR=${SCRIPT_DIR:h}
CHANGE_DIR="${REPO_DIR:h}/Website Files - CHANGE HERE"
CV_SOURCE="$CHANGE_DIR/CV/riccardo-di-cato-cv.pdf"
JMP_SOURCE="$CHANGE_DIR/Job Market Paper/DiCatoJMP.pdf"
CV_PUBLIC="$REPO_DIR/assets/docs/riccardo-di-cato-cv.pdf"
JMP_PUBLIC="$REPO_DIR/assets/docs/DiCatoJMP.pdf"
LOCK_DIR="/tmp/riccardo-website-documents.lock"

log() {
  print -r -- "$(date '+%Y-%m-%d %H:%M:%S')  $*"
}

if ! mkdir "$LOCK_DIR" 2>/dev/null; then
  exit 0
fi
trap 'rmdir "$LOCK_DIR" 2>/dev/null || true' EXIT INT TERM

validate_pdf() {
  local pdf_path=$1
  if [[ ! -s "$pdf_path" ]]; then
    log "Not publishing: missing or empty PDF: $pdf_path"
    return 1
  fi
  if [[ "$(head -c 5 "$pdf_path")" != "%PDF-" ]]; then
    log "Not publishing: file is not a PDF: $pdf_path"
    return 1
  fi

  local pdfinfo_path=""
  for candidate in /usr/local/bin/pdfinfo /opt/homebrew/bin/pdfinfo; do
    if [[ -x "$candidate" ]]; then
      pdfinfo_path=$candidate
      break
    fi
  done
  if [[ -n "$pdfinfo_path" ]] && ! "$pdfinfo_path" "$pdf_path" >/dev/null 2>&1; then
    log "Not publishing: PDF validation failed: $pdf_path"
    return 1
  fi
}

wait_for_live_version() {
  local expected_version=$1
  local max_attempts=39
  local attempt=1

  while (( attempt <= max_attempts )); do
    if /usr/bin/curl -fsSL --connect-timeout 10 --max-time 20 \
      "https://riccardodicato.com/?publisher-check=${expected_version}-${attempt}" 2>/dev/null \
      | /usr/bin/grep -Fq "DiCatoJMP.pdf?v=${expected_version}"; then
      return 0
    fi
    /bin/sleep 20
    (( attempt++ ))
  done

  return 1
}

cd "$REPO_DIR" || exit 1

# Stay completely idle until a document changes or an earlier upload needs a
# retry. This avoids unnecessary network traffic every 30 seconds.
cv_changed=0
jmp_changed=0
cmp -s "$CV_SOURCE" "$CV_PUBLIC" || cv_changed=1
cmp -s "$JMP_SOURCE" "$JMP_PUBLIC" || jmp_changed=1
unpushed=$(/usr/bin/git rev-list --count origin/main..HEAD)
if (( ! cv_changed && ! jmp_changed && ! unpushed )); then
  exit 0
fi

# Bring in ordinary website edits made elsewhere before creating a new update.
if ! /usr/bin/git pull --rebase --autostash origin main; then
  log "Publication paused because the website repository needs attention."
  exit 1
fi

changed=0
publish_version=""
if ! cmp -s "$CV_SOURCE" "$CV_PUBLIC"; then
  validate_pdf "$CV_SOURCE" || exit 1
  /bin/cp -f "$CV_SOURCE" "$CV_PUBLIC"
  changed=1
fi

if ! cmp -s "$JMP_SOURCE" "$JMP_PUBLIC"; then
  validate_pdf "$JMP_SOURCE" || exit 1
  /bin/cp -f "$JMP_SOURCE" "$JMP_PUBLIC"
  changed=1
fi

if (( changed )); then
  publish_version=$(date -u '+%Y%m%d%H%M%S')
  /usr/bin/python3 scripts/version_document_links.py "$publish_version"
  /usr/bin/git add -- assets/docs/riccardo-di-cato-cv.pdf assets/docs/DiCatoJMP.pdf '*.html'
  if ! /usr/bin/git diff --cached --quiet; then
    /usr/bin/git commit -m "Update website CV and job market paper" || exit 1
  fi
fi

if [[ $(/usr/bin/git rev-list --count origin/main..HEAD) -gt 0 ]]; then
  if /usr/bin/git push origin main; then
    log "Website documents published successfully."
  else
    log "Upload failed; the publisher will retry automatically."
    exit 1
  fi
fi

# A successful git push does not guarantee that GitHub Pages completed its
# separate deployment. Verify the exact document version on the public site.
# If GitHub Pages times out, request one fresh deployment and check it once
# more. This bounded work happens only after a PDF-triggered publication.
if [[ -n "$publish_version" ]]; then
  log "Waiting for website deployment to become visible."
  if wait_for_live_version "$publish_version"; then
    log "Website deployment verified successfully."
  else
    log "Website deployment was not visible; requesting one automatic retry."
    if ! /usr/bin/git commit --allow-empty -m "Retry website publication"; then
      log "Could not create the automatic deployment retry."
      exit 1
    fi
    if ! /usr/bin/git push origin main; then
      log "Could not upload the automatic deployment retry."
      exit 1
    fi
    if wait_for_live_version "$publish_version"; then
      log "Website deployment verified after the automatic retry."
    else
      log "GitHub Pages did not publish after one automatic retry; manual attention is required."
      exit 1
    fi
  fi
fi
