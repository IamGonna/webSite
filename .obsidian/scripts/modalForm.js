module.exports = async function modalForm(tp, formName) {
  const modalForm = app.plugins.plugins["modal-form"];
  if (!modalForm) {
    new Notice("Plugin Modal Form non trouvé");
    return null;
  }

  const result = await modalForm.api.openForm(formName);
  return result;
};
