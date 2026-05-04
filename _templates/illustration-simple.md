<%*
const modalForm = app.plugins.plugins["modalforms"]?.api;  
  
if (!modalForm) {  
new Notice("Plugin Modal Forms introuvable");  
tR = "";  
return;  
}  
  
const result = await modalForm.openForm("illustration-simple");
console.log(result);

const data = result.getData();

const title = (data.title ?? "").trim();
const draftChoice = data.draft ? "true" : "false";
const featuredChoice = data.featured ? "true" : "false";
const tagsInput = data.tags ?? "";
const description = data.description ?? "";
const image = (data.image ?? "").trim();

if (!title) {
  new Notice("Le titre est vide");
  tR = "";
  return;
}

if (!image) {
  new Notice("L’image est vide");
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
type: "illustration"
tags:
${tagsYaml || '  - ""'}
description: "${description.replace(/"/g, '\\"')}"
thumbnail: "${image.replace(/"/g, '\\"')}"
---

# ${title}

![[${image}]]
`;
%>
