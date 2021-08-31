const plugin = require('tailwindcss/plugin')

module.exports = {
  purge: {
    enabled: true,
    content: [
      "./Resources/Views/*.leaf",
    ]
  },
  darkMode: 'media',
  theme: {
    extend: {
      fontFamily: {
        'sans': ['Palanquin-Regular'],
        'display': ['Palanquin-Semibold'],
        'code': ['IBM Plex Mono'],
        'mono': ['IBM Plex Mono'],
      },
      colors: {
        'darkGray': '#2a2828',
        'orange': '#e8804b',
      },
      typography: (theme) => ({
        DEFAULT: {
          css: {
            pre: null,
            code: null,
            'code::before': null,
            'code::after': null,
            'pre code': null,
            'pre code::before': null,
            'pre code::after': null,
            a: {
              color: theme('colors.orange'),
            },
            h2: {
              'margin-top': 0,
              'margin-bottom': 0,
              color: theme('colors.orange'),
              a: {
                link: {
                  'text-decoration': 'none',
                }
              }
            }
          }
        }
      })
    }
  },
  variants: {
    extend: {},
  },
  plugins: [
    require("@tailwindcss/typography"),
  ],
}
