(() => {
  const STORAGE_KEY = "gab-theme";
  const DEFAULT_THEME = "light";
  const THEMES = ["light", "soft", "contrast", "dark"];

  function isValidTheme(theme) {
    return THEMES.includes(theme);
  }

  function getStoredTheme() {
    try {
      return localStorage.getItem(STORAGE_KEY);
    } catch {
      return null;
    }
  }

  function storeTheme(theme) {
    try {
      localStorage.setItem(STORAGE_KEY, theme);
    } catch {
      // ignore
    }
  }

  function applyTheme(theme) {
    const safeTheme = isValidTheme(theme) ? theme : DEFAULT_THEME;
    const root = document.documentElement;
    const select = document.querySelector("[data-theme-select]");

    root.setAttribute("data-theme", safeTheme);

    if (select && select.value !== safeTheme) {
      select.value = safeTheme;
    }
  }

  function getPreferredTheme() {
    const storedTheme = getStoredTheme();
    if (isValidTheme(storedTheme)) {
      return storedTheme;
    }

    const select = document.querySelector("[data-theme-select]");
    if (select && isValidTheme(select.value)) {
      return select.value;
    }

    if (window.matchMedia("(prefers-color-scheme: dark)").matches) {
      return "dark";
    }

    return DEFAULT_THEME;
  }

  function initThemeSelect() {
    const select = document.querySelector("[data-theme-select]");
    if (!select) return;

    select.addEventListener("change", (event) => {
      const theme = event.target.value;
      applyTheme(theme);
      storeTheme(theme);
    });
  }

  function initMobileNav() {
    const btn = document.querySelector("[data-nav-toggle]");
    if (!btn) return;

    btn.addEventListener("click", () => {
      document.body.classList.toggle("nav-open");
    });
  }

  function initTilePreviews() {
    const tiles = document.querySelectorAll(".tile--has-preview");

    tiles.forEach((tile) => {
      const video = tile.querySelector(".tile__preview-video");
      if (!video) return;

      let loaded = false;

      const showPreview = () => {
        tile.classList.add("tile--is-previewing");
      };

      const hidePreview = () => {
        tile.classList.remove("tile--is-previewing");
      };

      const play = () => {
        video.muted = true;
        video.playsInline = true;

        if (!loaded) {
          video.load();
          loaded = true;
        }

        const promise = video.play();
        if (promise && typeof promise.then === "function") {
          promise
            .then(() => {
              showPreview();
            })
            .catch(() => {
              hidePreview();
            });
        } else {
          showPreview();
        }
      };

      const pause = () => {
        video.pause();
        try {
          video.currentTime = 0;
        } catch (error) {
          // ignore
        }
        hidePreview();
      };

      tile.addEventListener("mouseenter", play);
      tile.addEventListener("mouseleave", pause);
      tile.addEventListener("focusin", play);
      tile.addEventListener("focusout", pause);
    });
  }

  function init() {
    applyTheme(getPreferredTheme());
    initThemeSelect();
    initMobileNav();
    initTilePreviews();
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();