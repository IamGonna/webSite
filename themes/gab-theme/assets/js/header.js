document.addEventListener("DOMContentLoaded", () => {
  const body = document.body;
  const navToggle = document.querySelector("[data-nav-toggle]");
  const themeToggle = document.querySelector("[data-theme-toggle]");

  function isTabletOrMobile() {
    return window.innerWidth <= 1180;
  }

  function isMobile() {
    return window.innerWidth <= 760;
  }

  function resetStatesOnResize() {
    if (!isTabletOrMobile()) {
      body.classList.remove("nav-open", "theme-open");
      if (navToggle) navToggle.setAttribute("aria-expanded", "false");
      if (themeToggle) themeToggle.setAttribute("aria-expanded", "false");
      return;
    }

    if (!isMobile()) {
      body.classList.remove("theme-open");
      if (themeToggle) themeToggle.setAttribute("aria-expanded", "false");
    }
  }

  if (navToggle) {
    navToggle.addEventListener("click", () => {
      if (!isTabletOrMobile()) return;

      const willOpen = !body.classList.contains("nav-open");
      body.classList.toggle("nav-open", willOpen);
      navToggle.setAttribute("aria-expanded", String(willOpen));
    });
  }

  if (themeToggle) {
    themeToggle.addEventListener("click", () => {
      if (!isMobile()) return;

      const willOpen = !body.classList.contains("theme-open");
      body.classList.toggle("theme-open", willOpen);
      themeToggle.setAttribute("aria-expanded", String(willOpen));
    });
  }

  document.addEventListener("click", (event) => {
    const target = event.target;

    const insideNav = target.closest(".site-nav");
    const insideTheme = target.closest(".theme-switcher");
    const onNavButton = navToggle && navToggle.contains(target);
    const onThemeButton = themeToggle && themeToggle.contains(target);

    if (isTabletOrMobile() && !insideNav && !onNavButton) {
      body.classList.remove("nav-open");
      if (navToggle) navToggle.setAttribute("aria-expanded", "false");
    }

    if (isMobile() && !insideTheme && !onThemeButton) {
      body.classList.remove("theme-open");
      if (themeToggle) themeToggle.setAttribute("aria-expanded", "false");
    }
  });

  window.addEventListener("resize", resetStatesOnResize);
  resetStatesOnResize();
});