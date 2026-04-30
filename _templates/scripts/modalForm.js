module.exports = async function modalForm(formName) {
  const plugin = app.plugins.plugins["modalforms"];

  if (!plugin || !plugin.api) {
    new Notice("Plugin Modal Forms non trouvé ou API indisponible");
    return null;
  }

  const result = await plugin.api.openForm(formName);
  return result;
};
