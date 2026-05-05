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
    const path = `${currentFolder}/${baseName}.${ext}`;
    if (fileExists(path)) return `${baseName}.${ext}`;
  }
  return null;
}

const cover = findImage("cover");

let sequenceImages = [];

for (let i = 1; i <= 99; i++) {
  const number = String(i).padStart(2, "0");
  const img = findImage(number);
  if (img) sequenceImages.push(img);
}

await tp.file.rename("index.fr");

const tagsYaml = tagsInput
  .split(",")
  .map(t => t.trim())
  .filter(Boolean)
  .map(t => `  - "${escapeYaml(t)}"`)
  .join("\n");

const thumbnail = cover ?? "cover.jpg";

const sequenceBlock = sequenceImages.length
  ? `## Sequence

${sequenceImages.map(img => `[![${title}](./${img})](./${img})`).join(" ")}`
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

${sequenceBlock}

## Explication
${explication}
`;
%>