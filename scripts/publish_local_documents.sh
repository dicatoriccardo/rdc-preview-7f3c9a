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
  local path=$1
  if [[ ! -s "$path" ]]; then
    log "Not publishing: missing or empty PDF: $path"
    return 1
  fi
  if [[ "$(head -c 5 "$path")" != "%PDF-" ]]; then
    log "Not publishing: file is not a PDF: $path"
    return 1
  fi

  local pdfinfo_path=""
  for candidate in /usr/local/bin/pdfinfo /opt/homebrew/bin/pdfinfo; do
    if [[ -x "$candidate" ]]; then
      pdfinfo_path=$candidate
      break
    fi
  done
  if [[ -n "$pdfinfo_path" ]] && ! "$pdfinfo_path" "$path" >/dev/null 2>&1; then
    log "Not publishing: PDF validation failed: $path"
    return 1
  fi
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
  version=$(date -u '+%Y%m%d%H%M%S')
  /usr/bin/python3 scripts/version_document_links.py "$version"
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
