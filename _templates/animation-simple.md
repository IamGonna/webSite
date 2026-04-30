<%*
const modalForm = app.plugins.plugins.modalforms.api;
const result = await modalForm.openForm("animation");

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
const platform = (data.platform ?? "").trim().toLowerCase();
const videoUrl = (data.url ?? "").trim();

if (!title) {
  new Notice("Le titre est vide");
  tR = "";
  return;
}

if (!["youtube", "vimeo"].includes(platform)) {
  new Notice("La plateforme doit être youtube ou vimeo");
  tR = "";
  return;
}

if (!videoUrl) {
  new Notice("L’URL vidéo est vide");
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

tR = `---
title: "${title.replace(/"/g, '\\"')}"
date: ${tp.date.now("YYYY-MM-DD")}
draft: ${draftChoice}
featured: ${featuredChoice}
tags:
${tagsYaml || '  - ""'}
description: "${description.replace(/"/g, '\\"')}"
${platform}: "${videoUrl.replace(/"/g, '\\"')}"
---

# ${title}
`;
%>