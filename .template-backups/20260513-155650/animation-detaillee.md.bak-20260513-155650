<%*
const modalForm = app.plugins.plugins.modalforms.api;
const result = await modalForm.openForm("animation-detaillee");

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
const explication = data.explication ?? "";
const image = (data.image ?? "").trim();

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

// Tags YAML
const tagsYaml = tagsInput
  .split(",")
  .map(t => t.trim())
  .filter(Boolean)
  .map(t => `  - "${t.replace(/"/g, '\\"')}"`)
  .join("\n");

// Image (simple)
let imageBlock = "";
let imageFrontmatter = "";

if (image) {
  imageFrontmatter = `thumbnail: "${image}"\n`;
  imageBlock = `\n## Illustration\n![[${image}]]\n`;
}

tR = `---
title: "${title.replace(/"/g, '\\"')}"
date: ${tp.date.now("YYYY-MM-DD")}
draft: ${draftChoice}
featured: ${featuredChoice}
type: "animation"
description: "${description.replace(/"/g, '\\"')}"
${platform}: "${videoUrl.replace(/"/g, '\\"')}"
${imageFrontmatter}---

# ${title}

## Résumé
${description}

## Explication
${explication}

## Vidéo
${videoUrl}${imageBlock}
`;
%>