<%*
const FORM_NAME = "illustration-detaillee";
const DEFAULT_TAG = "illustration";
const IMAGE_BASENAME = "cover";
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

// Recherche automatique de cover.jpg / jpeg / png / webp
let imagePath = "";
let imageExists = false;

for (const ext of IMAGE_EXTENSIONS) {
  const path = currentFolder
    ? `${currentFolder}/${IMAGE_BASENAME}.${ext}`
    : `${IMAGE_BASENAME}.${ext}`;

  const file = app.vault.getAbstractFileByPath(path);

  if (file) {
    imagePath = path;
    imageExists = true;
    break;
  }
}

// Si aucune image n’existe encore, on prépare le chemin attendu
if (!imagePath) {
  imagePath = currentFolder
    ? `${currentFolder}/${IMAGE_BASENAME}.jpg`
    : `${IMAGE_BASENAME}.jpg`;
}

await tp.file.rename(title);

const escapeYaml = (value) => String(value ?? "").replace(/"/g, '\\"');

const tagsYaml = tagsInput
  .split(",")
  .map(t => t.trim())
  .filter(Boolean)
  .map(t => `  - "${escapeYaml(t)}"`)
  .join("\n");

const imageBlock = imageExists
  ? `![[${imagePath}]]`
  : `> ⚠️ Merci de mettre une image nommée \`cover.jpg\`, \`cover.jpeg\`, \`cover.png\` ou \`cover.webp\` dans le même répertoire pour finaliser la publication.`;

tR = `---
title: "${escapeYaml(title)}"
date: ${tp.date.now("YYYY-MM-DD")}
draft: ${draftChoice}
featured: ${featuredChoice}
type: "illustration"
tags:
${tagsYaml || `  - "${DEFAULT_TAG}"`}
description: "${escapeYaml(description)}"
thumbnail: "${escapeYaml(imagePath)}"
---

# ${title}

## Résumé
${description}

## Explication
${explication}

## Illustration
${imageBlock}
`;
%>