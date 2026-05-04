<%*
const modalForm = app.plugins.plugins.modalforms.api;
const result = await modalForm.openForm("illustration-detaillee");

if (!result) {
  new Notice("Formulaire annulé");
  tR = "";
  return;
}

const data = result.getData();

const title = (data.title ?? "").trim();
const draftChoice = data.draft ? "true" : "false";
const featuredChoice = data.featured ? "true" : "false";
const tagsInput = data.tags ?? "";
const description = data.description ?? "";
const explication = data.explication ?? "";
const image = (data.image ?? "").trim();
const imagesExtra = (data.images ?? "").trim();

if (!title) {
  new Notice("Le titre est vide");
  tR = "";
  return;
}

if (!image) {
  new Notice("L’image principale est vide");
  tR = "";
  return;
}

await tp.file.rename(title);

const tagsYaml = tagsInput
  .split(",")
  .map(t => t.trim())
  .filter(Boolean)
  .map(t => `  - "${t.replace(/"/g, '\\"')}"`)
  .join("\n");

// Images additionnelles: liste séparée par virgules
const extraList = imagesExtra
  .split(",")
  .map(s => s.trim())
  .filter(Boolean);

let galleryBlock = "";
if (extraList.length) {
  const embeds = extraList.map(fn => `- ![[${fn}]]`).join("\n");
  galleryBlock = `\n## Galerie\n${embeds}\n`;
}

tR = `---
title: "${title.replace(/"/g, '\\"')}"
date: ${tp.date.now("YYYY-MM-DD")}
draft: ${draftChoice}
featured: ${featuredChoice}
type: "illustration"
description: "${description.replace(/"/g, '\\"')}"
tags:
${tagsYaml || '  - ""'}
thumbnail: "${image.replace(/"/g, '\\"')}"
---

# ${title}

## Résumé
${description}

## Explication
${explication}

## Illustration
![[${image}]]
${galleryBlock}`;
%>
