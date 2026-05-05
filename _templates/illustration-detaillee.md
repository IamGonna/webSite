<%*
const FORM_NAME = "illustration-detaillee";
const DEFAULT_TAG = "illustration";
const IMAGE_EXTENSIONS = ["jpg", "jpeg", "png", "webp"];

const modalForm = app.plugins.plugins["modalforms"]?.api;

if (!modalForm) {
  new Notice("Plugin Modal Forms introuvable");
  tR = "";
  return;
}

const result = await modalForm.openForm(FORM_NAME);

if (!result) {
  new Notice("Formulaire annulé");
  tR = "";
  return;
}

const data = result.getData();

const title = (data.title ?? "").trim();
const draftChoice = data.draft ? "true" : "false";
const featuredChoice = data.featured ? "true" : "false";
const tagsInput = data.tags ?? DEFAULT_TAG;
const description = data.description ?? "";
const explication = data.explication ?? "";

if (!title) {
  new Notice("Le titre est vide");
  tR = "";
  return;
}

const currentFolder = tp.file.folder(true);

const escapeYaml = (value) => String(value ?? "").replace(/"/g, '\\"');

function fileExists(path) {
  return !!app.vault.getAbstractFileByPath(path);
}

function findImage(baseName) {
  for (const ext of IMAGE_EXTENSIONS) {
    const path = currentFolder ? `${currentFolder}/${baseName}.${ext}` : `${baseName}.${ext}`;
    if (fileExists(path)) {
      return {
        path,
        fileName: `${baseName}.${ext}`
      };
    }
  }
  return null;
}

// Image principale
const cover = findImage("cover");

if (!cover) {
  new Notice("Merci d’ajouter une image cover.jpg/jpeg/png/webp dans le dossier");
}

// Images de séquence : 01.jpg, 02.jpg, 03.jpg...
let sequenceImages = [];

for (let i = 1; i <= 99; i++) {
  const number = String(i).padStart(2, "0");
  const image = findImage(number);

  if (image) {
    sequenceImages.push(image);
  }
}

await tp.file.rename(title);

const tagsYaml = tagsInput
  .split(",")
  .map(t => t.trim())
  .filter(Boolean)
  .map(t => `  - "${escapeYaml(t)}"`)
  .join("\n");

const thumbnail = cover ? cover.fileName : "cover.jpg";

const coverBlock = cover
  ? `![${title}](${cover.fileName})`
  : `> ⚠️ Merci de mettre une image nommée \`cover.jpg\`, \`cover.jpeg\`, \`cover.png\` ou \`cover.webp\` dans le même répertoire pour finaliser la publication.`;

const sequenceBlock = sequenceImages.length
  ? `## Sequence

<div class="sequence-grid">

${sequenceImages.map(img => `<img src="${img.fileName}" alt="${title}">`).join("\n")}

</div>`
  : "";

tR = `---
title: "${escapeYaml(title)}"
date: ${tp.date.now("YYYY-MM-DD")}
draft: ${draftChoice}
featured: ${featuredChoice}
type: "illustration"
tags:
${tagsYaml || `  - "${DEFAULT_TAG}"`}
description: "${escapeYaml(description)}"
thumbnail: "${escapeYaml(thumbnail)}"
---

# ${title}

${coverBlock}

${sequenceBlock}

## Résumé
${description}

## Explication
${explication}
`;
%>