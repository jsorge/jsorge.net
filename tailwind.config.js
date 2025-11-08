module.exports = {
  content: [
    "./Resources/Views/*.leaf",
  ],
  darkMode: 'media',
  theme: {
    extend: {
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
              color: '#e8804b',
            },
            h2: {
              'margin-top': 0,
              'margin-bottom': 0,
              color: '#e8804b',
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
}
