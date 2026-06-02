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

await tp.file.rename("index.fr");

const currentFolder = tp.file.folder(true);
const vaultBase = app.vault.adapter.getBasePath?.() ?? app.vault.adapter.basePath;
const previewFile = "preview_5s.webm";
const previewPath = currentFolder ? `${currentFolder}/${previewFile}` : previewFile;
const previewAbs = `${vaultBase}/${previewPath}`;
const scriptAbs = `${vaultBase}/_templates/scripts/video_preview_webm.sh`;
const shellQuote = (value) => `'${String(value).replace(/'/g, `'\\''`)}'`;

try {
  new Notice("Génération de la preview vidéo…");
  await tp.system.exec(`bash ${shellQuote(scriptAbs)} ${shellQuote(videoUrl)} 00:00:05 5 ${shellQuote(previewAbs)}`);
  if (await app.vault.adapter.exists(previewPath)) {
    new Notice(`Preview générée : ${previewFile}`);
  } else {
    new Notice(`Preview demandée, mais fichier non retrouvé : ${previewPath}`);
  }
} catch (error) {
  console.error(error);
  new Notice("Preview vidéo non générée — voir console Obsidian / yt-dlp");
}

const tagsYaml = tagsInput
  .split(",")
  .map(t => t.trim())
  .filter(Boolean)
  .map(t => `  - "${t.replace(/"/g, '\\"')}"`)
  .join("\n");

const escapeYaml = (value) => String(value ?? "").replace(/"/g, '\\"');

tR = `---
title: "${escapeYaml(title)}"
date: ${tp.date.now("YYYY-MM-DD")}
draft: ${draftChoice}
featured: ${featuredChoice}
tags:
${tagsYaml || '  - ""'}
description: "${escapeYaml(description)}"
${platform}: "${escapeYaml(videoUrl)}"
preview: "${previewFile}"
---

# ${title}
`;
%>
