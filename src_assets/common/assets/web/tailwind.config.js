const plugin = require('tailwindcss/plugin');

/** @type {import('tailwindcss').Config} */
module.exports = {
  darkMode: 'class',
  // Limit scanning to source files; avoid node_modules for performance
  content: [
    './index.html',
    './*.{vue,js,ts,html}',
    './components/**/*.{vue,js,ts}',
    './views/**/*.{vue,js,ts}',
    './configs/**/*.{vue,js,ts}',
    './stores/**/*.{js,ts}',
  ],
  theme: {
    extend: {
      // Single source of truth for semantic colors (light/dark).
      // These values drive CSS variables that both Tailwind utilities and Naive UI consume.
      semanticColors: {
        light: {
          // Nimbus host-console palette: neutral base, blue actions, mint streaming health.
          primary: '37 99 235', // #2563EB Nimbus Blue
          secondary: '45 212 191', // #2DD4BF Lucent Mint
          success: '34 197 94', // #22C55E
          warning: '245 158 11', // #F59E0B
          danger: '244 63 94', // #F43F5E
          info: '14 165 233', // #0EA5E9
          light: '246 248 251', // #F6F8FB Mist Surface
          dark: '13 17 23', // #0D1117 Cloud Ink
          surface: '255 255 255',
          accent: '45 212 191',
          onPrimary: '255 255 255',
          onSecondary: '13 17 23',
          onAccent: '13 17 23',
          onLight: '13 17 23',
          onDark: '246 248 251',
          brand: '30 64 175', // #1E40AF
        },
        dark: {
          dark: '13 17 23',
          surface: '22 27 34',
          light: '226 232 240',
          primary: '96 165 250',
          secondary: '45 212 191',
          accent: '251 191 36',
          info: '125 211 252',
          success: '52 211 153',
          warning: '245 158 11',
          danger: '251 113 133',
          onDark: '248 250 252',
          onSurface: '248 250 252',
          onLight: '13 17 23',
          onPrimary: '13 17 23',
          onSecondary: '13 17 23',
          onAccent: '13 17 23',
          onInfo: '13 17 23',
          brand: '147 197 253',
        },
      },
      colors: {
        // Semantic tokens resolved via CSS variables (light defaults, dark overrides via .dark)
        primary: 'rgb(var(--color-primary) / <alpha-value>)',
        secondary: 'rgb(var(--color-secondary) / <alpha-value>)',
        success: 'rgb(var(--color-success) / <alpha-value>)',
        warning: 'rgb(var(--color-warning) / <alpha-value>)',
        danger: 'rgb(var(--color-danger) / <alpha-value>)',
        info: 'rgb(var(--color-info) / <alpha-value>)',
        light: 'rgb(var(--color-light) / <alpha-value>)',
        dark: 'rgb(var(--color-dark) / <alpha-value>)',
        surface: 'rgb(var(--color-surface) / <alpha-value>)',
        accent: 'rgb(var(--color-accent) / <alpha-value>)',
        onPrimary: 'rgb(var(--color-on-primary) / <alpha-value>)',
        onSecondary: 'rgb(var(--color-on-secondary) / <alpha-value>)',
        onAccent: 'rgb(var(--color-on-accent) / <alpha-value>)',
        onLight: 'rgb(var(--color-on-light) / <alpha-value>)',
        onDark: 'rgb(var(--color-on-dark) / <alpha-value>)',
        // Optional brand token for places that previously mixed solar-secondary + lunar-onSecondary
        brand: 'rgb(var(--color-brand) / <alpha-value>)',
      },
    },
  },
  // Enable Tailwind preflight now that Bootstrap is removed. Keep visibility disabled if not needed.
  corePlugins: {
    preflight: true,
    visibility: false,
  },
  plugins: [
    // Emit CSS variables for semantic tokens from theme.semanticColors
    plugin(function ({ addBase, theme }) {
      const light = theme('semanticColors.light') || {};
      const dark = theme('semanticColors.dark') || {};
      const toVars = (src) => ({
        '--color-primary': src.primary,
        '--color-secondary': src.secondary,
        '--color-success': src.success,
        '--color-warning': src.warning,
        '--color-danger': src.danger,
        '--color-info': src.info,
        '--color-light': src.light,
        '--color-dark': src.dark,
        '--color-surface': src.surface,
        '--color-accent': src.accent,
        '--color-on-primary': src.onPrimary,
        '--color-on-secondary': src.onSecondary,
        '--color-on-accent': src.onAccent,
        '--color-on-light': src.onLight,
        '--color-on-dark': src.onDark,
        '--color-brand': src.brand,
      });
      addBase({
        ':root': toVars(light),
        '.dark': toVars(dark),
      });
    }),
  ],
};
